#ifdef ALLOW_OASIM

CBOP
C     !ROUTINE: OASIM_EXF_PARAMS.h
C     !INTERFACE:
C #include OASIM_EXF_PARAMS.h
C
C     !DESCRIPTION:
C Contains parameters for reading forcing for oasim package through exf
C
C Requires: OASIM_SIZE.h, EXF_PARAM.h
CEOP

C--   COMMON/oasim_forcing_exf_params_l/
C     useOasimYearlyFields :: whether files are per year with _YYYY suffix
      COMMON/oasim_forcing_exf_params_l/
     &    useoasimYearlyFields
      LOGICAL useoasimYearlyFields

C--   COMMON/oasim_forcing_exf_params_i/
C     oasim_timeInterp :: order for time interpolation: 0 or 1
      COMMON/oasim_forcing_exf_params_i/
     &    oasim_timeInterp
      INTEGER oasim_timeInterp

C--   COMMON /oasim_fields_c/ file names for forcing fields
      COMMON /oasim_fields_c/
     &    aerTaufile,
     &    asympfile,
     &    ssalbfile,
     &    cldcovfile,
     &    cldlwpfile,
     &    cldrefile,
     &    presfile,
     &    oawindfile,
     &    relhumfile,
     &    ozonefile,
     &    wvfile,
     &    afile,
     &    btfile,
     &    bbfile

      CHARACTER*128 aerTaufile
      CHARACTER*128 asympfile
      CHARACTER*128 ssalbfile
      CHARACTER*128 cldcovfile
      CHARACTER*128 cldlwpfile
      CHARACTER*128 cldrefile
      CHARACTER*128 presfile
      CHARACTER*128 oawindfile
      CHARACTER*128 relhumfile
      CHARACTER*128 ozonefile
      CHARACTER*128 wvfile
      CHARACTER*128 afile
      CHARACTER*128 btfile
      CHARACTER*128 bbfile

C aerTau forcing parameters for exf

      _RL aerTauStartTime

      COMMON/oasim_forcing_aerTau_c/
     &    aerTaumask
      COMMON/oasim_forcing_aerTau_i/
     &    aerTaustartdate1, aerTaustartdate2
      COMMON/oasim_forcing_aerTau_r/
     &    aerTauStartTime,
     &    aerTauperiod, aerTauRepCycle, aerTauconst,
     &    aerTau_exfremo_intercept, aerTau_exfremo_slope,
     &    aerTau_inscal
      CHARACTER*1 aerTaumask
      INTEGER aerTaustartdate1
      INTEGER aerTaustartdate2
      _RL aerTauperiod
      _RL aerTauRepCycle
      _RL aerTauconst(nlt)
      _RL aerTau_exfremo_intercept(nlt)
      _RL aerTau_exfremo_slope(nlt)
      _RL aerTau_inscal(nlt)

#ifdef USE_EXF_INTERPOLATION
      COMMON/oasim_interp_aerTau_i/
     &    aerTau_nlon, aerTau_nlat, aerTau_interpMethod
      COMMON/oasim_interp_aerTau_r/
     &    aerTau_lon0, aerTau_lat0, aerTau_lon_inc, aerTau_lat_inc
      INTEGER aerTau_interpMethod, aerTau_nlon, aerTau_nlat
      _RL  aerTau_lon0
      _RL  aerTau_lat0
      _RL  aerTau_lon_inc
      _RL  aerTau_lat_inc(MAX_LAT_INC)
#endif

C asymp forcing parameters for exf

      _RL asympStartTime

      COMMON/oasim_forcing_asymp_c/
     &    asympmask
      COMMON/oasim_forcing_asymp_i/
     &    asympstartdate1, asympstartdate2
      COMMON/oasim_forcing_asymp_r/
     &    asympStartTime,
     &    asympperiod, asympRepCycle, asympconst,
     &    asymp_exfremo_intercept, asymp_exfremo_slope,
     &    asymp_inscal
      CHARACTER*1 asympmask
      INTEGER asympstartdate1
      INTEGER asympstartdate2
      _RL asympperiod
      _RL asympRepCycle
      _RL asympconst(nlt)
      _RL asymp_exfremo_intercept(nlt)
      _RL asymp_exfremo_slope(nlt)
      _RL asymp_inscal(nlt)

