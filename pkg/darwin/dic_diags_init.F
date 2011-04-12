#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

#ifdef ALLOW_CARBON

CBOP
C !ROUTINE: DIC_DIAGS_INIT

C !INTERFACE: ==========================================================
      SUBROUTINE DIC_DIAGS_INIT( myThid )

C !DESCRIPTION:
C  DIC diagnostic initialization

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DARWIN_FLUX.h"

c!INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid


C !LOCAL VARIABLES: ====================================================
      INTEGER bi, bj, k
      CHARACTER*(MAX_LEN_MBUF) suff
CEOP

#ifdef ALLOW_TIMEAVE
c set arrays to zero if first timestep
        DO bj = myByLo(myThid), myByHi(myThid)
         DO bi = myBxLo(myThid), myBxHi(myThid)
          CALL TIMEAVE_RESET(SURave,   1,  bi, bj, myThid)
          CALL TIMEAVE_RESET(SURCave,   1,  bi, bj, myThid)
          CALL TIMEAVE_RESET(SUROave,   1,  bi, bj, myThid)
          CALL TIMEAVE_RESET(pCO2ave,   1,  bi, bj, myThid)
          CALL TIMEAVE_RESET(pHave,   1,  bi, bj, myThid)
          print*,'QQ start timeave'
          do k=1,Nr
            DIC_TimeAve(bi,bj,k)=0.d0
          enddo
         ENDDO
        ENDDO
#endif /* ALLOW_TIMEAVE */

        RETURN
        END
#endif  /*ALLOW_CARBON*/

#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/
c ==================================================================

