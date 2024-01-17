#ifdef ALLOW_OASIM

CBOP
C     !ROUTINE: OASIM_FIELDS.h
C     !INTERFACE:
C #include OASIM_FIELDS.h
C
C     !DESCRIPTION:
C Contains fields for the oasim package
C
C Requires: SIZE.h, OASIM_SIZE.h
CEOP

C--   COMMON /OASIM_FIELDS_I/
C     OASIM_lam :: reference wavelengths of OASIM wavebands [nm]
      INTEGER OASIM_lam(nlt)
      COMMON /OASIM_FIELDS_I/
     &       OASIM_lam

C--   COMMON /OASIM_FIELDS/
C     OASIM_Edabove :: above-surface direct downwelling irradiance
C     OASIM_Esabove :: above-surface diffuse downwelling irradiance
C     OASIM_Edbelow :: below-surface direct downwelling irradiance
C     OASIM_Esbelow :: below-surface diffuse downwelling irradiance
C     OASIM_solz    :: above-water solar zenith angle
C     OASIM_rmud    :: inverse cosine of below-water solar zenith angle
      _RL OASIM_Edabove(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlt)
      _RL OASIM_Esabove(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlt)
      _RL OASIM_Edbelow(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlt)
      _RL OASIM_Esbelow(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlt)
      _RL OASIM_solz   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL OASIM_rmud   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL OASIM_PARwgt(nlt)
      COMMON /OASIM_FIELDS/
     &       OASIM_Edabove, OASIM_Esabove,
     &       OASIM_Edbelow, OASIM_Esbelow,
     &       OASIM_solz, OASIM_rmud,
     &       OASIM_PARwgt

C--   COMMON /OASIM_FORCING_R/ forcing fields
      COMMON /OASIM_FORCING_R/
     &    aerTau0, aerTau1, taua,
     &    asymp0, asymp1, asymp,
     &    ssalb0, ssalb1, ssalb,
     &    cldcov0, cldcov1, ccov,
     &    cldlwp0, cldlwp1, rlwp,
     &    cldre0, cldre1, cdre,
     &    pres0, pres1, slp,
     &    oawind0, oawind1, wsm,
     &    relhum0, relhum1, rh,
     &    ozone0, ozone1, oz,
     &    wv0, wv1, wv

      _RL aerTau0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlt)
      _RL aerTau1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlt)
      _RL taua(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlt)

      _RL asymp0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlt)
      _RL asymp1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlt)
      _RL asymp(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlt)

      _RL ssalb0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlt)
      _RL ssalb1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlt)
      _RL ssalb(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy,nlt)

      _RL cldcov0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL cldcov1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL ccov(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL cldlwp0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL cldlwp1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL rlwp(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL cldre0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL cldre1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL cdre(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL pres0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL pres1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL slp(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL oawind0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL oawind1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL wsm(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL relhum0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL relhum1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL rh(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL ozone0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL ozone1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL oz(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL wv0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL wv1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL wv(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

C--   COMMON /oasim_localvec/
C     OASIM_up :: local vertical vector
C     OASIM_no :: local North vector
C     OASIM_ea :: local East vector
      _RL OASIM_up(sNx,sNy,nSx,nSy,3)
      _RL OASIM_no(sNx,sNy,nSx,nSy,3)
      _RL OASIM_ea(sNx,sNy,nSx,nSy,3)
      COMMON/oasim_localvec/ OASIM_up, OASIM_no, OASIM_ea

#endif /* ALLOW_OASIM */
