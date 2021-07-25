pro sne_sum_lss,name,segment,filter=filter,exclude=exclude,tid=tid,sum=sum,sndir=sndir,redl_sk=redl_sk

  if(not keyword_set(exclude)) then exclude='ASPCORR:NONE,DUPEXPID'
  if(not keyword_set(sum)) then sum=1
  if(not keyword_set(sndir)) then sndir='$SNE/'+name ;'/Volumes/TimeMachineBackups/SNE_ARCH/'+name; 
  if(not keyword_set(redl_sk)) then redl_sk=0

  
  spawn,'gunzip --force '+sndir+'*sk.img.gz*'
  spawn,'/bin/ls '+sndir,sndir_cont
  

  if(not keyword_set(tid)) then begin
;;Determine Target ID from SN name + segment #
     cut=where(strmid(sndir_cont,2,/reverse) eq segment)
     tid=strmid(sndir_cont[cut],0,8)
  endif


;;Internal Segment Directory Structure
  segdir=sndir+'/'+tid+segment
  skimdir=segdir+'/uvot/image/'
  spawn,'gunzip '+skimdir+'*sk.img.gz*'

;Re-DL Sky Images?
  if(redl_sk) then begin
     spawn,'\ls '+skimdir+'*.img',tempims
     if(keyword_set(tempims)) then begin
        Header=HEADFITS(tempims[0])
        ObsDate=FXPAR(Header,'DATE-OBS')
        ObD=StrMid(ObsDate,0,4)+'_'+StrMid(ObsDate,5,2)
        wgetcom="wget -nd --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks 'FTP://heasarc.gsfc.nasa.gov/swift/data/obs/"+ObD+"/"+tid+segment+"/uvot/image/*sk*' -P "+skimdir
        spawn,'mkdir '+skimdir+'bak'
        spawn,'\mv '+skimdir+'*sk* '+skimdir+'bak/'
        print,wgetcom
        spawn,wgetcom
        print,'wget done'
        spawn,'gunzip -f '+skimdir+'*.gz'
     endif
  endif

;;Define The Stacked Directory, and Create if Not Allready Present
;stdir='$SNE/'+name+'/stacked/'
;if(where(sndir_cont eq 'stacked') eq -1) then spawn,'mkdir '+stdir
;spawn, '/bin/ls '+stdir+'*.img',stims
;;Truncate Path Directory so that only Image Name remains
;stims=strmid(stims,strpos(stims[0],'/',/reverse_search)+1)

;;Get a List of Images in the Segment Directory and Stacked Directory
  spawn, '/bin/ls '+skimdir+'*_sk.img',skims
  spawn, '/bin/ls '+skimdir+'*_ex.img',exims
  spawn, '/bin/ls '+skimdir+'*.lss',lssims

  if(not keyword_set(skims)) then return
  
;;Check to see if image is .img or .img.gz, then extract filter codes
  filters=strmid(skims,strpos(skims[0],'_',/reverse_search)-2,2)
  nfilters=n_elements(filters)

;;Remove Previous summed image if re-summing is chosen
;;(So that multiple epochs may be stacked)
  if(keyword_set(sum)) then spawn,'\rm '+skimdir+'summed_*'

;;If specified filter is filter i, or, no filters are specified then
;;perform stacking


  for i=0,nfilters-1 do begin

     if(keyword_set(filter)) then begin
        if(where(filter eq filters[i]) ne -1) then compute=1 else compute=0
     endif else compute=1


     if (compute) then begin 
        
;Sum exposures in Filter
        sumfile=strcompress(skimdir+name+segment+filters[i]+'_e'+string(i)+'.fits',/remove_all)
        exsum=strcompress(skimdir+name+segment+filters[i]+'_e'+string(i)+'_ex.fits',/remove_all)
        lsssum=strcompress(skimdir+name+segment+filters[i]+'_e'+string(i)+'.lss',/remove_all)


        outfile=skimdir+'summed_'+tid+segment+filters[i]+'.img'
        exoutfile=skimdir+'summed_'+tid+segment+filters[i]+'_ex.img'
        lssoutfile=skimdir+'summed_'+tid+segment+filters[i]+'.lss'
        spawn,'\rm '+skimdir+'summed_*'+filters[i]+'*'
        
        if(sum) then begin
           exname=skimdir+'sw'+tid+segment+'u'+filters[i]+'_ex.img'
           lssname=skimdir+'sw'+tid+segment+'u'+filters[i]+'.lss'

