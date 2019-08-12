#ifdef ALLOW_DARWIN

CBOP
C     !ROUTINE: DARWIN_EXF_PARAMS.h
C     !INTERFACE:
C #include DARWIN_EXF_PARAMS.h

C     !DESCRIPTION:
C Contains parameters for reading forcing for darwin package through exf
C
C Requires: EXF_OPTIONS.h
C Requires: EXF_INTERP_SIZE.h

      COMMON/darwin_forcing_exf_params_l/
     &    darwin_loadFieldsEarly
      LOGICAL darwin_loadFieldsEarly


C PAR forcing parameters for exf

      _RL PARStartTime

      COMMON/darwin_forcing_PAR_c/
     &    PARmask
      COMMON/darwin_forcing_PAR_i/
     &    PARstartdate1, PARstartdate2
      COMMON/darwin_forcing_PAR_r/
     &    PARStartTime,
     &    PARperiod, PARRepCycle, PARconst,
     &    PAR_exfremo_intercept, PAR_exfremo_slope,
     &    darwin_inscal_PAR
      CHARACTER*1 PARmask
      INTEGER PARstartdate1
      INTEGER PARstartdate2
      _RL PARperiod
      _RL PARRepCycle
      _RL PARconst
      _RL PAR_exfremo_intercept
      _RL PAR_exfremo_slope
      _RL darwin_inscal_PAR

#ifdef USE_EXF_INTERPOLATION
      COMMON/darwin_interp_PAR_i/
     &    PAR_nlon, PAR_nlat, PAR_interpMethod
      COMMON/darwin_interp_PAR_r/
     &    PAR_lon0, PAR_lat0, PAR_lon_inc, PAR_lat_inc
      INTEGER PAR_interpMethod, PAR_nlon, PAR_nlat
      _RL  PAR_lon0
      _RL  PAR_lat0
      _RL  PAR_lon_inc
      _RL  PAR_lat_inc(MAX_LAT_INC)
#endif

C iron forcing parameters for exf

      _RL ironStartTime

      COMMON/darwin_forcing_iron_c/
     &    ironmask
      COMMON/darwin_forcing_iron_i/
     &    ironstartdate1, ironstartdate2
      COMMON/darwin_forcing_iron_r/
     &    ironStartTime,
     &    ironperiod, ironRepCycle, ironconst,
     &    iron_exfremo_intercept, iron_exfremo_slope,
     &    darwin_inscal_iron
      CHARACTER*1 ironmask
      INTEGER ironstartdate1
      INTEGER ironstartdate2
      _RL ironperiod
      _RL ironRepCycle
      _RL ironconst
      _RL iron_exfremo_intercept
      _RL iron_exfremo_slope
      _RL darwin_inscal_iron

#ifdef USE_EXF_INTERPOLATION
      COMMON/darwin_interp_iron_i/
     &    iron_nlon, iron_nlat, iron_interpMethod
      COMMON/darwin_interp_iron_r/
     &    iron_lon0, iron_lat0, iron_lon_inc, iron_lat_inc
      INTEGER iron_interpMethod, iron_nlon, iron_nlat
      _RL  iron_lon0
      _RL  iron_lat0
      _RL  iron_lon_inc
      _RL  iron_lat_inc(MAX_LAT_INC)
#endif

C ice forcing parameters for exf

      _RL iceStartTime

      COMMON/darwin_forcing_ice_c/
     &    icemask
      COMMON/darwin_forcing_ice_i/
     &    icestartdate1, icestartdate2
      COMMON/darwin_forcing_ice_r/
     &    iceStartTime,
     &    iceperiod, iceRepCycle, iceconst,
     &    ice_exfremo_intercept, ice_exfremo_slope,
     &    darwin_inscal_ice
      CHARACTER*1 icemask
      INTEGER icestartdate1
      INTEGER icestartdate2
      _RL iceperiod
      _RL iceRepCycle
      _RL iceconst
      _RL ice_exfremo_intercept
      _RL ice_exfremo_slope
      _RL darwin_inscal_ice

#ifdef USE_EXF_INTERPOLATION
      COMMON/darwin_interp_ice_i/
     &    ice_nlon, ice_nlat, ice_interpMethod
      COMMON/darwin_interp_ice_r/
     &    ice_lon0, ice_lat0, ice_lon_inc, ice_lat_inc
      INTEGER ice_interpMethod, ice_nlon, ice_nlat
      _RL  ice_lon0
      _RL  ice_lat0
      _RL  ice_lon_inc
      _RL  ice_lat_inc(MAX_LAT_INC)
#endif

C wind forcing parameters for exf

      _RL windStartTime

      COMMON/darwin_forcing_wind_c/
     &    windmask
      COMMON/darwin_forcing_wind_i/
     &    windstartdate1, windstartdate2
      COMMON/darwin_forcing_wind_r/
     &    windStartTime,
     &    windperiod, windRepCycle, windconst,
     &    wind_exfremo_intercept, wind_exfremo_slope,
     &    darwin_inscal_wind
      CHARACTER*1 windmask
      INTEGER windstartdate1
      INTEGER windstartdate2
      _RL windperiod
      _RL windRepCycle
      _RL windconst
      _RL wind_exfremo_intercept
      _RL wind_exfremo_slope
      _RL darwin_inscal_wind

#ifdef USE_EXF_INTERPOLATION
      COMMON/darwin_interp_wind_i/
     &    wind_nlon, wind_nlat, wind_interpMethod
      COMMON/darwin_interp_wind_r/
     &    wind_lon0, wind_lat0, wind_lon_inc, wind_lat_inc
      INTEGER wind_interpMethod, wind_nlon, wind_nlat
      _RL  wind_lon0
      _RL  wind_lat0
      _RL  wind_lon_inc
      _RL  wind_lat_inc(MAX_LAT_INC)
#endif

C pCO2 forcing parameters for exf

      _RL pCO2StartTime

      COMMON/darwin_forcing_pCO2_c/
     &    pCO2mask
      COMMON/darwin_forcing_pCO2_i/
     &    pCO2startdate1, pCO2startdate2
      COMMON/darwin_forcing_pCO2_r/
     &    pCO2StartTime,
     &    pCO2period, pCO2RepCycle, pCO2const,
     &    pCO2_exfremo_intercept, pCO2_exfremo_slope,
     &    darwin_inscal_pCO2
      CHARACTER*1 pCO2mask
      INTEGER pCO2startdate1
      INTEGER pCO2startdate2
      _RL pCO2period
      _RL pCO2RepCycle
      _RL pCO2const
      _RL pCO2_exfremo_intercept
      _RL pCO2_exfremo_slope
      _RL darwin_inscal_pCO2

#ifdef USE_EXF_INTERPOLATION
      COMMON/darwin_interp_pCO2_i/
     &    pCO2_nlon, pCO2_nlat, pCO2_interpMethod
      COMMON/darwin_interp_pCO2_r/
     &    pCO2_lon0, pCO2_lat0, pCO2_lon_inc, pCO2_lat_inc
      INTEGER pCO2_interpMethod, pCO2_nlon, pCO2_nlat
      _RL  pCO2_lon0
      _RL  pCO2_lat0
      _RL  pCO2_lon_inc
      _RL  pCO2_lat_inc(MAX_LAT_INC)
#endif
CEOP

#endif /* ALLOW_DARWIN */

