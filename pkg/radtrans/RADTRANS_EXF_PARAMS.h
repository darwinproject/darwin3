#ifdef ALLOW_RADTRANS

CBOP
C     !ROUTINE: RADTRANS_EXF_PARAMS.h
C     !INTERFACE:
C #include RADTRANS_EXF_PARAMS.h

C     !DESCRIPTION:
C Contains interpolation parameters for the radtrans package
C These are in a separate header because they require exf headers
C
C Requires: EXF_OPTIONS.h
C Requires: EXF_PARAM.h

#ifdef USE_EXF_INTERPOLATION
      COMMON/radtrans_interp_i/
     &    RT_E_nlon, RT_E_nlat, RT_E_interpMethod
      COMMON/radtrans_interp_r/
     &    RT_E_lon0, RT_E_lat0, RT_E_lon_inc, RT_E_lat_inc
      INTEGER RT_E_interpMethod, RT_E_nlon, RT_E_nlat
      _RL  RT_E_lon0
      _RL  RT_E_lat0
      _RL  RT_E_lon_inc
      _RL  RT_E_lat_inc(MAX_LAT_INC)
#endif

#ifdef USE_EXF_INTERPOLATION
      COMMON/RT_interp_ice_i/
     &    RT_ice_nlon, RT_ice_nlat, RT_ice_interpMethod
      COMMON/RT_interp_ice_r/
     &    RT_ice_lon0, RT_ice_lat0, RT_ice_lon_inc, RT_ice_lat_inc
      INTEGER RT_ice_interpMethod, RT_ice_nlon, RT_ice_nlat
      _RL  RT_ice_lon0
      _RL  RT_ice_lat0
      _RL  RT_ice_lon_inc
      _RL  RT_ice_lat_inc(MAX_LAT_INC)
#endif

CEOP

#endif /* ALLOW_RADTRANS */
