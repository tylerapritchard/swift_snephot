pro sne_plot_lc,name,w2cat=w2cat,m2cat=m2cat,w1cat=w1cat,uucat=uucat,bbcat=bbcat,vvcat=vvcat,save=save,ps=ps,xrange=xrange,yrange=yrange,xlog=xlog

if(not keyword_set(xlog)) then xlog=0
if(not keyword_set(save)) then save=0
if(not keyword_set(ps)) then ps=0

;;If No FIlters Specified, Get a List of Filters in $SNE/name/stacked
if((keyword_set(w2cat)+keyword_set(w1cat)+keyword_set(m2cat)+keyword_set(uucat)+keyword_set(vvcat)+keyword_set(bbcat)) eq 0) then begin
 
sndir='$SNE/'+name
stdir='$SNE/'+name+'/stacked/'

;;Change sn to SN for File Naming Conventions
fname='SN'+strmid(name,2)

;;Make Region File Names
srcreg=stdir+fname+'_3.reg'
bkgreg=stdir+fname+'_bkgclear.reg'

;;Get a List of Images in Stacked Directory, Truncate File Paths
spawn, '/bin/ls '+stdir+'*_mags3.dat',ims
;ims=strmid(ims,strpos(ims[0],'/',/reverse_search)+1 ) ;For Linux

for i=0,n_elements(ims)-1 do begin 
ims[i]=strmid(ims[i],strpos(ims[i],'/',/reverse_search)+1) ;For OS X 
endfor

;;Get Stacked Images Only
f1='[ubvmw]'
f2='[ubv12h]'
stims=ims[where(strmatch(ims,fname+'_'+f1+f2+'_mags3.dat') eq 1)]      

;;Get a List of Filters From Stacked Image
filters=strmid(stims,11,2,/reverse)
nfilters=n_elements(filters)

;;Set Keywords for present Images
cname='SN'+strmid(name,2)
for i=0,nfilters-1 do begin

case filters[i] of
   'w2':  begin
      w2cat=1
      w2catname='$SNE/'+name+'/stacked/'+cname+'_w2_mags3.dat'
   end
   'm2':  begin
      m2cat=1
      m2catname='$SNE/'+name+'/stacked/'+cname+'_m2_mags3.dat'
   end
   'w1':  begin
      w1cat=1
      w1catname='$SNE/'+name+'/stacked/'+cname+'_w1_mags3.dat'
   end
   'uu':  begin
      uucat=1
      uucatname='$SNE/'+name+'/stacked/'+cname+'_uu_mags3.dat'
   end
   'vv':  begin
      vvcat=1
      vvcatname='$SNE/'+name+'/stacked/'+cname+'_vv_mags3.dat'
   end
   'bb':  begin
      bbcat=1
      bbcatname='$SNE/'+name+'/stacked/'+cname+'_bb_mags3.dat'
   end
   'wh':  begin
      whcat=1
      whcatname='$SNE/'+name+'/stacked/'+cname+'_wh_mags3.dat'
   end
endcase

endfor
 

endif else begin
;;Otherwise, Use All Filters Not Specifically Removed
if(not keyword_set(w2cat)) then begin 
w2cat=1
w2catname='$SNE/'+name+'/stacked/'+cname+'_w2_mags3.dat'
endif

if(not keyword_set(m2cat)) then begin 
m2cat=1
m2catname='$SNE/'+name+'/stacked/'+cname+'_m2_mags3.dat'
endif

if(not keyword_set(w1cat)) then begin 
w1cat=1
w1catname='$SNE/'+name+'/stacked/'+cname+'_w1_mags3.dat'
endif

if(not keyword_set(uucat)) then begin 
uucat=1
uucatname='$SNE/'+name+'/stacked/'+cname+'_uu_mags3.dat'
endif

if(not keyword_set(vvcat)) then begin 
vvcat=1
vvcatname='$SNE/'+name+'/stacked/'+cname+'_vv_mags3.dat'
endif

