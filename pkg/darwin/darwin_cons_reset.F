#include "DARWIN_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: DARWIN_CONS_RESET

C     !INTERFACE:
      SUBROUTINE DARWIN_CONS_RESET( myThid )

C     !DESCRIPTION:
C     Reset conservation correction accumulator arrays

C     !USES:
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_FIELDS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_DARWIN
#ifdef DARWIN_ALLOW_CONS

C     !LOCAL VARIABLES:
      INTEGER i,j,k,bi,bj

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        DO k=1,Nr
         DO j=1,sNy
          DO i=1,sNx
           DARWIN_Nfix(i,j,k,bi,bj) = 0 _d 0
           DARWIN_Ndenit(i,j,k,bi,bj) = 0 _d 0
           DARWIN_partScav(i,j,k,bi,bj) = 0 _d 0
           DARWIN_minFeLoss(i,j,k,bi,bj) = 0 _d 0
           DARWIN_O2prod(i,j,k,bi,bj) = 0 _d 0
           DARWIN_O2cons(i,j,k,bi,bj) = 0 _d 0
           DARWIN_AlkSrc(i,j,k,bi,bj) = 0 _d 0
          ENDDO
         ENDDO
        ENDDO
        DO j=1,sNy
         DO i=1,sNx
          ironSedFlx(i,j,bi,bj) = 0 _d 0
          carbSfcFlx(i,j,bi,bj) = 0 _d 0
          carbVirFlx(i,j,bi,bj) = 0 _d 0
          oxySfcFlx(i,j,bi,bj) = 0 _d 0
          alkVirFlx(i,j,bi,bj) = 0 _d 0
#ifdef DARWIN_BOTTOM_SINK
          botSnkC(i,j,bi,bj) = 0 _d 0
          botSnkN(i,j,bi,bj) = 0 _d 0
          botSnkP(i,j,bi,bj) = 0 _d 0
          botSnkFe(i,j,bi,bj) = 0 _d 0
          botSnkSi(i,j,bi,bj) = 0 _d 0
#endif
         ENDDO
        ENDDO
       ENDDO
      ENDDO

#endif /* DARWIN_ALLOW_CONS */
#endif /* ALLOW_DARWIN */

      RETURN
      END