#ifdef USE_EXF_INTERPOLATION
      COMMON/oasim_interp_asymp_i/
     &    asymp_nlon, asymp_nlat, asymp_interpMethod
      COMMON/oasim_interp_asymp_r/
     &    asymp_lon0, asymp_lat0, asymp_lon_inc, asymp_lat_inc
      INTEGER asymp_interpMethod, asymp_nlon, asymp_nlat
      _RL  asymp_lon0
      _RL  asymp_lat0
      _RL  asymp_lon_inc
      _RL  asymp_lat_inc(MAX_LAT_INC)
#endif

C ssalb forcing parameters for exf

      _RL ssalbStartTime

      COMMON/oasim_forcing_ssalb_c/
     &    ssalbmask
      COMMON/oasim_forcing_ssalb_i/
     &    ssalbstartdate1, ssalbstartdate2
      COMMON/oasim_forcing_ssalb_r/
     &    ssalbStartTime,
     &    ssalbperiod, ssalbRepCycle, ssalbconst,
     &    ssalb_exfremo_intercept, ssalb_exfremo_slope,
     &    ssalb_inscal
      CHARACTER*1 ssalbmask
      INTEGER ssalbstartdate1
      INTEGER ssalbstartdate2
      _RL ssalbperiod
      _RL ssalbRepCycle
      _RL ssalbconst(nlt)
      _RL ssalb_exfremo_intercept(nlt)
      _RL ssalb_exfremo_slope(nlt)
      _RL ssalb_inscal(nlt)

#ifdef USE_EXF_INTERPOLATION
      COMMON/oasim_interp_ssalb_i/
     &    ssalb_nlon, ssalb_nlat, ssalb_interpMethod
      COMMON/oasim_interp_ssalb_r/
     &    ssalb_lon0, ssalb_lat0, ssalb_lon_inc, ssalb_lat_inc
      INTEGER ssalb_interpMethod, ssalb_nlon, ssalb_nlat
      _RL  ssalb_lon0
      _RL  ssalb_lat0
      _RL  ssalb_lon_inc
      _RL  ssalb_lat_inc(MAX_LAT_INC)
#endif

C cldcov forcing parameters for exf

      _RL cldcovStartTime

      COMMON/oasim_forcing_cldcov_c/
     &    cldcovmask
      COMMON/oasim_forcing_cldcov_i/
     &    cldcovstartdate1, cldcovstartdate2
      COMMON/oasim_forcing_cldcov_r/
     &    cldcovStartTime,
     &    cldcovperiod, cldcovRepCycle, cldcovconst,
     &    cldcov_exfremo_intercept, cldcov_exfremo_slope,
     &    cldcov_inscal
      CHARACTER*1 cldcovmask
      INTEGER cldcovstartdate1
      INTEGER cldcovstartdate2
      _RL cldcovperiod
      _RL cldcovRepCycle
      _RL cldcovconst
      _RL cldcov_exfremo_intercept
      _RL cldcov_exfremo_slope
      _RL cldcov_inscal

#ifdef USE_EXF_INTERPOLATION
      COMMON/oasim_interp_cldcov_i/
     &    cldcov_nlon, cldcov_nlat, cldcov_interpMethod
      COMMON/oasim_interp_cldcov_r/
     &    cldcov_lon0, cldcov_lat0, cldcov_lon_inc, cldcov_lat_inc
      INTEGER cldcov_interpMethod, cldcov_nlon, cldcov_nlat
      _RL  cldcov_lon0
      _RL  cldcov_lat0
      _RL  cldcov_lon_inc
      _RL  cldcov_lat_inc(MAX_LAT_INC)
#endif

C cldlwp forcing parameters for exf

      _RL cldlwpStartTime

      COMMON/oasim_forcing_cldlwp_c/
     &    cldlwpmask
      COMMON/oasim_forcing_cldlwp_i/
     &    cldlwpstartdate1, cldlwpstartdate2
      COMMON/oasim_forcing_cldlwp_r/
     &    cldlwpStartTime,
     &    cldlwpperiod, cldlwpRepCycle, cldlwpconst,
     &    cldlwp_exfremo_intercept, cldlwp_exfremo_slope,
     &    cldlwp_inscal
      CHARACTER*1 cldlwpmask
      INTEGER cldlwpstartdate1
      INTEGER cldlwpstartdate2
      _RL cldlwpperiod
      _RL cldlwpRepCycle
      _RL cldlwpconst
      _RL cldlwp_exfremo_intercept
      _RL cldlwp_exfremo_slope
      _RL cldlwp_inscal

