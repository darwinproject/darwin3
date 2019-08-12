#include "RADTRANS_OPTIONS.h"
#include "EXF_OPTIONS.h"

CBOP
C !ROUTINE: RADTRANS_FIELDS_LOAD

C !INTERFACE: ==========================================================
      SUBROUTINE RADTRANS_FIELDS_LOAD( mytime, myiter, mythid )

C !DESCRIPTION:
C     Load and interpolate forcing fields for radtrans package

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "EXF_INTERP_SIZE.h"
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"
#include "RADTRANS_EXF_PARAMS.h"
#include "RADTRANS_FIELDS.h"

C !INPUT PARAMETERS: ===================================================
      _RL     mytime
      integer myiter
      integer mythid
CEOP

#ifdef ALLOW_RADTRANS

C !LOCAL VARIABLES: ====================================================
      INTEGER bi,bj
      INTEGER i,j,k,l
      CHARACTER*8 fld

#ifdef ALLOW_EXF
c--   read forcing fields from files and temporal interpolation

      IF (.NOT.(RT_loadFieldsEarly.AND.myiter.EQ.niter0)) THEN
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
     &     mytime, myiter, mythid )

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
     &     mytime, myiter, mythid )
       ENDDO

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
     &     mytime, myiter, mythid )

       DO l = 1, nlam
        _EXCH_XY_RL( RT_Ed_sfc(1-OLx,1-OLy,1,1,l), myThid )
        _EXCH_XY_RL( RT_Es_sfc(1-OLx,1-OLy,1,1,l), myThid )
       ENDDO
       _EXCH_XY_RL( RT_iceFrac, myThid )

C     endif .NOT.(RT_loadFieldsEarly.AND.myiter.EQ.niter0)
      ENDIF

      CALL RADTRANS_MONITOR(myTime, myIter, myThid)

#ifdef ALLOW_DIAGNOSTICS
      IF (useDIAGNOSTICS) THEN
       CALL DIAGNOSTICS_FILL(RT_iceFrac,'RTice   ',0,1,0,0,0,myThid)
      ENDIF
#endif /* ALLOW_DIAGNOSTICS */

#endif /* ALLOW_EXF */

#endif /* ALLOW_RADTRANS */

      RETURN
      END
