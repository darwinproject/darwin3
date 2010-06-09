C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/radtrans/radtrans_sun2000.F,v 1.1 2010/06/09 15:59:38 jahn Exp $
C $Name:  $

#include "RADTRANS_OPTIONS.h"

CBOP
C     !ROUTINE: RADTRANS_SUN2000

C     !INTERFACE: ======================================================
      subroutine radtrans_sun2000 (radeg, iyr, imon, iday, sec,
     O                             sunvec, rs)

C     !DESCRIPTION:
c  This subroutine computes the Sun vector in geocentric inertial 
c  (equatorial) coodinates.  It uses the model referenced in The 
c  Astronomical Almanac for 1984, Section S (Supplement) and documented
c  in Exact closed-form geolocation algorithm for Earth survey
c  sensors, by F.S. Patt and W.W. Gregg, Int. Journal of Remote
c  Sensing, 1993.  The accuracy of the Sun vector is approximately 0.1 
c  arcminute.
c
c	Arguments:
c
c	Name	Type	I/O	Description
c	--------------------------------------------------------
c	IYR	I*4	 I	Year, four digits (i.e, 1993)
c	IDAY	I*4	 I	Day of year (1-366)
c	SEC	R*8	 I	Seconds of day 
c	SUN(3)	R*8	 O	Unit Sun vector in geocentric inertial 
c				 coordinates of date
c	RS	R*8	 O	Magnitude of the Sun vector (AU)
c
c	Subprograms referenced:
c
c	JD		Computes Julian day from calendar date
c	EPHPARMS	Computes mean solar longitude and anomaly and
c			 mean lunar lontitude and ascending node
c	NUTATE		Compute nutation corrections to lontitude and 
c			 obliquity
c
c	Coded by:  Frederick S. Patt, GSC, November 2, 1992
c	Modified to include Earth constants subroutine by W. Gregg,
c		May 11, 1993.

C     !USES: ===========================================================
      IMPLICIT NONE
#include "RADTRANS_VARS.h"

C     !INPUT PARAMETERS: ===============================================
      INTEGER iyr, imon, iday
      _RL radeg, sec
c     INTEGER myThid

C     !OUTPUT PARAMETERS: ==============================================
      _RL sunvec(3), rs

C     !FUNCTIONS: ======================================================
      INTEGER radtrans_jd
      EXTERNAL radtrans_jd

C     !LOCAL VARIABLES: ================================================
      INTEGER nt
      _RL xk,rjd,t,xls,gs,xlm,omega,g2,g4,g5,dls,xlsg,xlsa
      parameter (xk=0.0056932)    !Constant of aberration 
CEOP

c   Compute floating point days since Jan 1.5, 2000 
c    Note that the Julian day starts at noon on the specified date
       rjd = float(radtrans_jd(iyr,imon,iday))
       t = rjd - 2451545.0D0 + (sec-43200.0D0)/86400.0D0

c  Compute solar ephemeris parameters
       call radtrans_ephparms (t, xls, gs, xlm, omega)

c  Check if need to compute nutation corrections for this day
      nt = int(t)
      if (nt.ne.nutime) then
        nutime = nt
        call radtrans_nutate (radeg, t, xls, gs, xlm, omega, dpsi, eps)
      end if

c  Compute planet mean anomalies
c   Venus Mean Anomaly 	
      g2 = 50.40828D0 + 1.60213022D0*t
      g2 = mod(g2,360.0)

c   Mars Mean Anomaly 		
      g4 = 19.38816D0 + 0.52402078D0*t
      g4 = mod(g4,360.0)

c  Jupiter Mean Anomaly 
      g5 = 20.35116D0 + 0.08309121D0*t
      g5 = mod(g5,360.0)

c  Compute solar distance (AU)
      rs = 1.00014D0 - 0.01671D0*cos(gs/radeg) 
     *       - 0.00014D0*cos(2.0D0*gs/radeg)

c  Compute Geometric Solar Longitude 
      dls = (6893.0D0 - 4.6543463D-4*t)*sin(gs/radeg) 
     * + 72.0D0*sin(2.0D0*gs/radeg) 
     * - 7.0D0*cos((gs - g5)/radeg)
     * + 6.0D0*sin((xlm - xls)/radeg) 
     * + 5.0D0*sin((4.0D0*gs - 8.0D0*g4 + 3.0D0*g5)/radeg) 
     * - 5.0D0*cos((2.0D0*gs - 2.0D0*g2)/radeg)
     * - 4.0D0*sin((gs - g2)/radeg) 
     * + 4.0D0*cos((4.0D0*gs - 8.0D0*g4 + 3.0D0*g5)/radeg) 
     * + 3.0D0*sin((2.0D0*gs - 2.0D0*g2)/radeg)
     * - 3.0D0*sin(g5/radeg) 
     * - 3.0D0*sin((2.0D0*gs - 2.0D0*g5)/radeg)  !arcseconds

      xlsg = xls + dls/3600.0D0

c  Compute Apparent Solar Longitude; includes corrections for nutation 
c   in longitude and velocity aberration
      xlsa = xlsg + dpsi - xk/rs

c   Compute unit Sun vector 
      sunvec(1) = cos(xlsa/radeg)
      sunvec(2) = sin(xlsa/radeg)*cos(eps/radeg)
      sunvec(3) = sin(xlsa/radeg)*sin(eps/radeg)
c	type *,' Sunlon = ',xlsg,xlsa,eps

      return
      end
c
