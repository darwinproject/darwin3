c Set parameters:
c tlam = number of wavebands
c        must match number of wavebands in input datafiles
c        must be the same for all data types (water, phyto, CDOM, surface spectra)

c need this if spectral AND/OR oasim
coj: now defined in WAVEBANDS_PARAMS.h
c         integer tlam
c         PARAMETER (tlam=13)


#ifdef OASIM
         _RL oasim_ed(1-OLx:sNx+OLx,1-OLy:sNy+OLy,tlam,nSx, nSy)
         _RL oasim_es(1-OLx:sNx+OLx,1-OLy:sNy+OLy,tlam,nSx, nSy)
         COMMON /SPECTRAL_INPUT/ oasim_ed, oasim_es
#endif