#ifdef USE_EXF_INTERPOLATION
      COMMON/oasim_interp_cldlwp_i/
     &    cldlwp_nlon, cldlwp_nlat, cldlwp_interpMethod
      COMMON/oasim_interp_cldlwp_r/
     &    cldlwp_lon0, cldlwp_lat0, cldlwp_lon_inc, cldlwp_lat_inc
      INTEGER cldlwp_interpMethod, cldlwp_nlon, cldlwp_nlat
      _RL  cldlwp_lon0
      _RL  cldlwp_lat0
      _RL  cldlwp_lon_inc
      _RL  cldlwp_lat_inc(MAX_LAT_INC)
#endif

C cldre forcing parameters for exf

      _RL cldreStartTime

      COMMON/oasim_forcing_cldre_c/
     &    cldremask
      COMMON/oasim_forcing_cldre_i/
     &    cldrestartdate1, cldrestartdate2
      COMMON/oasim_forcing_cldre_r/
     &    cldreStartTime,
     &    cldreperiod, cldreRepCycle, cldreconst,
     &    cldre_exfremo_intercept, cldre_exfremo_slope,
     &    cldre_inscal
      CHARACTER*1 cldremask
      INTEGER cldrestartdate1
      INTEGER cldrestartdate2
      _RL cldreperiod
      _RL cldreRepCycle
      _RL cldreconst
      _RL cldre_exfremo_intercept
      _RL cldre_exfremo_slope
      _RL cldre_inscal

#ifdef USE_EXF_INTERPOLATION
      COMMON/oasim_interp_cldre_i/
     &    cldre_nlon, cldre_nlat, cldre_interpMethod
      COMMON/oasim_interp_cldre_r/
     &    cldre_lon0, cldre_lat0, cldre_lon_inc, cldre_lat_inc
      INTEGER cldre_interpMethod, cldre_nlon, cldre_nlat
      _RL  cldre_lon0
      _RL  cldre_lat0
      _RL  cldre_lon_inc
      _RL  cldre_lat_inc(MAX_LAT_INC)
#endif

C pres forcing parameters for exf

      _RL presStartTime

      COMMON/oasim_forcing_pres_c/
     &    presmask
      COMMON/oasim_forcing_pres_i/
     &    presstartdate1, presstartdate2
      COMMON/oasim_forcing_pres_r/
     &    presStartTime,
     &    presperiod, presRepCycle, presconst,
     &    pres_exfremo_intercept, pres_exfremo_slope,
     &    pres_inscal
      CHARACTER*1 presmask
      INTEGER presstartdate1
      INTEGER presstartdate2
      _RL presperiod
      _RL presRepCycle
      _RL presconst
      _RL pres_exfremo_intercept
      _RL pres_exfremo_slope
      _RL pres_inscal

#ifdef USE_EXF_INTERPOLATION
      COMMON/oasim_interp_pres_i/
     &    pres_nlon, pres_nlat, pres_interpMethod
      COMMON/oasim_interp_pres_r/
     &    pres_lon0, pres_lat0, pres_lon_inc, pres_lat_inc
      INTEGER pres_interpMethod, pres_nlon, pres_nlat
      _RL  pres_lon0
      _RL  pres_lat0
      _RL  pres_lon_inc
      _RL  pres_lat_inc(MAX_LAT_INC)
#endif

C wind forcing parameters for exf

      _RL oawindStartTime

      COMMON/oasim_forcing_oawind_c/
     &    oawindmask
      COMMON/oasim_forcing_oawind_i/
     &    oawindstartdate1, oawindstartdate2
      COMMON/oasim_forcing_oawind_r/
     &    oawindStartTime,
     &    oawindperiod, oawindRepCycle, oawindconst,
     &    oawind_exfremo_intercept, oawind_exfremo_slope,
     &    oawind_inscal
      CHARACTER*1 oawindmask
      INTEGER oawindstartdate1
      INTEGER oawindstartdate2
      _RL oawindperiod
      _RL oawindRepCycle
      _RL oawindconst
      _RL oawind_exfremo_intercept
      _RL oawind_exfremo_slope
      _RL oawind_inscal

#ifdef USE_EXF_INTERPOLATION
      COMMON/oasim_interp_oawind_i/
     &    oawind_nlon, oawind_nlat, oawind_interpMethod
      COMMON/oasim_interp_oawind_r/
     &    oawind_lon0, oawind_lat0, oawind_lon_inc, oawind_lat_inc
      INTEGER oawind_interpMethod, oawind_nlon, oawind_nlat
      _RL  oawind_lon0
      _RL  oawind_lat0
      _RL  oawind_lon_inc
      _RL  oawind_lat_inc(MAX_LAT_INC)