if(not keyword_set(bbcat)) then begin 
bbcat=1
bbcatname='$SNE/'+name+'/stacked/'+cname+'_bb_mags3.dat'
endif

if(not keyword_set(whcat)) then begin 
whcat=1
whcatname='$SNE/'+name+'/stacked/'+cname+'_wh_mags3.dat'
endif

endelse
;;If The Filters are chosen for plotting, Read in catalogue name, 
;;Construct Catalogue Files for Plotting
;;and add the data to times, mags for auto scaling


;;Load W2 CAT
if(keyword_set(w2cat)) then begin 
readcol,w2catname,w2t,w2m,w2e,/silent,format='D,A,D'
w2cut=where(w2m eq 'NULL',complement=nw2cut)
if(where(w2cut eq -1) eq -1) then w2m[w2cut]=w2e[w2cut]
if(where(w2cut eq -1) eq -1) then w2e[w2cut]=0
w2m=double(w2m)
if(not keyword_set(times)) then times=w2t else times=[times,w2t]
if(not keyword_set(mags)) then mags=w2m else mags=[mags,w2m]  
if(not keyword_set(lname)) then lname='uvw2' else lname=[lname,'uvw2']
if(not keyword_set(lclr)) then lclr=!CYAN else lclr=[lclr,!CYAN]
if(not keyword_set(lpsym)) then lpsym=-3 else lpsym=[lpsym,-3]
if(not keyword_set(llsty)) then llsty=0 else llsty=[llsty,0]
endif


;;Load M2 Cat
if(keyword_set(m2cat)) then begin
readcol,m2catname,m2t,m2m,m2e,/silent,format='D,A,D'
m2cut=where(m2m eq 'NULL',complement=nm2cut)
if(where(m2cut eq -1) eq -1) then m2m[m2cut]=m2e[m2cut]
if(where(m2cut eq -1) eq -1) then m2e[m2cut]=0
m2m=double(m2m)

if(not keyword_set(times)) then times=m2t else times=[times,m2t]
if(not keyword_set(mags)) then mags=m2m else mags=[mags,m2m]
if(not keyword_set(lname)) then lname='uvm2' else lname=[lname,'uvm2']
if(not keyword_set(lclr)) then lclr=!MAGENTA else lclr=[lclr,!MAGENTA]
if(not keyword_set(lpsym)) then lpsym=-3 else lpsym=[lpsym,-3]
if(not keyword_set(llsty)) then llsty=0 else llsty=[llsty,0]
endif


;;Load W1 Cat
if(keyword_set(w1cat)) then begin
readcol,w1catname,w1t,w1m,w1e,/silent,format='D,A,D'
w1cut=where(w1m eq 'NULL',complement=nw1cut)
if(where(w1cut eq -1) eq -1) then w1m[w1cut]=w1e[w1cut]
if(where(w1cut eq -1) eq -1)then w1e[w1cut]=0.0
w1m=double(w1m)

if(not keyword_set(times)) then times=w1t else times=[times,w1t]
if(not keyword_set(mags)) then mags=w1m else mags=[mags,w1m]
if(not keyword_set(lname)) then lname='uvw1' else lname=[lname,'uvw1']
if(not keyword_set(lclr)) then lclr=!ORANGE else lclr=[lclr,!ORANGE]
if(not keyword_set(lpsym)) then lpsym=-3 else lpsym=[lpsym,-3]
if(not keyword_set(llsty)) then llsty=0 else llsty=[llsty,0]
endif

;;Load UU Cat
if(keyword_set(uucat)) then begin
readcol,uucatname,uut,uum,uue,/silent,format='D,A,D'
uucut=where(uum eq 'NULL',complement=nuucut)
if(where(uucut eq -1) eq -1) then uum[uucut]=uue[uucut]
if(where(uucut eq -1) eq -1) then uue[uucut]=0
uum=double(uum)

