#include "SUN_OPTIONS.h"

CBOP
C     !ROUTINE: SUN_INIT_VARIA

C     !INTERFACE: ======================================================
      SUBROUTINE SUN_INIT_VARIA( myThid )

C     !DESCRIPTION:
C     Compute local east, north, and vertical vectors
C
C     !USES: ===========================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "SUN_FIELDS.h"

C     !INPUT PARAMETERS: ===============================================
      INTEGER myThid
CEOP

#ifdef ALLOW_SUN

C     !LOCAL VARIABLES: ================================================
      INTEGER i,j,bi,bj
      _RL rlon,cosx,sinx,rlat,cosy,siny,upxy

      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
        DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx

c  Convert geodetic lat/lon to Earth-centered, earth-fixed (ECEF)
c  vector (geodetic unit vector)
          rlon = XC(i,j,bi,bj)*deg2rad
          cosx = COS(rlon)
          sinx = SIN(rlon)
          rlat = YC(i,j,bi,bj)*deg2rad
          cosy = COS(rlat)
          siny = SIN(rlat)

c  Compute the local up, East and North unit vectors
          SUN_up(i,j,bi,bj,1) = cosy*cosx
          SUN_up(i,j,bi,bj,2) = cosy*sinx
          SUN_up(i,j,bi,bj,3) = siny
          upxy = SQRT(SUN_up(i,j,bi,bj,1)*SUN_up(i,j,bi,bj,1)
     &               +SUN_up(i,j,bi,bj,2)*SUN_up(i,j,bi,bj,2))
          SUN_ea(i,j,bi,bj,1) = -SUN_up(i,j,bi,bj,2)/upxy
          SUN_ea(i,j,bi,bj,2) = SUN_up(i,j,bi,bj,1)/upxy
          SUN_no(i,j,bi,bj,1) = SUN_up(i,j,bi,bj,2)*SUN_ea(i,j,bi,bj,3)
     &                        - SUN_up(i,j,bi,bj,3)*SUN_ea(i,j,bi,bj,2)
          SUN_no(i,j,bi,bj,2) = SUN_up(i,j,bi,bj,3)*SUN_ea(i,j,bi,bj,1)
     &                        - SUN_up(i,j,bi,bj,1)*SUN_ea(i,j,bi,bj,3)
          SUN_no(i,j,bi,bj,3) = SUN_up(i,j,bi,bj,1)*SUN_ea(i,j,bi,bj,2)
     &                        - SUN_up(i,j,bi,bj,2)*SUN_ea(i,j,bi,bj,1)

         ENDDO
        ENDDO
       ENDDO
      ENDDO

#endif

      RETURN
      END
