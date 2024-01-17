#include "OASIM_OPTIONS.h"
#ifdef ALLOW_EXF
#include "EXF_OPTIONS.h"
#endif

CBOP
C !ROUTINE: OASIM_EXF_LOAD

C !INTERFACE: ==========================================================
      SUBROUTINE OASIM_EXF_LOAD( mytime, myiter, mythid )

C !DESCRIPTION:
C     Load and interpolate forcing fields for oasim package

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#ifdef ALLOW_EXF
#include "EXF_INTERP_SIZE.h"
#endif
#include "OASIM_SIZE.h"
#include "OASIM_EXF_PARAMS.h"
#include "OASIM_FIELDS.h"

C !INPUT PARAMETERS: ===================================================
      _RL     mytime
      integer myiter
      integer mythid
CEOP

#ifdef ALLOW_OASIM
#ifdef ALLOW_EXF

C !LOCAL VARIABLES: ====================================================
C     !FUNCTIONS:
      INTEGER  ILNBLNK
      EXTERNAL ILNBLNK

      CHARACTER*(MAX_LEN_FNAM) fnam
      INTEGER l, il

c--   read forcing fields from files and temporal interpolation

      il = ILNBLNK( aerTaufile )
      DO l=1,nlt
        WRITE(fnam,'(A,I3.3)') aerTauFile(1:il), l
        CALL oasim_set_fld (
     &      'aerTau', fnam, aerTaumask,
     &      aerTauStartTime, aerTauperiod, aerTauRepCycle,
     &      oasim_timeInterp, aerTau_inscal(l),
     &      aerTau_exfremo_intercept(l), aerTau_exfremo_slope(l),
     &      taua(1-OLx,1-OLy,1,1,l),
     &      aerTau0(1-OLx,1-OLy,1,1,l),
     &      aerTau1(1-OLx,1-OLy,1,1,l),
#ifdef USE_EXF_INTERPOLATION
     &      aerTau_lon0, aerTau_lon_inc,
     &      aerTau_lat0, aerTau_lat_inc,
     &      aerTau_nlon, aerTau_nlat, xC, yC, aerTau_interpMethod,
#endif
     &      mytime, myiter, mythid )
      ENDDO

      il = ILNBLNK( asympfile )
      DO l=1,nlt
        WRITE(fnam,'(A,I3.3)') asympFile(1:il), l
        CALL oasim_set_fld (
     &      'asymp', fnam, asympmask,
     &      asympStartTime, asympperiod, asympRepCycle,
     &      oasim_timeInterp, asymp_inscal(l),
     &      asymp_exfremo_intercept(l), asymp_exfremo_slope(l),
     &      asymp(1-OLx,1-OLy,1,1,l),
     &      asymp0(1-OLx,1-OLy,1,1,l),
     &      asymp1(1-OLx,1-OLy,1,1,l),
#ifdef USE_EXF_INTERPOLATION
     &      asymp_lon0, asymp_lon_inc,
     &      asymp_lat0, asymp_lat_inc,
     &      asymp_nlon, asymp_nlat, xC, yC, asymp_interpMethod,
#endif
     &      mytime, myiter, mythid )
      ENDDO

      il = ILNBLNK( ssalbfile )
      DO l=1,nlt
        WRITE(fnam,'(A,I3.3)') ssalbFile(1:il), l
        CALL oasim_set_fld (
     &      'ssalb', fnam, ssalbmask,
     &      ssalbStartTime, ssalbperiod, ssalbRepCycle,
     &      oasim_timeInterp, ssalb_inscal(l),
     &      ssalb_exfremo_intercept(l), ssalb_exfremo_slope(l),
     &      ssalb(1-OLx,1-OLy,1,1,l),
     &      ssalb0(1-OLx,1-OLy,1,1,l),
     &      ssalb1(1-OLx,1-OLy,1,1,l),
#ifdef USE_EXF_INTERPOLATION
     &      ssalb_lon0, ssalb_lon_inc,
     &      ssalb_lat0, ssalb_lat_inc,
     &      ssalb_nlon, ssalb_nlat, xC, yC, ssalb_interpMethod,
#endif
     &      mytime, myiter, mythid )
      ENDDO

      call oasim_set_fld(
     &     'cldcov', cldcovfile, cldcovmask,
     &     cldcovStartTime, cldcovperiod, cldcovRepCycle,
     &     oasim_timeInterp, cldcov_inscal,
     &     cldcov_exfremo_intercept, cldcov_exfremo_slope,
     &     ccov, cldcov0, cldcov1,
#ifdef USE_EXF_INTERPOLATION
     &     cldcov_lon0, cldcov_lon_inc,
     &     cldcov_lat0, cldcov_lat_inc,
     &     cldcov_nlon, cldcov_nlat, xC, yC, cldcov_interpMethod,
#endif
     &     mytime, myiter, mythid )

      call oasim_set_fld(
     &     'cldlwp', cldlwpfile, cldlwpmask,
     &     cldlwpStartTime, cldlwpperiod, cldlwpRepCycle,
     &     oasim_timeInterp, cldlwp_inscal,
     &     cldlwp_exfremo_intercept, cldlwp_exfremo_slope,
     &     rlwp, cldlwp0, cldlwp1,
#ifdef USE_EXF_INTERPOLATION
     &     cldlwp_lon0, cldlwp_lon_inc,
     &     cldlwp_lat0, cldlwp_lat_inc,
     &     cldlwp_nlon, cldlwp_nlat, xC, yC, cldlwp_interpMethod,
#endif
     &     mytime, myiter, mythid )

      call oasim_set_fld(
     &     'cldre', cldrefile, cldremask,
     &     cldreStartTime, cldreperiod, cldreRepCycle,
     &     oasim_timeInterp, cldre_inscal,
     &     cldre_exfremo_intercept, cldre_exfremo_slope,
     &     cdre, cldre0, cldre1,
#ifdef USE_EXF_INTERPOLATION
     &     cldre_lon0, cldre_lon_inc,
     &     cldre_lat0, cldre_lat_inc,
     &     cldre_nlon, cldre_nlat, xC, yC, cldre_interpMethod,
#endif
     &     mytime, myiter, mythid )

      call oasim_set_fld(
     &     'pres', presfile, presmask,
     &     presStartTime, presperiod, presRepCycle,
     &     oasim_timeInterp, pres_inscal,
     &     pres_exfremo_intercept, pres_exfremo_slope,
     &     slp, pres0, pres1,
#ifdef USE_EXF_INTERPOLATION
     &     pres_lon0, pres_lon_inc,
     &     pres_lat0, pres_lat_inc,
     &     pres_nlon, pres_nlat, xC, yC, pres_interpMethod,
#endif
     &     mytime, myiter, mythid )

      call oasim_set_fld(
     &     'oawind', oawindfile, oawindmask,
     &     oawindStartTime, oawindperiod, oawindRepCycle,
     &     oasim_timeInterp, oawind_inscal,
     &     oawind_exfremo_intercept, oawind_exfremo_slope,
     &     wsm, oawind0, oawind1,
#ifdef USE_EXF_INTERPOLATION
     &     oawind_lon0, oawind_lon_inc,
     &     oawind_lat0, oawind_lat_inc,
     &     oawind_nlon, oawind_nlat, xC, yC, oawind_interpMethod,
#endif
     &     mytime, myiter, mythid )

      call oasim_set_fld(
     &     'relhum', relhumfile, relhummask,
     &     relhumStartTime, relhumperiod, relhumRepCycle,
     &     oasim_timeInterp, relhum_inscal,
     &     relhum_exfremo_intercept, relhum_exfremo_slope,
     &     rh, relhum0, relhum1,
#ifdef USE_EXF_INTERPOLATION
     &     relhum_lon0, relhum_lon_inc,
     &     relhum_lat0, relhum_lat_inc,
     &     relhum_nlon, relhum_nlat, xC, yC, relhum_interpMethod,
#endif
     &     mytime, myiter, mythid )

      call oasim_set_fld(
     &     'ozone', ozonefile, ozonemask,
     &     ozoneStartTime, ozoneperiod, ozoneRepCycle,
     &     oasim_timeInterp, ozone_inscal,
     &     ozone_exfremo_intercept, ozone_exfremo_slope,
     &     oz, ozone0, ozone1,
#ifdef USE_EXF_INTERPOLATION
     &     ozone_lon0, ozone_lon_inc,
     &     ozone_lat0, ozone_lat_inc,
     &     ozone_nlon, ozone_nlat, xC, yC, ozone_interpMethod,
#endif
     &     mytime, myiter, mythid )

      call oasim_set_fld(
     &     'wv', wvfile, wvmask,
     &     wvStartTime, wvperiod, wvRepCycle,
     &     oasim_timeInterp, wv_inscal,
     &     wv_exfremo_intercept, wv_exfremo_slope,
     &     wv, wv0, wv1,
#ifdef USE_EXF_INTERPOLATION
     &     wv_lon0, wv_lon_inc,
     &     wv_lat0, wv_lat_inc,
     &     wv_nlon, wv_nlat, xC, yC, wv_interpMethod,
#endif
     &     mytime, myiter, mythid )

      _EXCH_XY_RL( taua, myThid )
      _EXCH_XY_RL( asymp, myThid )
      _EXCH_XY_RL( ssalb, myThid )
      _EXCH_XY_RL( ccov, myThid )
      _EXCH_XY_RL( rlwp, myThid )
      _EXCH_XY_RL( cdre, myThid )
      _EXCH_XY_RL( slp, myThid )
      _EXCH_XY_RL( wsm, myThid )
      _EXCH_XY_RL( rh, myThid )
      _EXCH_XY_RL( oz, myThid )
      _EXCH_XY_RL( wv, myThid )

#endif /* ALLOW_EXF */
#endif /* ALLOW_OASIM */

      RETURN
      END
