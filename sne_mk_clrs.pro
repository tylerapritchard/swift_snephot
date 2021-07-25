pro sne_mk_clrs,name,filename=filename

dir='$SNE/'+name+'/stacked/'
if(keyword_set(filename)) then restore,filename,/ver else begin
restore,dir+name+'_lc_str.sav'
endelse

if(keyword_set(w2lc) and keyword_set(m2lc)) then w2m2Clr=sne_clr_calc(w2lc,m2lc)
if(keyword_set(w2lc) and keyword_set(w1lc)) then w2w1Clr=sne_clr_calc(w2lc,w1lc)
if(keyword_set(w2lc) and keyword_set(uulc)) then w2uuClr=sne_clr_calc(w2lc,uulc)
if(keyword_set(w2lc) and keyword_set(bblc)) then w2bbClr=sne_clr_calc(w2lc,bblc)
if(keyword_set(w2lc) and keyword_set(vvlc)) then w2vvClr=sne_clr_calc(w2lc,vvlc)
if(keyword_set(m2lc) and keyword_set(w1lc)) then m2w1Clr=sne_clr_calc(m2lc,w1lc)
if(keyword_set(m2lc) and keyword_set(uulc)) then m2uuClr=sne_clr_calc(m2lc,uulc)
if(keyword_set(m2lc) and keyword_set(bblc)) then m2bbClr=sne_clr_calc(m2lc,bblc)
if(keyword_set(m2lc) and keyword_set(vvlc)) then m2vvClr=sne_clr_calc(m2lc,vvlc)
if(keyword_set(w1lc) and keyword_set(uulc)) then w1uuClr=sne_clr_calc(w1lc,uulc)
if(keyword_set(w1lc) and keyword_set(bblc)) then w1bbClr=sne_clr_calc(w1lc,bblc)
if(keyword_set(w1lc) and keyword_set(vvlc)) then w1vvClr=sne_clr_calc(w1lc,vvlc)
if(keyword_set(uulc) and keyword_set(bblc)) then uubbClr=sne_clr_calc(uulc,bblc)
if(keyword_set(uulc) and keyword_set(vvlc)) then uuvvClr=sne_clr_calc(uulc,vvlc)
if(keyword_set(bblc) and keyword_set(vvlc)) then bbvvClr=sne_clr_calc(bblc,vvlc)

save,w2m2Clr,w2w1Clr,w2UUClr,w2BBClr,w2VVClr,m2w1Clr,m2UUClr,m2BBClr,m2VVClr,w1UUClr,w1BBClr,w1VVClr,UUBBClr,UUVVClr,BBVVClr,filename=dir+name+'_clr_str.sav'

end
