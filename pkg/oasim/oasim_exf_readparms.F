#include "OASIM_OPTIONS.h"
#ifdef ALLOW_EXF
#include "EXF_OPTIONS.h"
#endif

CBOP
C !ROUTINE: OASIM_EXF_READPARMS

C !INTERFACE: ==========================================================
      SUBROUTINE OASIM_EXF_READPARMS( iUnit, oUnit, myThid )

C !DESCRIPTION:
C     Initialize OASIM parameters, read in data.oasim

C !USES: ===============================================================
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#ifdef ALLOW_EXCH2
#include "W2_EXCH2_SIZE.h"
#include "W2_EXCH2_TOPOLOGY.h"
#endif
#ifdef ALLOW_GCHEM
#include "GCHEM.h"
#endif
#ifdef ALLOW_EXF
#ifdef USE_EXF_INTERPOLATION
#include "SET_GRID.h"
#include "EXF_CONSTANTS.h"
#endif
#include "EXF_PARAM.h"
#include "EXF_INTERP_SIZE.h"
#include "EXF_INTERP_PARAM.h"
#endif
#ifdef ALLOW_RADTRANS
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"
#endif
#include "OASIM_SIZE.h"
#include "OASIM_PARAMS.h"
#include "OASIM_EXF_PARAMS.h"

C !INPUT PARAMETERS: ===================================================
C  iUnit   :: unit number for reading
C  oUnit   :: unit number for writing
C  myThid  :: thread number
      INTEGER iUnit, oUnit, myThid

C !OUTPUT PARAMETERS: ==================================================
C  none
CEOP

#ifdef ALLOW_OASIM
#ifdef ALLOW_EXF

C !LOCAL VARIABLES: ====================================================
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER j

      NAMELIST/OASIM_FORCING_PARM/
     &    useOasimYearlyFields,
     &    oasim_timeInterp,
C
     &    aerTaufile,
     &    aerTauperiod,
     &    aerTauRepCycle,
     &    aerTauStartTime,
     &    aerTaustartdate1,
     &    aerTaustartdate2,
     &    aerTauconst,
     &    aerTau_exfremo_intercept,
     &    aerTau_exfremo_slope,
     &    aerTaumask,
     &    aerTau_inscal,
C
     &    asympfile,
     &    asympperiod,
     &    asympRepCycle,
     &    asympStartTime,
     &    asympstartdate1,
     &    asympstartdate2,
     &    asympconst,
     &    asymp_exfremo_intercept,
     &    asymp_exfremo_slope,
     &    asympmask,
     &    asymp_inscal,
C
     &    ssalbfile,
     &    ssalbperiod,
     &    ssalbRepCycle,
     &    ssalbStartTime,
     &    ssalbstartdate1,
     &    ssalbstartdate2,
     &    ssalbconst,
     &    ssalb_exfremo_intercept,
     &    ssalb_exfremo_slope,
     &    ssalbmask,
     &    ssalb_inscal,
C
     &    cldcovfile,
     &    cldcovperiod,
     &    cldcovRepCycle,
     &    cldcovStartTime,
     &    cldcovstartdate1,
     &    cldcovstartdate2,
     &    cldcovconst,
     &    cldcov_exfremo_intercept,
     &    cldcov_exfremo_slope,
     &    cldcovmask,
     &    cldcov_inscal,
C
     &    cldlwpfile,
     &    cldlwpperiod,
     &    cldlwpRepCycle,
     &    cldlwpStartTime,
     &    cldlwpstartdate1,
     &    cldlwpstartdate2,
     &    cldlwpconst,
     &    cldlwp_exfremo_intercept,
     &    cldlwp_exfremo_slope,
     &    cldlwpmask,
     &    cldlwp_inscal,
C
     &    cldrefile,
     &    cldreperiod,
     &    cldreRepCycle,
     &    cldreStartTime,
     &    cldrestartdate1,
     &    cldrestartdate2,
     &    cldreconst,
     &    cldre_exfremo_intercept,
     &    cldre_exfremo_slope,
     &    cldremask,
     &    cldre_inscal,
C
     &    presfile,
     &    presperiod,
     &    presRepCycle,
     &    presStartTime,
     &    presstartdate1,
     &    presstartdate2,
     &    presconst,
     &    pres_exfremo_intercept,
     &    pres_exfremo_slope,
     &    presmask,
     &    pres_inscal,