;;If ExpMap and LSS Map do not exist
           if(NOT (FILE_TEST(exname) AND FILE_TEST(lssname))) then begin
              Print, 'Missing EXP And/OR LSS'
;;Download Attitude and Housekeeping Files
              Header=HEADFITS(skims[i])
              ObsDate=FXPAR(Header,'DATE-OBS')
              ObD=StrMid(ObsDate,0,4)+'_'+StrMid(ObsDate,5,2)
              wgetcom="wget -q -nd --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks FTP://heasarc.gsfc.nasa.gov/swift/data/obs/"+ObD+"/"+tid+segment

              spawn,'mkdir '+segdir+'/auxil/'
              spawn,'mkdir '+segdir+'/uvot/hk/'

              patf='sw'+tid+segment+'pat.fits'
              satf='sw'+tid+segment+'sat.fits'
              uaf='sw'+tid+segment+'uaf.hk'
              
              
;              spawn,wgetcom+'/auxil/'+patf+'*'
;              spawn,wgetcom+'/auxil/'+satf+'*'
;              spawn,wgetcom+'/uvot/hk/'+uaf+'*'
              
              

              spawn, 'gunzip *.gz'

              if(File_Test(patf)) then atf=patf else atf=satf
              if(not File_Test(segdir+'/auxil/'+atf)) then spawn,'cp '+atf+' '+segdir+'/auxil/'
              if(not File_Test(segdir+'/uvot/hk'+uaf)) then spawn,'cp '+uaf+' '+segdir+'/uvot/hk/'
              
              spawn,'\rm '+patf
              spawn,'\rm '+satf
              spawn,'\rm '+uaf

;;Generate EXPMap
              Print, 'GENERATING EXPMAP'
;              if(not File_Test(exname)) then spawn,'uvotexpmap ' + skims[i] +$
;                                                   ' attfile=' + segdir+'/auxil/'+atf + ' trackfile=' + segdir+'/uvot/hk/'+uaf + $
;                                                   ' outfile=' + exname + $
;                                                   ' teldeffile=CALDB method=SHIFTADD badpixfile=NONE clobber=yes'


;;Generate LSSMap
;              Print, 'Generating LSSMAP'
;              if(not File_Test(lssname)) then spawn,'uvotskylss infile=' + skims[i] + ' outfile=' + lssname + $
;                                                    ' attfile=' + segdir+'/auxil/'+atf + ' clobber=yes'
;              
           endif

;;If Exposure and LSS Map Files found, sum them
           if (FILE_TEST(exname) AND FILE_TEST(lssname)) then begin
              Print,'Exposure Map and LSS File Found!!'
                                ;spawn,'uvotimsum '+exname+' '+exsum+' exclude='+exclude+' method=EXPMAP clobber=yes'
                                ;spawn,'uvotimsum '+lssname+' '+lsssum+' exclude='+exclude+' method=LSSMAP clobber=yes'
           endif else  Print, 'Error Processing EXP/LSSMAP, CONTINUING WITHOUT'

           spawn,'uvotimsum '+skims[i]+' '+sumfile+' exclude='+exclude+' clobber=yes'
           
           if(FILE_TEST(outfile)) then begin
              spawn,'fappend '+sumfile+' '+outfile
              print,'Obs Appended!'
              spawn,'uvotimsum '+outfile+' '+outfile+' clobber=yes exclude='+exclude
              print,'Obs Stack Summed!'
           endif else spawn,'mv '+sumfile+' '+outfile

;           if(FILE_TEST(exoutfile)) then begin
;              spawn,'fappend '+exsum+' '+exoutfile
;              spawn,'uvotimsum '+exoutfile+' '+exoutfile+' method=EXPMAP clobber=yes exclude='+exclude
;           endif else spawn,'mv  '+exsum+' '+exoutfile

;           if(FILE_TEST(lssoutfile)) then begin
;              spawn,'fappend '+lsssum+' '+lssoutfile
;              spawn,'uvotimsum '+lssoutfile+' '+lssoutfile+' method=LSSMAP clobber=yes exclude='+exclude
;           endif else spawn,'mv  '+lsssum+' '+lssoutfile

        endif else print, 'Filter '+filters[i]+' SKIPPED'

     endif

  endfor

end
