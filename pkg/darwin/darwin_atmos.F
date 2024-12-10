#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_ATMOS

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_ATMOS( myTime, myIter, myThid )

C !DESCRIPTION:
C  dummy routine: this is not supported!
C
C !USES: ===============================================================
      IMPLICIT NONE

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
C  myIter               :: current timestep
C  myTime               :: current time
      INTEGER myIter, myThid
      _RL myTime
CEOP

      RETURN
      END
