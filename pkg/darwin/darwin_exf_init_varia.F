#include "DARWIN_OPTIONS.h"
#include "EXF_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: DARWIN_EXF_INIT_VARIA

C     !INTERFACE:
      SUBROUTINE DARWIN_EXF_INIT_VARIA( myThid )

C     !DESCRIPTION:
C     Initialize DARWIN constants

C     !USES:
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#include "GRID.h"
#include "PARAMS.h"
#ifdef ALLOW_EXF
#include "EXF_INTERP_SIZE.h"
#endif
#include "DARWIN_SIZE.h"
#include "DARWIN_EXF_PARAMS.h"
#include "DARWIN_EXF_FIELDS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_DARWIN
#ifdef ALLOW_EXF

#ifdef ALLOW_RADTRANS
      INTEGER l
#endif

C     these load constant forcing fields

      call exf_init_fld (
     &     'PAR', PARfile, PARmask,
     &     PARperiod, darwin_inscal_PAR, PARconst,
     &     surfPAR, PAR0, PAR1,
#ifdef USE_EXF_INTERPOLATION
     &     PAR_lon0, PAR_lon_inc,
     &     PAR_lat0, PAR_lat_inc,
     &     PAR_nlon, PAR_nlat, xC, yC, PAR_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'iron', ironfile, ironmask,
     &     ironperiod, darwin_inscal_iron, ironconst,
     &     inputFe, iron0, iron1,
#ifdef USE_EXF_INTERPOLATION
     &     iron_lon0, iron_lon_inc,
     &     iron_lat0, iron_lat_inc,
     &     iron_nlon, iron_nlat, xC, yC, iron_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'ice', icefile, icemask,
     &     iceperiod, darwin_inscal_ice, iceconst,
     &     iceFrac, ice0, ice1,
#ifdef USE_EXF_INTERPOLATION
     &     ice_lon0, ice_lon_inc,
     &     ice_lat0, ice_lat_inc,
     &     ice_nlon, ice_nlat, xC, yC, ice_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'wind', windfile, windmask,
     &     windperiod, darwin_inscal_wind, windconst,
     &     windSpeed, wind0, wind1,
#ifdef USE_EXF_INTERPOLATION
     &     wind_lon0, wind_lon_inc,
     &     wind_lat0, wind_lat_inc,
     &     wind_nlon, wind_nlat, xC, yC, wind_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'pCO2', pCO2file, pCO2mask,
     &     pCO2period, darwin_inscal_pCO2, pCO2const,
     &     atmospCO2, pCO20, pCO21,
#ifdef USE_EXF_INTERPOLATION
     &     pCO2_lon0, pCO2_lon_inc,
     &     pCO2_lat0, pCO2_lat_inc,
     &     pCO2_nlon, pCO2_nlat, xC, yC, pCO2_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'DOCrunoff', DOCrunofffile, DOCrunoffmask,
     &     DOCrunoffperiod, darwin_inscal_DOCrunoff,
     &     DOCrunoffconst,
     &     DOCrunoff, DOCrunoff0, DOCrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     DOCrunoff_lon0, DOCrunoff_lon_inc,
     &     DOCrunoff_lat0, DOCrunoff_lat_inc,
     &     DOCrunoff_nlon, DOCrunoff_nlat, xC, yC,
     &     DOCrunoff_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'DONrunoff', DONrunofffile, DONrunoffmask,
     &     DONrunoffperiod, darwin_inscal_DONrunoff,
     &     DONrunoffconst,
     &     DONrunoff, DONrunoff0, DONrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     DONrunoff_lon0, DONrunoff_lon_inc,
     &     DONrunoff_lat0, DONrunoff_lat_inc,
     &     DONrunoff_nlon, DONrunoff_nlat, xC, yC,
     &     DONrunoff_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'DONrunoff', DOPrunofffile, DOPrunoffmask,
     &     DOPrunoffperiod, darwin_inscal_DOPrunoff,
     &     DOPrunoffconst,
     &     DOPrunoff, DOPrunoff0, DOPrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     DOPrunoff_lon0, DOPrunoff_lon_inc,
     &     DOPrunoff_lat0, DOPrunoff_lat_inc,
     &     DOPrunoff_nlon, DOPrunoff_nlat, xC, yC,
     &     DOPrunoff_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'DINrunoff', DINrunofffile, DINrunoffmask,
     &     DINrunoffperiod, darwin_inscal_DINrunoff,
     &     DINrunoffconst,
     &     DINrunoff, DINrunoff0, DINrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     DINrunoff_lon0, DINrunoff_lon_inc,
     &     DINrunoff_lat0, DINrunoff_lat_inc,
     &     DINrunoff_nlon, DINrunoff_nlat, xC, yC,
     &     DINrunoff_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'IPrunoff', IPrunofffile, IPrunoffmask,
     &     IPrunoffperiod, darwin_inscal_IPrunoff,
     &     IPrunoffconst,
     &     IPrunoff, IPrunoff0, IPrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     IPrunoff_lon0, IPrunoff_lon_inc,
     &     IPrunoff_lat0, IPrunoff_lat_inc,
     &     IPrunoff_nlon, IPrunoff_nlat, xC, yC,
     &     IPrunoff_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'DSirunoff', DSirunofffile, DSirunoffmask,
     &     DSirunoffperiod, darwin_inscal_DSirunoff,
     &     DSirunoffconst,
     &     DSirunoff, DSirunoff0, DSirunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     DSirunoff_lon0, DSirunoff_lon_inc,
     &     DSirunoff_lat0, DSirunoff_lat_inc,
     &     DSirunoff_nlon, DSirunoff_nlat, xC, yC,
     &     DSirunoff_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'POCrunoff', POCrunofffile, POCrunoffmask,
     &     POCrunoffperiod, darwin_inscal_POCrunoff,
     &     POCrunoffconst,
     &     POCrunoff, POCrunoff0, POCrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     POCrunoff_lon0, POCrunoff_lon_inc,
     &     POCrunoff_lat0, POCrunoff_lat_inc,
     &     POCrunoff_nlon, POCrunoff_nlat, xC, yC,
     &     POCrunoff_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'POPrunoff', POPrunofffile, POPrunoffmask,
     &     POPrunoffperiod, darwin_inscal_POPrunoff,
     &     POPrunoffconst,
     &     POPrunoff, POPrunoff0, POPrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     POPrunoff_lon0, POPrunoff_lon_inc,
     &     POPrunoff_lat0, POPrunoff_lat_inc,
     &     POPrunoff_nlon, POPrunoff_nlat, xC, yC,
     &     POPrunoff_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'PONrunoff', PONrunofffile, PONrunoffmask,
     &     PONrunoffperiod, darwin_inscal_PONrunoff,
     &     PONrunoffconst,
     &     PONrunoff, PONrunoff0, PONrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     PONrunoff_lon0, PONrunoff_lon_inc,
     &     PONrunoff_lat0, PONrunoff_lat_inc,
     &     PONrunoff_nlon, PONrunoff_nlat, xC, yC,
     &     PONrunoff_interpMethod,
#endif
     &     mythid )

      call exf_init_fld (
     &     'DICrunoff', DICrunofffile, DICrunoffmask,
     &     DICrunoffperiod, darwin_inscal_DICrunoff,
     &     DICrunoffconst,
     &     DICrunoff, DICrunoff0, DICrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     DICrunoff_lon0, DICrunoff_lon_inc,
     &     DICrunoff_lat0, DICrunoff_lat_inc,
     &     DICrunoff_nlon, DICrunoff_nlat, xC, yC,
     &     DICrunoff_interpMethod,
#endif
     &     mythid )

      IF (darwin_loadFieldsEarly) THEN
