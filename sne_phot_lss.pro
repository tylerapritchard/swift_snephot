pro sne_phot_lss,name,infile,filter=filter,sigma=sigma,magtype=magtype,sndir=sndir
  if(not keyword_set(sndir)) then sndir='$SNE/'+name  ;'$SNE/'+name ;'/Volumes/TimeMachineBackups/SNE_ARCH/'+name;'$SNE/'+name 
  if(not keyword_set(magtype)) then magtype='vega' 
  if(not keyword_set(sigma)) then sigma='3'
  sig_type=size(sigma,/type)
  if(sig_type ne 7) then sigma=strcompress(string(sigma),/remove_all)

;Read In Directories to Compyte Photometry For
  readcol,infile,tid,seg,templ,excl,format='A,A,I,A'
  flist=['w2','m2','w1','uu','bb','vv','wh']

;;Create the Stack Directory
  stdir=sndir+'/stacked/'
  spawn,'mkdir '+stdir
;Make Sure any Previous Fits Phot and Temporary Files are gone
  spawn,'\rm '+stdir+'*.tempfits'
  spawn,'\rm '+stdir+'*clear.fits'

;;Change sn to SN for File Naming Conventions
  fname='SN'+strmid(name,2)

;;Make Region File Names, Check if they exist
;;Error Out if Not
  srcreg=stdir+fname+'_3.reg'
  bkgreg=stdir+fname+'_bkgclear.reg'
  if(not(File_Test(srcreg) and File_Test(bkgreg))) then Begin
     Print, 'Error: No Source/background Region'
     return
  endif

;;If We are Summing Template Images, Delete any currently in the Stack Directory
;if(sumtemp) then spawn, '\rm '+stdir+'*_tempsum.img'

;;Go Through TID/Segments and do photometry on summed images
  for i=0, n_elements(tid) -1 do begin
     skimdir=sndir+'/'+tid[i]+seg[i]+'/uvot/image/'
     spawn, '/bin/ls '+skimdir+'*_sk.img*',skims

;;Make Sure There Are actually SK images
     if(keyword_set(skims)) then begin

        filters=strmid(skims,strpos(skims[0],'_',/reverse_search)-2,2)
        nfilters=n_elements(filters)
        
        for j=0,nfilters-1 do begin
;;If This is NOT a template, compute photometry

           skim=skimdir+'summed_'+tid[i]+seg[i]+filters[j]+'.img'
           exim=skimdir+'summed_'+tid[i]+seg[i]+filters[j]+'_ex.img'
           lssim=skimdir+'summed_'+tid[i]+seg[i]+filters[j]+'.lss'

           if(not templ[i]) then begin
              if((filters[j] ne 'gu') and (filters[j] ne 'gv')) then begin

                 snout=skimdir+'phot_'+tid[i]+seg[i]+filters[j]+'.fits'
                 if(File_Test(exim) and File_Test(lssim)) then begin
                    Print,'Tid: '+tid[i]+' Seg: '+seg[i]+' Filter: '+filters[j]+' EXP/LSS Found'
                    com='uvotsource image='+skim+' lssfile='+lssim+' expfile='+exim
                 endif else begin
                    Print,'Tid: '+tid[i]+' Seg: '+seg[i]+' Filter: '+filters[j]+' No EXP/LSS Found'
                    com='uvotsource image='+skim
                 endelse
;;Call UVOTSOURCE
                 com=com+' srcreg='+srcreg+' bkgreg='+bkgreg+' outfile='+snout+' sigma='+sigma+' coinfile=caldb zerofile=caldb chatter=0 clobber=yes psffile=caldb apercorr=curveofgrowth sensfile=caldb centroid=yes' 
                 spawn, com
;;Stack Photometry
                 stackim=stdir+fname+'_'+filters[j]+'_3_clear.fits'
                 tempstack=stdir+fname+'_'+filters[j]+'_3_clear.tempfits'
;;Append photometry to stack if it exists, otherwise copy to start a stack
                 if(File_Test(tempstack)) then begin 
                    spawn,'ftmerge '+snout+','+tempstack +' '+stackim+' clobber=yes'
                    spawn,'\cp '+stackim+' '+tempstack
                 endif else spawn,'cp '+snout+' '+tempstack