C
     &    oawindfile,
     &    oawindperiod,
     &    oawindRepCycle,
     &    oawindStartTime,
     &    oawindstartdate1,
     &    oawindstartdate2,
     &    oawindconst,
     &    oawind_exfremo_intercept,
     &    oawind_exfremo_slope,
     &    oawindmask,
     &    oawind_inscal,
C
     &    relhumfile,
     &    relhumperiod,
     &    relhumRepCycle,
     &    relhumStartTime,
     &    relhumstartdate1,
     &    relhumstartdate2,
     &    relhumconst,
     &    relhum_exfremo_intercept,
     &    relhum_exfremo_slope,
     &    relhummask,
     &    relhum_inscal,
C
     &    ozonefile,
     &    ozoneperiod,
     &    ozoneRepCycle,
     &    ozoneStartTime,
     &    ozonestartdate1,
     &    ozonestartdate2,
     &    ozoneconst,
     &    ozone_exfremo_intercept,
     &    ozone_exfremo_slope,
     &    ozonemask,
     &    ozone_inscal,
C
     &    wvfile,
     &    wvperiod,
     &    wvRepCycle,
     &    wvStartTime,
     &    wvstartdate1,
     &    wvstartdate2,
     &    wvconst,
     &    wv_exfremo_intercept,
     &    wv_exfremo_slope,
     &    wvmask,
     &    wv_inscal

#ifdef USE_EXF_INTERPOLATION
      NAMELIST/OASIM_INTERP_PARM/
     &    aerTau_lon0,
     &    aerTau_lat0,
     &    aerTau_nlon,
     &    aerTau_nlat,
     &    aerTau_lon_inc,
     &    aerTau_interpMethod,
     &    aerTau_lat_inc,
C
     &    asymp_lon0,
     &    asymp_lat0,
     &    asymp_nlon,
     &    asymp_nlat,
     &    asymp_lon_inc,
     &    asymp_interpMethod,
     &    asymp_lat_inc,
C
     &    ssalb_lon0,
     &    ssalb_lat0,
     &    ssalb_nlon,
     &    ssalb_nlat,
     &    ssalb_lon_inc,
     &    ssalb_interpMethod,
     &    ssalb_lat_inc,
C
     &    cldcov_lon0,
     &    cldcov_lat0,
     &    cldcov_nlon,
     &    cldcov_nlat,
     &    cldcov_lon_inc,
     &    cldcov_interpMethod,
     &    cldcov_lat_inc,
C
     &    cldlwp_lon0,
     &    cldlwp_lat0,
     &    cldlwp_nlon,
     &    cldlwp_nlat,
     &    cldlwp_lon_inc,
     &    cldlwp_interpMethod,
     &    cldlwp_lat_inc,
C
     &    cldre_lon0,
     &    cldre_lat0,
     &    cldre_nlon,
     &    cldre_nlat,
     &    cldre_lon_inc,
     &    cldre_interpMethod,
     &    cldre_lat_inc,
C
     &    pres_lon0,
     &    pres_lat0,
     &    pres_nlon,
     &    pres_nlat,
     &    pres_lon_inc,
     &    pres_interpMethod,
     &    pres_lat_inc,
C
     &    oawind_lon0,
     &    oawind_lat0,
     &    oawind_nlon,
     &    oawind_nlat,
     &    oawind_lon_inc,
     &    oawind_interpMethod,
     &    oawind_lat_inc,
C
     &    relhum_lon0,
     &    relhum_lat0,
     &    relhum_nlon,
     &    relhum_nlat,
     &    relhum_lon_inc,
     &    relhum_interpMethod,
     &    relhum_lat_inc,
C
     &    ozone_lon0,
     &    ozone_lat0,
     &    ozone_nlon,
     &    ozone_nlat,
     &    ozone_lon_inc,
     &    ozone_interpMethod,
     &    ozone_lat_inc,
C
     &    wv_lon0,
     &    wv_lat0,
     &    wv_nlon,
     &    wv_nlat,
     &    wv_lon_inc,
     &    wv_interpMethod,
     &    wv_lat_inc
#endif

