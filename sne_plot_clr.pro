pro addstrrange,clr,r,e,f,c,cl
if(not keyword_set(ps)) then ps=0
if(f[0] eq ' ') then begin 
r=clr.mag 
e=clr.epoch 
f=clr.color
c=cl
endif else begin 
r=[r,clr.mag]
e=[e,clr.epoch]
f=[f,clr.color]
c=[c,cl]
endelse
end


pro sne_plot_clr,name,ps=ps
if(not keyword_set(ps)) then ps=0
stdir='$SNE/'+name+'/stacked/'
restore,stdir+name+'_clr_str.sav'

range=0
epoch=0
flist=' '

range2=0
epoch2=0
flist2=' '


range3=0
epoch3=0
flist3=' '

;;Load The Various Colors if they exist
if(keyword_set(w2m2clr)) then addstrrange,w2m2clr,range,epoch,flist,clist,!cyan
if(keyword_set(w2w1clr)) then addstrrange,w2w1clr,range,epoch,flist,clist,!blue
if(keyword_set(m2w1clr)) then addstrrange,m2w1clr,range,epoch,flist,clist,!magenta


if(keyword_set(uubbclr)) then addstrrange,uubbclr,range2,epoch2,flist2,clist2,!red
if(keyword_set(uuvvclr)) then addstrrange,uuvvclr,range2,epoch2,flist2,clist2,!blue
if(keyword_set(bbvvclr)) then addstrrange,bbvvclr,range2,epoch2,flist2,clist2,!green


if(keyword_set(w2uuclr)) then addstrrange,w2uuclr,range3,epoch3,flist3,clist3,!cyan
if(keyword_set(w2bbclr)) then addstrrange,w2bbclr,range3,epoch3,flist3,clist3,!blue
if(keyword_set(w2vvclr)) then addstrrange,w2vvclr,range3,epoch3,flist3,clist3,!green
if(keyword_set(m2uuclr)) then addstrrange,m2uuclr,range3,epoch3,flist3,clist3,!forest
if(keyword_set(m2bbclr)) then addstrrange,m2bbclr,range3,epoch3,flist3,clist3,!gray
if(keyword_set(m2vvclr)) then addstrrange,m2vvclr,range3,epoch3,flist3,clist3,!purple
if(keyword_set(w1uuclr)) then addstrrange,w1uuclr,range3,epoch3,flist3,clist3,!magenta
if(keyword_set(w1bbclr)) then addstrrange,w1bbclr,range3,epoch3,flist3,clist3,!orange
if(keyword_set(w1vvclr)) then addstrrange,w1vvclr,range3,epoch3,flist3,clist3,!red

clist2_2=[!cyan,!blue,!magenta]
clist_2=[!red,!blue,!green]
clist3_2=[!cyan,!blue,!green,!forest,!gray,!purple,!magenta,!orange,!red]

ep=[epoch,epoch2,epoch3]
ep=ep[where(ep ne 0)]
r=[min(range)-0.5,max(range)+0.5]
e=[min(ep)-1,max(ep)+1+0.225*(max(ep)-min(ep))]

r2=[min(range2)-0.5,max(range2)+0.5]
e2=[min(epoch2)-1,max(epoch2)+1]

r3=[min(range3)-0.5,max(range3)+0.5]
e3=[min(epoch3)-1,max(epoch3)+1]



xm=0.07
ym=0.05
d1=0.35
d2=0.65
;pos1=[0+xm,.45,1-0.25*xm,1-.1]
;pos2=[0+xm,0+ym,1-0.25*xm,.45]
;pos3=

pos1=[0+xm,d2,1-0.25*xm,1-ym]
pos2=[0+xm,d1,1-0.25*xm,d2]
pos3=[0+xm,0+ym,1-0.25*xm,d1]

if(n_elements(clist) eq 0) then clist=0
if(n_elements(clist2) eq 0) then clist2=0
if(n_elements(clist3) eq 0) then clist3=0


