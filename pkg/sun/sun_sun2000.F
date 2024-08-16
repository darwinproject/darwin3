#include "SUN_OPTIONS.h"

CBOP
C     !ROUTINE: SUN_SUN2000

C     !INTERFACE: ======================================================
      SUBROUTINE SUN_SUN2000(
     I                        t, xls, gs, xlm, asc, dpsi, eps,
     O                        sunvec, rs )

C     !DESCRIPTION:
C  This subroutine computes the Sun vector in geocentric inertial
C  (equatorial) coodinates.  It uses the model referenced in The
C  Astronomical Almanac for 1984, Section S (Supplement) and documented
C  in Exact closed-form geolocation algorithm for Earth survey
C  sensors, by F.S. Patt and W.W. Gregg, Int. Journal of Remote
C  Sensing, 1993.  The accuracy of the Sun vector is approximately 0.1
C  arcminute.
C
C	Coded by:  Frederick S. Patt, GSC, November 2, 1992
C	Modified to include Earth constants subroutine by W. Gregg,
C		May 11, 1993.

C     !USES: ===========================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT PARAMETERS: ===============================================
C     t    :: Time in days since January 1, 2000 at 12 hours UT
C     xls  :: Mean solar longitude (degrees)
C     gs   :: Mean solar anomaly   (degrees)
C     xlm  :: Mean lunar longitude (degrees)
C     asc  :: Ascending node of mean lunar orbit
C     dpsi :: Nutation in longitude (degrees)
C     eps  :: Obliquity of the Ecliptic (degrees)
      _RL t, xls, gs, xlm, asc, dpsi, eps

C     !OUTPUT PARAMETERS: ==============================================
C     sunvec :: Unit Sun vector in geocentric inertial coords of date
C     rs     :: Magnitude of the Sun vector (AU)
      _RL sunvec(3), rs
CEOP

#ifdef ALLOW_SUN

C     !LOCAL VARIABLES: ================================================
      INTEGER nt
      _RL xk,g2,g4,g5,dls,xlsg,xlsa
C  Constant of aberration
      PARAMETER (xk=0.0056932 _d 0)

C  Compute planet mean anomalies
C   Venus Mean Anomaly 	
      g2 = 50.40828 _d 0 + 1.60213022 _d 0*t
      g2 = MOD(g2,360 _d 0)

C   Mars Mean Anomaly 		
      g4 = 19.38816 _d 0 + 0.52402078 _d 0*t
      g4 = MOD(g4,360 _d 0)

C  Jupiter Mean Anomaly
      g5 = 20.35116 _d 0 + 0.08309121 _d 0*t
      g5 = MOD(g5,360 _d 0)

C  Compute solar distance (AU)
      rs = 1.00014 _d 0 - 0.01671 _d 0*COS(gs*deg2rad)
     &                  - 0.00014 _d 0*COS(2.0 _d 0*gs*deg2rad)

C  Compute Geometric Solar Longitude
      dls = (6893.0 _d 0 - 4.6543463 _d -4*t)*SIN(gs*deg2rad)
     & + 72.0 _d 0*SIN(2.0 _d 0*gs*deg2rad)
     & - 7.0 _d 0*COS((gs - g5)*deg2rad)
     & + 6.0 _d 0*SIN((xlm - xls)*deg2rad)
     & + 5.0 _d 0*SIN((4.0 _d 0*gs - 8.0 _d 0*g4 + 3.0 _d 0*g5)*deg2rad)
     & - 5.0 _d 0*COS((2.0 _d 0*gs - 2.0 _d 0*g2)*deg2rad)
     & - 4.0 _d 0*SIN((gs - g2)*deg2rad)
     & + 4.0 _d 0*COS((4.0 _d 0*gs - 8.0 _d 0*g4 + 3.0 _d 0*g5)*deg2rad)
     & + 3.0 _d 0*SIN((2.0 _d 0*gs - 2.0 _d 0*g2)*deg2rad)
     & - 3.0 _d 0*SIN(g5*deg2rad)
     & - 3.0 _d 0*SIN((2.0 _d 0*gs - 2.0 _d 0*g5)*deg2rad)

      xlsg = xls + dls/3600.0 _d 0

C  Compute Apparent Solar Longitude; includes corrections for nutation
C  in longitude and velocity aberration
      xlsa = xlsg + dpsi - xk/rs

C  Compute unit Sun vector
      sunvec(1) = COS(xlsa*deg2rad)
      sunvec(2) = SIN(xlsa*deg2rad)*COS(eps*deg2rad)
      sunvec(3) = SIN(xlsa*deg2rad)*SIN(eps*deg2rad)

#endif

      RETURN
      END
