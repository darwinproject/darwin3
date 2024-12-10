#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_NUT_SUPPLY
C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_NUT_SUPPLY(Nut,
     &                          bi,bj,iMin,iMax,jMin,jMax,
     &                          myIter,myTime,myThid)

C !DESCRIPTION:
C     step forward supply of nutrients

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"

C !INPUT PARAMETERS: ===================================================
      _RL myTime
      INTEGER bi,bj,iMin,iMax,jMin,jMax,myIter,myThid

C !INPUT/OUTPUT PARAMETERS: ============================================
      _RL  Nut(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
CEOP

#ifdef ALLOW_DARWIN

C !LOCAL VARIABLES: ====================================================

      STOP 'not implemented'

#endif /* ALLOW_DARWIN */

      RETURN
      END
