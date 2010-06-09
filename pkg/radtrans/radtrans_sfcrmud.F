C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/radtrans/radtrans_sfcrmud.F,v 1.1 2010/06/09 15:59:38 jahn Exp $
C $Name:  $

#include "RADTRANS_OPTIONS.h"

CBOP
C     !ROUTINE: RADTRANS_SFCRMUD

C     !INTERFACE: ======================================================
      subroutine radtrans_sfcrmud(rad,sunz,
     O                            rmud)

C     !DESCRIPTION:
c     Computes average cosine for direct irradiance.
c
C     !USES: ===========================================================
      IMPLICIT NONE

C     !INPUT PARAMETERS: ===============================================
      _RL rad
      _RL sunz
c     INTEGER myThid

C     !OUTPUT PARAMETERS: ==============================================
      _RL rmud

C     !FUNCTIONS: ======================================================

C     !LOCAL VARIABLES: ================================================
      _RL rsza, sinszaw, szaw, rmudl, rn
      data rn /1.341 _d 0/  !refractive index of seawater
CEOP

c
c  Compute average cosine for direct irradiance in the water 
c  column given solar zenith angle (in degrees) at surface.
c
      rsza = sunz/rad
      sinszaw = sin(rsza)/rn
      szaw = asin(sinszaw)
      rmudl = 1.0/cos(szaw)   !avg cosine direct (1 over)
      rmud = min(rmudl,1.5)
      rmud = max(rmud,0.0)
c
      return
      end
