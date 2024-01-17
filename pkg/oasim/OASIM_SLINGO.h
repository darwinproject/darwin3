#ifdef ALLOW_OASIM

CBOP
C     !ROUTINE: OASIM_SLINGO.h
C     !INTERFACE:
C #include OASIM_SLINGO.h

C     !DESCRIPTION:
C     global variables for slingo cloud model
CEOP

      INTEGER ncld
      PARAMETER(ncld=24)
      _RL rnl1(ncld),rnl2(ncld)
      _RL asl(ncld),bsl(ncld),csl(ncld),dsl(ncld)
      _RL esl(ncld),fsl(ncld)
      COMMON /OASIM_SLINGO_PARMS/ rnl1,rnl2,asl,bsl,csl,dsl,esl,fsl

      INTEGER ica(nlt)
      _RL U1
      COMMON /OASIM_SLINGO_SAVE/ U1
      COMMON /OASIM_BICA/ ica

#endif /* ALLOW_OASIM */
