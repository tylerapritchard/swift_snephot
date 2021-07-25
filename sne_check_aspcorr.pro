pro sne_check_aspcorr,name,file=file
if(not keyword_set(file)) then file=name+'_aspcorr_rpt.txt'

spawn,'ls $SNE/'+name+'/000*/uvot/image/sw*',filelist
outlist=' '
nocorr=' '

for i=0,n_elements(filelist)-1 do begin
pfile=0
spawn,'fkeyprint '+filelist[i]+' ASPCORR',output

for j=0,n_elements(output)-1 do begin

if(strpos(output[j],'NONE') ne -1) then begin
if(not pfile) then begin
nocorr=[nocorr,filelist[i]]
pfile=1
endif

nocorr=[nocorr,output[j-1],output[j]]
endif

endfor

outlist=[outlist,output]

endfor

print,nocorr

openw,lun,'$SNE/'+name+'/'+file,/get_lun

printf,lun,'Non-aspect corrected list'
printf,lun,' '
for i=0,n_elements(nocorr)-1 do printf,lun,nocorr[i]

printf,lun,' '
printf,lun,'Total List'
printf,lun,' '
for i=0,n_elements(outlist)-1 do printf,lun,outlist[i]

close,lun

end