if(ps) then psopen,stdir+name+'_clrs.ps',/bold,/times,/isolatin1,/landscape,/color
setcolors,/system_variables
!p.multi=[0,0,3]

plot,[0,1],[0,1],xr=e,yr=r2,font=ps-1,/nodata,thick=2+ps,charsize=1+ps,charthick=1+ps,ysty=1,xsty=1,xthick=2.5+ps,ythick=2.5+ps,pos=pos1,xtickname=replicate(' ',7),title=name+' colors'

legend,flist2,color=clist2,/right,font=ps-1,thick=2+0.5*ps,charsize=1.0+0.25*ps,linesty=replicate(0,n_elements(clist2))

xyouts,0.025,0.5,textoidl('m_{Vega}',font=ps-1),alignment=0.5,charthick=1+ps,charsize=1+ps,orientation=90,/normal,font=ps-1


if(keyword_set(uubbclr)) then begin
oplot,uubbclr.epoch,uubbclr.mag,thick=2+ps,color=clist_2[0]
errplot,uubbclr.epoch,uubbclr.mag-uubbclr.err,uubbclr.mag+uubbclr.err,thick=2.5+ps,color=clist_2[0]
endif

if(keyword_set(uuvvclr)) then begin
oplot,uuvvclr.epoch,uuvvclr.mag,thick=2+ps,color=clist_2[1]
errplot,uuvvclr.epoch,uuvvclr.mag-uuvvclr.err,uuvvclr.mag+uuvvclr.err,thick=2.5+ps,color=clist_2[1]
endif

if(keyword_set(bbvvclr)) then begin
oplot,bbvvclr.epoch,bbvvclr.mag,thick=2+ps,color=clist_2[2]
errplot,bbvvclr.epoch,bbvvclr.mag-bbvvclr.err,bbvvclr.mag+bbvvclr.err,thick=2.5+ps,color=clist_2[2]
endif



plot,[0,1],[0,1],xr=e,yr=r,font=ps-1,/nodata,thick=2+ps,charsize=1+ps,charthick=1+ps,ysty=1,xsty=1,xthick=2.5+ps,ythick=2.5+ps,pos=pos2,xtickname=replicate(' ',7)

legend,flist,color=clist,/right,font=ps-1,thick=2+0.5*ps,charsize=1+0.25*ps,linesty=replicate(0,n_elements(clist))


if(keyword_set(w2m2clr)) then begin
oplot,w2m2clr.epoch,w2m2clr.mag,thick=2+ps,color=clist2_2[0]
errplot,w2m2clr.epoch,w2m2clr.mag-w2m2clr.err,w2m2clr.mag+w2m2clr.err,thick=2.5+ps,color=clist2_2[0]
endif

if(keyword_set(w2w1clr)) then begin
oplot,w2w1clr.epoch,w2w1clr.mag,thick=2+ps,color=clist_2[1]
errplot,w2w1clr.epoch,w2w1clr.mag-w2w1clr.err,w2w1clr.mag+w2w1clr.err,thick=2.5+ps,color=clist2_2[1]
endif

if(keyword_set(m2w1clr)) then begin
oplot,m2w1clr.epoch,m2w1clr.mag,thick=2+ps,color=clist_2[2]
errplot,m2w1clr.epoch,m2w1clr.mag-m2w1clr.err,m2w1clr.mag+m2w1clr.err,thick=2.5+ps,color=clist2_2[2]
endif



plot,[0,1],[0,1],xr=e,yr=r3,font=ps-1,/nodata,thick=2+ps,charsize=1+ps,charthick=1+ps,ysty=1,xsty=1,xthick=2.5+ps,ythick=2.5+ps,pos=pos3,xtitle='JD-2450000'

legend,flist3,color=clist3,/right,font=ps-1,thick=2+0.5*ps,charsize=1.0+0.25*ps,linesty=replicate(0,n_elements(clist3))


