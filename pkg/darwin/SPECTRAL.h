C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/SPECTRAL.h,v 1.4 2011/04/12 19:23:39 jahn Exp $
C $Name:  $

C SPECTRAL.h 
C description: spectral runtime parameters and fields

C  darwin_waves         :: 'central' wavelengths of wavebands (nm)
      COMMON/SPECTRAL_PARAMS_R/darwin_waves
      _RL darwin_waves(tlam)

C WtouEins    :: W to uEin/s conversion factor
      COMMON/darwin_oasim/ WtouEins
      _RL WtouEins(tlam)

C oasim_ed :: spectral direct downwelling irradiance at surface read from file
C oasim_es :: spectral diffuse downwelling irradiance at surface read from file
#ifdef OASIM
         _RL oasim_ed(1-OLx:sNx+OLx,1-OLy:sNy+OLy,tlam,nSx, nSy)
         _RL oasim_es(1-OLx:sNx+OLx,1-OLy:sNy+OLy,tlam,nSx, nSy)
         COMMON /SPECTRAL_INPUT/ oasim_ed, oasim_es
#endif

