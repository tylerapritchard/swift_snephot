;;Returns an array of the first contiguous integers in array, starting
;;from index , with the first element of the returned array being the
;;index stopped at

;IE: retcont([0,3,4,5,6,9,10],0)=[4,3,4,5,6,9]
;    retcont([0,3,4,5,6,9,10],6)=[6,9,10]
;    retcont([0,2,4,6,8],0)=4

function ret_cont_arr,array,index
cut=array
n=n_elements(array)

if(index lt n-1) then begin 

   if(index eq 0) then istart=0 else istart=index-1

   for i=istart,n-2 do cut[i]=(array[i] eq array[i+1]-1)
   cut[n-1]=(array[n-1] eq array[n-2]+1)
   
   for i=index,n-1 do begin
  
      if(cut[i] eq 1) then begin 

      if(i eq 0) then cont_test=array[i] else begin 

         if(cut[i-1] eq 0) then cont_test=array[i] else cont_test=[cont_test,array[i]]

      endelse

   endif else begin

      if(i ne 0) then begin 

         if(cut[i-1] eq 1) then return,[i,cont_test,array[i]]

      endif

   endelse

endfor


if(cut[n-1] eq 1) then return,[n-1,cont_test] 

endif 
return,[n_elements(array)-1]

end