if(not keyword_set(times)) then times=uut else times=[times,uut]
if(not keyword_set(mags)) then mags=uum else mags=[mags,uum]
if(not keyword_set(lname)) then lname='!8u!X' else lname=[lname,'!8u!X']
if(not keyword_set(lclr)) then lclr=!RED else lclr=[lclr,!RED]
if(not keyword_set(lpsym)) then lpsym=-3 else lpsym=[lpsym,-3]
if(not keyword_set(llsty)) then llsty=0 else llsty=[llsty,0]

endif

;;Load bb cat
if(keyword_set(bbcat)) then begin
readcol,bbcatname,bbt,bbm,bbe,/silent,format='D,A,D'
bbcut=where(bbm eq 'NULL',complement=nbbcut)
if(where(bbcut eq -1) eq -1) then bbm[bbcut]=bbe[bbcut]
if(where(bbcut eq -1) eq -1) then bbe[bbcut]=0
bbm=double(bbm)

if(not keyword_set(times)) then times=bbt else times=[times,bbt]
if(not keyword_set(mags)) then mags=bbm else mags=[mags,bbm]
if(not keyword_set(lname)) then lname='!8b!X' else lname=[lname,'!8b!X']
if(not keyword_set(lclr)) then lclr=!GREEN else lclr=[lclr,!GREEN]
if(not keyword_set(lpsym)) then lpsym=-3 else lpsym=[lpsym,-3]
if(not keyword_set(llsty)) then llsty=0 else llsty=[llsty,0]
endif

;;Load vv Cat
if(keyword_set(vvcat)) then begin
readcol,vvcatname,vvt,vvm,vve,/silent,format='D,A,D'
vvcut=where(vvm eq 'NULL',complement=nvvcut)
if(where(vvcut eq -1) eq -1) then vvm[vvcut]=vve[vvcut]
if(where(vvcut eq -1) eq -1) then vve[vvcut]=0
vvm=double(vvm)

if(not keyword_set(times)) then times=vvt else times=[times,vvt]
if(not keyword_set(mags)) then mags=vvm else mags=[mags,vvm]
if(not keyword_set(lname)) then lname='!8v!X' else lname=[lname,'!8v!X']
if(not keyword_set(lclr)) then lclr=!BLUE else lclr=[lclr,!BLUE]
if(not keyword_set(lpsym)) then lpsym=-3 else lpsym=[lpsym,-3]
if(not keyword_set(llsty)) then llsty=0 else llsty=[llsty,0]
endif

;;Load wh Cat
if(keyword_set(whcat)) then begin
readcol,whcatname,wht,whm,whe,/silent,format='D,A,D'
whcut=where(whm eq 'NULL',complement=nwhcut)
if(where(whcut eq -1) eq -1) then whm[whcut]=whe[whcut]
if(where(whcut eq -1) eq -1) then whe[whcut]=0
whm=double(whm)

if(not keyword_set(times)) then times=wht else times=[times,wht]
if(not keyword_set(mags)) then mags=whm else mags=[mags,whm]
if(not keyword_set(lname)) then lname='!8white!X' else lname=[lname,'!8white!X']
if(not keyword_set(lclr)) then lclr=!Forest else lclr=[lclr,!Forest]
if(not keyword_set(lpsym)) then lpsym=-3 else lpsym=[lpsym,-3]
if(not keyword_set(llsty)) then llsty=0 else llsty=[llsty,0]
endif


;;Save The Loaded Inputs into an idl .sav file in both variable and str form
if(save) then save,w2t,w2m,w2e,m2t,m2m,m2e,w1t,w1m,w1e,uut,uum,uue,bbt,bbm,bbe,vvt,vvm,vve,filename='$SNE/'+name+'/stacked/'+name+'_lc_mgs.sav'
if(save) then sne_arr2str_sav,name
if(save) then sne_mk_clrs,name

