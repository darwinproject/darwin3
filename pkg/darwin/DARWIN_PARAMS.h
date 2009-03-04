C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/DARWIN_PARAMS.h,v 1.1 2009/03/04 20:47:39 jahn Exp $
C $Name:  $

c DARWIN_PARAMS.h 
c description: runtime configurable parameters for darwin package
c
#ifdef DAR_DIAG_CHL
      COMMON/DAR_DIAG_CHL_PARAMS/
     &       Geider_Bigalphachl, Geider_smallalphachl,
     &       Geider_Bigchl2cmax, Geider_smallchl2cmax,
     &       Geider_Bigchl2cmin, Geider_smallchl2cmin,
     &       Doney_Bmin, Doney_Bmax, Doney_PARstar,
     &       Cloern_A, Cloern_B, Cloern_C, Cloern_chl2cmin
      _RL Geider_Bigalphachl
      _RL Geider_Smallalphachl
      _RL Geider_Bigchl2cmax
      _RL Geider_Smallchl2cmax
      _RL Geider_Bigchl2cmin
      _RL Geider_smallchl2cmin
      _RL Doney_Bmin
      _RL Doney_Bmax
      _RL Doney_PARstar
      _RL Cloern_chl2cmin
      _RL Cloern_A
      _RL Cloern_B
      _RL Cloern_C
#endif /* DAR_DIAG_CHL */

