#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C !ROUTINE: OASIM_SUN_VECTOR

C !INTERFACE:
      SUBROUTINE OASIM_SUN_VECTOR(
     I                             iday, iyr, gmt,
     O                             sunvec, rs )

C     !DESCRIPTION:
C     compute sun vector in earth-fixed coordinate system
C
C     Together with a local zenith-pointing vector, this can be used
C     to compute the solar zenith angle.
C
C     Original comment:
C     Given year, day of year, time in hours (GMT) and latitude and
C     longitude, returns an accurate solar zenith and azimuth angle.
C     Based on IAU 1976 Earth ellipsoid.  Method for computing solar
C     vector and local vertical from Patt and Gregg, 1994, Int. J.
C     Remote Sensing.  Only outputs solar zenith angle.  This version
C     utilizes a pre-calculation of the local up, north, and east
C     vectors, since the locations where the solar zenith angle are
C     calculated in the model are fixed.
C
C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "OASIM_SIZE.h"
#include "OASIM_INTERNAL.h"

C     !INPUT PARAMETERS:
C     iday :: yearday (1..366)
C     iyr  :: year (e.g., 1970)
C     gmt  :: time of day in hours (e.g., 12.5)
      INTEGER iday, iyr
      _RL gmt

C     !OUTPUT PARAMETERS:
C     sunvec(3) :: sun vector in earth-fixed coordinate system
C     rs        :: correction to earth-sun distance
      _RL sunvec(3), rs
CEOP

#ifdef ALLOW_OASIM

C     !FUNCTIONS:
      EXTERNAL OASIM_JULIAN_DAY
      INTEGER OASIM_JULIAN_DAY

C     !LOCAL VARIABLES:
      INTEGER imon, jday, nutime, nt, iiday
      _RL rjd, t, sec, day, suni(3), fday, gha, ghar
      _RL xls, gs, xlm, omega, dpsi, eps
#ifdef OASIM_DAILY_NUTATE
      COMMON/oasim_eph_parms/ dpsi, eps, nutime
      DATA nutime/-99999/
#endif
      DATA imon/1/

      sec = gmt*3600.0 _d 0
c  Compute floating point days since Jan 1.5, 2000
c   Note that the Julian day starts at noon on the specified date
      rjd = FLOAT(OASIM_JULIAN_DAY(iyr,imon,iday))
      t = rjd - 2451545.0 _d 0 + (sec-43200.0 _d 0)/86400.0 _d 0
      CALL OASIM_EPHPARMS(t,xls,gs,xlm,omega)
#ifdef OASIM_DAILY_NUTATE
      nt = INT(t)
      IF (nt.NE.nutime) THEN
        nutime = nt
        CALL OASIM_NUTATE(rad,t,xls,gs,xlm,omega,dpsi,eps)
      ENDIF
#else
      CALL OASIM_NUTATE(rad,t,xls,gs,xlm,omega,dpsi,eps)
#endif

c  Compute sun vector
c   Compute unit sun vector in geocentric inertial coordinates
      CALL OASIM_SUN2000(rad,t,xls,gs,xlm,omega,dpsi,eps,suni,rs)

c   Get Greenwich mean sidereal angle
#ifdef OASIM_DAILY_NUTATE
c  Compute days since J2000
      day = FLOAT(iday) + sec/86400.0 _d 0
      iiday = INT(day)
      fday = day - iiday
#else
      fday = sec/86400.0 _d 0
#endif
      CALL OASIM_GHA2000(rad, t, fday, dpsi, eps, gha)
      ghar = gha/rad

c   Transform Sun vector into geocentric rotating frame
      sunvec(1) = suni(1)*COS(ghar) + suni(2)*SIN(ghar)
      sunvec(2) = suni(2)*COS(ghar) - suni(1)*SIN(ghar)
      sunvec(3) = suni(3)

#endif /* ALLOW_OASIM */

      RETURN
      END

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_SUN2000