C Open and read the data.oasim file

      useOasimYearlyFields = useExfYearlyFields
      oasim_timeInterp     = 1

      aerTaufile = ' '
      aerTauperiod             = 0.0 _d 0
      aerTauRepCycle           = repeatPeriod
      aerTauStartTime          = UNSET_RL
      aerTaustartdate1         = 0
      aerTaustartdate2         = 0
      aerTauconst              = 0.0 _d 0
      aerTau_exfremo_intercept = 0.0 _d 0
      aerTau_exfremo_slope     = 0.0 _d 0
      aerTau_inscal            = 1. _d 0
      aerTaumask               = ' '

      asympfile = ' '
      asympperiod             = 0.0 _d 0
      asympRepCycle           = repeatPeriod
      asympStartTime          = UNSET_RL
      asympstartdate1         = 0
      asympstartdate2         = 0
      asympconst              = 0.0 _d 0
      asymp_exfremo_intercept = 0.0 _d 0
      asymp_exfremo_slope     = 0.0 _d 0
      asymp_inscal            = 1. _d 0
      asympmask               = ' '

      ssalbfile = ' '
      ssalbperiod             = 0.0 _d 0
      ssalbRepCycle           = RepeatPeriod
      ssalbStartTime          = UNSET_RL
      ssalbstartdate1         = 0
      ssalbstartdate2         = 0
      ssalbconst              = 0.0 _d 0
      ssalb_exfremo_intercept = 0.0 _d 0
      ssalb_exfremo_slope     = 0.0 _d 0
      ssalb_inscal            = 1. _d 0
      ssalbmask               = ' '

      cldcovfile = ' '
      cldcovperiod             = 0.0 _d 0
      cldcovRepCycle           = repeatPeriod
      cldcovStartTime          = UNSET_RL
      cldcovstartdate1         = 0
      cldcovstartdate2         = 0
      cldcovconst              = UNSET_RL
      cldcov_exfremo_intercept = 0.0 _d 0
      cldcov_exfremo_slope     = 0.0 _d 0
      cldcov_inscal            = 1. _d 0
      cldcovmask               = ' '

      cldlwpfile = ' '
      cldlwpperiod             = 0.0 _d 0
      cldlwpRepCycle           = repeatPeriod
      cldlwpStartTime          = UNSET_RL
      cldlwpstartdate1         = 0
      cldlwpstartdate2         = 0
      cldlwpconst              = UNSET_RL
      cldlwp_exfremo_intercept = 0.0 _d 0
      cldlwp_exfremo_slope     = 0.0 _d 0
      cldlwp_inscal            = 1. _d 0
      cldlwpmask               = ' '

      cldrefile = ' '
      cldreperiod             = 0.0 _d 0
      cldreRepCycle           = repeatPeriod
      cldreStartTime          = UNSET_RL
      cldrestartdate1         = 0
      cldrestartdate2         = 0
      cldreconst              = UNSET_RL
      cldre_exfremo_intercept = 0.0 _d 0
      cldre_exfremo_slope     = 0.0 _d 0
      cldre_inscal            = 1. _d 0
      cldremask               = ' '

      presfile = ' '
      presperiod             = 0.0 _d 0
      presRepCycle           = repeatPeriod
      presStartTime          = UNSET_RL
      presstartdate1         = 0
      presstartdate2         = 0
      presconst              = UNSET_RL
      pres_exfremo_intercept = 0.0 _d 0
      pres_exfremo_slope     = 0.0 _d 0
      pres_inscal            = 1. _d 0
      presmask               = ' '

      oawindfile = ' '
      oawindperiod             = 0.0 _d 0
      oawindRepCycle           = repeatPeriod
      oawindStartTime          = UNSET_RL
      oawindstartdate1         = 0
      oawindstartdate2         = 0
      oawindconst              = UNSET_RL
      oawind_exfremo_intercept = 0.0 _d 0
      oawind_exfremo_slope     = 0.0 _d 0
      oawind_inscal            = 1. _d 0
      oawindmask               = ' '

      relhumfile = ' '
      relhumperiod             = 0.0 _d 0
      relhumRepCycle           = repeatPeriod
      relhumStartTime          = UNSET_RL
      relhumstartdate1         = 0
      relhumstartdate2         = 0
      relhumconst              = UNSET_RL
      relhum_exfremo_intercept = 0.0 _d 0
      relhum_exfremo_slope     = 0.0 _d 0
      relhum_inscal            = 1. _d 0
      relhummask               = ' '

      ozonefile = ' '
      ozoneperiod             = 0.0 _d 0
      ozoneRepCycle           = repeatPeriod
      ozoneStartTime          = UNSET_RL
      ozonestartdate1         = 0
      ozonestartdate2         = 0
      ozoneconst              = UNSET_RL
      ozone_exfremo_intercept = 0.0 _d 0
      ozone_exfremo_slope     = 0.0 _d 0
      ozone_inscal            = 1. _d 0
      ozonemask               = ' '

      wvfile = ' '
      wvperiod             = 0.0 _d 0
      wvRepCycle           = repeatPeriod
      wvStartTime          = UNSET_RL
      wvstartdate1         = 0
      wvstartdate2         = 0
      wvconst              = UNSET_RL
      wv_exfremo_intercept = 0.0 _d 0
      wv_exfremo_slope     = 0.0 _d 0
      wv_inscal            = 1. _d 0
      wvmask               = ' '

