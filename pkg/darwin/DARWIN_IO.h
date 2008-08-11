C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/DARWIN_IO.h,v 1.6 2008/08/11 14:48:39 stephd Exp $
C $Name:  $

#include "GCHEM_OPTIONS.h"

c DARWIN_IO.h
c --------------------------------------------------------------------
c  Description:  input and diagnostic output for DARWIN pkg
c          Stephanie Dutkiewicz: Spring 2006
c NOTE: additional diagnostics still needed
c --------------------------------------------------------------------      

C--   COMMON /DARWIN_FILENAMES/
C  darwin_iceFile       :: file name of seaice fraction
C  darwin_ironFile      :: file name of aeolian iron flux
C  darwin_PARFile       :: file name of Photosynthetically Active Radiation at surface
C  darwin_nutWVelFile   :: file name of nutrient wvel
C  darwin_forcingPeriod :: perioDARWIN forcing parameter specific for DARWIN (seconds)
C  darwin_forcingCycle  :: perioDARWIN forcing parameter specific for DARWIN (seconds)
C  darwin_seed          :: seed for the random number generator

      COMMON /DARWIN_FILENAMES/
     &        darwin_iceFile,
     &        darwin_ironFile,
     &        darwin_PARFile,
     &        darwin_nutWVelFile,
     &        darwin_PO4_relaxFile, darwin_NO3_relaxFile,
     &        darwin_FeT_relaxFile, darwin_Si_relaxFile,
     &        darwin_relaxscale,
     &        darwin_forcingPeriod, darwin_forcingCycle,
     &        darwin_seed

      CHARACTER*(MAX_LEN_FNAM) darwin_iceFile
      CHARACTER*(MAX_LEN_FNAM) darwin_ironFile
      CHARACTER*(MAX_LEN_FNAM) darwin_PARFile
      CHARACTER*(MAX_LEN_FNAM) darwin_NutWVelFile
      CHARACTER*(MAX_LEN_FNAM) darwin_PO4_relaxFile
      CHARACTER*(MAX_LEN_FNAM) darwin_NO3_relaxFile
      CHARACTER*(MAX_LEN_FNAM) darwin_FeT_relaxFile
      CHARACTER*(MAX_LEN_FNAM) darwin_Si_relaxFile
      _RL darwin_relaxscale
      _RL     darwin_forcingPeriod
      _RL     darwin_forcingCycle
      INTEGER darwin_seed

c INPUT:
c    fice           - ice fraction
c    inputFe        - aeolian input of iron
c    sur_par        - surface PAR
      COMMON /DARWIN_INPUT/
     &       fice, inputFe, sur_par
#ifdef NUT_SUPPLY
     &      ,nut_wvel
#endif
#ifdef RELAX_NUTS
     &      ,po4_obs, no3_obs, fet_obs, si_obs
#endif
c
       _RL   fice(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx, nSy)
       _RL   inputFe(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx, nSy)
       _RL   sur_par(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx, nSy)
#ifdef NUT_SUPPLY
       _RL   nut_wvel(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy)
#endif
#ifdef RELAX_NUTS
       _RL   po4_obs(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy)
       _RL   no3_obs(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy)
       _RL   fet_obs(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy)
       _RL   si_obs(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy)
#endif


c
c OUPUT DIAGNOSTICS
c    PPave        - average primary production
c    Nfixave      - average N fixation
c    Zoograzave   - average zooplankton consumption
c    Parave       - average PAR
c    Chlave       - average chlorophyll
c    npzd_timeave  - time for averaging

      COMMON /DARWIN_OUPUT/
     &      PPave, Nfixave, Zoograzave,
     &      PARave, Chlave, 
#ifdef DAR_DIAG_RSTAR
     &      Rstarave, RNstarave,
#endif
#ifdef DAR_DIAG_DIVER
     &      Diver1ave, Diver2ave, Diver3ave, Diver4ave,
#endif
     &      dar_timeave,
     &      DAR_cons_unit1, DAR_cons_unit2,
     &      DAR_cons_unit3, DAR_cons_unit4
c  
       _RL  PPave(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy)
       _RL  Nfixave(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy)
       _RL  Zoograzave(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy)
       _RL  PARave(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy)
       _RL  Chlave(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy)
#ifdef DAR_DIAG_RSTAR
       _RL  Rstarave(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy,npmax)
       _RL  RNstarave(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy,npmax)
#endif
#ifdef DAR_DIAG_DIVER
       _RL  Diver1ave(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy)
       _RL  Diver2ave(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy)
       _RL  Diver3ave(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy)
       _RL  Diver4ave(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy)
#endif
       _RL  DAR_timeave(nSx,nSy,nR)
       INTEGER DAR_cons_unit1
       INTEGER DAR_cons_unit2
       INTEGER DAR_cons_unit3
       INTEGER DAR_cons_unit4

#ifdef GEIDER
      COMMON /DARWIN_CHL/
     &      Chl_phy          
         _RL Chl_phy(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy,npmax)
#endif