C     !INTERFACE:
      SUBROUTINE OASIM_SUN2000(
     I               radeg, t, xls , gs, xlm, omega, dpsi, eps,
     O               sunvec, rs )

C     !DESCRIPTION:
C     This subroutine computes the Sun vector in geocentric inertial
C     (equatorial) coodinates.  It uses the model referenced in The
C     Astronomical Almanac for 1984, Section S (Supplement) and documented
C     in Exact closed-form geolocation algorithm for Earth survey
C     sensors, by F.S. Patt and W.W. Gregg, Int. Journal of Remote
C     Sensing, 1993.  The accuracy of the Sun vector is approximately 0.1
C     arcminute.
C
C       Coded by:  Frederick S. Patt, GSC, November 2, 1992
C       Modified to include Earth constants subroutine by W. Gregg,
C               May 11, 1993.

C     !USES:
      IMPLICIT NONE

C     !INPUT PARAMETERS:
C     radeg :: conversion factor for radians to degrees
C     t     :: floating point days since Jan 1.5, 2000
C     xls   :: Mean solar longitude (degrees)
C     gs    :: Mean solar anomaly (degrees)
C     xlm   :: Mean lunar longitude (degrees)
C     omega :: Ascending node of mean lunar orbit (degrees)
C     dpsi  :: Nutation in longitude (degrees)
C     eps   :: Obliquity of the Ecliptic (degrees)
      _RL radeg, t
      _RL xls, gs, xlm, omega, dpsi, eps

C     !OUTPUT PARAMETERS:
C     sunvec :: Unit sun vector in geocentric inertial coords of date
C     rs     :: Magnitude of the Sun vector (AU)
      _RL sunvec(3), rs
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      INTEGER nt
      _RL g2, g4, g5, dls, xlsg, xlsa

      _RL xk
      DATA xk/0.0056932 _d 0/              !Constant of aberration

c  Compute planet mean anomalies
c   Venus Mean Anomaly
      g2 = 50.40828 _d 0 + 1.60213022 _d 0*t
      g2 = MOD(g2,360.0 _d 0)

c   Mars Mean Anomaly
      g4 = 19.38816 _d 0 + 0.52402078 _d 0*t
      g4 = MOD(g4,360.0 _d 0)

c  Jupiter Mean Anomaly
      g5 = 20.35116 _d 0 + 0.08309121 _d 0*t
      g5 = MOD(g5,360.0 _d 0)

c  Compute solar distance (AU)
      rs = 1.00014 _d 0 - 0.01671 _d 0*COS(gs/radeg)
     &                  - 0.00014 _d 0*COS(2.0 _d 0*gs/radeg)

c  Compute Geometric Solar Longitude
      dls = (6893.0 _d 0 - 4.6543463 _d -4*t)*SIN(gs/radeg)
     &      + 72.0 _d 0*SIN(2.0 _d 0*gs/radeg)
     &      - 7.0 _d 0*COS((gs - g5)/radeg)
     &      + 6.0 _d 0*SIN((xlm - xls)/radeg)
     &      + 5.0 _d 0*SIN((4 _d 0*gs - 8 _d 0*g4 + 3 _d 0*g5)/radeg)
     &      - 5.0 _d 0*COS((2 _d 0*gs - 2 _d 0*g2)/radeg)
     &      - 4.0 _d 0*SIN((gs - g2)/radeg)
     &      + 4.0 _d 0*COS((4 _d 0*gs - 8 _d 0*g4 + 3 _d 0*g5)/radeg)
     &      + 3.0 _d 0*SIN((2 _d 0*gs - 2 _d 0*g2)/radeg)
     &      - 3.0 _d 0*SIN(g5/radeg)
     &      - 3.0 _d 0*SIN((2.0 _d 0*gs - 2.0 _d 0*g5)/radeg)  !arcseconds

      xlsg = xls + dls/3600.0 _d 0

c  Compute Apparent Solar Longitude; includes corrections for nutation
c   in longitude and velocity aberration
      xlsa = xlsg + dpsi - xk/rs

