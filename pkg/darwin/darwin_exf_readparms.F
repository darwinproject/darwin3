#include "DARWIN_OPTIONS.h"
#include "EXF_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_EXF_READPARMS

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_EXF_READPARMS( iUnit, oUnit, myThid )

C !DESCRIPTION:
C     Initialize DARWIN parameters, read in data.darwin

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
#endif
#ifdef ALLOW_RADTRANS
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"
#endif
#include "DARWIN_SIZE.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_EXF_PARAMS.h"
#include "DARWIN_EXF_FIELDS.h"

C !INPUT PARAMETERS: ===================================================
C  iUnit   :: unit number for reading
C  oUnit   :: unit number for writing
C  myThid  :: thread number
      INTEGER iUnit, oUnit, myThid

C !OUTPUT PARAMETERS: ==================================================
C  none
CEOP

#ifdef ALLOW_DARWIN

C !LOCAL VARIABLES: ====================================================
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER j
      _RL inp_lon0, inp_lat0, inp_dLon, inp_dLat, gridNx, gridNy

      NAMELIST/darwin_forcing_params/
     &    useDarwinYearlyFields,
     &    darwin_chlInitBalanced,
     &    darwin_chlIter0,
C
     &    PARfile,
     &    PARperiod,
     &    PARStartTime,
     &    PARstartdate1,
     &    PARstartdate2,
     &    PARconst,
     &    PAR_exfremo_intercept,
     &    PAR_exfremo_slope,
     &    PARmask,
     &    darwin_inscal_PAR,
C
     &    ironfile,
     &    ironperiod,
     &    ironStartTime,
     &    ironstartdate1,
     &    ironstartdate2,
     &    ironconst,
     &    iron_exfremo_intercept,
     &    iron_exfremo_slope,
     &    ironmask,
     &    darwin_inscal_iron,
C
     &    icefile,
     &    iceperiod,
     &    iceStartTime,
     &    icestartdate1,
     &    icestartdate2,
     &    iceconst,
     &    ice_exfremo_intercept,
     &    ice_exfremo_slope,
     &    icemask,
     &    darwin_inscal_ice,
C
     &    windfile,
     &    windperiod,
     &    windStartTime,
     &    windstartdate1,
     &    windstartdate2,
     &    windconst,
     &    wind_exfremo_intercept,
     &    wind_exfremo_slope,
     &    windmask,
     &    darwin_inscal_wind,
C
     &    pCO2file,
     &    pCO2period,
     &    pCO2StartTime,
     &    pCO2startdate1,
     &    pCO2startdate2,
     &    pCO2const,
     &    pCO2_exfremo_intercept,
     &    pCO2_exfremo_slope,
     &    pCO2mask,
     &    darwin_inscal_pCO2

#ifdef USE_EXF_INTERPOLATION
      NAMELIST/darwin_interp_params/
C
     &    PAR_lon0,
     &    PAR_lat0,
     &    PAR_nlon,
     &    PAR_nlat,
     &    PAR_lon_inc,
     &    PAR_interpMethod,
     &    PAR_lat_inc,
C
     &    iron_lon0,
     &    iron_lat0,
     &    iron_nlon,
     &    iron_nlat,
     &    iron_lon_inc,
     &    iron_interpMethod,
     &    iron_lat_inc,
C
     &    ice_lon0,
     &    ice_lat0,
     &    ice_nlon,
     &    ice_nlat,
     &    ice_lon_inc,
     &    ice_interpMethod,
     &    ice_lat_inc,
C
     &    wind_lon0,
     &    wind_lat0,
     &    wind_nlon,
     &    wind_nlat,
     &    wind_lon_inc,
     &    wind_interpMethod,
     &    wind_lat_inc,
C
     &    pCO2_lon0,
     &    pCO2_lat0,
     &    pCO2_nlon,
     &    pCO2_nlat,
     &    pCO2_lon_inc,
     &    pCO2_interpMethod,
     &    pCO2_lat_inc
#endif

