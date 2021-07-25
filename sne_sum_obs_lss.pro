pro sne_sum_obs_lss,name,infile,sndir=sndir,all=all
  if(not keyword_set(all)) then all=0
  if(all) then begin
     if(not keyword_set(sndir)) then sndir='$SNE/'+name;'/Volumes/TimeMachineBackups/SNE_ARCH/'+name+'/';
     spawn,'\ls -d '+sndir+'00*/',obsids
     print,obsids
     for i=0,n_elements(obsids)-1 do begin 
        seg=strmid(obsids[i],3,3,/reverse)
        tid=strmid(obsids[i],11,8,/reverse)
        sne_sum_lss,name,seg,tid=tid,sum=sum,exclude=exclude,filter=filter,sndir=sndir;,/redl_sk
     endfor
  endif else begin
     readcol,infile,tid,segment,templ,exclude,format='A,A,I,A'
     for i=0,n_elements(tid)-1 do sne_sum_lss,name,segment[i],filter=filter,exclude=exclude,tid=tid[i],sum=sum,sndir=sndir;,/redl_sk
  endelse
end
