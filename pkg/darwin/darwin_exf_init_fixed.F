#include "DARWIN_OPTIONS.h"
#include "EXF_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: DARWIN_EXF_INIT_FIXED

C     !INTERFACE:
      SUBROUTINE DARWIN_EXF_INIT_FIXED( myThid )

C     !DESCRIPTION:
C     Initialize DARWIN constants for exf field loading

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "EXF_PARAM.h"
#include "EXF_INTERP_SIZE.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_EXF_PARAMS.h"
#include "DARWIN_EXF_FIELDS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

C     !LOCAL VARIABLES:
C     === Local variables ===
C     msgBuf    :: Informational/error message buffer
C     errCount  :: error counter
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER errCount

#ifdef ALLOW_DARWIN
#ifdef ALLOW_EXF

      _BEGIN_MASTER( myThid )
      errCount = 0


      IF ( PARfile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START PAR',myThid)
# endif
       CALL EXF_GETFFIELD_START( useExfYearlyFields,
     I                           'darwin', 'PAR', PARperiod,
     I                           PARstartdate1, PARstartdate2,
     U                           PARStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( ironfile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START iron',myThid)
# endif
       CALL EXF_GETFFIELD_START( useExfYearlyFields,
     I                           'darwin', 'iron', ironperiod,
     I                           ironstartdate1, ironstartdate2,
     U                           ironStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( icefile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START ice',myThid)
# endif
       CALL EXF_GETFFIELD_START( useExfYearlyFields,
     I                           'darwin', 'ice', iceperiod,
     I                           icestartdate1, icestartdate2,
     U                           iceStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( windfile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START wind',myThid)
# endif
       CALL EXF_GETFFIELD_START( useExfYearlyFields,
     I                           'darwin', 'wind', windperiod,
     I                           windstartdate1, windstartdate2,
     U                           windStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( pCO2file .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START pCO2',myThid)
# endif
       CALL EXF_GETFFIELD_START( useExfYearlyFields,
     I                           'darwin', 'pCO2', pCO2period,
     I                           pCO2startdate1, pCO2startdate2,
     U                           pCO2StartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( errCount.GE.1 ) THEN
       WRITE(msgBuf,'(A,I3,A)')
     &     'DARWIN_EXF_INIT_FIXED: detected', errCount,' fatal error(s)'
       CALL PRINT_ERROR( msgBuf, myThid )
       CALL ALL_PROC_DIE( 0 )
       STOP 'ABNORMAL END: S/R DARWIN_EXF_INIT_FIXED'
      ENDIF

      _END_MASTER( myThid )
      _BARRIER

#endif /* ALLOW_EXF */
#endif /* ALLOW_DARWIN */

      RETURN
      END