;spawn,'cp '+snout+' '+stackim

              endif
                               

           endif else begin

;;If this IS a template and we want to re-sum template images, append template to stack 
              tempim=stdir+fname+'_'+filters[j]+'_tempsum.img'
              tempex=stdir+fname+'_'+filters[j]+'_tempsum.ex'
              templss=stdir+fname+'_'+filters[j]+'_tempsum.lss'

               ;if(File_Test(tempim)) then spawn,'uvotimsum '+skim+','+tempim+' '+tempim+' exclude=DUPEXPID clobber=yes' else spawn,'cp '+skim+' '+tempim
               ;if(File_Test(tempex)) then spawn,'uvotimsum '+exim+','+tempim+' '+tempex+' exclude=DUPEXPID method=EXPMAP clobber=yes' else spawn,'cp '+exim+' '+tempex
               ;if(File_Test(templss)) then spawn,'uvotimsum '+lssim+','+tempim+' '+templss+' exclude=DUPEXPID method=LSSMAP clobber=yes' else spawn,'cp '+lssim+' '+templss
           endelse

        endfor

     endif else print, 'Skipping'+tid[i]+seg[i]+' - No Sky Files!'


  endfor
;Make Sure any Previous Temporary Files are gone, but if only temp
;images exist, make them non-temp (i.e. one obs)
  spawn, '\ls '+stdir+'*clear.fits',pfits
  spawn, '\ls '+stdir+'*clear.tempfits',tfits
  if(keyword_set(pfits) eq '') then begin
     for i=0,n_elements(tfits)-1 do begin
        spawn,'\mv '+tfits[i]+' '+strmid(tfits[i],0,strlen(tfits[i])-8)+'fits'
        endfor
  endif else spawn,'\rm '+stdir+'*.tempfits'




;;Choose Magnitude Type, Vega Default
  if(magtype eq 'ab') then begin
     print,'Using AB Magnitudes'
     readcol,'~/lib/zeropoints/swift_ab.dat',zp,zpe 
  endif else begin
     print,'Using Vega Magnitudes'
     readcol,'~/lib/zeropoints/swift_vega.dat',zp,zpe 
  endelse


;;Get a List of Photometry Stacks in Stacked Directory, Truncate File Paths
  spawn, '/bin/ls '+stdir+'*.fits',ims
;ims=strmid(ims,strpos(ims[0],'/',/reverse_search)+1 ) ;For Linux

  for i=0,n_elements(ims)-1 do begin 
     ims[i]=strmid(ims[i],strpos(ims[i],'/',/reverse_search)+1) ;For OS X 
  endfor

;;Get Stacked Images Only
  f1='[ubvmw]'
  f2='[ubv12h]'
  stims=ims[where(strmatch(ims,fname+'_'+f1+f2+'_3_clear.fits') eq 1)]      

;;Get a List of Filters From Stacked Image
  filters=strmid(stims,14,2,/reverse)
  nfilters=n_elements(filters)
;filters=strmid(stims,strlen(fname)+1,2)

;;Get a List of Template Images in Stacked Directory, Truncate File Paths
  spawn, '/bin/ls '+stdir+'*_tempsum.img',temp_ims
  tims=strmid(temp_ims,strpos(temp_ims[0],'/',/reverse_search)+1)
;;;Compute Template Photometry
  for i=0,nfilters-1 do begin


     tempim=stdir+fname+'_'+filters[i]+'_tempsum.img'
     tempex=stdir+fname+'_'+filters[i]+'_tempsum.ex'
     templss=stdir+fname+'_'+filters[i]+'_tempsum.lss'
     tempout=stdir+fname+'_'+filters[i]+'_3_cleartempsum.fits'
;;For Each Filter, Check to See if Stacked template Image Exists
     if(FILE_TEST(tempim)) then begin
