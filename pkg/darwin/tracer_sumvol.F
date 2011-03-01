#include "PTRACERS_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

C !INTERFACE: ==========================================================
      SUBROUTINE TRACER_SUMVOL(
     I                    tracer, kLev,
     O                    gsm_tracer,
     I                    myThid )

C !DESCRIPTION:
C  Calculate surface means of tracer

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
c#include "DYNVARS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid
      INTEGER kLev
      _RL tracer (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)

C !OUTPUT PARAMETERS: ===================================================
C  gcm_tracer               :: surface mean of tracer
      _RL gsm_tracer

C !LOCAL VARIABLES: ====================================================
      INTEGER i,j,k,bi,bj
      _RL sumTracer
CEOP

       sumTracer= 0. _d 0

       DO bj=myByLo(myThid),myByHi(myThid)
        DO bi=myBxLo(myThid),myBxHi(myThid)
         DO j=1,sNy
          DO i=1,sNx
           DO k=1,kLev
            sumTracer=sumTracer+
     &          tracer(i,j,k,bi,bj)*rA(i,j,bi,bj)*drF(k)*
     &                        HFacC(i,j,k,bi,bj)
           ENDDO
          ENDDO
         ENDDO
        ENDDO
       ENDDO
       _GLOBAL_SUM_RL(sumTracer,myThid)
       gsm_tracer=sumTracer

       RETURN
       END
