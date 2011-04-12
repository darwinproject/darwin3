C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/DARWIN_FIELDS.h,v 1.1 2011/04/12 19:22:51 jahn Exp $
C $Name:  $

#include "DARWIN_OPTIONS.h"

c DARWIN_FIELDS.h
c --------------------------------------------------------------------
c  Description:  fields for DARWIN pkg
c --------------------------------------------------------------------      

C Chl_phy :: diagnostic Chlorophyll to be used in next time step
C            for attenuation, ....

#ifndef DYNAMIC_CHL
#ifdef GEIDER
      COMMON /DARWIN_CHL/
     &      Chl_phy          
         _RL Chl_phy(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx, nSy,npmax)
#endif
#endif