;;If The LSS/EXP Maps exist, use them.  Otherwise .... don't
        ;;;;;;Temporarily, ignore LSS, EXP MAP for P. Brown check
        ;if(FILE_TEST(Templss) and FILE_TEST(TEMPEX)) then com='uvotsource image='+tempim+' lssfile='+templss+'+1 expfile='+tempex+'+1' else com='uvotsource image='+tempim
        com='uvotsource image='+tempim
        com=com+' srcreg='+srcreg+' bkgreg='+bkgreg+' outfile='+tempout+' sigma='+sigma+' coinfile=caldb zerofile=caldb chatter=0 clobber=yes psffile=caldb apercorr=curveofgrowth sensfile=caldb' 
        spawn, com
     endif

  endfor

  for i=0,nfilters-1 do begin
;;If specified filter is filter i, or, no filters are specified then
;;perform stacking
     if(keyword_set(filter)) then begin
        if(where(filter eq filters[i]) ne -1) then compute=1 else compute=0
     endif else compute=1

     if (compute) then begin 

;;Retrieve Galaxy Count Rates From Template Image. 
;;(Only If Template Image Exists)
;;Requires 3" Source Region,and background region
;;"SN200Zzz_3.reg","SN200Zzz_bkgclear.reg"
;;Galaxy Count Rates From Template Image
        tempimage=fname+'_'+filters[i]+'_tempsum.img'
        gtout=stdir+fname+'_'+filters[i]+'_3_cleartempsum.fits'
        snout=stdir+fname+'_'+filters[i]+'_3_clear.fits'
;;Remove any Previous Backup Files For This Filter (Templ + SN)
        spawn, '\rm '+stdir+fname+'_'+filters[i]+'_phot*.fits'

;;Copy Photometry File In Case of Errors
;;SN File Name:SN200Zzz_Filter_phot.fits
;;Tmpl File Name:SN200Zzz_Filter_phottempsum.fits
        snphot=stdir+fname+'_'+filters[i]+'_phot.fits'
        tempphot=stdir+fname+'_'+filters[i]+'_phottempsum.fits'
        spawn,'fcopy '+snout+' '+snphot
        if(where(tempimage eq tims) ne -1) then spawn,'fcopy '+gtout+' '+tempphot
;;Rename CORR_RATE to S3BCR for Uniformity
        spawn, 'fcalc '+snphot+' '+snphot+' clobber=yes clname="S3BCR" tform=1E expr="COI_SRC_RATE*LSS_FACTOR*SENSCORR_FACTOR"'


        if(where(tempimage eq tims) ne -1) then begin
           spawn, 'fcalc '+tempphot+' '+tempphot+' clobber=yes clname="S3BCR" tform=1E expr="COI_SRC_RATE*LSS_FACTOR*SENSCORR_FACTOR"'
        endif

;;Increase Error on Count Rate By 3% In Quadrature to Poission Error
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S3BCRe" tform=1E  expr="sqrt((COI_SRC_RATE_ERR*LSS_FACTOR*SENSCORR_FACTOR)^2+(COI_SRC_RATE*LSS_FACTOR*SENSCORR_FACTOR*0.03)^2)"'

        if(where(tempimage eq tims) ne -1) then begin
           spawn,'fcalc '+tempphot+' '+tempphot+' clobber=yes clname="S3BCRe" tform=1E  expr="sqrt((COI_SRC_RATE_ERR*LSS_FACTOR*SENSCORR_FACTOR)^2+(COI_SRC_RATE*LSS_FACTOR*SENSCORR_FACTOR*0.03)^2)"'
        endif

;;Extract Count Rates From Template Images
;;Returns 0 in G3BCR in snphot file if no template image
;;e=error, l=limit

        if(where(tempimage eq tims) ne -1) then begin
           spawn,'echo "Template Image for Filter '+filters[i]+' Found"'

           spawn,'fstatistic '+tempphot+' colname=S3BCR rows=1 outfile=/tmp/junk.txt clobber=yes'
           spawn,'pget fstatistic mean',fstat_out
           spawn,'fthedit '+snphot+' G3BCR operation=add value='+fstat_out


           spawn,'fstatistic '+tempphot+' colname=S3BCRe rows=1 outfile=/tmp/junk.txt clobber=yes'
           spawn,'pget fstatistic mean',fstat_err_out
           spawn,'fthedit '+snphot+' G3BCRe operation=add value='+fstat_err_out

           spawn,'echo "'+filters[i]+' count rate is '+fstat_out+'"'
        endif else begin
