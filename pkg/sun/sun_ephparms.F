#include "SUN_OPTIONS.h"

CBOP
C     !ROUTINE: SUN_EPHPARMS

C     !INTERFACE: ======================================================
      SUBROUTINE SUN_EPHPARMS(
     I                         t,
     O                         xls, gs, xlm, asc )

C     !DESCRIPTION:
C  This subroutine computes ephemeris parameters used by other Mission
C  Operations routines:  the solar mean longitude and mean anomaly, and
C  the lunar mean longitude and mean ascending node.  It uses the model
C  referenced in The Astronomical Almanac for 1984, Section S
C  (Supplement) and documented and documented in Exact closed-form
C  geolocation algorithm for Earth survey sensors, by F.S. Patt and
C  W.W. Gregg, Int. Journal of Remote Sensing, 1993.  These parameters
C  are used to compute the solar longitude and the nutation in
C  longitude and obliquity.
C
C	Program written by:	Frederick S. Patt
C				General Sciences Corporation
C				November 2, 1992

C     !USES: ===========================================================
      IMPLICIT NONE

C     !INPUT PARAMETERS: ===============================================
C     t :: Time in days since January 1, 2000 at 12 hours UT
      _RL t

C     !OUTPUT PARAMETERS: ==============================================
C     xls :: Mean solar longitude (degrees)
C     gs  :: Mean solar anomaly (degrees)
C     xlm :: Mean lunar longitude (degrees)
C     asc :: Ascending node of mean lunar orbit (degrees)
      _RL xls, gs, xlm, asc
CEOP

#ifdef ALLOW_SUN

C  Sun Mean Longitude 		
      xls = 280.46592 _d 0 + 0.9856473516 _d 0*t
      xls = MOD(xls,360 _d 0)

C  Sun Mean Anomaly		
      gs = 357.52772 _d 0 + 0.9856002831 _d 0*t
      gs = MOD(gs,360 _d 0)

C  Moon Mean Longitude		
      xlm = 218.31643 _d 0 + 13.17639648 _d 0*t
      xlm = MOD(xlm,360 _d 0)

C  Ascending Node of Moons Mean Orbit 	
      asc = 125.04452 _d 0 - 0.0529537648 _d 0*t
      asc = MOD(asc,360 _d 0)

#endif /* ALLOW_SUN */

      RETURN
      END

