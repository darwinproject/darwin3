#include "DARWIN_OPTIONS.h"

CStartOfInterface
      SUBROUTINE DARWIN_DIAGS( myTime, myIter, myThid )
C     /==========================================================\
C     | SUBROUTINE DARWIN_DIAGS                                  |
C     | o dummy subroutine                                       |
C     \==========================================================/
      IMPLICIT NONE

C     == Routine arguments ==
C     myTime - Current time of simulation ( s )
C     myIter - Iteration number
C     myThid -  Number of this instance of INI_FORCING
      _RL     myTime
      INTEGER myIter
      INTEGER myThid
CEndOfInterface

      RETURN
      END
