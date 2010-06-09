C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/radtrans/radtrans_nutate.F,v 1.1 2010/06/09 15:59:37 jahn Exp $
C $Name:  $

#include "RADTRANS_OPTIONS.h"

CBOP
C     !ROUTINE: RADTRANS_NUTATE

C     !INTERFACE: ======================================================
      subroutine radtrans_nutate (radeg, t, xls, gs, xlm, omega,
     O                            dpsi, eps)

C     !DESCRIPTION:
c  This subroutine computes the nutation in longitude and the obliquity
c  of the ecliptic corrected for nutation.  It uses the model referenced
c  in The Astronomical Almanac for 1984, Section S (Supplement) and 
c  documented in Exact closed-form geolocation algorithm for Earth 
c  survey sensors, by F.S. Patt and W.W. Gregg, Int. Journal of 
c  Remote Sensing, 1993.  These parameters are used to compute the 
c  apparent time correction to the Greenwich Hour Angle and for the 
c  calculation of the geocentric Sun vector.  The input ephemeris 
c  parameters are computed using subroutine ephparms.  Terms are 
c  included to 0.1 arcsecond.

c  Calling Arguments

c  Name		Type 	I/O	Description
c
c  t		R*8	 I	Time in days since January 1, 2000 at 
c				 12 hours UT
c  xls		R*8	 I	Mean solar longitude (degrees)
c  gs		R*8	 I	Mean solar anomaly   (degrees)
c  xlm		R*8	 I	Mean lunar longitude (degrees)
c  Omega	R*8	 I	Ascending node of mean lunar orbit 
c  				 (degrees)
c  dPsi		R*8	 O	Nutation in longitude (degrees)
c  Eps		R*8	 O	Obliquity of the Ecliptic (degrees)
c 				 (includes nutation in obliquity)
c
c
c	Program written by:	Frederick S. Patt
c				General Sciences Corporation
c				October 21, 1992
c
c	Modification History:
c
C     !USES: ===========================================================
      IMPLICIT NONE

C     !INPUT PARAMETERS: ===============================================
      _RL radeg, t, xls, gs, xlm, omega
c     INTEGER myThid

C     !OUTPUT PARAMETERS: ==============================================
      _RL dpsi, eps

C     !FUNCTIONS: ======================================================

C     !LOCAL VARIABLES: ================================================
      _RL epsm, deps
CEOP


c  Nutation in Longitude
      dpsi = - 17.1996D0*sin(omega/radeg) 
     * + 0.2062D0*sin(2.0D0*omega/radeg)
     * - 1.3187D0*sin(2.0D0*xls/radeg) 
     * + 0.1426D0*sin(gs/radeg) 
     * - 0.2274D0*sin(2.0D0*xlm/radeg) 

c  Mean Obliquity of the Ecliptic	
      epsm = 23.439291D0 - 3.560D-7*t 

c  Nutation in Obliquity 
      deps = 9.2025D0*cos(omega/radeg) + 0.5736D0*cos(2.0D0*xls/radeg)

c  True Obliquity of the Ecliptic 
      eps = epsm + deps/3600.0D0

      dpsi = dpsi/3600.0D0

      return
      end
c
