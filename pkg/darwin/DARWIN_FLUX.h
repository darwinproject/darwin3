#ifdef ALLOW_DARWIN

CBOP
C     !ROUTINE: DARWIN_FLUX.h
C     !INTERFACE:
C #include DARWIN_FLUX.h

C     !DESCRIPTION:
C Contains surface means needed for carbon chemistry surface forcing
C
C Requires: SIZE.h
C

#ifdef DARWIN_ALLOW_CARBON

       COMMON /GLOBAL_SURF_MEAN/ gsm_ALK,gsm_S,gsm_DIC
      _RL gsm_ALK
      _RL gsm_S
      _RL gsm_DIC

#endif

CEOP
#endif /* ALLOW_DARWIN */
