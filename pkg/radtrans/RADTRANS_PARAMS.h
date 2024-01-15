#ifdef ALLOW_RADTRANS

CBOP
C     !ROUTINE: RADTRANS_PARAMS.h
C     !INTERFACE:
C #include RADTRANS_PARAMS.h

C     !DESCRIPTION:
C Contains parameters for the radtrans package
C
C Requires: RADTRANS_SIZE.h

C  RT_loadFieldsEarly :: whether forcing fields need to be read early
C                        for initialization

      COMMON/radtrans_forcing_params_l/
     &    RT_loadFieldsEarly

      LOGICAL RT_loadFieldsEarly

C Radtrans forcing parameters work just like the parameters in the exf
C package.  The forcing files are as follows:
C
C   RT_EdFile  :: downward direct irradiance below sea surface [W/m^2]
C                 per waveband, not taking into account ice cover
C   RT_EsFile  :: downward diffuse irradiance below sea surface [W/m^2]
C                 per waveband, not taking into account ice cover
C   RT_iceFile :: fraction of the sea surface covered by ice
C                 used to reduce incoming irradiances
C
C Parameters for interpolation are in RADTRANS_EXF_PARAMS.h

      COMMON/radtrans_forcing_c/
     &    RT_E_mask, RT_EdFile, RT_EsFile
      COMMON/radtrans_forcing_i/
     &    RT_E_startdate1, RT_E_startdate2
      COMMON/radtrans_forcing_r/
     &    RT_E_startTime, RT_E_period, RT_E_RepCycle,
     &    RT_Ed_const, RT_Es_const,
     &    RT_Ed_exfremo_intercept, RT_Es_exfremo_intercept,
     &    RT_Ed_exfremo_slope, RT_Es_exfremo_slope,
     &    RT_inscal_Ed, RT_inscal_Es
      CHARACTER*128  RT_EdFile(nlam)
      CHARACTER*128  RT_EsFile(nlam)
      CHARACTER*1 RT_E_mask
      INTEGER RT_E_startdate1
      INTEGER RT_E_startdate2
      _RL RT_E_StartTime
      _RL RT_E_period
      _RL RT_E_RepCycle
      _RL RT_Ed_const(nlam)
      _RL RT_Es_const(nlam)
      _RL RT_Ed_exfremo_intercept(nlam)
      _RL RT_Es_exfremo_intercept(nlam)
      _RL RT_Ed_exfremo_slope(nlam)
      _RL RT_Es_exfremo_slope(nlam)
      _RL RT_inscal_Ed(nlam)
      _RL RT_inscal_Es(nlam)

      COMMON/RT_forcing_ice_c/
     &    RT_icemask, RT_icefile
      COMMON/RT_forcing_ice_i/
     &    RT_icestartdate1, RT_icestartdate2
      COMMON/RT_forcing_ice_r/
     &    RT_iceStartTime,
     &    RT_iceperiod, RT_iceRepCycle, RT_iceconst,
     &    RT_ice_exfremo_intercept, RT_ice_exfremo_slope,
     &    RT_inscal_ice
      CHARACTER*128  RT_icefile
      CHARACTER*1 RT_icemask
      INTEGER RT_icestartdate1
      INTEGER RT_icestartdate2
      _RL RT_iceStartTime
      _RL RT_iceperiod
      _RL RT_iceRepCycle
      _RL RT_iceconst
      _RL RT_ice_exfremo_intercept
      _RL RT_ice_exfremo_slope
      _RL RT_inscal_ice

C other run-time parameters
C
C  RT_refract_water  :: refractive index of water
C  RT_rmud_max       :: cutoff for inverse cosine of solar zenith angle
C  RT_wbRefWLs       :: reference wavelengths for wavebands [nm]
C  RT_wbEdges        :: waveband edges [nm]
C  RT_rmus           :: mean inverse cosine of zenith angle for downward
C                       diffuse irradiance
C  RT_rmuu           :: mean inverse cosine of zenith angle for upward
C                       diffuse irradiance
C  RT_rd             :: mean upward scattering fraction for downward
C                       diffuse irradiance
C  RT_ru             :: mean downward scattering fraction for upward
C                       diffuse irradiance
C  RT_sfcIrrThresh   :: minimum irradiance for radiative transfer
C                       computations [W/m^2]
C  RT_kmax           :: maximum depth index for radtrans computations
C  RT_useMeanCosSolz :: flag for using mean daytime cosine of solar zenith angle
C  RT_useNoonSolz    :: flag for using noon solar zenith angle;
C                       if false use angle at actual time

      COMMON/radtrans_params_r/
     &    RT_refract_water,
     &    RT_rmud_max,
     &    RT_wbRefWLs,
     &    RT_wbEdges,
     &    RT_wbWidths,
     &    RT_wbTotalWidth,
     &    RT_WtouEins,
     &    RT_rmus, RT_rmuu, RT_rd, RT_ru,
     &    RT_sfcIrrThresh
      _RL RT_refract_water
      _RL RT_rmud_max
      _RL RT_wbRefWLs(nlam)
      _RL RT_wbEdges(nlam+1)
      _RL RT_wbWidths(nlam)
      _RL RT_wbTotalWidth
      _RL RT_WtouEins(nlam)
      _RL RT_rmus, RT_rmuu, RT_rd, RT_ru
      _RL RT_sfcIrrThresh

      COMMON/radtrans_params_i/ RT_kmax
      INTEGER RT_kmax

      COMMON/radtrans_params_l/
     &    RT_useMeanCosSolz,
     &    RT_useNoonSolz,
     &    RT_useSEAICE,
     &    RT_haveIce
      LOGICAL RT_useMeanCosSolz
      LOGICAL RT_useNoonSolz
      LOGICAL RT_useSEAICE
      LOGICAL RT_haveIce
CEOP

#endif /* ALLOW_RADTRANS */
