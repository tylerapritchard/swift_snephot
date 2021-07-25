pro sne_stack_obs,name,infile

readcol,infile,tid,seg,templ,excl,format='A,A,I,A'

for i=0,n_elements(seg)-1 do begin
sne_stack_epochs,name,seg[i],template=templ[i],exclude=excl[i],tid=tid[i],sum=1,stack=1        
end

end
