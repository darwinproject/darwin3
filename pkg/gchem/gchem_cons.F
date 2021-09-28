#include "GCHEM_OPTIONS.h"
#ifdef ALLOW_DIC
# include "DIC_OPTIONS.h"
#endif
#ifdef ALLOW_BLING
# include "BLING_OPTIONS.h"
#endif
#ifdef ALLOW_DARWIN
# include "DARWIN_OPTIONS.h"
#endif

CBOP
C !ROUTINE: GCHEM_CONS
C !INTERFACE: ==========================================================
      SUBROUTINE GCHEM_CONS( stage, myTime, myIter, myThid )

C !DESCRIPTION:
C     calls subroutines that check for conservation of chemical elements
C     (carbon, nitrogen , phosphorus, ...).

C !USES: ===============================================================
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "GCHEM.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      _RL myTime
      INTEGER stage, myIter, myThid
CEOP

#ifdef ALLOW_GCHEM

C!LOCAL VARIABLES: ====================================================

#ifdef ALLOW_DEBUG
      IF (debugMode) CALL DEBUG_ENTER('GCHEM_CONS',myThid)
#endif

#ifdef ALLOW_DARWIN
      IF ( useDARWIN ) THEN
        CALL DARWIN_CONS( stage, myTime, myIter, myThid )
      ENDIF
#endif

#ifdef ALLOW_DEBUG
      IF (debugMode) CALL DEBUG_LEAVE('GCHEM_FORCING_SEP',myThid)
#endif

#endif /* ALLOW_GCHEM */

      RETURN
      END
