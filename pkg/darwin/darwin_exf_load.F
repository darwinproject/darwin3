#include "DARWIN_OPTIONS.h"
#include "EXF_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_EXF_LOAD

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_EXF_LOAD( mytime, myiter, mythid )

C !DESCRIPTION:
C     Load and interpolate forcing fields for darwin package

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#ifdef ALLOW_EXF
#include "EXF_INTERP_SIZE.h"
#endif
#include "DARWIN_SIZE.h"
#include "DARWIN_EXF_PARAMS.h"
#include "DARWIN_EXF_FIELDS.h"

C !INPUT PARAMETERS: ===================================================
      _RL     mytime
      integer myiter
      integer mythid
CEOP

#ifdef ALLOW_DARWIN
#ifdef ALLOW_EXF

C !LOCAL VARIABLES: ====================================================
#ifdef ALLOW_RADTRANS
      INTEGER l
#endif

c--   read forcing fields from files and temporal interpolation

      IF (.NOT.(darwin_loadFieldsEarly.AND.myiter.EQ.niter0)) THEN

       call exf_set_fld(
     &     'PAR', PARfile, PARmask,
     &     PARStartTime, PARperiod, PARRepCycle,
     &     darwin_inscal_PAR,
     &     PAR_exfremo_intercept, PAR_exfremo_slope,
     &     surfPAR, PAR0, PAR1,
#ifdef USE_EXF_INTERPOLATION
     &     PAR_lon0, PAR_lon_inc,
     &     PAR_lat0, PAR_lat_inc,
     &     PAR_nlon, PAR_nlat, xC, yC, PAR_interpMethod,
#endif
     &     mytime, myiter, mythid )

       call exf_set_fld(
     &     'iron', ironfile, ironmask,
     &     ironStartTime, ironperiod, ironRepCycle,
     &     darwin_inscal_iron,
     &     iron_exfremo_intercept, iron_exfremo_slope,
     &     inputFe, iron0, iron1,
#ifdef USE_EXF_INTERPOLATION
     &     iron_lon0, iron_lon_inc,
     &     iron_lat0, iron_lat_inc,
     &     iron_nlon, iron_nlat, xC, yC, iron_interpMethod,
#endif
     &     mytime, myiter, mythid )

       call exf_set_fld(
     &     'ice', icefile, icemask,
     &     iceStartTime, iceperiod, iceRepCycle,
     &     darwin_inscal_ice,
     &     ice_exfremo_intercept, ice_exfremo_slope,
     &     iceFrac, ice0, ice1,
#ifdef USE_EXF_INTERPOLATION
     &     ice_lon0, ice_lon_inc,
     &     ice_lat0, ice_lat_inc,
     &     ice_nlon, ice_nlat, xC, yC, ice_interpMethod,
#endif
     &     mytime, myiter, mythid )

       call exf_set_fld(
     &     'wind', windfile, windmask,
     &     windStartTime, windperiod, windRepCycle,
     &     darwin_inscal_wind,
     &     wind_exfremo_intercept, wind_exfremo_slope,
     &     windSpeed, wind0, wind1,
#ifdef USE_EXF_INTERPOLATION
     &     wind_lon0, wind_lon_inc,
     &     wind_lat0, wind_lat_inc,
     &     wind_nlon, wind_nlat, xC, yC, wind_interpMethod,
#endif
     &     mytime, myiter, mythid )

       call exf_set_fld(
     &     'pCO2', pCO2file, pCO2mask,
     &     pCO2StartTime, pCO2period, pCO2RepCycle,
     &     darwin_inscal_pCO2,
     &     pCO2_exfremo_intercept, pCO2_exfremo_slope,
     &     atmospCO2, pCO20, pCO21,
#ifdef USE_EXF_INTERPOLATION
     &     pCO2_lon0, pCO2_lon_inc,
     &     pCO2_lat0, pCO2_lat_inc,
     &     pCO2_nlon, pCO2_nlat, xC, yC, pCO2_interpMethod,
#endif
     &     mytime, myiter, mythid )

        _EXCH_XY_RL( surfPAR, myThid )

        _EXCH_XY_RL( inputFe, myThid )

        _EXCH_XY_RL( iceFrac, myThid )

        _EXCH_XY_RL( windSpeed, myThid )

        _EXCH_XY_RL( atmospCO2, myThid )
      ENDIF

#endif /* ALLOW_EXF */
#endif /* ALLOW_DARWIN */

      RETURN
      END
