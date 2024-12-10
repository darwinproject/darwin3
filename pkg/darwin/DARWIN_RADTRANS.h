#ifdef ALLOW_DARWIN
CBOP
C    !ROUTINE: DARWIN_RADTRANS.h
C    !INTERFACE:
C #include DARWIN_RADTRANS.h
C
C    !DESCRIPTION:
C Contains radtrans-related parameters for the darwin package
C
C Requires: RADTRANS_SIZE.h
C Requires: DARWIN_SIZE.h

#ifdef ALLOW_RADTRANS

      COMMON /DARWIN_RADTRANS_PARAMS_l/
     &    darwin_allomSpectra
      LOGICAL darwin_allomSpectra
      COMMON /DARWIN_RADTRANS_PARAMS_c/
     &    darwin_waterAbsorbFile,
     &    darwin_phytoAbsorbFile,
     &    darwin_particleAbsorbFile
      CHARACTER*256 darwin_waterAbsorbFile
      CHARACTER*256 darwin_phytoAbsorbFile
      CHARACTER*256 darwin_particleAbsorbFile
      COMMON /DARWIN_RADTRANS_PARAMS_r/
     &    darwin_part_size_P,
     &    darwin_bbmin,
     &    darwin_bbw,
     &    darwin_lambda_aCDOM,
     &    darwin_Sdom,
     &    darwin_aCDOM_fac,
     &    darwin_aCarCell,
     &    darwin_bCarCell,
     &    darwin_absorpSlope,
     &    darwin_bbbSlope,
     &    darwin_scatSwitchSizeLog,
     &    darwin_scatSlopeSmall,
     &    darwin_scatSlopeLarge
      _RL darwin_part_size_P
      _RL darwin_bbmin
      _RL darwin_bbw
      _RL darwin_lambda_aCDOM
      _RL darwin_Sdom
      _RL darwin_aCDOM_fac
      _RL darwin_aCarCell
      _RL darwin_bCarCell
      _RL darwin_absorpSlope
      _RL darwin_bbbSlope
      _RL darwin_scatSwitchSizeLog(nlam)
      _RL darwin_scatSlopeSmall(nlam)
      _RL darwin_scatSlopeLarge(nlam)

      COMMON /DARWIN_RT_DEPPARAMS_r/
     &    aw,
     &    bw,
     &    aphy_chl_type,
     &    aphy_chl_ps_type,
     &    bphy_mgC_type,
     &    bbphy_mgC_type,
     &    asize,
     &    apsize,
     &    bsize,
     &    bbsize,
     &    apart,
     &    bpart,
     &    bbpart,
     &    apart_P,
     &    bpart_P,
     &    bbpart_P,
     &    exCDOM
      _RL aw(nlam)
      _RL bw(nlam)
      _RL aphy_chl_type(nopt,nlam)
      _RL aphy_chl_ps_type(nopt,nlam)
      _RL bphy_mgC_type(nopt,nlam)
      _RL bbphy_mgC_type(nopt,nlam)
      _RL asize(nopt)
      _RL apsize(nopt)
      _RL bsize(nopt)
      _RL bbsize(nopt)
      _RL apart(nlam)
      _RL bpart(nlam)
      _RL bbpart(nlam)
      _RL apart_P(nlam)
      _RL bpart_P(nlam)
      _RL bbpart_P(nlam)
      _RL exCDOM(nlam)


      COMMON /DARWIN_RADTRANS_TRAITS_r/
     &    aphy_chl,
     &    aphy_chl_ps,
     &    bphy_mgC,
     &    bbphy_mgC
      _RL aphy_chl(nplank,nlam)
      _RL aphy_chl_ps(nplank,nlam)
      _RL bphy_mgC(nplank,nlam)
      _RL bbphy_mgC(nplank,nlam)

#endif /* ALLOW_RADTRANS */

      COMMON /DARWIN_RT_DEPTRAITS_r/
     &    alphachl
      _RL alphachl(nplank,nlam)

CEOP
#endif /* ALLOW_DARWIN */
