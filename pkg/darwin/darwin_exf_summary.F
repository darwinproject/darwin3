#include "DARWIN_OPTIONS.h"
#include "EXF_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: DARWIN_EXF_SUMMARY( myThid )
C     !INTERFACE:

      SUBROUTINE DARWIN_EXF_SUMMARY( myThid )

C     !USES:
      IMPLICIT NONE

C     === Global variables ===
#include "EEPARAMS.h"
#include "SIZE.h"
#include "EXF_PARAM.h"
#include "EXF_CONSTANTS.h"
#include "EXF_INTERP_SIZE.h"
#include "EXF_INTERP_PARAM.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_EXF_PARAMS.h"
#include "DARWIN_EXF_FIELDS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid  :: My thread Id number
      INTEGER myThid

C     !FUNCTIONS:
#ifdef ALLOW_RUNOFTEMP
      INTEGER  ILNBLNK
      EXTERNAL ILNBLNK
      INTEGER iL
#endif

C     !LOCAL VARIABLES:
      LOGICAL prtBlkLn, addBlkLn
      CHARACTER*1 blkLin
      CHARACTER*(MAX_LEN_MBUF) msgBuf
CEOP

      _BEGIN_MASTER( myThid )

      blkLin = ' '
      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)')
     &'// ======================================================='
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)')
     &'// Darwin external forcing configuration >>> START <<<'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)')
     &'// ======================================================='
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

