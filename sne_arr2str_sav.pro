pro sne_arr2str_sav,name
dir='$SNE/'+name+'/stacked/'
restore,dir+name+'_lc_mgs.sav'

if(keyword_set(w2m)) then w2lc={Filter:'uvw2',Mag:w2m,Epoch:w2t,Err:w2e}
if(keyword_set(m2m)) then m2lc={Filter:'uvm2',Mag:m2m,Epoch:m2t,Err:m2e}
if(keyword_set(w1m)) then w1lc={Filter:'uvw1',Mag:w1m,Epoch:w1t,Err:w1e}
if(keyword_set(uum)) then uulc={Filter:'!8u!X',Mag:uum,Epoch:uut,Err:uue}
if(keyword_set(bbm)) then bblc={Filter:'!8b!X',Mag:bbm,Epoch:bbt,Err:bbe}
if(keyword_set(vvm)) then vvlc={Filter:'!8v!X',Mag:vvm,Epoch:vvt,Err:vve}

save,w2lc,m2lc,w1lc,uulc,bblc,vvlc,filename=dir+name+'_lc_str.sav'

end