;;If No Template Photometry/Image, set columns to zero
           spawn,'fthedit '+snphot+' G3BCR operation=add value=0'
           spawn,'fthedit '+snphot+' G3BCRe operation=add value=0'
           spawn,'echo "No Template Image for '+filters[i]+'"'
        endelse

;;Add In Zero Points
        case filters[i] of
           'w2':begin
              ZPT=string(zp[0])
              ZPTe=string(zpe[0])
           end
           'm2':begin
              ZPT=string(zp[1])
              ZPTe=string(zpe[1])
           end
           'w1':begin
              ZPT=string(zp[2])
              ZPTe=string(zpe[2])
           end
           'uu':begin
              ZPT=string(zp[3])
              ZPTe=string(zpe[3])
           end
           'bb':begin
              ZPT=string(zp[4])
              ZPTe=string(zpe[4])
           end
           'vv':begin
              ZPT=string(zp[5])
              ZPTe=string(zpe[5])
           end
           'wh':begin
              ZPT=string(zp[6])
              ZPTe=string(zpe[6])
           end
           else:begin 
              ZPT=string(zp[6])
              ZPTe=string(zpe[6])
              print,'Err:No Zero Point'
           end
        endcase

        spawn,'fparkey '+ZPT+' '+snphot+' ZPT add=yes'
        spawn,'fparkey '+ZPTe+' '+snphot+' ZPTe add=yes' 

;;Subtract The Galaxy, Propogate Errors
        spawn,'echo "  subtract galaxy, propogate error"'
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S3BCGR" tform=1E  expr="(S3BCR-G3BCR)"'
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S3BCGRe" tform=1E  expr="sqrt((S3BCRe)^2+(G3BCRe)^2)"'

;;Apply aperture Corrections
;;Do After Background Subtraction(need a ~ pt src)
;; Corrections Come From Maghistt
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S3BCGAR" tform=1E  expr="S3BCGR*AP_FACTOR"'
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S3BCGARe" tform=1E  expr="S3BCGRe*AP_FACTOR_ERR"'

;;Determine Significance/3 Sigma Upper Limit
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S3BCGARs" tform=1E  expr="S3BCGAR/S3BCGARe"'
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S3BCGAMl" tform=1E  expr="(-2.5*log10('+sigma+'*S3BCGARe))+ZPT"'

;;Convert Rate, Error To Magnitudes
        spawn,'ftcalc '+snphot+' '+snphot+' clobber=yes column="S3BCGAM" tform=1E  expression="S3BCGARs>'+sigma+'?-2.5*log10(S3BCGAR)+ZPT:#null"'
        spawn,'ftcalc '+snphot+' '+snphot+' clobber=yes column="S3BCGAMe" tform=1E  expression="S3BCGARs>'+sigma+'?(2.5/log(10))*((S3BCGARe/S3BCGAR)):S3BCGAMl"'

;;Add In Convienient Time Columns
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="TMID" expr="(TSTOP-TSTART)/2+TSTART"'
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="JD" expr="TMID/60/60/24+2451910.5"'
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="JDshort" tform=1E  expr="JD-2450000"'

;;Add In Numerical Formatting for future output
        spawn,'fthedit '+snphot+' TDISP78 add f7.2'
        spawn,'fthedit '+snphot+' TDISP74 add f5.2'
        spawn,'fthedit '+snphot+' TDISP75 add f5.2'

;;;Output Magnitudes
        magout=stdir+fname+'_'+filters[i]+'_mags3.dat'
        spawn,'ftlist '+snphot+' option=t outfile='+magout+' columns="JDshort, S3BCGAM, S3BCGAMe" clobber=yes rownum=no colheader=no'

        print,' '
        print,'3" Photometry Complete for '+filters[i]+', beginning 5"'
        print,' '

