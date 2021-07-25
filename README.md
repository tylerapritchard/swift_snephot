# swift_snephot
# Swift Supernovae Photometry Pipeline from Pritchard et al. 2014 - https://ui.adsabs.harvard.edu/abs/2014ApJ...787..157P/abstract

## Legacy, IDL, use at your own (extreme) risk as this repo is more for my records than anything as I haven't touched it since ~2014.  

Expects to have an up-to-date CALDB, HEADAS install, and a $SNE system variable for a data root directory, and a $SNEPL system variable for a photomety archive directory

E.g. , in your profile ... 

####NASA HEASOFT Setup. 
HEADAS=/home/users/tpritchard/heasoft/x86_64-pc-linux-gnu-libc2.12
export HEADAS

source $HEADAS/headas-init.sh

CALDB=/home/users/tpritchard/bin/caldb
export CALDB

source $CALDB/software/tools/caldbinit.sh

####UVOT Pipeline Config
SNE=/home/users/tpritchard/sne
export SNE

SNEPL=/home/users/tpritchard/sne_phot
export SNEPL

## General usage:
Download and untar swift data into $SNE/SNXXXXabcd  
Make a text file control that has a line for each file you want to process in the form of:  
TID Seg# Templ? Ignore-Keywords

Should look something like:  

-bash-4.1$ pwd  
/home/users/tp1632/sne/SN2018gep

-bash-4.1$ more comlist.bat

00010879	001		0		ASPCORR:NONE  
00010879	002		0		ASPCORR:NONE  
00010879	004		0		ASPCORR:NONE  
00010879	005		0		ASPCORR:NONE  
00010879	006		0		ASPCORR:NONE  
00010879	008		0		ASPCORR:NONE  
00010879	009		0		ASPCORR:NONE  
00010879	010		0		ASPCORR:NONE  
00010879	011		0		ASPCORR:NONE  
00010879	012		0		ASPCORR:NONE  
00010879	013		0		ASPCORR:NONE  
00010879	014		0		ASPCORR:NONE  
00010879	015		1		ASPCORR:NONE  

## Commands can be run as:

### To stack data:  
sne_stack_obs,'SNXXXXabc','comlist.bat'  

### To perform photometry:  
sne_gal_sub,'SNXXXXabc'  
  This expects two regions to be in $SNE/SNXXXXabcd directory:  
    SNXXXXabc_3.reg - a 3" source region file centered on the science object  
    SNXXXXabc_bkgclear.reg - a larger region for sky-background for aperture photometry  
  
  Will perform aperture photometry on object region in stacked science image (from first command) in the stacked directory (will be made automatically).  
  
  If no template image is found (would be made automatically by the above command), procedes to compute aperture phot w/o image subtraction.  
  
  Image subtraction uses coincidence loss corrections described in Brown et al. 2012 and Pritchard et al. 2014.  
  
  Has keywords to specify AB or Vega magnitudes, aperture size (typically 3" or 5" dependding on background.   

### Also includes automated plotting tools:
 sne_plot_lc,'SNXXXXabc'  
 sne_plot_clr,'SNXXXXabc'  
 
 Plots get placed in subdirectories under #SNEPL  
 
 Above Functions have optional /save commands to save IDL .sav files of photometry and color in these archive subdirectories  
 
## Files with *_lss.pro include additional CCD large scale structure correction

  
