C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/radtrans/radtrans_gha2000.F,v 1.2 2016/01/04 17:08:12 jahn Exp $
C $Name:  $

#include "RADTRANS_OPTIONS.h"

CBOP
C     !ROUTINE: RADTRANS_GHA2000

C     !INTERFACE: ======================================================
      subroutine radtrans_gha2000 (radeg, iyr, imon, day, gha)

C     !DESCRIPTION:
c  This subroutine computes the Greenwich hour angle in degrees for the
c  input time.  It uses the model referenced in The Astronomical Almanac
c  for 1984, Section S (Supplement) and documented in Exact 
c  closed-form geolocation algorithm for Earth survey sensors, by 
c  F.S. Patt and W.W. Gregg, Int. Journal of Remote Sensing, 1993.
c  It includes the correction to mean sideral time for nutation
c  as well as precession.

c  Calling Arguments

c  Name		Type 	I/O	Description
c
c  iyr		I*4	 I	Year (four digits)
c  day		R*8	 I	Day (time of day as fraction)
c  gha		R*8	 O	Greenwich hour angle (degrees)


c	Subprograms referenced:
c
c	JD		Computes Julian day from calendar date
c	EPHPARMS	Computes mean solar longitude and anomaly and
c			 mean lunar lontitude and ascending node
c	NUTATE		Compute nutation corrections to lontitude and 
c			 obliquity
c 	
c
c	Program written by:	Frederick S. Patt
c				General Sciences Corporation
c				November 2, 1992
c
c	Modification History:
c
C     !USES: ===========================================================
      IMPLICIT NONE
#include "RADTRANS_VARS.h"

C     !INPUT PARAMETERS: ===============================================
      INTEGER myThid
      _RL radeg, day
      INTEGER iyr, imon

C     !OUTPUT PARAMETERS: ==============================================
      _RL gha

C     !FUNCTIONS: ======================================================
      INTEGER radtrans_jd
      EXTERNAL radtrans_jd
      
C     !LOCAL VARIABLES: ================================================
      integer iday,jday,nt
      _RL fday, t, gmst, xls, gs, xlm, omega

      data nutime /-99999/
CEOP

c  Compute days since J2000
       iday = int(day)
       fday = day - iday
       jday = radtrans_jd(iyr,imon,iday)
       t = jday - 2451545.5D0 + fday
c  Compute Greenwich Mean Sidereal Time	(degrees)
       gmst = 100.4606184D0 + 0.9856473663D0*t + 2.908D-13*t*t

c  Check if need to compute nutation correction for this day
       nt = int(t)
       if (nt.ne.nutime) then
         nutime = nt
         call radtrans_ephparms (t, xls, gs, xlm, omega)
         call radtrans_nutate (radeg, t, xls, gs, xlm, omega, dpsi, eps)
       end if

c  Include apparent time correction and time-of-day
       gha = gmst + dpsi*cos(eps/radeg) + fday*360.0D0
       gha = mod(gha,360.0)
       if (gha.lt.0.0D0) gha = gha + 360.0D0

      return
      end

