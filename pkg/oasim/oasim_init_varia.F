#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C !ROUTINE: OASIM_INIT_VARIA

C !INTERFACE:
      SUBROUTINE OASIM_INIT_VARIA( myThid )

C     !DESCRIPTION:
C     Initialize OASIM variables

C     !USES:
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#include "OASIM_SIZE.h"
#include "OASIM_FIELDS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      INTEGER myThid
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
C     === Local variables ===
      INTEGER i,j,k,bi,bj,l

C     Initialize arrays in common blocks :
      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        DO j=1,sNy
         DO i=1,sNx
          OASIM_solz(i,j,bi,bj) = 0. _d 0
          OASIM_rmud(i,j,bi,bj) = 0. _d 0
         ENDDO
        ENDDO
       ENDDO
      ENDDO

      DO l=1,nlt
       DO bj=myByLo(myThid),myByHi(myThid)
        DO bi=myBxLo(myThid),myBxHi(myThid)
         DO j=1,sNy
          DO i=1,sNx
           OASIM_Edabove(i,j,bi,bj,l) = 0. _d 0
           OASIM_Esabove(i,j,bi,bj,l) = 0. _d 0
           OASIM_Edbelow(i,j,bi,bj,l) = 0. _d 0
           OASIM_Esbelow(i,j,bi,bj,l) = 0. _d 0
          ENDDO
         ENDDO
        ENDDO
       ENDDO
      ENDDO

#ifndef OASIM_READ_UNFORMATTED
      CALL OASIM_EXF_INIT_VARIA(myThid)
#endif

#endif /* ALLOW_OASIM */

      RETURN
      END