;;Compute Standard 5" aperture photometry, using std aper
;;Apply coincidence correction to std rate
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S5CR" tform=1E  expr="(RAW_STD_RATE*COI_STD_FACTOR*LSS_FACTOR*SENSCORR_FACTOR)"'
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S5CRe" tform=1E  expr="(RAW_STD_RATE_ERR*COI_STD_FACTOR*LSS_FACTOR*SENSCORR_FACTOR)"'
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S5BCR" tform=1E  expr="((RAW_STD_RATE*COI_STD_FACTOR)-(COI_BKG_RATE*STD_AREA))"'
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S5BCRe" tform=1E  expr="sqrt((S5CRe)^2+(S5CR*0.03)^2+(COI_BKG_RATE_ERR*STD_AREA)^2)"'

;;Compute Template Photometry if It Exists
        if(where(tempimage eq tims) ne -1) then begin
           spawn,'fcalc '+tempphot+' '+tempphot+' clobber=yes clname="S5CR" tform=1E  expr="(RAW_STD_RATE*COI_STD_FACTOR*LSS_FACTOR*SENSCORR_FACTOR)"'
           spawn,'fcalc '+tempphot+' '+tempphot+' clobber=yes clname="S5CRe" tform=1E  expr="(RAW_STD_RATE_ERR*COI_STD_FACTOR*LSS_FACTOR*SENSCORR_FACTOR)"'
           spawn,'fcalc '+tempphot+' '+tempphot+' clobber=yes clname="S5BCR" tform=1E  expr="((RAW_STD_RATE*COI_STD_FACTOR)-(COI_BKG_RATE*STD_AREA))"'
           spawn,' fcalc '+tempphot+' '+tempphot+' clobber=yes clname="S5BCRe" tform=1E  expr="sqrt((S5CRe)^2+(S5CR*0.03)^2+(COI_BKG_RATE_ERR*STD_AREA)^2)"'
        endif

;;Perform Background Subtraction if Possible
        if(where(tempimage eq tims) ne -1) then begin
           spawn,'fstatistic '+tempphot+' colname=S5BCR rows=1 outfile=/tmp/junk.txt clobber=yes'
           spawn,'pget fstatistic mean',fstat_out
           spawn,'fthedit '+snphot+' G5BCR operation=add value='+fstat_out
           spawn,'fstatistic '+tempphot+' colname=S5BCRe rows=1 outfile=/tmp/junk.txt clobber=yes'
           spawn,'pget fstatistic mean',fstat_err_out
           spawn,'fthedit '+snphot+' G5BCRe operation=add value='+fstat_err_out
        endif else begin
           spawn,'fthedit '+snphot+' G5BCR operation=add value=0'
           spawn, 'fthedit '+snphot+' G5BCRe operation=add value=0'
        endelse

;;Subtract Background, Propogate Error
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S5BCGR" tform=1E  expr="(S5BCR-G5BCR)"'
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S5BCGRe" tform=1E  expr="sqrt((S5BCRe)^2+(G5BCRe)^2)"'

;;Determine Significance
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S5BCGRs" tform=1E  expr="S5BCGR/S5BCGRe"'
        spawn,'fcalc '+snphot+' '+snphot+' clobber=yes clname="S5BCGMl" tform=1E  expr="(-2.5*log10(3*S5BCGRe))+ZPT"'

        spawn,'ftcalc '+snphot+' '+snphot+' clobber=yes column="S5BCGM" tform=1E expression="S5BCGRs>3?(-2.5*log10(S5BCGR)+ZPT):#null"'
        spawn,'ftcalc '+snphot+' '+snphot+' clobber=yes column="S5BCGMe" tform=1E  expression="S5BCGRs>3?(2.5/log(10))*((S5BCGRe/S5BCGR)):S5BCGMl"'

        spawn,'fthedit '+snphot+' TDISP87 add f5.2'
        spawn,'fthedit '+snphot+' TDISP88 add f5.2'

        spawn,'ftlist '+snphot+' option=t outfile='+stdir+fname+'_'+filters[i]+'_mags5.dat columns="JDshort, S5BCGM, S5BCGMe" clobber=yes rownum=no colheader=no'

     endif


  endfor




end
