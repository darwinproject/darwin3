#include "SUN_OPTIONS.h"

CBOP
C     !ROUTINE: SUN_GHA2000

C     !INTERFACE: ======================================================
      SUBROUTINE SUN_GHA2000(
     I                        t, dpsi, eps,
     O                        gha )

C     !DESCRIPTION:
C  This subroutine computes the Greenwich hour angle in degrees for the
C  input time.  It uses the model referenced in The Astronomical Almanac
C  for 1984, Section S (Supplement) and documented in Exact
C  closed-form geolocation algorithm for Earth survey sensors, by
C  F.S. Patt and W.W. Gregg, Int. Journal of Remote Sensing, 1993.
C  It includes the correction to mean sideral time for nutation
C  as well as precession.
C
C	Program written by:	Frederick S. Patt
C				General Sciences Corporation
C				November 2, 1992

C     !USES: ===========================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT PARAMETERS: ===============================================
C     t    :: Time in days since January 1, 2000 at 12 hours UT
C     dpsi :: Nutation in longitude (degrees)
C     eps  :: Obliquity of the Ecliptic (degrees)
      _RL t, dpsi, eps

C     !OUTPUT PARAMETERS: ==============================================
C     gha :: Greenwich hour angle (degrees)
      _RL gha
CEOP

#ifdef ALLOW_SUN

C     !LOCAL VARIABLES: ================================================
      INTEGER iday
      _RL fday, gmst

      fday = t + 0.5 _d 0
      iday = INT(fday)
      fday = fday - iday

C  Compute Greenwich Mean Sidereal Time	(degrees)
      gmst = 100.4606184 _d 0 + 0.9856473663 _d 0*t + 2.908 _d -13*t*t

C  Include apparent time correction and time-of-day
      gha = gmst + dpsi*COS(eps*deg2rad) + fday*360.0 _d 0
      gha = MOD(gha,360.0 _d 0)
      IF (gha .LT. 0.0 _d 0) THEN
        gha = gha + 360.0 _d 0
      ENDIF

#endif

      RETURN
      END
