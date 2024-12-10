#include "SUN_OPTIONS.h"

CBOP
C     !ROUTINE: SUN_JD
C     !INTERFACE: ======================================================
      FUNCTION SUN_JD( i, j, k )

C     !DESCRIPTION:
C  This function converts a calendar date to the corresponding Julian
C  day starting at noon on the calendar date.  The algorithm used is
C  from Van Flandern and Pulkkinen, Ap. J. Supplement Series 41,
C  November 1979, p. 400.
C
C     Written by Frederick S. Patt, GSC, November 4, 1992

C     !USES: ===========================================================
      IMPLICIT NONE

C     !INPUT PARAMETERS: ===============================================
C     i :: Year - e.g. 1970
C     j :: Month - (1-12)
C     k :: Day - (1-31)
      INTEGER i, j, k

C     !OUTPUT PARAMETERS: ==============================================
C     SUN_JD :: Julian day
      INTEGER SUN_JD
CEOP

#ifdef ALLOW_SUN

      SUN_JD = 367*i - 7*(i+(j+9)/12)/4 + 275*j/9 + k + 1721014

c  This additional calculation is needed only for dates outside of the
c  period March 1, 1900 to February 28, 2100
c     	sun_jd = sun_jd + 15 - 3*((i+(j-9)/7)/100+1)/4

#endif

      RETURN
      END