C       these load time-varying forcing fields
C       (usually done in darwin_fields_load, but may be needed for chl)
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
     &     starttime, nIter0, mythid )

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
     &     starttime, nIter0, mythid )

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
     &     starttime, nIter0, mythid )

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
     &     starttime, nIter0, mythid )

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
     &     starttime, nIter0, mythid )

        call exf_set_fld(
     &     'DOCrunoff', DOCrunofffile, DOCrunoffmask,
     &     DOCrunoffStartTime, DOCrunoffperiod, DOCrunoffRepCycle,
     &     darwin_inscal_DOCrunoff,
     &     DOCrunoff_exfremo_intercept, DOCrunoff_exfremo_slope,
     &     DOCrunoff, DOCrunoff0, DOCrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     DOCrunoff_lon0, DOCrunoff_lon_inc,
     &     DOCrunoff_lat0, DOCrunoff_lat_inc,
     &     DOCrunoff_nlon, DOCrunoff_nlat, xC, yC,
     &     DOCrunoff_interpMethod,
#endif
     &     starttime, nIter0, mythid )

        call exf_set_fld(
     &     'DONrunoff', DONrunofffile, DONrunoffmask,
     &     DONrunoffStartTime, DONrunoffperiod, DONrunoffRepCycle,
     &     darwin_inscal_DONrunoff,
     &     DONrunoff_exfremo_intercept, DONrunoff_exfremo_slope,
     &     DONrunoff, DONrunoff0, DONrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     DONrunoff_lon0, DONrunoff_lon_inc,
     &     DONrunoff_lat0, DONrunoff_lat_inc,
     &     DONrunoff_nlon, DONrunoff_nlat, xC, yC,
     &     DONrunoff_interpMethod,
#endif
     &     starttime, nIter0, mythid )

        call exf_set_fld(
     &     'DOPrunoff', DOPrunofffile, DOPrunoffmask,
     &     DOPrunoffStartTime, DOPrunoffperiod, DOPrunoffRepCycle,
     &     darwin_inscal_DOPrunoff,
     &     DOPrunoff_exfremo_intercept, DOPrunoff_exfremo_slope,
     &     DOPrunoff, DOPrunoff0, DOPrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     DOPrunoff_lon0, DOPrunoff_lon_inc,
     &     DOPrunoff_lat0, DOPrunoff_lat_inc,
     &     DOPrunoff_nlon, DOPrunoff_nlat, xC, yC,
     &     DOPrunoff_interpMethod,
#endif
     &     starttime, nIter0, mythid )

        call exf_set_fld(
     &     'DINrunoff', DINrunofffile, DINrunoffmask,
     &     DINrunoffStartTime, DINrunoffperiod, DINrunoffRepCycle,
     &     darwin_inscal_DINrunoff,
     &     DINrunoff_exfremo_intercept, DINrunoff_exfremo_slope,
     &     DINrunoff, DINrunoff0, DINrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     DINrunoff_lon0, DINrunoff_lon_inc,
     &     DINrunoff_lat0, DINrunoff_lat_inc,
     &     DINrunoff_nlon, DINrunoff_nlat, xC, yC,
     &     DINrunoff_interpMethod,
#endif
     &     starttime, nIter0, mythid )

        call exf_set_fld(
     &     'IPrunoff', IPrunofffile, IPrunoffmask,
     &     IPrunoffStartTime, IPrunoffperiod, IPrunoffRepCycle,
     &     darwin_inscal_IPrunoff,
     &     IPrunoff_exfremo_intercept, IPrunoff_exfremo_slope,
     &     IPrunoff, IPrunoff0, IPrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     IPrunoff_lon0, IPrunoff_lon_inc,
     &     IPrunoff_lat0, IPrunoff_lat_inc,
     &     IPrunoff_nlon, IPrunoff_nlat, xC, yC,
     &     IPrunoff_interpMethod,
#endif
     &     starttime, nIter0, mythid )

        call exf_set_fld(
     &     'DSirunoff', DSirunofffile, DSirunoffmask,
     &     DSirunoffStartTime, DSirunoffperiod, DSirunoffRepCycle,
     &     darwin_inscal_DSirunoff,
     &     DSirunoff_exfremo_intercept, DSirunoff_exfremo_slope,
     &     DSirunoff, DSirunoff0, DSirunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     DSirunoff_lon0, DSirunoff_lon_inc,
     &     DSirunoff_lat0, DSirunoff_lat_inc,
     &     DSirunoff_nlon, DSirunoff_nlat, xC, yC,
     &     DSirunoff_interpMethod,
#endif
     &     starttime, nIter0, mythid )

        call exf_set_fld(
     &     'POCrunoff', POCrunofffile, POCrunoffmask,
     &     POCrunoffStartTime, POCrunoffperiod, POCrunoffRepCycle,
     &     darwin_inscal_POCrunoff,
     &     POCrunoff_exfremo_intercept, POCrunoff_exfremo_slope,
     &     POCrunoff, POCrunoff0, POCrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     POCrunoff_lon0, POCrunoff_lon_inc,
     &     POCrunoff_lat0, POCrunoff_lat_inc,
     &     POCrunoff_nlon, POCrunoff_nlat, xC, yC,
     &     POCrunoff_interpMethod,
#endif
     &     starttime, nIter0, mythid )

        call exf_set_fld(
     &     'POPrunoff', POPrunofffile, POPrunoffmask,
     &     POPrunoffStartTime, POPrunoffperiod, POPrunoffRepCycle,
     &     darwin_inscal_POPrunoff,
     &     POPrunoff_exfremo_intercept, POPrunoff_exfremo_slope,
     &     POPrunoff, POPrunoff0, POPrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     POPrunoff_lon0, POPrunoff_lon_inc,
     &     POPrunoff_lat0, POPrunoff_lat_inc,
     &     POPrunoff_nlon, POPrunoff_nlat, xC, yC,
     &     POPrunoff_interpMethod,
#endif
     &     starttime, nIter0, mythid )

        call exf_set_fld(
     &     'PONrunoff', PONrunofffile, PONrunoffmask,
     &     PONrunoffStartTime, PONrunoffperiod, PONrunoffRepCycle,
     &     darwin_inscal_PONrunoff,
     &     PONrunoff_exfremo_intercept, PONrunoff_exfremo_slope,
     &     PONrunoff, PONrunoff0, PONrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     PONrunoff_lon0, PONrunoff_lon_inc,
     &     PONrunoff_lat0, PONrunoff_lat_inc,
     &     PONrunoff_nlon, PONrunoff_nlat, xC, yC,
     &     PONrunoff_interpMethod,
#endif
     &     starttime, nIter0, mythid )

        call exf_set_fld(
     &     'DICrunoff', DICrunofffile, DICrunoffmask,
     &     DICrunoffStartTime, DICrunoffperiod, DICrunoffRepCycle,
     &     darwin_inscal_DICrunoff,
     &     DICrunoff_exfremo_intercept, DICrunoff_exfremo_slope,
     &     DICrunoff, DICrunoff0, DICrunoff1,
#ifdef USE_EXF_INTERPOLATION
     &     DICrunoff_lon0, DICrunoff_lon_inc,
     &     DICrunoff_lat0, DICrunoff_lat_inc,
     &     DICrunoff_nlon, DICrunoff_nlat, xC, yC,
     &     DICrunoff_interpMethod,
#endif
     &     starttime, nIter0, mythid )

        _EXCH_XY_RL( surfPAR, myThid )

        _EXCH_XY_RL( inputFe, myThid )

        _EXCH_XY_RL( iceFrac, myThid )

        _EXCH_XY_RL( windSpeed, myThid )

        _EXCH_XY_RL( atmospCO2, myThid )

        _EXCH_XY_RL( DOCrunoff, myThid )

        _EXCH_XY_RL( DONrunoff, myThid )

        _EXCH_XY_RL( DOPrunoff, myThid )

        _EXCH_XY_RL( DINrunoff, myThid )

        _EXCH_XY_RL( IPrunoff, myThid )

        _EXCH_XY_RL( DSirunoff, myThid )

        _EXCH_XY_RL( POCrunoff, myThid )

        _EXCH_XY_RL( POPrunoff, myThid )

        _EXCH_XY_RL( PONrunoff, myThid )

        _EXCH_XY_RL( DICrunoff, myThid )

      ENDIF

#endif /* ALLOW_EXF */
#endif /* ALLOW_DARWIN */

      RETURN
      END
