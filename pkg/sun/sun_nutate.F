#include "SUN_OPTIONS.h"

CBOP
C     !ROUTINE: SUN_NUTATE

C     !INTERFACE: ======================================================
      SUBROUTINE SUN_NUTATE(
     I                       t, xls, gs, xlm, asc,
     O                       dpsi, eps )

C     !DESCRIPTION:
C  This subroutine computes the nutation in longitude and the obliquity
C  of the ecliptic corrected for nutation.  It uses the model referenced
C  in The Astronomical Almanac for 1984, Section S (Supplement) and
C  documented in Exact closed-form geolocation algorithm for Earth
C  survey sensors, by F.S. Patt and W.W. Gregg, Int. Journal of
C  Remote Sensing, 1993.  These parameters are used to compute the
C  apparent time correction to the Greenwich Hour Angle and for the
C  calculation of the geocentric Sun vector.  The input ephemeris
C  parameters are computed using subroutine ephparms.  Terms are
C  included to 0.1 arcsecond.
C
C	Program written by:	Frederick S. Patt
C				General Sciences Corporation
C				October 21, 1992

C     !USES: ===========================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT PARAMETERS: ===============================================
C     t   :: Time in days since January 1, 2000 at 12 hours UT
C     xls :: Mean solar longitude (degrees)
C     gs  :: Mean solar anomaly   (degrees)
C     xlm :: Mean lunar longitude (degrees)
C     asc :: Ascending node of mean lunar orbit
      _RL t, xls, gs, xlm, asc

C     !OUTPUT PARAMETERS: ==============================================
C     dPsi :: Nutation in longitude (degrees)
C     Eps  :: Obliquity of the Ecliptic (degrees)
C             (includes nutation in obliquity)
      _RL dpsi, eps
CEOP

#ifdef ALLOW_SUN

C     !LOCAL VARIABLES: ================================================
      _RL epsm, deps

C  Nutation in Longitude
      dpsi = - 17.1996 _d 0*SIN(asc*deg2rad)
     &       + 0.2062 _d 0*SIN(2.0 _d 0*asc*deg2rad)
     &       - 1.3187 _d 0*SIN(2.0 _d 0*xls*deg2rad)
     &       + 0.1426 _d 0*SIN(gs*deg2rad)
     &       - 0.2274 _d 0*SIN(2.0 _d 0*xlm*deg2rad)

C  Mean Obliquity of the Ecliptic	
      epsm = 23.439291 _d 0 - 3.560 _d -7*t

C  Nutation in Obliquity
      deps = 9.2025 _d 0*COS(asc*deg2rad) +
     &       0.5736 _d 0*COS(2.0 _d 0*xls*deg2rad)

C  True Obliquity of the Ecliptic
      eps = epsm + deps/3600.0 _d 0

      dpsi = dpsi/3600.0 _d 0

#endif

      RETURN
      END
