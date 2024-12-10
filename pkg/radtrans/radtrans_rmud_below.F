#include "RADTRANS_OPTIONS.h"

CBOP
C     !ROUTINE: RADTRANS_RMUD_BELOW

C     !INTERFACE: ======================================================
      SUBROUTINE RADTRANS_RMUD_BELOW(
     O                           rmud,
     I                           sunz,
     I                           iMin, iMax, jMin, jMax, myThid )

C     !DESCRIPTION:
C     Compute average cosine for direct irradiance in the water column
C     given solar zenith angle (in degrees) above surface.
C
C     !USES: ===========================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"

C     !INPUT PARAMETERS: ===============================================
C     sunz :: solar zenith angle above surface in degrees
      _RL sunz(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
      INTEGER iMin, iMax, jMin, jMax, myThid

C     !OUTPUT PARAMETERS: ==============================================
C     rmud :: inverse cosine of zenith angle below surface
      _RL rmud(1-OLx:sNx+OLx, 1-OLy:sNy+OLy)
CEOP

#ifdef ALLOW_RADTRANS

C     !LOCAL VARIABLES: ================================================
      _RL sinbelow, solzbelow
      INTEGER i, j

      DO j=jMin,jMax
       DO i=iMin,iMax
        sinbelow = SIN(sunz(i,j)*deg2rad)/rt_refract_water
        solzbelow = ASIN(sinbelow)
        rmud(i,j) = MAX(0 _d 0, MIN(rt_rmud_max, 1./COS(solzbelow)))
       ENDDO
      ENDDO

#endif /* ALLOW_RADTRANS */

      RETURN
      END