C Open and read the data.darwin file

      useDarwinYearlyFields = useExfYearlyFields
      darwin_chlInitBalanced = .FALSE.
      darwin_chlIter0 = 0

      PARfile = ' '
      PARperiod             = 0.0 _d 0
      PARStartTime          = UNSET_RL
      PARstartdate1         = 0
      PARstartdate2         = 0
      PARconst              = 0.0 _d 0
      PAR_exfremo_intercept = 0.0 _d 0
      PAR_exfremo_slope     = 0.0 _d 0
      PARmask = 'c'

      darwin_inscal_PAR    =  1. _d 0

      ironfile = ' '
      ironperiod             = 0.0 _d 0
      ironStartTime          = UNSET_RL
      ironstartdate1         = 0
      ironstartdate2         = 0
      ironconst              = 0.0 _d 0
      iron_exfremo_intercept = 0.0 _d 0
      iron_exfremo_slope     = 0.0 _d 0
      ironmask = 'c'

      darwin_inscal_iron    =  1. _d 0

      icefile = ' '
      iceperiod             = 0.0 _d 0
      iceStartTime          = UNSET_RL
      icestartdate1         = 0
      icestartdate2         = 0
      iceconst              = 0.0 _d 0
      ice_exfremo_intercept = 0.0 _d 0
      ice_exfremo_slope     = 0.0 _d 0
      icemask = 'c'

      darwin_inscal_ice    =  1. _d 0

      windfile = ' '
      windperiod             = 0.0 _d 0
      windStartTime          = UNSET_RL
      windstartdate1         = 0
      windstartdate2         = 0
      windconst              = 0.0 _d 0
      wind_exfremo_intercept = 0.0 _d 0
      wind_exfremo_slope     = 0.0 _d 0
      windmask = 'c'

      darwin_inscal_wind    =  1. _d 0

      pCO2file = ' '
      pCO2period             = 0.0 _d 0
      pCO2StartTime          = UNSET_RL
      pCO2startdate1         = 0
      pCO2startdate2         = 0
      pCO2const              = 0.0 _d 0
      pCO2_exfremo_intercept = 0.0 _d 0
      pCO2_exfremo_slope     = 0.0 _d 0
      pCO2mask = 'c'

      darwin_inscal_pCO2    =  1. _d 0

#ifdef USE_EXF_INTERPOLATION
      inp_lon0 = xgOrigin + delX(1)*exf_half
      inp_lat0 = ygOrigin + delY(1)*exf_half
      inp_dLon = delX(1)
# ifdef ALLOW_EXCH2
      gridNx = exch2_mydNx(1)
      gridNy = exch2_mydNy(1)
# else /* ALLOW_EXCH2 */
      gridNx = Nx
      gridNy = Ny
# endif /* ALLOW_EXCH2 */


      PAR_lon0 = inp_lon0
      PAR_lat0 = inp_lat0
      PAR_nlon = gridNx
      PAR_nlat = gridNy
      PAR_lon_inc = inp_dLon
      PAR_interpMethod  = 1

      iron_lon0 = inp_lon0
      iron_lat0 = inp_lat0
      iron_nlon = gridNx
      iron_nlat = gridNy
      iron_lon_inc = inp_dLon
      iron_interpMethod  = 1

      ice_lon0 = inp_lon0
      ice_lat0 = inp_lat0
      ice_nlon = gridNx
      ice_nlat = gridNy
      ice_lon_inc = inp_dLon
      ice_interpMethod  = 1

      wind_lon0 = inp_lon0
      wind_lat0 = inp_lat0
      wind_nlon = gridNx
      wind_nlat = gridNy
      wind_lon_inc = inp_dLon
      wind_interpMethod  = 1

      pCO2_lon0 = inp_lon0
      pCO2_lat0 = inp_lat0
      pCO2_nlon = gridNx
      pCO2_nlat = gridNy
      pCO2_lon_inc = inp_dLon
      pCO2_interpMethod  = 1

      DO j=1,MAX_LAT_INC
        IF (j.LT.gridNy) THEN
          inp_dLat = (delY(j) + delY(j+1))*exf_half
        ELSE
          inp_dLat = 0.
        ENDIF
        PAR_lat_inc(j) = inp_dLat
        iron_lat_inc(j) = inp_dLat
        ice_lat_inc(j) = inp_dLat
        wind_lat_inc(j) = inp_dLat
        pCO2_lat_inc(j) = inp_dLat
      ENDDO
#endif /* USE_EXF_INTERPOLATION */

C ======================================================================

      PARconst = UNSET_RL
      iceconst = UNSET_RL
      windconst = UNSET_RL

      READ(UNIT=iUnit, NML=darwin_forcing_params)
#ifdef USE_EXF_INTERPOLATION
      READ(UNIT=iUnit, NML=darwin_interp_params)
