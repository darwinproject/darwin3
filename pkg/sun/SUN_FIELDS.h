#ifdef ALLOW_SUN

CBOP
C !ROUTINE: SUN_FIELDS.h
C !INTERFACE:
C #include SUN_FIELDS.h

C !DESCRIPTION:
C Contains fields for the sun package
C
C Requires: SIZE.h
C

      COMMON /SUN_FIELDS_R/ SUN_up, SUN_no, SUN_ea
      _RL SUN_up(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,3)
      _RL SUN_no(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,3)
      _RL SUN_ea(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,3)

CEOP

#endif /* ALLOW_SUN */