#endif

C relhum forcing parameters for exf

      _RL relhumStartTime

      COMMON/oasim_forcing_relhum_c/
     &    relhummask
      COMMON/oasim_forcing_relhum_i/
     &    relhumstartdate1, relhumstartdate2
      COMMON/oasim_forcing_relhum_r/
     &    relhumStartTime,
     &    relhumperiod, relhumRepCycle, relhumconst,
     &    relhum_exfremo_intercept, relhum_exfremo_slope,
     &    relhum_inscal
      CHARACTER*1 relhummask
      INTEGER relhumstartdate1
      INTEGER relhumstartdate2
      _RL relhumperiod
      _RL relhumRepCycle
      _RL relhumconst
      _RL relhum_exfremo_intercept
      _RL relhum_exfremo_slope
      _RL relhum_inscal

#ifdef USE_EXF_INTERPOLATION
      COMMON/oasim_interp_relhum_i/
     &    relhum_nlon, relhum_nlat, relhum_interpMethod
      COMMON/oasim_interp_relhum_r/
     &    relhum_lon0, relhum_lat0, relhum_lon_inc, relhum_lat_inc
      INTEGER relhum_interpMethod, relhum_nlon, relhum_nlat
      _RL  relhum_lon0
      _RL  relhum_lat0
      _RL  relhum_lon_inc
      _RL  relhum_lat_inc(MAX_LAT_INC)
#endif

C ozone forcing parameters for exf

      _RL ozoneStartTime

      COMMON/oasim_forcing_ozone_c/
     &    ozonemask
      COMMON/oasim_forcing_ozone_i/
     &    ozonestartdate1, ozonestartdate2
      COMMON/oasim_forcing_ozone_r/
     &    ozoneStartTime,
     &    ozoneperiod, ozoneRepCycle, ozoneconst,
     &    ozone_exfremo_intercept, ozone_exfremo_slope,
     &    ozone_inscal
      CHARACTER*1 ozonemask
      INTEGER ozonestartdate1
      INTEGER ozonestartdate2
      _RL ozoneperiod
      _RL ozoneRepCycle
      _RL ozoneconst
      _RL ozone_exfremo_intercept
      _RL ozone_exfremo_slope
      _RL ozone_inscal

#ifdef USE_EXF_INTERPOLATION
      COMMON/oasim_interp_ozone_i/
     &    ozone_nlon, ozone_nlat, ozone_interpMethod
      COMMON/oasim_interp_ozone_r/
     &    ozone_lon0, ozone_lat0, ozone_lon_inc, ozone_lat_inc
      INTEGER ozone_interpMethod, ozone_nlon, ozone_nlat
      _RL  ozone_lon0
      _RL  ozone_lat0
      _RL  ozone_lon_inc
      _RL  ozone_lat_inc(MAX_LAT_INC)
#endif

C wv forcing parameters for exf

      _RL wvStartTime

      COMMON/oasim_forcing_wv_c/
     &    wvmask
      COMMON/oasim_forcing_wv_i/
     &    wvstartdate1, wvstartdate2
      COMMON/oasim_forcing_wv_r/
     &    wvStartTime,
     &    wvperiod, wvRepCycle, wvconst,
     &    wv_exfremo_intercept, wv_exfremo_slope,
     &    wv_inscal
      CHARACTER*1 wvmask
      INTEGER wvstartdate1
      INTEGER wvstartdate2
      _RL wvperiod
      _RL wvRepCycle
      _RL wvconst
      _RL wv_exfremo_intercept
      _RL wv_exfremo_slope
      _RL wv_inscal

#ifdef USE_EXF_INTERPOLATION
      COMMON/oasim_interp_wv_i/
     &    wv_nlon, wv_nlat, wv_interpMethod
      COMMON/oasim_interp_wv_r/
     &    wv_lon0, wv_lat0, wv_lon_inc, wv_lat_inc
      INTEGER wv_interpMethod, wv_nlon, wv_nlat
      _RL  wv_lon0
      _RL  wv_lat0
      _RL  wv_lon_inc
      _RL  wv_lat_inc(MAX_LAT_INC)
#endif

#endif /* ALLOW_OASIM */

