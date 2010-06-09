C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/radtrans/radtrans_localvec.F,v 1.1 2010/06/09 15:59:37 jahn Exp $
C $Name:  $

#include "RADTRANS_OPTIONS.h"

CBOP
C     !ROUTINE: RADTRANS_LOCALVEC

C     !INTERFACE: ======================================================
      subroutine radtrans_localvec(rad,xlon,ylat,
     O                             up,no,ea)

C     !DESCRIPTION:
c  Create arrays of up, north, and east vectors for fixed locations
c  corresponding to these nwater indicators.  
c
C     !USES: ===========================================================
      IMPLICIT NONE

C     !INPUT PARAMETERS: ===============================================
      _RL rad, xlon,ylat
c     INTEGER myThid

C     !OUTPUT PARAMETERS: ==============================================
      _RL up(3),no(3),ea(3)

C     !FUNCTIONS: ======================================================

C     !LOCAL VARIABLES: ================================================
      _RL rlon,cosx,sinx,rlat,cosy,siny,upxy
CEOP


c  Compute local east, north, and vertical vectors 
      no = 0.0
      ea = 0.0
      up = 0.0
c
c  Convert geodetic lat/lon to Earth-centered, earth-fixed (ECEF)
c  vector (geodetic unit vector)
      rlon = xlon/rad
      cosx = cos(rlon)
      sinx = sin(rlon)
      rlat = ylat/rad
      cosy = cos(rlat)
      siny = sin(rlat)
c
c  Compute the local up, East and North unit vectors
      up(1) = cosy*cosx
      up(2) = cosy*sinx
      up(3) = siny
      upxy = sqrt(up(1)*up(1)+up(2)*up(2))
      ea(1) = -up(2)/upxy
      ea(2) = up(1)/upxy
      no(1) = up(2)*ea(3) - up(3)*ea(2)  !cross product
      no(2) = up(3)*ea(1) - up(1)*ea(3)
      no(3) = up(1)*ea(2) - up(2)*ea(1)
      write(6,*)'Local pointing vectors'
      write(6,*)'no(2) = ',no
      write(6,*)'ea(2) = ',ea
      write(6,*)'up(2) = ',up
c
      return
      end