#ifdef USE_EXF_INTERPOLATION
      aerTau_lon0 = inp_lon0
      aerTau_lat0 = inp_lat0
      aerTau_nlon = inp_gNx
      aerTau_nlat = inp_gNy
      aerTau_lon_inc = inp_dLon
      aerTau_interpMethod  = 1

      asymp_lon0 = inp_lon0
      asymp_lat0 = inp_lat0
      asymp_nlon = inp_gNx
      asymp_nlat = inp_gNy
      asymp_lon_inc = inp_dLon
      asymp_interpMethod  = 1

      ssalb_lon0 = inp_lon0
      ssalb_lat0 = inp_lat0
      ssalb_nlon = inp_gNx
      ssalb_nlat = inp_gNy
      ssalb_lon_inc = inp_dLon
      ssalb_interpMethod  = 1

      cldcov_lon0 = inp_lon0
      cldcov_lat0 = inp_lat0
      cldcov_nlon = inp_gNx
      cldcov_nlat = inp_gNy
      cldcov_lon_inc = inp_dLon
      cldcov_interpMethod  = 1

      cldlwp_lon0 = inp_lon0
      cldlwp_lat0 = inp_lat0
      cldlwp_nlon = inp_gNx
      cldlwp_nlat = inp_gNy
      cldlwp_lon_inc = inp_dLon
      cldlwp_interpMethod  = 1

      cldre_lon0 = inp_lon0
      cldre_lat0 = inp_lat0
      cldre_nlon = inp_gNx
      cldre_nlat = inp_gNy
      cldre_lon_inc = inp_dLon
      cldre_interpMethod  = 1

      pres_lon0 = inp_lon0
      pres_lat0 = inp_lat0
      pres_nlon = inp_gNx
      pres_nlat = inp_gNy
      pres_lon_inc = inp_dLon
      pres_interpMethod  = 1

      oawind_lon0 = inp_lon0
      oawind_lat0 = inp_lat0
      oawind_nlon = inp_gNx
      oawind_nlat = inp_gNy
      oawind_lon_inc = inp_dLon
      oawind_interpMethod  = 1

      relhum_lon0 = inp_lon0
      relhum_lat0 = inp_lat0
      relhum_nlon = inp_gNx
      relhum_nlat = inp_gNy
      relhum_lon_inc = inp_dLon
      relhum_interpMethod  = 1

      ozone_lon0 = inp_lon0
      ozone_lat0 = inp_lat0
      ozone_nlon = inp_gNx
      ozone_nlat = inp_gNy
      ozone_lon_inc = inp_dLon
      ozone_interpMethod  = 1

      wv_lon0 = inp_lon0
      wv_lat0 = inp_lat0
      wv_nlon = inp_gNx
      wv_nlat = inp_gNy
      wv_lon_inc = inp_dLon
      wv_interpMethod  = 1

      DO j=1,MAX_LAT_INC
        aerTau_lat_inc(j) = inp_dLat(j)
        asymp_lat_inc(j) = inp_dLat(j)
        ssalb_lat_inc(j) = inp_dLat(j)
        cldcov_lat_inc(j) = inp_dLat(j)
        cldlwp_lat_inc(j) = inp_dLat(j)
        cldre_lat_inc(j) = inp_dLat(j)
        pres_lat_inc(j) = inp_dLat(j)
        oawind_lat_inc(j) = inp_dLat(j)
        relhum_lat_inc(j) = inp_dLat(j)
        ozone_lat_inc(j) = inp_dLat(j)
        wv_lat_inc(j) = inp_dLat(j)
      ENDDO
#endif /* USE_EXF_INTERPOLATION */

C ======================================================================

      READ(UNIT=iUnit, NML=OASIM_FORCING_PARM)
#ifdef USE_EXF_INTERPOLATION
      READ(UNIT=iUnit, NML=OASIM_INTERP_PARM)
#endif

C ======================================================================

      IF (oUnit .GE. 0) THEN
       WRITE(UNIT=oUnit, NML=OASIM_FORCING_PARM)
#ifdef USE_EXF_INTERPOLATION
       WRITE(UNIT=oUnit, NML=OASIM_INTERP_PARM)
#endif
      ENDIF

#endif /* ALLOW_EXF */
#endif /* ALLOW_OASIM */

      RETURN
      END