;;Copy the idl save files over to an archive directory w/ assosciated
;;Fits Files
if(save) then spawn,'\cp $SNE/'+name+'/stacked/'+name+'_lc_str.sav $SNEPH/lc/'
if(save) then spawn,'\cp $SNE/'+name+'/stacked/'+name+'_clr_str.sav $SNEPH/clr/'
if(save) then spawn,'\cp $SNE/'+name+'/stacked/*_phot.fits $SNEPH/fits/'

;;Auto Select The Plotting Range
t_range=[min(times)-3,max(times)+5]
m_range=[max(mags)+0.5,min(mags)-0.5]

;;Output is selected, set nescessary variables.  
if(ps) then psopen,'$SNE/'+name+'/stacked/'+name+'_lc.ps',/bold,/Times,/color,/ISOLATIN1,/landscape
setcolors,/system_variables



;;Format the Plot Axis, Upper Limit Symbols
if(keyword_set(xrange)) then t_range=xrange
if(keyword_set(yrange)) then m_range=yrange

plot,[0,0],[0,0],xr=t_range,yr=m_range,font=ps-1,/nodata,thick=2+ps,charsize=1.+0.25*ps,charthick=1+ps,ysty=1,xsty=1,xtitle=textoidl('JD-2450000',font=ps-1),ytitle=textoidl('m_{Vega}',font=ps-1),xthick=2+ps,ythick=2+ps,Title=Name+' Lightcurve',xlog=xlog

sharpcorners,thick=2+ps
plotsym,1,2.5,thick=2+ps

;;Set Up A Legend
if(ps) then legend,lname,psym=lpsym,linesty=llstye,font=ps-1,charsize=1.5,charthick=1.5,color=lclr,thick=2.5,/right else legend,lname,psym=lpsym,linesty=llsty,font=ps-1,charsize=1.5,charthick=1.5,color=lclr,thick=2.5,/right



;;For each filter, if present, overplot the data on the axis

;;Begin W2 Plot
if(keyword_set(w2cat)) then begin 

index=0
while((index lt n_elements(nw2cut)) and (index ne -1)) do begin
cont_ind=ret_cont_arr(nw2cut,index)
index=cont_ind[0]
if (index ne -1) then index=index+1
nv=n_elements(cont_ind)
 
if(nv  ge 3) then begin
ind=cont_ind[1:nv-1]
oplot,w2t[ind],w2m[ind],psym=-3, linesty=0,thick=2+ps,color=!cyan
endif

endwhile

if(total(w2cut) ne -1) then oplot,w2t[w2cut],w2m[w2cut],psym=8,color=!Cyan
errplot,w2t,w2m-w2e,w2m+w2e,color=!cyan,thick=2.5+ps

endif

;;Begin M2 Plot
if(keyword_set(m2cat)) then begin
index=0
while((index lt n_elements(nm2cut)) and (index ne -1)) do begin
cont_ind=ret_cont_arr(nm2cut,index)
index=cont_ind[0]
if (index ne -1) then index=index+1
nv=n_elements(cont_ind) 

if(nv  ge 3) then begin
ind=cont_ind[1:nv-1] 
oplot,m2t[ind],m2m[ind],psym=-3, linesty=0,thick=2+ps,color=!MAGENTA
endif

endwhile

if(total(m2cut) ne -1) then oplot,m2t[m2cut],m2m[m2cut],psym=8,color=!Magenta
errplot,m2t,m2m-m2e,m2m+m2e,color=!MAGENTA,thick=2.5+ps

endif

;;Begin W1 Plot

if(keyword_set(w1cat)) then begin
index=0
while((index lt n_elements(nw1cut)) and (index ne -1)) do begin
cont_ind=ret_cont_arr(nw1cut,index)
index=cont_ind[0]
if (index ne -1) then index=index+1
nv=n_elements(cont_ind)
  
if(nv  ge 3) then begin 
ind=cont_ind[1:nv-1]
oplot,w1t[ind],w1m[ind],psym=-3, linesty=0,thick=2+ps,color=!ORANGE
endif

endwhile