c   Compute unit Sun vector
      sunvec(1) = COS(xlsa/radeg)
      sunvec(2) = SIN(xlsa/radeg)*COS(eps/radeg)
      sunvec(3) = sin(xlsa/radeg)*SIN(eps/radeg)
c       type *,' Sunlon = ',xlsg,xlsa,eps

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_GHA2000

C     !INTERFACE:
      SUBROUTINE OASIM_GHA2000( radeg,t,fday,dpsi,eps,gha )

C     !DESCRIPTION:
C     This subroutine computes the Greenwich hour angle in degrees for the
C     input time.  It uses the model referenced in The Astronomical Almanac
C     for 1984, Section S (Supplement) and documented in Exact
C     closed-form geolocation algorithm for Earth survey sensors, by
C     F.S. Patt and W.W. Gregg, Int. Journal of Remote Sensing, 1993.
C     It includes the correction to mean sideral time for nutation
C     as well as precession.
C
C       Program written by:     Frederick S. Patt
C                               General Sciences Corporation
C                               November 2, 1992

C     !USES:
      IMPLICIT NONE

C     !INPUT PARAMETERS:
C     t    :: floating point days since Jan 1.5, 2000
C     fday :: fractional day
C     dpsi :: Nutation in longitude (degrees)
C     eps  :: Obliquity of the Ecliptic (degrees)
      _RL radeg, t, fday, dpsi, eps

C     !OUTPUT PARAMETERS:
C     gha :: Greenwich hour angle (degrees)
      _RL gha
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      _RL gmst

c  Compute Greenwich Mean Sidereal Time (degrees)
      gmst = 100.4606184 _d 0 + 0.9856473663 _d 0*t + 2.908 _d -13*t*t

c  Include apparent time correction and time-of-day
      gha = gmst + dpsi*COS(eps/radeg) + fday*360.0 _d 0
      gha = MOD(gha,360.0 _d 0)
      IF (gha.LT.0.0 _d 0) THEN
        gha = gha + 360.0 _d 0
      ENDIF

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_EPHPARMS

C     !INTERFACE:
      SUBROUTINE OASIM_EPHPARMS( t,
     O                           xls, gs, xlm, omega )

C     !DESCRIPTION:
C     This subroutine computes ephemeris parameters used by other Mission
C     Operations routines:  the solar mean longitude and mean anomaly, and
C     the lunar mean longitude and mean ascending node.  It uses the model
C     referenced in The Astronomical Almanac for 1984, Section S
C     (Supplement) and documented and documented in Exact closed-form
C     geolocation algorithm for Earth survey sensors, by F.S. Patt and
C     W.W. Gregg, Int. Journal of Remote Sensing, 1993.  These parameters
C     are used to compute the solar longitude and the nutation in
C     longitude and obliquity.
C
C       Program written by:     Frederick S. Patt
C                               General Sciences Corporation
C                               November 2, 1992

C     !USES:
      IMPLICIT NONE

C     !INPUT PARAMETERS:
C     t :: time in days since January 1, 2000 at 12 hours UT
      _RL t

C     !OUTPUT PARAMETERS:
C     xls   :: Mean solar longitude (degrees)
C     gs    :: Mean solar anomaly (degrees)
C     xlm   :: Mean lunar longitude (degrees)
C     omega :: Ascending node of mean lunar orbit (degrees)
      _RL xls, gs, xlm, omega
CEOP

#ifdef ALLOW_OASIM

c  Sun Mean Longitude
      xls = 280.46592 _d 0 + 0.9856473516 _d 0*t
      xls = MOD(xls, 360.0 _d 0)

c  Sun Mean Anomaly
      gs = 357.52772 _d 0 + 0.9856002831 _d 0*t
      gs = MOD(gs, 360.0 _d 0)

c  Moon Mean Longitude
      xlm = 218.31643 _d 0 + 13.17639648 _d 0*t
      xlm = MOD(xlm, 360.0 _d 0)

c  Ascending Node of Moons Mean Orbit
      omega = 125.04452 _d 0 - 0.0529537648 _d 0*t
      omega = MOD(omega, 360.0 _d 0)

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_NUTATE