#endif

C ======================================================================
C set alternate forcing sources

      DARWIN_haveSurfPAR = PARFile.NE.' ' .OR. PARconst.NE.UNSET_RL
      IF (PARconst .EQ. UNSET_RL) THEN
        PARconst = 0 _d 0
      ENDIF

      DARWIN_haveIce = iceFile.NE.' ' .OR. iceconst.NE.UNSET_RL

#ifdef ALLOW_RADTRANS
C     darwin iceFile is used for carbon air-sea exchanges while
C     RT_iceFile is used for light.
C     If one is set but not the other we stop.
C     If they are both set but different, we warn (see further below).
      IF (DARWIN_haveIce .NEQV. RT_haveIce) THEN
       WRITE(msgBuf,'(A,A)') 'DARWIN_EXF_READPARMS: ',
     &  'One of darwin and radtrans does not have ice forcing set.'
       CALL PRINT_ERROR( msgBuf, myThid )
       WRITE(msgBuf,'(A,A)') 'DARWIN_EXF_READPARMS: ',
     &  'If you really want this, set iceconst or RT_iceconst to zero.'
       CALL PRINT_ERROR( msgBuf, myThid )
       STOP 'ABNORMAL END: DARWIN_EXF_READPARMS: ice inconsistency'
      ENDIF
#endif

      IF (iceconst.EQ.UNSET_RL) THEN
        iceconst = 0 _d 0
      ENDIF

#ifdef ALLOW_RADTRANS
C     warn if darwin and radtrans ice forcing are different
      IF (iceFile.NE.RT_iceFile .OR. iceconst.NE.RT_iceconst) THEN
       WRITE(msgBuf,'(A,A)') '** WARNING ** DARWIN_EXF_READPARMS: ',
     &  'iceFile or iceconst different from RT_iceFile or RT_iceconst.'
       CALL PRINT_MESSAGE( msgBuf, errorMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
       WRITE(msgBuf,'(A,A)') '** WARNING ** DARWIN_EXF_READPARMS: ',
     &  'darwin settings will be used for carbon surface forcing and'
       CALL PRINT_MESSAGE( msgBuf, errorMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
       WRITE(msgBuf,'(A,A)') '** WARNING ** DARWIN_EXF_READPARMS: ',
     &  'radtrans settings for light.'
       CALL PRINT_MESSAGE( msgBuf, errorMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      ENDIF
#endif

C first preference: darwin wind if given
      IF (windFile.NE.' ' .OR. windconst.NE.UNSET_RL) THEN
        DARWIN_useEXFwind = .FALSE.
C second preference: exf wspeed if given
      ELSEIF (wspeedfile.NE.' ' .OR. wspeedconst.NE.0 _d 0) THEN
        DARWIN_useEXFwind = .TRUE.
#ifdef DARWIN_ALLOW_CARBON
        WRITE(msgBuf,'(2A)') '** WARNING ** DARWIN_EXF_READPARMS: ',
     &    'wspeedFile and wspeedconst unset, using wspeed from exf'
        CALL PRINT_MESSAGE( msgBuf, errorMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
#endif
      ELSE
C last preference: constant value of 5 m/s
        DARWIN_useEXFwind = .FALSE.
        windconst = 5 _d 0
#ifdef DARWIN_ALLOW_CARBON
        WRITE(msgBuf,'(2A)') '** WARNING ** DARWIN_EXF_READPARMS: ',
     &    'wspeedFile and wspeedconst unset, using default of 5 m/s'
        CALL PRINT_MESSAGE( msgBuf, errorMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
#endif
      ENDIF

C ======================================================================
C     compute dependent parameters
      darwin_loadFieldsEarly = darwin_chlInitBalanced .AND.
     &                      nIter0 .EQ. darwin_chlIter0
#ifdef ALLOW_RADTRANS
      RT_loadFieldsEarly=RT_loadFieldsEarly .OR. darwin_loadFIeldsEarly
#endif

      IF (oUnit .GE. 0) THEN
       WRITE(UNIT=oUnit, NML=DARWIN_FORCING_PARAMS)
#ifdef USE_EXF_INTERPOLATION
       WRITE(UNIT=oUnit, NML=DARWIN_INTERP_PARAMS)
#endif
      ENDIF

#endif /* ALLOW_DARWIN */

      RETURN
      END

