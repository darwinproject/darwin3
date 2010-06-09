C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/radtrans/radtrans_sunmod.F,v 1.1 2010/06/09 15:59:38 jahn Exp $
C $Name:  $

#include "RADTRANS_OPTIONS.h"

CBOP
C     !ROUTINE: RADTRANS_SUNMOD

C     !INTERFACE: ======================================================
      subroutine radtrans_sunmod(rad,iday,imon,iyr,gmt,up,no,ea,
     O                           sunz,rs)

C     !DESCRIPTION:
c MODIFIED only by separating subroutines that were previously included
c
c  Given year, day of year, time in hours (GMT) and latitude and 
c  longitude, returns an accurate solar zenith and azimuth angle.  
c  Based on IAU 1976 Earth ellipsoid.  Method for computing solar 
c  vector and local vertical from Patt and Gregg, 1994, Int. J. 
c  Remote Sensing.  Only outputs solar zenith angle.  This version
c  utilizes a pre-calculation of the local up, north, and east 
c  vectors, since the locations where the solar zenith angle are 
c  calculated in the model are fixed.
c
c  Subroutines required: sun2000
c                        gha2000
c                        jd
c
C     !USES: ===========================================================
      IMPLICIT NONE

C     !INPUT PARAMETERS: ===============================================
      INTEGER iday, imon, iyr
      _RL rad, gmt, up(3), no(3), ea(3)
c     INTEGER myThid

C     !OUTPUT PARAMETERS: ==============================================
      _RL sunz, rs

C     !FUNCTIONS: ======================================================

C     !LOCAL VARIABLES: ================================================
      INTEGER j
      _RL radeg, sec, day, gha, ghar, sunv, sunn, sune
      _RL suni(3),sung(3)
CEOP


      radeg = rad
c  Compute sun vector
c   Compute unit sun vector in geocentric inertial coordinates
      sec = gmt*3600.0D0
      call radtrans_sun2000 (radeg, iyr, imon, iday, sec, suni, rs)

c   Get Greenwich mean sidereal angle
      day = float(iday) + sec/86400.0D0
      call radtrans_gha2000 (radeg, iyr, imon, day, gha)
      ghar = gha/radeg

c   Transform Sun vector into geocentric rotating frame
      sung(1) = suni(1)*cos(ghar) + suni(2)*sin(ghar)
      sung(2) = suni(2)*cos(ghar) - suni(1)*sin(ghar)
      sung(3) = suni(3)
c
c  Compute components of spacecraft and sun vector in the
c  vertical (up), North (no), and East (ea) vectors frame
      sunv = 0.0
      sunn = 0.0
      sune = 0.0
      do j = 1,3
       sunv = sunv + sung(j)*up(j)
       sunn = sunn + sung(j)*no(j)
       sune = sune + sung(j)*ea(j)
      enddo
c
c  Compute the solar zenith 
      sunz = radeg*atan2(sqrt(sunn*sunn+sune*sune),sunv)
c
      return
      end
c
c *****************************************************************
c HERE SUBROUTINE sun2000 removed
c *********************************************************************
c HERE SUBROUTINE gha2000 removed
c HERE SUBROUTINE ephparms removed
c HERE SUBROUTINE nutate removed
c HERE FUNCTION jd removed
c ************************************************************************
