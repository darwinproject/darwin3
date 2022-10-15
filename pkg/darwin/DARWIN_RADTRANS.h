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

C     COMMON /DARWIN_RADTRANS_PARAMS_l/ boolean parameters for using radtrans with darwin
C     darwin_allomSpectra :: enable/disable allometric scaling of plankton absorption and scattering spectra
      COMMON /DARWIN_RADTRANS_PARAMS_l/
     &    darwin_allomSpectra
      LOGICAL darwin_allomSpectra

C     COMMON /DARWIN_RADTRANS_PARAMS_c/ character parameters for using radtrans with darwin
C     darwin_waterAbsorbFile    :: filename for reading water absorption and scattering spectra
C     darwin_phytoAbsorbFile    :: filename for reading plankton absorption and scattering spectra
C     darwin_particleAbsorbFile :: filename for reading particle absorption and scattering spectra
      COMMON /DARWIN_RADTRANS_PARAMS_c/
     &    darwin_waterAbsorbFile,
     &    darwin_phytoAbsorbFile,
     &    darwin_particleAbsorbFile
      CHARACTER*256 darwin_waterAbsorbFile
      CHARACTER*256 darwin_phytoAbsorbFile
      CHARACTER*256 darwin_particleAbsorbFile

C     COMMON /DARWIN_RADTRANS_PARAMS_r/
C     darwin_part_size_P       :: [mmol P/particle]  conversion factor for particle absorption and scattering spectra
C     darwin_bbmin             :: [1/m]        minimum backscattering ratio
C     darwin_bbw               :: []           backscattering ratio of water
C     darwin_lambda_aCDOM      :: [nm]         reference wavelength for CDOM absorption spectra
C     darwin_Sdom              :: [1/nm]       coefficient for CDOM absorption spectra
C     darwin_aCDOM_fac         :: []           factor for computing aCDOM from water+Chlorophyll absorption
C     darwin_rCDOM             :: [mmol C/m3]  recalcitrant CDOM concentration
C                                              (with #define DARWIN_CDOM_UNITS_CARBON)
C     darwin_rCDOM             :: [mmol P/m3]  recalcitrant CDOM concentration
C                                              (with #undef DARWIN_CDOM_UNITS_CARBON)
C     darwin_RPOC              :: [mmol C/m3]  recalcitrant POC concentration
C-
C     darwin_aCarCell          :: [mg C/cell]  coefficient coefficient for scaling plankton spectra
C     darwin_bCarCell          :: []           coefficient coefficient for scaling plankton spectra
C     darwin_absorpSlope       :: []           slope for scaled absorption spectra
C     darwin_bbbSlope          :: []           slope for scaled backscattering ratio spectra
C     darwin_scatSwitchSizeLog :: [log10(um)]  log of size for switching slopes
C     darwin_scatSlopeSmall    :: []           slope for small plankton
C     darwin_scatSlopeLarge    :: []           slope for large plankton
      COMMON /DARWIN_RADTRANS_PARAMS_r/
     &    darwin_part_size_P,
     &    darwin_bbmin,
     &    darwin_bbw,
     &    darwin_lambda_aCDOM,
     &    darwin_Sdom,
     &    darwin_aCDOM_fac,
     &    darwin_rCDOM,
     &    darwin_RPOC,
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
      _RL darwin_rCDOM
      _RL darwin_RPOC
      _RL darwin_aCarCell
      _RL darwin_bCarCell
      _RL darwin_absorpSlope
      _RL darwin_bbbSlope
      _RL darwin_scatSwitchSizeLog(nlam)
      _RL darwin_scatSlopeSmall(nlam)
      _RL darwin_scatSlopeLarge(nlam)

C     COMMON /DARWIN_RT_DEPPARAMS_r/
C     aw               :: [m^-1]             absorption coefficient for water
C     bw               :: [m^-1]             total scattering coefficient for water
C     aphy_chl_type    :: [m^2 (mg Chl)^-1]  phytoplankton Chl-specific absorption coefficient by optical type
C     aphy_chl_ps_type :: [m^2 (mg Chl)^-1]  part of aphy_chl_type that is available for phtosynthesis
C     aphy_mgC_type    :: [m^2 (mg C)^-1]    plankton carbon-specific absorption coefficient by optical type
C     bphy_mgC_type    :: [m^2 (mg C)^-1]    carbon-specific total scttering coefficient by optical type
C     bbphy_mgC_type   :: [m^2 (mg C)^-1]    carbon-specific backscattering coefficient by optical type
C     asize            :: [um]               reference cell diameter for aphy_chl_type
C     apsize           :: [um]               reference cell diameter for aphy_chl_ps_type
C     asize_mgC        :: [um]               reference cell diameter for aphy_mgC_type
C     bsize            :: [um]               reference cell diameter for bphy_mgC_type
C     bbsize           :: [um]               reference cell diameter for bbphy_mgC_type
C     apart            :: [m^-1]             absorption coefficient for detritus read in from file
C     bpart            :: [m^-1]             total scattering coefficient for detritus read in from file
C     bbpart           :: [m^-1]             backscattering coefficient for detritus read in from file
C     apart_P          :: [m^2 (mmol P)^-1]  P-specific absorption coefficient for detritus
C     bpart_P          :: [m^2 (mmol P)^-1]  P-specific total scattering coefficient for detritus
C     bbpart_P         :: [m^2 (mmol P)^-1]  P-specific backscattering coefficient for detritus
C     exCDOM           :: [ ]                wavelength-dependent part of CDOM absorption spectrum
      COMMON /DARWIN_RT_DEPPARAMS_r/
     &    aw,
     &    bw,
     &    aphy_chl_type,
     &    aphy_chl_ps_type,
     &    aphy_mgC_type,
     &    bphy_mgC_type,
     &    bbphy_mgC_type,
     &    asize,
     &    apsize,
     &    asize_mgC,
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
      _RL aphy_mgC_type(nopt,nlam)
      _RL bphy_mgC_type(nopt,nlam)
      _RL bbphy_mgC_type(nopt,nlam)
      _RL asize(nopt)
      _RL apsize(nopt)
      _RL asize_mgC(nopt)
      _RL bsize(nopt)
      _RL bbsize(nopt)
      _RL apart(nlam)
      _RL bpart(nlam)
      _RL bbpart(nlam)
      _RL apart_P(nlam)
      _RL bpart_P(nlam)
      _RL bbpart_P(nlam)
      _RL exCDOM(nlam)

C     COMMON /DARWIN_RADTRANS_TRAITS_r/
C     aphy_chl    :: [m^2 (mg Chl)^-1]  phytoplankton Chl-specific absorption coefficient
C     aphy_chl_ps :: [m^2 (mg Chl)^-1]  part of aphy_chl that is used in photosynthesis
C     aphy_mgC    :: [m^2 (mg C)^-1]    plankton carbon-specific absorption coefficient
C     bphy_mgC    :: [m^2 (mg C)^-1]    carbon-specific total scattering coefficient
C     bbphy_mgC   :: [m^2 (mg C)^-1]    carbon-specific backscattering coefficient
      COMMON /DARWIN_RADTRANS_TRAITS_r/
     &    aphy_chl,
     &    aphy_chl_ps,
     &    aphy_mgC,
     &    bphy_mgC,
     &    bbphy_mgC
      _RL aphy_chl(nplank,nlam)
      _RL aphy_chl_ps(nplank,nlam)
      _RL aphy_mgC(nplank,nlam)
      _RL bphy_mgC(nplank,nlam)
      _RL bbphy_mgC(nplank,nlam)

#endif /* ALLOW_RADTRANS */

C     COMMON /DARWIN_RT_DEPTRAITS_r/
C     alphachl :: [mmol C m^2 (uEin mg Chl)^-1]  Chlorophyll-specific initial slope for photosynthesis
      COMMON /DARWIN_RT_DEPTRAITS_r/
     &    alphachl
      _RL alphachl(nplank,nlam)

CEOP
#endif /* ALLOW_DARWIN */
