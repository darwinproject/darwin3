#include "RADTRANS_OPTIONS.h"
#include "EXF_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: RADTRANS_INIT_VARIA

C     !INTERFACE:
      SUBROUTINE RADTRANS_INIT_VARIA( myThid )

C     !DESCRIPTION:
C     Initialize radtrans constants

C     !USES:
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#include "GRID.h"
#include "PARAMS.h"
#include "EXF_INTERP_SIZE.h"
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"
#include "RADTRANS_EXF_PARAMS.h"
#include "RADTRANS_FIELDS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_RADTRANS
#ifdef ALLOW_EXF

      INTEGER l
      CHARACTER*8 fld

C     these load constant forcing fields

      DO l = 1, nlam
       WRITE(fld,'(A,I3.3)') 'RT_Ed', l
       CALL exf_init_fld (
     &     fld, RT_Edfile(l), RT_E_mask,
     &     RT_E_period, RT_inscal_Ed(l), RT_Ed_const(l),
     &     RT_Ed_sfc(1-OLx,1-OLy,1,1,l),
     &     RT_Ed0(1-OLx,1-OLy,1,1,l),
     &     RT_Ed1(1-OLx,1-OLy,1,1,l),
#ifdef USE_EXF_INTERPOLATION
     &     RT_E_lon0, RT_E_lon_inc,
     &     RT_E_lat0, RT_E_lat_inc,
     &     RT_E_nlon, RT_E_nlat, xC, yC, RT_E_interpMethod,
#endif
     &     mythid )

       WRITE(fld,'(A,I3.3)') 'RT_Es', l
       CALL exf_init_fld (
     &     fld, RT_Esfile(l), RT_E_mask,
     &     RT_E_period, RT_inscal_Es(l), RT_Es_const(l),
     &     RT_Es_sfc(1-OLx,1-OLy,1,1,l),
     &     RT_Es0(1-OLx,1-OLy,1,1,l),
     &     RT_Es1(1-OLx,1-OLy,1,1,l),
#ifdef USE_EXF_INTERPOLATION
     &     RT_E_lon0, RT_E_lon_inc,
     &     RT_E_lat0, RT_E_lat_inc,
     &     RT_E_nlon, RT_E_nlat, xC, yC, RT_E_interpMethod,
#endif
     &     mythid )
      ENDDO

      CALL exf_init_fld (
     &     'RT_ice', RT_icefile, RT_icemask,
     &     RT_iceperiod, RT_inscal_ice, RT_iceconst,
     &     RT_iceFrac, RT_ice0, RT_ice1,
#ifdef USE_EXF_INTERPOLATION
     &     RT_ice_lon0, RT_ice_lon_inc,
     &     RT_ice_lat0, RT_ice_lat_inc,
     &     RT_ice_nlon, RT_ice_nlat, xC, yC, RT_ice_interpMethod,
#endif
     &     mythid )


      IF (RT_loadFieldsEarly) THEN
       DO l = 1, nlam
        WRITE(fld,'(A,I3.3)') 'RT_Ed', l
        CALL exf_set_fld(
     &     fld, RT_Edfile(l), RT_E_mask,
     &     RT_E_StartTime, RT_E_period, RT_E_RepCycle,
     &     RT_inscal_Ed(l),
     &     RT_Ed_exfremo_intercept(l), RT_Ed_exfremo_slope(l),
     &     RT_Ed_sfc(1-OLx,1-OLy,1,1,l),
     &     RT_Ed0(1-OLx,1-OLy,1,1,l),
     &     RT_Ed1(1-OLx,1-OLy,1,1,l),
#ifdef USE_EXF_INTERPOLATION
     &     RT_E_lon0, RT_E_lon_inc,
     &     RT_E_lat0, RT_E_lat_inc,
     &     RT_E_nlon, RT_E_nlat, xC, yC, RT_E_interpMethod,
#endif
     &     starttime, nIter0, mythid )

        WRITE(fld,'(A,I3.3)') 'RT_Es', l
        CALL exf_set_fld(
     &     fld, RT_Esfile(l), RT_E_mask,
     &     RT_E_StartTime, RT_E_period, RT_E_RepCycle,
     &     RT_inscal_Es(l),
     &     RT_Es_exfremo_intercept(l), RT_Es_exfremo_slope(l),
     &     RT_Es_sfc(1-OLx,1-OLy,1,1,l),
     &     RT_Es0(1-OLx,1-OLy,1,1,l),
     &     RT_Es1(1-OLx,1-OLy,1,1,l),
#ifdef USE_EXF_INTERPOLATION
     &     RT_E_lon0, RT_E_lon_inc,
     &     RT_E_lat0, RT_E_lat_inc,
     &     RT_E_nlon, RT_E_nlat, xC, yC, RT_E_interpMethod,
#endif
     &     starttime, nIter0, mythid )
       ENDDO

C      these load time-varying forcing fields
C      (usually done in RT_fields_load, but may be needed for chl)
       CALL exf_set_fld(
     &     'RT_ice', RT_icefile, RT_icemask,
     &     RT_iceStartTime, RT_iceperiod, RT_iceRepCycle,
     &     RT_inscal_ice,
     &     RT_ice_exfremo_intercept, RT_ice_exfremo_slope,
     &     RT_iceFrac, RT_ice0, RT_ice1,
#ifdef USE_EXF_INTERPOLATION
     &     RT_ice_lon0, RT_ice_lon_inc,
     &     RT_ice_lat0, RT_ice_lat_inc,
     &     RT_ice_nlon, RT_ice_nlat, xC, yC, RT_ice_interpMethod,
#endif
     &     starttime, nIter0, mythid )

       DO l = 1, nlam
        _EXCH_XY_RL( RT_Ed_sfc(1-OLx,1-OLy,1,1,l), myThid )
        _EXCH_XY_RL( RT_Es_sfc(1-OLx,1-OLy,1,1,l), myThid )
       ENDDO
       _EXCH_XY_RL( RT_iceFrac, myThid )

C     endif RT_loadFieldsEarly
      ENDIF

#endif /* ALLOW_EXF */
#endif /* ALLOW_RADTRANS */

      RETURN
      END
