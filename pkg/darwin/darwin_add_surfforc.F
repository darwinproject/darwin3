#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_ADD_SURFFORC
C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_ADD_SURFFORC(
     U                        gPtr,
     I                        surfForc, fac,
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
      _RL surfForc(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
      _RL fac
      _RL myTime
      INTEGER iMin, iMax, jMin, jMax, bi, bj, myIter, myThid

C!INPUT/OUTPUT PARAMETERS: =============================================
C  gPtr      :: surface tracer tendency array to update
      _RL gPtr(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
CEOP

#ifdef ALLOW_DARWIN

C!LOCAL VARIABLES: =====================================================
C  i,j :: loop indices
      INTEGER i,j
      _RL tmp2d(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)

      DO j=jMin,jMax
       DO i=iMin,iMax
        tmp2d(i,j) = surfForc(i,j)*fac
     &             * recip_drF(1)*recip_hFacC(i,j,1,bi,bj)
       ENDDO
      ENDDO
#ifdef NONLIN_FRSURF
C-    Account for change in level thickness
      IF (nonlinFreeSurf.GT.0) THEN
        CALL FREESURF_RESCALE_G(
     I                           bi, bj, 1,
     U                           tmp2d,
     I                           myThid )
      ENDIF
#endif /* NONLIN_FRSURF */
      DO j=jMin,jMax
       DO i=iMin,iMax
        gPtr(i,j) = gPtr(i,j) + tmp2d(i,j)
       ENDDO
      ENDDO

#endif /* ALLOW_DARWIN */

      RETURN
      END