if(keyword_set(w2uuclr)) then begin
oplot,w2uuclr.epoch,w2uuclr.mag,thick=2+ps,color=clist3_2[0]
errplot,w2uuclr.epoch,w2uuclr.mag-w2uuclr.err,w2uuclr.mag+w2uuclr.err,thick=2.5+ps,color=clist3_2[0]
endif

if(keyword_set(w2bbclr)) then begin
oplot,w2bbclr.epoch,w2bbclr.mag,thick=2+ps,color=clist3_2[1]
errplot,w2bbclr.epoch,w2bbclr.mag-w2bbclr.err,w2bbclr.mag+w2bbclr.err,thick=2.5+ps,color=clist3_2[1]
endif

if(keyword_set(w2vvclr)) then begin
oplot,w2vvclr.epoch,w2vvclr.mag,thick=2+ps,color=clist3_2[2]
errplot,w2vvclr.epoch,w2vvclr.mag-w2vvclr.err,w2vvclr.mag+w2vvclr.err,thick=2.5+ps,color=clist3_2[2]
endif

if(keyword_set(m2uuclr)) then begin
oplot,m2uuclr.epoch,m2uuclr.mag,thick=2+ps,color=clist3_2[3]
errplot,m2uuclr.epoch,m2uuclr.mag-m2uuclr.err,m2uuclr.mag+m2uuclr.err,thick=2.5+ps,color=clist3_2[3]
endif

if(keyword_set(m2bbclr)) then begin
oplot,m2bbclr.epoch,m2bbclr.mag,thick=2+ps,color=clist3_2[4]
errplot,m2bbclr.epoch,m2bbclr.mag-m2bbclr.err,m2bbclr.mag+m2bbclr.err,thick=2.5+ps,color=clist3_2[4]
endif

if(keyword_set(m2vvclr)) then begin
oplot,m2vvclr.epoch,m2vvclr.mag,thick=2+ps,color=clist3_2[5]
errplot,m2vvclr.epoch,m2vvclr.mag-m2vvclr.err,m2vvclr.mag+m2vvclr.err,thick=2.5+ps,color=clist3_2[5]
endif

if(keyword_set(w1uuclr)) then begin
oplot,w1uuclr.epoch,w1uuclr.mag,thick=2+ps,color=clist3_2[6]
errplot,w1uuclr.epoch,w1uuclr.mag-w1uuclr.err,w1uuclr.mag+w1uuclr.err,thick=2.5+ps,color=clist3_2[6]
endif

if(keyword_set(w1bbclr)) then begin
oplot,w1bbclr.epoch,w1bbclr.mag,thick=2+ps,color=clist3_2[7]
errplot,w1bbclr.epoch,w1bbclr.mag-w1bbclr.err,w1bbclr.mag+w1bbclr.err,thick=2.5+ps,color=clist3_2[7]
endif

if(keyword_set(w1vvclr)) then begin
oplot,w1vvclr.epoch,w1vvclr.mag,thick=2+ps,color=clist3_2[8]
errplot,w1vvclr.epoch,w1vvclr.mag-w1vvclr.err,w1vvclr.mag+w1vvclr.err,thick=2.5+ps,color=clist3_2[8]
endif



if(ps) then psclose
!p.multi=0

jpgname=strupcase(strmid(name,0,2))+strmid(name,2)+'_colors.jpg'

if(ps) then spawn,'gs -dBatch -dNOPAUSE -sDEVICE=jpeg -sOutputFile='+'$SNE/'+name+'/stacked/'+jpgname+' -r300 - < '+'$SNE/'+name+'/stacked/'+name+'_clrs.ps'
if(ps) then spawn,'\cp $SNE/'+name+'/stacked/'+name+'_clrs.ps $SNEPL/clrs_ps/'
if(ps) then spawn,'\cp $SNE/'+name+'/stacked/'+jpgname+' $SNEPL/clrs_jpg/'


end