C     !INTERFACE:
      SUBROUTINE OASIM_NUTATE( radeg,t,xls,gs,xlm,omega,
     O                         dpsi,eps )

C     !DESCRIPTION:
C     This subroutine computes the nutation in longitude and the obliquity
C     of the ecliptic corrected for nutation.  It uses the model referenced
C     in The Astronomical Almanac for 1984, Section S (Supplement) and
C     documented in Exact closed-form geolocation algorithm for Earth
C     survey sensors, by F.S. Patt and W.W. Gregg, Int. Journal of
C     Remote Sensing, 1993.  These parameters are used to compute the
C     apparent time correction to the Greenwich Hour Angle and for the
C     calculation of the geocentric Sun vector.  The input ephemeris
C     parameters are computed using subroutine ephparms.  Terms are
C     included to 0.1 arcsecond.
C
C       Program written by:     Frederick S. Patt
C                               General Sciences Corporation
C                               October 21, 1992

C     !USES:
      IMPLICIT NONE

C     !INPUT PARAMETERS:
C     radeg :: conversion factor for radians to degrees
C     t     :: time in days since January 1, 2000 at 12 hours UT
C     xls   :: Mean solar longitude (degrees)
C     gs    :: Mean solar anomaly (degrees)
C     xlm   :: Mean lunar longitude (degrees)
C     omega :: Ascending node of mean lunar orbit (degrees)
      _RL radeg, t, xls, gs, xlm, omega

C     !OUTPUT PARAMETERS:
C     dpsi :: Nutation in longitude (degrees)
C     eps  :: Obliquity of the Ecliptic (degrees)
C             (includes nutation in obliquity)
      _RL dpsi, eps
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      _RL epsm, deps

c  Nutation in Longitude
      dpsi = - 17.1996 _d 0*SIN(omega/radeg)
     &       + 0.2062 _d 0*SIN(2.0 _d 0*omega/radeg)
     &       - 1.3187 _d 0*SIN(2.0 _d 0*xls/radeg)
     &       + 0.1426 _d 0*SIN(gs/radeg)
     &       - 0.2274 _d 0*SIN(2.0 _d 0*xlm/radeg)

c  Mean Obliquity of the Ecliptic
      epsm = 23.439291 _d 0 - 3.560 _d -7*t

c  Nutation in Obliquity
      deps = 9.2025 _d 0*COS(omega/radeg)
     &     + 0.5736 _d 0*COS(2.0 _d 0*xls/radeg)

c  True Obliquity of the Ecliptic
      eps = epsm + deps/3600.0 _d 0

      dpsi = dpsi/3600.0 _d 0

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: OASIM_JULIAN_DAY

C     !INTERFACE:
      FUNCTION OASIM_JULIAN_DAY( i, j, k )

C     !DESCRIPTION:
C     This function converts a calendar date to the corresponding Julian
C     day starting at noon on the calendar date.  The algorithm used is
C     from Van Flandern and Pulkkinen, Ap. J. Supplement Series 41,
C     November 1979, p. 400.
C
C     Written by Frederick S. Patt, GSC, November 4, 1992

C     !USES:
      IMPLICIT NONE

C     !INPUT PARAMETERS:
C     i :: Year - e.g. 1970
C     j :: Month - (1-12)
C     k :: Day  - (1-31)
      INTEGER i, j, k

C     !OUTPUT PARAMETERS:
C     oasim_julian_day :: Julian day
      INTEGER OASIM_JULIAN_DAY
CEOP

#ifdef ALLOW_OASIM

      OASIM_JULIAN_DAY= 367*i - 7*(i+(j+9)/12)/4 + 275*j/9 + k + 1721014

c  This additional calculation is needed only for dates outside of the
c   period March 1, 1900 to February 28, 2100
c     oasim_julian_day = oasim_julian_day + 15 - 3*((i+(j-9)/7)/100+1)/4

#endif /* ALLOW_OASIM */

      RETURN
      END
