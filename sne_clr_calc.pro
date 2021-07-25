function sne_clr_calc,f1,f2,thresh=thresh
if(not keyword_set(thresh)) then thresh=0.37

;Upper Limits Marked by Points with Zero Error
;Remove These Before Continuing
f1cut=where(f1.err ne 0)
f2cut=where(f2.err ne 0)

if(total(f1cut) ne -1) then begin 
g1={Epoch:f1.epoch[f1cut],Mag:f1.mag[f1cut],Err:f1.err[f1cut]}
endif else g1=f1

if(total(f2cut) ne -1) then begin 
g2={Epoch:f2.epoch[f2cut],Mag:f2.mag[f2cut],Err:f2.err[f2cut]} 
endif else g2=f2

cut12=-1
cut21=-1
n=n_elements(g1.epoch)

;If the two epochs have a single point within threshold days
;Then add the indicies into an array

for i=0,n-1 do begin
temp_cut=where(abs(g1.epoch[i]-g2.epoch) lt thresh)

if (total(temp_cut) ne -1) then begin

if (n_elements(temp_cut) eq 1) then begin

if(total(cut21) eq -1) then cut21=temp_cut else cut21=[cut21,temp_cut]
if(total(cut12) eq -1) then cut12=i else cut12=[cut12,i]

endif else begin
print,'Warning:  Multiple Matching Epochs Found!'
print,f1.filter+'-'+f2.filter+' Epoch: '+string(g1.epoch[i])
print,f2.epoch[temp_cut]
endelse
endif

endfor

if((total(cut12) ne -1) and (total(cut21) ne -1)) then begin

Color={Color:f1.filter+'-'+f2.filter,Epoch:0.5*(g1.epoch[cut12]+g2.epoch[cut21]),Mag:g1.mag[cut12]-g2.mag[cut21],Err:sqrt(g1.Err[cut12]^2.+g2.Err[cut21]^2)}

return,Color

endif 


end