C--   For each data set used the summary prints the calendar data
C     and the corresponding file from which the data will be read.
      prtBlkLn = .FALSE.
      addBlkLn = .TRUE.

      IF ( PARfile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'PAR',
     I      PARfile, PARRepCycle, PARperiod,
     I      PARStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'PAR',
     &  PAR_lon0, PAR_lon_inc, PAR_lat0, PAR_lat_inc,
     &  PAR_nlon, PAR_nlat, PAR_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( ironfile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'iron',
     I      ironfile, ironRepCycle, ironperiod,
     I      ironStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'iron',
     &  iron_lon0, iron_lon_inc, iron_lat0, iron_lat_inc,
     &  iron_nlon, iron_nlat, iron_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( icefile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'ice',
     I      icefile, iceRepCycle, iceperiod,
     I      iceStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'ice',
     &  ice_lon0, ice_lon_inc, ice_lat0, ice_lat_inc,
     &  ice_nlon, ice_nlat, ice_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( windfile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'wind',
     I      windfile, windRepCycle, windperiod,
     I      windStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'wind',
     &  wind_lon0, wind_lon_inc, wind_lat0, wind_lat_inc,
     &  wind_nlon, wind_nlat, wind_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( pCO2file.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'pCO2',
     I      pCO2file, pCO2RepCycle, pCO2period,
     I      pCO2StartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'pCO2',
     &  pCO2_lon0, pCO2_lon_inc, pCO2_lat0, pCO2_lat_inc,
     &  pCO2_nlon, pCO2_nlat, pCO2_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( ventHe3file.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'ventHe3',
     I      ventHe3file, ventHe3RepCycle, ventHe3period,
     I      ventHe3StartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'ventHe3',
     &  ventHe3_lon0, ventHe3_lon_inc, ventHe3_lat0, ventHe3_lat_inc,
     &  ventHe3_nlon, ventHe3_nlat, ventHe3_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( DOCrunofffile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'DOCrunoff',
     I      DOCrunofffile, DOCrunoffRepCycle, DOCrunoffperiod,
     I      DOCrunoffStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'DOCrunoff',
     &  DOCrunoff_lon0, DOCrunoff_lon_inc,
     &  DOCrunoff_lat0, DOCrunoff_lat_inc,
     &  DOCrunoff_nlon, DOCrunoff_nlat, DOCrunoff_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( DONrunofffile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'DONrunoff',
     I      DONrunofffile, DONrunoffRepCycle, DONrunoffperiod,
     I      DONrunoffStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'DONrunoff',
     &  DONrunoff_lon0, DONrunoff_lon_inc,
     &  DONrunoff_lat0, DONrunoff_lat_inc,
     &  DONrunoff_nlon, DONrunoff_nlat, DONrunoff_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( DOPrunofffile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'DOPrunoff',
     I      DOPrunofffile, DOPrunoffRepCycle, DOPrunoffperiod,
     I      DOPrunoffStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'DOPrunoff',
     &  DOPrunoff_lon0, DOPrunoff_lon_inc,
     &  DOPrunoff_lat0, DOPrunoff_lat_inc,
     &  DOPrunoff_nlon, DOPrunoff_nlat, DOPrunoff_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( DINrunofffile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'DINrunoff',
     I      DINrunofffile, DINrunoffRepCycle, DINrunoffperiod,
     I      DINrunoffStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'DINrunoff',
     &  DINrunoff_lon0, DINrunoff_lon_inc,
     &  DINrunoff_lat0, DINrunoff_lat_inc,
     &  DINrunoff_nlon, DINrunoff_nlat, DINrunoff_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( NO3runofffile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'NO3runoff',
     I      NO3runofffile, NO3runoffRepCycle, NO3runoffperiod,
     I      NO3runoffStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'NO3runoff',
     &  NO3runoff_lon0, NO3runoff_lon_inc,
     &  NO3runoff_lat0, NO3runoff_lat_inc,
     &  NO3runoff_nlon, NO3runoff_nlat, NO3runoff_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( NO2runofffile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'NO2runoff',
     I      NO2runofffile, NO2runoffRepCycle, NO2runoffperiod,
     I      NO2runoffStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'NO2runoff',
     &  NO2runoff_lon0, NO2runoff_lon_inc,
     &  NO2runoff_lat0, NO2runoff_lat_inc,
     &  NO2runoff_nlon, NO2runoff_nlat, NO2runoff_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( NH4runofffile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'NH4runoff',
     I      NH4runofffile, NH4runoffRepCycle, NH4runoffperiod,
     I      NH4runoffStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'NH4runoff',
     &  NH4runoff_lon0, NH4runoff_lon_inc,
     &  NH4runoff_lat0, NH4runoff_lat_inc,
     &  NH4runoff_nlon, NH4runoff_nlat, NH4runoff_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( IPrunofffile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'IPrunoff',
     I      IPrunofffile, IPrunoffRepCycle, IPrunoffperiod,
     I      IPrunoffStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'IPrunoff',
     &  IPrunoff_lon0, IPrunoff_lon_inc,
     &  IPrunoff_lat0, IPrunoff_lat_inc,
     &  IPrunoff_nlon, IPrunoff_nlat, IPrunoff_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( DSirunofffile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'DSirunoff',
     I      DSirunofffile, DSirunoffRepCycle, DSirunoffperiod,
     I      DSirunoffStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'DSirunoff',
     &  DSirunoff_lon0, DSirunoff_lon_inc,
     &  DSirunoff_lat0, DSirunoff_lat_inc,
     &  DSirunoff_nlon, DSirunoff_nlat, DSirunoff_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( POCrunofffile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'POCrunoff',
     I      POCrunofffile, POCrunoffRepCycle, POCrunoffperiod,
     I      POCrunoffStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'POCrunoff',
     &  POCrunoff_lon0, POCrunoff_lon_inc,
     &  POCrunoff_lat0, POCrunoff_lat_inc,
     &  POCrunoff_nlon, POCrunoff_nlat, POCrunoff_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( POPrunofffile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'POPrunoff',
     I      POPrunofffile, POPrunoffRepCycle, POPrunoffperiod,
     I      POPrunoffStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'POPrunoff',
     &  POPrunoff_lon0, POPrunoff_lon_inc,
     &  POPrunoff_lat0, POPrunoff_lat_inc,
     &  POPrunoff_nlon, POPrunoff_nlat, POPrunoff_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( PONrunofffile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'PONrunoff',
     I      PONrunofffile, PONrunoffRepCycle, PONrunoffperiod,
     I      PONrunoffStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'PONrunoff',
     &  PONrunoff_lon0, PONrunoff_lon_inc,
     &  PONrunoff_lat0, PONrunoff_lat_inc,
     &  PONrunoff_nlon, PONrunoff_nlat, PONrunoff_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

      IF ( DICrunofffile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'DICrunoff',
     I      DICrunofffile, DICrunoffRepCycle, DICrunoffperiod,
     I      DICrunoffStartTime, useExfYearlyFields, addBlkLn, myThid )
#ifdef USE_EXF_INTERPOLATION
       CALL EXF_PRINT_INTERP( 'DICrunoff',
     &  DICrunoff_lon0, DICrunoff_lon_inc,
     &  DICrunoff_lat0, DICrunoff_lat_inc,
     &  DICrunoff_nlon, DICrunoff_nlat, DICrunoff_interpMethod, myThid )
#endif
       prtBlkLn = .TRUE.
      ENDIF

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)')
     &'// ======================================================='
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)')
     &'// Darwin external fording configuration  >>> END <<<'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)')
     &'// ======================================================='
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )

      _END_MASTER( myThid )

      RETURN
      END
