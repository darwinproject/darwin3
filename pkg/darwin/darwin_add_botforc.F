#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_ADD_BOTFORC
C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_ADD_BOTFORC(
     U                        gPtr,
     I                        botForc, fac,
     I                        bi, bj, iMin, iMax, jMin, jMax,
     I                        myIter, myTime, myThid )

C !DESCRIPTION:

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "GRID.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C!INPUT PARAMETERS: ====================================================
C  surfForc  :: surface forcing field to apply
C  fac       :: factor to multiply surface forcing by
C  myThid    :: thread number
      _RL botForc(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
      _RL fac
      _RL myTime
      INTEGER iMin, iMax, jMin, jMax, bi, bj, myIter, myThid

C!INPUT/OUTPUT PARAMETERS: =============================================
C  gPtr      :: surface tracer tendency array to update
      _RL gPtr(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr)
CEOP

#ifdef ALLOW_DARWIN

C!LOCAL VARIABLES: =====================================================
C  i,j :: loop indices
      INTEGER i,j,k
      _RL tmp3d(1-OLx:sNx+OLx, 1-OLy:sNy+OLy, Nr)

      DO k=1,Nr
       DO j=jMin,jMax
        DO i=iMin,iMax
         tmp3d(i,j,k) = 0 _d 0
        ENDDO
       ENDDO
      ENDDO
      DO j=jMin,jMax
       DO i=iMin,iMax
        k = kLowC(i,j,bi,bj)
        IF (k .GT. 0) THEN
         tmp3d(i,j,k) = botForc(i,j)*fac
     &     *maskC(i,j,k,bi,bj)*recip_drF(k)*recip_hFacC(i,j,k,bi,bj)
        ENDIF
       ENDDO
      ENDDO
      DO k=1,Nr
#ifdef NONLIN_FRSURF
C-    Account for change in level thickness
       IF (nonlinFreeSurf.GT.0) THEN
        CALL FREESURF_RESCALE_G(
     I                           bi, bj, k,
     U                           tmp3d,
     I                           myThid )
       ENDIF
#endif /* NONLIN_FRSURF */
       DO j=jMin,jMax
        DO i=iMin,iMax
         gPtr(i,j,k) = gPtr(i,j,k) + tmp3d(i,j,k)
        ENDDO
       ENDDO
      ENDDO

#endif /* ALLOW_DARWIN */

      RETURN
      END
