pro sne_stack_epochs,name,segment,template=template,filter=filter,exclude=exclude,tid=tid,sum=sum,stack=stack

if(not keyword_set(exclude)) then exclude='NONE'
if(not keyword_set(template)) then template=0
if(not keyword_set(sum)) then sum=1
if(not keyword_set(stack)) then stack=1
sndir='$SNE/'+name
spawn,'/bin/ls '+sndir,sndir_cont

if(not keyword_set(tid)) then begin
;;Determine Target ID from SN name + segment #
cut=where(strmid(sndir_cont,2,/reverse) eq segment)
tid=strmid(sndir_cont[cut],0,8)
endif


;;Internal Segment Directory Structure
segdir=sndir+'/'+tid+segment
skimdir=segdir+'/uvot/image/'

;;Define The Stacked Directory, and Create if Not Allready Present
stdir='$SNE/'+name+'/stacked/'
if(where(sndir_cont eq 'stacked') eq -1) then spawn,'mkdir '+stdir


;;Get a List of Images in the Segment Directory and Stacked Directory
spawn, '/bin/ls '+skimdir+'*_sk.img*',skims
spawn, '/bin/ls '+stdir+'*.img',stims

;;Truncate Path Directory so that only Image Name remains
stims=strmid(stims,strpos(stims[0],'/',/reverse_search)+1)

;;Check to see if image is .img or .img.gz, then extract filter codes
filters=strmid(skims,strpos(skims[0],'_',/reverse_search)-2,2)
nfilters=n_elements(filters)

;;Remove Previous summed image if re-summing is chosen
;;(So that multiple epochs may be stacked)
if(keyword_set(sum)) then spawn,'\rm '+skimdir+name+'*'

;;If specified filter is filter i, or, no filters are specified then
;;perform stacking
for i=0,nfilters-1 do begin
if(keyword_set(filter)) then begin
if(where(filter eq filters[i]) ne -1) then compute=1 else compute=0
endif else compute=1


if (compute) then begin 

;Sum exposures in Filter
sumfile=strcompress(skimdir+name+segment+filters[i]+'_e'+string(i)+'.fits',/remove_all)
outfile=skimdir+name+segment+filters[i]+'.img'

if(sum) then begin
spawn,'uvotimsum '+skims[i]+' '+sumfile+' exclude='+exclude+' clobber=yes'

;
spawn,'\ls '+outfile,out_exists

if(out_exists ne '') then begin
spawn,'fappend '+sumfile+' '+outfile
print,'Obs Appended!'
spawn,'uvotimsum '+outfile+' '+outfile+' clobber=yes exclude=NONE'
print,'Obs Stack Summed!'
endif else spawn,'cp '+sumfile+' '+outfile

endif



endif else print, 'Filter '+filters[i]+' SKIPPED'

endfor

;;Append summed image to stacked image
if(stack) then begin
flist=['w2','m2','w1','uu','bb','vv','wh']

for i=0,6 do begin 
;;Check to see if filter is to be computed
;;If the user specifies a filter and the filter is this one, compute
if(keyword_set(filter)) then begin

if(total(where(filter eq flist[i])) ne -1) then compute=1 else compute=0

endif else begin
;;Else, if the current filter is in the list of filters, compute
if(total(where(flist[i] eq filters)) ne -1) then compute =1 else compute =0 

endelse


if(compute) then begin

;;Change sn to SN for File Naming Conventions
fname='SN'+strmid(name,2)

;;If its a template image, use the template naming convention for
;;stack files, otherwise use std convention
;;Std:   SN2006gy_w2.img      
;;Tmpl:  SN2006gy_w2tempsum.img

if(template) then begin
print,tid+segment+flist[i]+' Template Obs' 
stcomp=fname+'_'+flist[i]+'tempsum.img'
endif else begin
print,tid+segment+flist[i]+' SN Obs'
stcomp=fname+'_'+flist[i]+'.img'
endelse

;Check to see if a stacked File has allready been created.  If so,
;append.  If Not, make one
stackfile=stdir+stcomp
outfile=skimdir+name+segment+flist[i]+'*.img'

if (where(stcomp eq stims) eq -1) then begin
print,stcomp+' copied to start stack'
spawn,'fcopy '+outfile+' '+stackfile
endif else begin
print,stcomp+' appended to stack'
spawn,'fappend '+outfile+' '+stackfile
if(template) then spawn,'uvotimsum infile='+stackfile+' outfile='+stackfile+' clobber=yes exclude=NONE'
print,stackfile+' summed'
endelse

endif

endfor
endif

end
