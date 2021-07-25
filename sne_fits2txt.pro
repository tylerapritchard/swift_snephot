pro sne_fits2txt,name,dirout=dirout
if(n_elements(dirout) eq 0) then dirout=' '

fname='SN'+strmid(name,2)
spawn, '/bin/ls $SNEPH/fits/'+fname+'*',files
print, files
filters=strmid(files,11,2,/reverse)
nfilters=n_elements(filters)
print, filters

for i=0, nfilters-1 do begin
magout=fname+'_'+filters[i]+'_mags3.dat'
spawn,'ftlist '+files[i]+' option=t outfile='+dirout+magout+' columns="JDshort, S3BCGAM, S3BCGAMe" clobber=yes rownum=no colheader=no'

endfor

end
