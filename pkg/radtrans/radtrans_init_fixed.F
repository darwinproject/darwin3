#include "RADTRANS_OPTIONS.h"
#include "EXF_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: RADTRANS_INIT_FIXED

C     !INTERFACE:
      SUBROUTINE RADTRANS_INIT_FIXED( myThid )

C     !DESCRIPTION:
C     Initialize radtrans constants for exf field loading

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "EXF_PARAM.h"
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

C     !LOCAL VARIABLES:
C     === Local variables ===
C     msgBuf    :: Informational/error message buffer
C     errCount  :: error counter
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER errCount, l, oUnit
      _RL planck, c, hc, oavo, hcoavo, rlamm

#ifdef ALLOW_RADTRANS

#ifdef ALLOW_DIAGNOSTICS
      IF ( useDiagnostics ) THEN
        CALL RADTRANS_DIAGNOSTICS_INIT( myThid )
      ENDIF
#endif

      _BEGIN_MASTER( myThid )

      planck = 6.6256 _d -34   !Plancks constant J sec
      c = 2.998 _d 8                 !speed of light m/sec
      hc = 1.0/(planck*c)
      oavo = 1.0/6.023 _d 23   ! 1/Avogadros number
      hcoavo = hc*oavo
      DO l = 1,nlam
        rlamm = RT_wbRefWLs(l)*1 _d -9  !lambda in m
        RT_WtouEins(l) = 1 _d 6*rlamm*hcoavo      !Watts to uEin/s conversion
      ENDDO

#ifdef ALLOW_EXF
      errCount = 0

      IF ( RT_Edfile(1) .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START RT_E',myThid)
# endif
       CALL EXF_GETFFIELD_START( useEXFYearlyFields,
     I                           'radtrans', 'RT_E', RT_E_period,
     I                           RT_E_startdate1, RT_E_startdate2,
     U                           RT_E_StartTime, errCount,
     I                           myThid )
      ENDIF


      IF ( RT_icefile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START RT_ice',myThid)
# endif
       CALL EXF_GETFFIELD_START( useEXFYearlyFields,
     I                           'RT', 'RT_ice', RT_iceperiod,
     I                           RT_icestartdate1, RT_icestartdate2,
     U                           RT_iceStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( errCount.GE.1 ) THEN
       WRITE(msgBuf,'(A,I3,A)')
     &     'RADTRANS_INIT_FIXED: detected', errCount,' fatal error(s)'
       CALL PRINT_ERROR( msgBuf, myThid )
       CALL ALL_PROC_DIE( 0 )
       STOP 'ABNORMAL END: S/R RADTRANS_INIT_FIXED'
      ENDIF

#endif /* ALLOW_EXF */

      _END_MASTER( myThid )
      _BARRIER

#endif /* ALLOW_RADTRANS */

      RETURN
      END
