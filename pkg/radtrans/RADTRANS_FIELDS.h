#ifdef ALLOW_RADTRANS

CBOP
C     !ROUTINE: RADTRANS_FIELDS.h
C     !INTERFACE:
C #include RADTRANS_FIELDS.h

C     !DESCRIPTION:
C Contains fields for time interpolation of forcing fields in the
C radtrans package
C
C Requires: SIZE.h
C Requires: RADTRANS_SIZE.h

      COMMON /RADTRANS_FIELDS_R/
     &    RT_Ed0, RT_Ed1, RT_Ed_sfc,
     &    RT_Es0, RT_Es1, RT_Es_sfc,
     &    RT_ice0, RT_ice1, RT_iceFrac

      _RL RT_Ed0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlam)
      _RL RT_Ed1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlam)
      _RL RT_Ed_sfc(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlam)

      _RL RT_Es0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlam)
      _RL RT_Es1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlam)
      _RL RT_Es_sfc(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlam)


      _RL RT_ice0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL RT_ice1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL RT_iceFrac(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

CEOP
#endif /* ALLOW_RADTRANS */
