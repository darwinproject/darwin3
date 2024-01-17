#include "OASIM_OPTIONS.h"
#ifdef ALLOW_EXF
#include "EXF_OPTIONS.h"
#endif

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: OASIM_EXF_INIT_FIXED

C     !INTERFACE:
      SUBROUTINE OASIM_EXF_INIT_FIXED( myThid )

C     !DESCRIPTION:
C     Initialize OASIM constants for exf field loading

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#ifdef ALLOW_EXF
#include "EXF_INTERP_SIZE.h"
#endif
#include "OASIM_SIZE.h"
#include "OASIM_EXF_PARAMS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

C     !LOCAL VARIABLES:
C     === Local variables ===
C     msgBuf    :: Informational/error message buffer
C     errCount  :: error counter
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER errCount

#ifdef ALLOW_OASIM
#ifdef ALLOW_EXF

      _BEGIN_MASTER( myThid )
      errCount = 0

      IF ( aerTaufile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START aerTau',myThid)
# endif
       CALL EXF_GETFFIELD_START( useOasimYearlyFields,
     I                           'oasim', 'aerTau', aerTauperiod,
     I                           aerTaustartdate1, aerTaustartdate2,
     U                           aerTauStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( asympfile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START asymp',myThid)
# endif
       CALL EXF_GETFFIELD_START( useOasimYearlyFields,
     I                           'oasim', 'asymp', asympperiod,
     I                           asympstartdate1, asympstartdate2,
     U                           asympStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( ssalbfile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START ssalb',myThid)
# endif
       CALL EXF_GETFFIELD_START( useOasimYearlyFields,
     I                           'oasim', 'ssalb', ssalbperiod,
     I                           ssalbstartdate1, ssalbstartdate2,
     U                           ssalbStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( cldcovfile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START cldcov',myThid)
# endif
       CALL EXF_GETFFIELD_START( useOasimYearlyFields,
     I                           'oasim', 'cldcov', cldcovperiod,
     I                           cldcovstartdate1, cldcovstartdate2,
     U                           cldcovStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( cldlwpfile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START cldlwp',myThid)
# endif
       CALL EXF_GETFFIELD_START( useOasimYearlyFields,
     I                           'oasim', 'cldlwp', cldlwpperiod,
     I                           cldlwpstartdate1, cldlwpstartdate2,
     U                           cldlwpStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( cldrefile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START cldre',myThid)
# endif
       CALL EXF_GETFFIELD_START( useOasimYearlyFields,
     I                           'oasim', 'cldre', cldreperiod,
     I                           cldrestartdate1, cldrestartdate2,
     U                           cldreStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( presfile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START pres',myThid)
# endif
       CALL EXF_GETFFIELD_START( useOasimYearlyFields,
     I                           'oasim', 'pres', presperiod,
     I                           presstartdate1, presstartdate2,
     U                           presStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( oawindfile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START oawind',myThid)
# endif
       CALL EXF_GETFFIELD_START( useOasimYearlyFields,
     I                           'oasim', 'oawind', oawindperiod,
     I                           oawindstartdate1, oawindstartdate2,
     U                           oawindStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( relhumfile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START relhum',myThid)
# endif
       CALL EXF_GETFFIELD_START( useOasimYearlyFields,
     I                           'oasim', 'relhum', relhumperiod,
     I                           relhumstartdate1, relhumstartdate2,
     U                           relhumStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( ozonefile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START ozone',myThid)
# endif
       CALL EXF_GETFFIELD_START( useOasimYearlyFields,
     I                           'oasim', 'ozone', ozoneperiod,
     I                           ozonestartdate1, ozonestartdate2,
     U                           ozoneStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( wvfile .NE. ' ' ) THEN
# ifdef ALLOW_DEBUG
       IF (debugMode) CALL DEBUG_CALL('GETFFIELD_START wv',myThid)
# endif
       CALL EXF_GETFFIELD_START( useOasimYearlyFields,
     I                           'oasim', 'wv', wvperiod,
     I                           wvstartdate1, wvstartdate2,
     U                           wvStartTime, errCount,
     I                           myThid )
      ENDIF

      IF ( errCount.GE.1 ) THEN
       WRITE(msgBuf,'(A,I3,A)')
     &     'OASIM_EXF_INIT_FIXED: detected', errCount,' fatal error(s)'
       CALL PRINT_ERROR( msgBuf, myThid )
       CALL ALL_PROC_DIE( 0 )
       STOP 'ABNORMAL END: S/R OASIM_EXF_INIT_FIXED'
      ENDIF

      _END_MASTER( myThid )
      _BARRIER

#endif /* ALLOW_EXF */
#endif /* ALLOW_OASIM */

      RETURN
      END
