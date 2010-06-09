C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_solz360.F,v 1.1 2010/06/09 22:51:36 jahn Exp $
C $Name:  $

#include "DARWIN_OPTIONS.h"

CBOP
C     !ROUTINE: DARWIN_SOLZ360

C     !INTERFACE: ======================================================
      SUBROUTINE darwin_solz360(Time,ylat,
     O                          solz)

C     !DESCRIPTION:
C     Procedure name: DARWIN_SOLZ360
C           Function: find solar zenith angle for model calendar
C                     (360 day year)
c                     based on paltridge and parson
C                     cos(solz) = average cos(sol.zenith) during daylight
C           Comments: swd, April 1998
C                     following code by mick
C
C     !USES: ===========================================================
      IMPLICIT NONE

C     !INPUT PARAMETERS: ===============================================
C     time :: model time in seconds since Jan 1 (of start year)
C     ylat :: latitude in degrees
      _RL time, ylat
c     INTEGER myThid

C     !OUTPUT PARAMETERS: ==============================================
C     delta :: solar zenith angle in degrees
      _RL solz

C     !FUNCTIONS: ======================================================

C     !LOCAL VARIABLES: ================================================
      _RL  dayfrac, yday, delta, lat, sun1, dayhrs, cosz
CEOP

c find day (****NOTE for year starting in 1 Jan *****)
      dayfrac = mod(Time, 360. _d 0*86400. _d 0)
     &          /(360. _d 0*86400. _d 0)                !fraction of year
      yday = 2.0 _d 0*3.1416 _d 0*dayfrac               !convert to radians
      delta = (0.006918 _d 0- (0.399912 _d 0*cos(yday)) !zenith angle
     &        +(0.070257 _d 0*sin(yday))                 !(paltridge+platt)
     &        -(0.006758 _d 0*cos(2.0 _d 0*yday))
     &        +(0.000907 _d 0*sin(2.0 _d 0*yday))
     &        -(0.002697 _d 0*cos(3.0 _d 0*yday))
     &        +(0.001480 _d 0*sin(3.0 _d 0*yday)) )

      lat = ylat/180. _d 0*3.1416 _d 0
      sun1 = -sin(delta)/cos(delta) * sin(lat)/cos(lat)
      if (sun1.le.-0.999 _d 0) sun1=-0.999 _d 0
      if (sun1.ge. 0.999 _d 0) sun1= 0.999 _d 0
      dayhrs = abs(acos(sun1))
      cosz = ( sin(delta)*sin(lat)+              !average zenith angle
     &        (cos(delta)*cos(lat)*sin(dayhrs)/dayhrs) )
      if (cosz.le.0.005 _d 0) cosz=0.005 _d 0
      if (cosz.ge. 0.999 _d 0) cosz= 0.999 _d 0
      solz = acos(cosz)*180. _d 0/3.1416 _d 0
c      frac = dayhrs/3.1416 _d 0           !fraction of daylight in day
cc daily average photosynthetically active solar radiation just below surface
c          fluxi = solar*(1.0 _d 0-albedo)*cosz*frac*par
cc
cc convert to sfac
c          if (fluxi.gt.0.0 _d 0) sfac(j)=fluxi
cc very large for polar night
c          if (fluxi.lt.0.00001 _d 0) sfac(j)=0.00001 _d 0

      return
      end
c
C==========================================================================
