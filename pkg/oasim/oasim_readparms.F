#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C !ROUTINE: OASIM_READPARMS

C !INTERFACE:
      SUBROUTINE OASIM_READPARMS( myThid )

C     !DESCRIPTION:
C     Set OASIM runtime parameters

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_PARAMS.h"
#include "OASIM_FIELDS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
C     msgBuf     :: Informational/error message buffer
C     iUnit      :: Work variable for IO unit number
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit

      NAMELIST /OASIM_PARM/ oasim_atmoFile
      NAMELIST /OASIM_PARM/ oasim_waterFile
      NAMELIST /OASIM_PARM/ oasim_slingoFile
#ifdef OASIM_READ_UNFORMATTED
      NAMELIST /OASIM_PARM/ oasim_modisCloudFile
      NAMELIST /OASIM_PARM/ oasim_cloudClimFile
      NAMELIST /OASIM_PARM/ oasim_cloudCoverFile
      NAMELIST /OASIM_PARM/ oasim_cloudCoverClimFile
      NAMELIST /OASIM_PARM/ oasim_opticsFile
      NAMELIST /OASIM_PARM/ oasim_aerosolFile
      NAMELIST /OASIM_PARM/ oasim_aerosolClimFile
      NAMELIST /OASIM_PARM/ oasim_aerTauFile
      NAMELIST /OASIM_PARM/ oasim_aerTauClimFile
#endif
      NAMELIST /OASIM_PARM/ oasim_startYear
      NAMELIST /OASIM_PARM/ oasim_dTsolz
      NAMELIST /OASIM_PARM/ oasim_am, oasim_Vi
      NAMELIST /OASIM_PARM/ oasim_fixedSolz
      NAMELIST /OASIM_PARM/ oasim_fixedLon
      NAMELIST /OASIM_PARM/ oasim_monitorFreq
      NAMELIST /OASIM_PARM/ oasim_fixedLon
      NAMELIST /OASIM_PARM/ oasim_PARwgt
      NAMELIST /OASIM_PARM/ oasim_rmus

      _BEGIN_MASTER(myThid)

C-----------------------------------------------------------------------
C     check prerequisites indepent of oasim runtime parameters
#ifndef OASIM_READ_UNFORMATTED
#ifdef ALLOW_EXF
      IF (.NOT.useEXF) THEN
#else
      IF (.TRUE.) THEN
#endif
        WRITE(msgBuf,'(2A)') 'OASIM_CHECK: need the exf package or ',
     &   'define OASIM_READ_UNFORMATTED.'
        CALL PRINT_ERROR( msgBuf, myThid )
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R OASIM_CHECK'
      ENDIF
#endif

C-----------------------------------------------------------------------
C     default values
      oasim_atmoFile       = ' '
      oasim_waterFile      = ' '
      oasim_slingoFile     = ' '
#ifdef OASIM_READ_UNFORMATTED
      oasim_modisCloudFile = ' '
      oasim_cloudClimFile  = ' '
      oasim_cloudCoverFile = ' '
      oasim_cloudCoverClimFile = ' '
      oasim_opticsFile     = ' '
      oasim_aerosolFile    = ' '
      oasim_aerosolClimFile = ' '
      oasim_aerTauFile     = ' '
      oasim_aerTauClimFile = ' '
#endif
      oasim_startYear      = UNSET_I
      oasim_dTsolz         = 900. _d 0
      oasim_am             = 1.0 _d 0
      oasim_Vi             = 25.0 _d 0
      oasim_fixedSolz      = -1 _d 0
      oasim_fixedLon       = UNSET_RL
      oasim_monitorFreq    = monitorFreq
      oasim_PARwgt(:)      = 0 _d 0
      oasim_rmus           = 1./0.83 _d 0

      WRITE(msgBuf,'(A)') 'OASIM_READPARMS: opening data.oasim'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)
      CALL OPEN_COPY_DATA_FILE(
     I                     'data.oasim', 'OASIM_READPARMS',
     O                     iUnit,
     I                     myThid )

#ifndef OASIM_READ_UNFORMATTED
      CALL OASIM_EXF_READPARMS(iUnit, -1, myThid)
#endif

C     Read parameters from open data file
      READ(UNIT=iUnit,NML=OASIM_PARM)
      WRITE(msgBuf,'(A)')
     &    'OASIM_READPARMS: finished reading data.oasim'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &    SQUEEZE_RIGHT , 1)
C     Close the open data file
      CLOSE(iUnit)

#ifndef ALLOW_CAL
      IF ( oasim_startYear .EQ. UNSET_I ) THEN
        WRITE(msgBuf,'(2A)') 'OASIM_READPARAMS:',
     &   ' must provide oasim_startYear unless using cal package'
        CALL PRINT_ERROR( msgBuf , myThid)
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R OASIM_READPARAMS'
      ENDIF
#endif

      _END_MASTER(myThid)

C--   Everyone else must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_OASIM */

      RETURN
      END
