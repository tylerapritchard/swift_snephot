;;Legacy Version Of SNE_stack_epochs
;;Doesnt work for stacked obs, only individual
;;Segments and Target IDs
pro sne_stack_image,name,segment,template=template,filter=filter,exclude=exclude,tid=tid,sum=sum,stack=stack
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

;;If specified filter is filter i, or, no filters are specified then
;;perform stacking
for i=0,nfilters-1 do begin
if(keyword_set(filter)) then begin
if(where(filter eq filters[i]) ne -1) then compute=1 else compute=0
endif else compute=1


if (compute) then begin 

;Sum exposures in Filter
outfile=skimdir+name+segment+filters[i]+'.img'

if(sum) then begin
spawn,'uvotimsum '+skims[i]+' '+outfile+' exclude='+exclude+' clobber=yes'
endif

;;Change sn to SN for File Naming Conventions
fname='SN'+strmid(name,2)

;;If its a template image, use the template naming convention for
;;stack files, otherwise use std convention
;;Std:   SN2006gy_w2.img      
;;Tmpl:  SN2006gy_w2tempsum.img
if(template) then begin
print,tid+segment+' Template Obs' 
stcomp=fname+'_'+filters[i]+'tempsum.img'
endif else begin
print,tid+segment+' SN Obs'
stcomp=fname+'_'+filters[i]+'.img'
endelse

stackfile=stdir+stcomp

if(stack) then begin
;Check to see if a stacked File has allready been created.  If so,
;append.  If Not, make one
if (where(stcomp eq stims) eq -1) then begin
spawn,'fcopy '+outfile+' '+stackfile
endif else begin
spawn,'fappend '+outfile+' '+stackfile
endelse
endif

endif else print, 'Filter '+filters[i]+' SKIPPED'

endfor


end
