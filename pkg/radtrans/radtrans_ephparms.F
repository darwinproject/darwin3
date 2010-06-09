C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/radtrans/radtrans_ephparms.F,v 1.1 2010/06/09 15:59:37 jahn Exp $
C $Name:  $

#include "RADTRANS_OPTIONS.h"

CBOP
C !ROUTINE: RADTRANS_EPHPARMS

C !INTERFACE: ==========================================================
      subroutine radtrans_ephparms (t, 
     O                              xls, gs, xlm, omega)

C !DESCRIPTION:
c  This subroutine computes ephemeris parameters used by other Mission
c  Operations routines:  the solar mean longitude and mean anomaly, and
c  the lunar mean longitude and mean ascending node.  It uses the model
c  referenced in The Astronomical Almanac for 1984, Section S 
c  (Supplement) and documented and documented in Exact closed-form 
c  geolocation algorithm for Earth survey sensors, by F.S. Patt and 
c  W.W. Gregg, Int. Journal of Remote Sensing, 1993.  These parameters 
c  are used to compute the solar longitude and the nutation in 
c  longitude and obliquity.
c
c	Program written by:	Frederick S. Patt
c				General Sciences Corporation
c				November 2, 1992
 
c  Calling Arguments
C !USES: ===============================================================
      IMPLICIT NONE

C !INPUT PARAMETERS: ===================================================
c  t      :: Time in days since January 1, 2000 at 12 hours UT
      _RL t
c      INTEGER myThid

C !OUTPUT PARAMETERS: ==================================================
c  xls	 :: Mean solar longitude (degrees)
c  gs	 :: Mean solar anomaly (degrees)
c  xlm	 :: Mean lunar longitude (degrees)
c  omega :: Ascending node of mean lunar orbit (degrees)
      _RL xls, gs, xlm, omega
CEOP

C !LOCAL VARIABLES: ====================================================
c

c  Sun Mean Longitude 		
      xls = 280.46592D0 + 0.9856473516D0*t
      xls = mod(xls,360.0)
 
c  Sun Mean Anomaly		
      gs = 357.52772D0 + 0.9856002831D0*t 
      gs = mod(gs,360.0)

c  Moon Mean Longitude		
      xlm = 218.31643D0 + 13.17639648D0*t 
      xlm = mod(xlm,360.0)

c  Ascending Node of Moons Mean Orbit 	
      omega = 125.04452D0 - 0.0529537648D0*t 
      omega = mod(omega,360.0)

      return
      end

