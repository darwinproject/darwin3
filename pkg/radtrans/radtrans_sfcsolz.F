C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/radtrans/radtrans_sfcsolz.F,v 1.1 2010/06/09 15:59:38 jahn Exp $
C $Name:  $

#include "RADTRANS_OPTIONS.h"

CBOP
C     !ROUTINE: RADTRANS_SFCSOLZ

C     !INTERFACE: ======================================================
      subroutine radtrans_sfcsolz(rad,iyr,imon,iday,isec,xlon,ylat,
     O                            solz)

C     !DESCRIPTION:
c SLIGHTLY MODIFIED FORM WG sfsolz
c original version contained subroutine code for
c localvec
c which is here separated into separate file
c
c  Computes solar zenith angle at surface given location 
c  and time.  
c

C     !USES: ===========================================================
      IMPLICIT NONE

C     !INPUT PARAMETERS: ===============================================
      INTEGER iyr, imon, iday, isec
      _RL rad, xlon, ylat
c     INTEGER myThid

C     !OUTPUT PARAMETERS: ==============================================
      _RL solz

C     !FUNCTIONS: ======================================================

C     !LOCAL VARIABLES: ================================================

c
c ifst is not used, so don't need this ???
c      save
      _RL up(3),no(3),ea(3),gmt,rs
c      data ifst /0/
CEOP


c  Local direction vector
      call radtrans_localvec(rad,xlon,ylat,up,no,ea)
c
c  Solar zenith angle
      solz = -1.0
      gmt = float(isec)/3600.
      call radtrans_sunmod(rad,iday,imon,iyr,gmt,up,no,ea,solz,rs)
c
      return
      end
c
c **********************************************************************
c HERE SUBROUTINE localvec REMOVED AND PUT IN SEP FILE
