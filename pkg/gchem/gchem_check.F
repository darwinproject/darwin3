C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/gchem/Attic/gchem_check.F,v 1.1 2008/01/11 21:28:01 jahn Exp $
C $Name:  $
#include "GCHEM_OPTIONS.h"

      SUBROUTINE GCHEM_CHECK( myThid )
C     /==========================================================\
C     | SUBROUTINE GCHEM_CHECK                                   |
C     | o Validate basic package setup and inter-package         |
C     | dependencies.                                            |
C     \==========================================================/
      IMPLICIT NONE

C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     === Routine arguments ===
C     myThid -  Number of this instance
      INTEGER myThid

#ifdef ALLOW_GCHEM

C     === Local variables ===
C     msgBuf      - Informational/error meesage buffer
      CHARACTER*(MAX_LEN_MBUF) msgBuf

      _BEGIN_MASTER(myThid)

      WRITE(msgBuf,'(A)') 'GCHEM_CHECK: #define ALLOW_GCHEM'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &     SQUEEZE_RIGHT , myThid )

C     GCHEM needs passive tracer package
      IF ( .NOT.usePTRACERS) THEN
         WRITE(msgBuf,'(A)') 'usePTRACERS has to be .TRUE. for GCHEM'
         CALL PRINT_ERROR( msgBuf , myThid )
         STOP 'ABNORMAL END: S/R GCHEM_CHECK'
      ENDIF

      _END_MASTER(myThid)

#endif /* ALLOW_GCHEM */

      RETURN
      END