errplot,w1t,w1m-w1e,w1m+w1e,color=!Orange,thick=2.5+ps
if(total(w1cut) ne -1) then oplot,w1t[w1cut],w1m[w1cut],psym=8,color=!Orange

endif

;;Begin UU Plot 

if(keyword_set(uucat)) then begin
index=0
while((index lt n_elements(nuucut)) and (index ne -1)) do begin
cont_ind=ret_cont_arr(nuucut,index)
index=cont_ind[0]
if (index ne -1) then index=index+1
nv=n_elements(cont_ind) 

if((nv  ge 3)  and (index ne -1))then begin
ind=cont_ind[1:nv-1]
oplot,uut[ind],uum[ind],psym=-3, linesty=0,thick=2+ps,color=!RED
endif

endwhile

errplot,uut,uum-uue,uum+uue,color=!RED,thick=2.5+ps
if(total(uucut) ne -1) then oplot,uut[uucut],uum[uucut],psym=8,color=!Red
endif

;;Begin bb Plot

if(keyword_set(bbcat)) then begin
index=0
while((index lt n_elements(nbbcut)) and (index ne -1)) do begin
cont_ind=ret_cont_arr(nbbcut,index)
index=cont_ind[0]
if (index ne -1) then index=index+1
nv=n_elements(cont_ind)

if(nv  ge 3) then begin 
ind=cont_ind[1:nv-1] 
oplot,bbt[ind],bbm[ind],psym=-3, linesty=0,thick=2.5+ps,color=!GREEN
endif

endwhile

errplot,bbt,bbm-bbe,bbm+bbe,color=!green,thick=2+ps
if(total(bbcut) ne -1) then oplot,bbt[bbcut],bbm[bbcut],psym=8,color=!Green
endif

;;Begin VV Plot

if(keyword_set(vvcat)) then begin
index=0
while((index lt n_elements(nvvcut)) and (index ne -1)) do begin
cont_ind=ret_cont_arr(nvvcut,index)
index=cont_ind[0]
if (index ne -1) then index=index+1
nv=n_elements(cont_ind) 

if(nv  ge 3) then begin
ind=cont_ind[1:nv-1]
oplot,vvt[ind],vvm[ind],psym=-3, linesty=0,thick=2+ps,color=!BLUE
endif

endwhile

errplot,vvt,vvm-vve,vvm+vve,color=!BLUE,thick=2.5+ps
if(total(vvcut) ne -1) then oplot,vvt[vvcut],vvm[vvcut],psym=8,color=!BLUE

endif


;;Begin White Plot

if(keyword_set(whcat)) then begin
index=0
while((index lt n_elements(nwhcut)) and (index ne -1)) do begin
cont_ind=ret_cont_arr(nwhcut,index)
index=cont_ind[0]
if (index ne -1) then index=index+1
nv=n_elements(cont_ind) 

if(nv  ge 3) then begin
ind=cont_ind[1:nv-1]
oplot,wht[ind],whm[ind],psym=-3, linesty=0,thick=2+ps,color=!Forest
endif

endwhile

errplot,wht,whm-whe,whm+whe,color=!Forest,thick=2.5+ps
if(total(whcut) ne -1) then oplot,wht[whcut],whm[whcut],psym=8,color=!Forest

endif

if(ps) then psclose

jpgname=strupcase(strmid(name,0,2))+strmid(name,2)+'_lightcurve.jpg'

if(ps) then spawn,'gs -dBatch -dNOPAUSE -sDEVICE=jpeg -sOutputFile='+'$SNE/'+name+'/stacked/'+jpgname+' -r300 - < '+'$SNE/'+name+'/stacked/'+name+'_lc.ps'
if(ps) then spawn,'\cp $SNE/'+name+'/stacked/'+name+'_lc.ps $SNEPL/lc_ps/'
if(ps) then spawn,'\cp $SNE/'+name+'/stacked/'+jpgname+' $SNEPL/lc_jpg/'


end
