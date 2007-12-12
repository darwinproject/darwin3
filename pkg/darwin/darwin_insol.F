C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_insol.F,v 1.2 2007/12/12 21:19:01 jahn Exp $
C $Name:  $

#include "CPP_OPTIONS.h"

C     Procedure name: DARWIN_INSOL
C           Function: find time scale for plankton growth as
C                     function of light
c                     based on paltridge and parson
C           Comments: swd, April 1998
C                     following code by mick
C============================================================================
CStartofinterface
      SUBROUTINE darwin_insol(Time,sfac,bj)
      IMPLICIT NONE
C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "FFIELDS.h"
#include "GRID.h"
#include "DYNVARS.h"
C     =============== Global data ==========================================
       _RL time
       _RL sfac(1-OLy:sNy+OLy)
       integer bj
C============== Local variables ============================================
       _RL  solar, albedo, par
       _RL  dayfrac, yday, delta
       _RL  lat, sun1, dayhrs
       _RL  cosz, frac, fluxi
       integer j
c
      solar = 1360. _d 0   !solar constant
      albedo = 0.6 _d 0    !planetary albedo
      par = 0.4 _d 0       !photosynthetically reactive frac
c
c find day (****NOTE for year starting in 1 Jan *****)
        dayfrac=mod(Time,360. _d 0*86400. _d 0)
     &                    /(360. _d 0*86400. _d 0)        !fraction of year
        yday = 2.0 _d 0*3.1416 _d 0*dayfrac               !convert to radians
        delta = (0.006918 _d 0- (0.399912 _d 0*cos(yday)) !cosine zenith angle
     &          +(0.070257 _d 0*sin(yday))                 !(paltridge+platt)
     &          -(0.006758 _d 0*cos(2.0 _d 0*yday))
     &          +(0.000907 _d 0*sin(2.0 _d 0*yday))
     &          -(0.002697 _d 0*cos(3.0 _d 0*yday))
     &          +(0.001480 _d 0*sin(3.0 _d 0*yday)) )
       do j=1-OLy,sNy+OLy
c latitude in radians
          lat=YC(1,j,1,bj)/180. _d 0*3.1416 _d 0
          sun1 = -sin(delta)/cos(delta) * sin(lat)/cos(lat)
          if (sun1.le.-0.999 _d 0) sun1=-0.999 _d 0
          if (sun1.ge. 0.999 _d 0) sun1= 0.999 _d 0
          dayhrs = abs(acos(sun1))
          cosz = ( sin(delta)*sin(lat)+              !average zenith angle
     &            (cos(delta)*cos(lat)*sin(dayhrs)/dayhrs) )
          if (cosz.le.0.005 _d 0) cosz=0.005 _d 0
          frac = dayhrs/3.1416 _d 0           !fraction of daylight in day
c daily average photosynthetically active solar radiation just below surface
          fluxi = solar*(1.0 _d 0-albedo)*cosz*frac*par
c
c convert to sfac
          if (fluxi.gt.0.0 _d 0) sfac(j)=fluxi
c very large for polar night
          if (fluxi.lt.0.00001 _d 0) sfac(j)=0.00001 _d 0
       enddo !j
c
      return
      end
c
C==========================================================================
