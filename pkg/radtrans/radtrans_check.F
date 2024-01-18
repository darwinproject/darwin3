#include "RADTRANS_OPTIONS.h"
#include "EXF_OPTIONS.h"

CBOP
C !ROUTINE: RADTRANS_CHECK

C !INTERFACE: ==========================================================
      SUBROUTINE RADTRANS_CHECK( myThid )

C !DESCRIPTION:
C     Check radtrans parameters,

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#ifdef ALLOW_EXF
#include "EXF_PARAM.h"
#include "EXF_INTERP_SIZE.h"
#include "EXF_INTERP_PARAM.h"
#endif
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"
#include "RADTRANS_EXF_PARAMS.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid

C !OUTPUT PARAMETERS: ==================================================
C  none
CEOP

#ifdef ALLOW_RADTRANS

C     !FUNCTIONS:
      INTEGER     ILNBLNK
      EXTERNAL    ILNBLNK

C !LOCAL VARIABLES: ====================================================
      LOGICAL haveAny,haveAll,addBlkLn
      INTEGER oUnit, l, iL, errCount, cnt
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      CHARACTER*1 blkLin

      _BEGIN_MASTER(myThid)

C ======================================================================
C     check for errors in configuration

C ----------------------------------------------------------------------
C     check for unsupported forcing configurations
      errCount = 0
      IF ( useExfYearlyFields ) THEN
       IF ( RT_E_RepCycle.NE.0. ) THEN
        WRITE(msgBuf,'(2A)') 'RADTRANS_CHECK: The use of ',
     &       'useExfYearlyFields AND RT_E_RepCycle is not implemented'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
       IF ( RT_iceRepCycle.NE.0. ) THEN
        WRITE(msgBuf,'(2A)') 'RADTRANS_CHECK: The use of ',
     &       'useExfYearlyFields AND RT_iceRepCycle is not implemented'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF
      IF ( errCount.GE.1 ) THEN
        WRITE(msgBuf,'(A,I3,A)')
     &     'RADTRANS_CHECK: detected', errCount,' fatal error(s)'
        CALL PRINT_ERROR( msgBuf, myThid )
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R RADTRANS_CHECK'
      ENDIF

C ----------------------------------------------------------------------
C     need sun package unless using mean cos(solz)

#ifndef ALLOW_SUN
      IF (.NOT.(RT_useMeanCosSolz.OR.RT_useOASIMrmud)) THEN
        WRITE(msgBuf,'(2A)') 'RADTRANS_CHECK: need to compile the sun ',
     &   'package unless RT_useMeanCosSolz or oasim pkg is used.'
        CALL PRINT_ERROR( msgBuf, myThid )
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R RADTRANS_CHECK'
      ENDIF
#endif

C ----------------------------------------------------------------------
C     requirements for various solar zenith angle definitions

      IF (RT_useOASIMrmud .AND. .NOT.useOASIM) THEN
        WRITE(msgBuf,'(2A)') 'RADTRANS_CHECK: ',
     &       'RT_useOASIMrmud requires the OASIM package'
        CALL PRINT_ERROR( msgBuf, myThid )
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R RADTRANS_CHECK'
      ENDIF

      IF (useOASIM .AND. .NOT.RT_useOASIMrmud) THEN
        WRITE(msgBuf,'(2A)') '** WARNING ** RADTRANS_CHECK: ',
     &       'RT_useOASIMrmud=.FALSE. but is recommended with useOASIM'
        CALL PRINT_MESSAGE(msgBuf,errorMessageUnit,SQUEEZE_RIGHT,myThid)
      ENDIF

C     make sure only on solz option is set
      cnt = 0
      IF (RT_useOASIMrmud) cnt = cnt + 1
      IF (RT_useMeanCosSolz) cnt = cnt + 1
      IF (RT_useNoonSolz) cnt = cnt + 1
      IF (cnt .GT. 1) THEN
        WRITE(msgBuf,'(2A)') 'RADTRANS_CHECK: only one of ',
     &  'RT_useOASIMrmud, RT_useMeanCosSolz, RT_useNoonSolz can be set'
        CALL PRINT_ERROR( msgBuf, myThid )
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R RADTRANS_CHECK'
      ENDIF

C ----------------------------------------------------------------------
C     check for unsupported forcing configurations
      errCount = 0
      IF ( useExfYearlyFields ) THEN
       IF ( RT_E_RepCycle.NE.0. ) THEN
        WRITE(msgBuf,'(2A)') 'RADTRANS_CHECK: The use of ',
     &       'useExfYearlyFields AND RT_E_RepCycle is not implemented'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
       IF ( RT_iceRepCycle.NE.0. ) THEN
        WRITE(msgBuf,'(2A)') 'RADTRANS_CHECK: The use of ',
     &       'useExfYearlyFields AND RT_iceRepCycle is not implemented'
        CALL PRINT_ERROR( msgBuf, myThid )
        errCount = errCount + 1
       ENDIF
      ENDIF
      IF ( errCount.GE.1 ) THEN
        WRITE(msgBuf,'(A,I3,A)')
     &     'RADTRANS_CHECK: detected', errCount,' fatal error(s)'
        CALL PRINT_ERROR( msgBuf, myThid )
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R RADTRANS_CHECK'
      ENDIF

C ======================================================================

      blkLin = ' '

C ======================================================================
C     write waveband detail to standard output

      WRITE(msgBuf,'(A)') 'RADTRANS_CHECK: #define ALLOW_RADTRANS'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                    SQUEEZE_RIGHT , myThid )

      WRITE(msgBuf,'(A)') 'RADTRANS_CHECK: wavebands:'
      CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                   SQUEEZE_RIGHT,myThid)
      WRITE(msgBuf,'(2A)') 'RADTRANS_CHECK: ',
     &   ' idx       low   rep      high    width'
      CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                   SQUEEZE_RIGHT,myThid)
      DO l=1,nlam
        WRITE(msgBuf,'(A,I4,F10.3,F6.0,F10.3,F9.3)')
     &  'RADTRANS_CHECK: ', l, RT_wbEdges(l),
     &  RT_wbRefWLs(l),RT_wbEdges(l+1),RT_wbWidths(l)
        CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                   SQUEEZE_RIGHT,myThid)
      ENDDO
      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                    SQUEEZE_RIGHT , myThid )

C ----------------------------------------------------------------------
C     and to separate text file
      IF ( myProcId.EQ.0 .AND. myThid.EQ.1 ) THEN
        CALL MDSFINDUNIT( oUnit, myThid )
        OPEN(oUnit,file='pwaves-check.dat',status='unknown')
        WRITE(oUnit,'(F6.0)')RT_wbRefWLs
        CLOSE(oUnit)
      ENDIF

C ======================================================================

C--   RT_E

      addBlkLn = .FALSE.

      IF ( .NOT.useOASIM ) THEN
       haveAny = .FALSE.
       haveAll = .FALSE.
       DO l=1,nlam
        IF ( RT_EdFile(l).EQ.' ' ) THEN
         haveAll = .FALSE.
        ELSE
         haveAny = .TRUE.
         WRITE(msgBuf,'(A,I3.3,A)')'RT_Ed',l,' forcing'
         iL = ILNBLNK(msgBuf)
         CALL EXF_FLD_SUMMARY( msgBuf(1:iL),
     I        RT_EdFile(l), RT_E_RepCycle, RT_E_period,
     I        RT_E_StartTime, useExfYearlyFields, addBlkLn, myThid )
        ENDIF
       ENDDO

       CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )

       DO l=1,nlam
        IF ( RT_EsFile(l).EQ.' ' ) THEN
         haveAll = .FALSE.
        ELSE
         haveAny = .TRUE.
         WRITE(msgBuf,'(A,I3.3,A)')'RT_Es',l,' forcing'
         iL = ILNBLNK(msgBuf)
         CALL EXF_FLD_SUMMARY( msgBuf(1:iL),
     I        RT_EsFile(l), RT_E_RepCycle, RT_E_period,
     I        RT_E_StartTime, useExfYearlyFields, addBlkLn, myThid )
        ENDIF
       ENDDO

       IF (haveAny) THEN
        CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                      SQUEEZE_RIGHT , myThid )
        CALL WRITE_1D_RL(RT_Ed_exfremo_intercept,nlam,INDEX_NONE,
     &   'RT_Ed_exfremo_intercept =',
     &   ' /* intercept for RT_Ed forcing mean removal */')
        CALL WRITE_1D_RL(RT_Ed_exfremo_slope,nlam,INDEX_NONE,
     &   'RT_Ed_exfremo_slope =',
     &   ' /* slope for RT_Ed forcing trend removal */')
        CALL WRITE_1D_RL(RT_inscal_Ed,nlam,INDEX_NONE,
     &   'RT_inscal_Ed =',
     &   ' /* scaling factor for RT_Ed fields */')

        CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                      SQUEEZE_RIGHT , myThid )

        CALL WRITE_1D_RL(RT_Es_exfremo_intercept,nlam,INDEX_NONE,
     &   'RT_Es_exfremo_intercept =',
     &   ' /* intercept for RT_Es forcing mean removal */')
        CALL WRITE_1D_RL(RT_Es_exfremo_slope,nlam,INDEX_NONE,
     &   'RT_Es_exfremo_slope =',
     &   ' /* slope for RT_Es forcing trend removal */')
        CALL WRITE_1D_RL(RT_inscal_Es,nlam,INDEX_NONE,
     &   'RT_inscal_Es =',
     &   ' /* scaling factor for RT_Es fields */')
       ENDIF
       IF (.NOT.haveAll) THEN
        CALL WRITE_1D_RL(RT_Ed_const,nlam,INDEX_NONE,
     &   'RT_Ed_const =',
     &   ' /* constant RT_Ed forcing */')
        CALL WRITE_1D_RL(RT_Es_const,nlam,INDEX_NONE,
     &   'RT_Es_const =',
     &   ' /* constant RT_Es forcing */')
       ENDIF

       CALL WRITE_0D_C(RT_E_mask,-1,INDEX_NONE,
     &   'RT_E_mask =',
     &   ' /* mask for RT_E forcing */')

C     endif .NOT.useOASIM
      ENDIF

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )

C--   ice
      IF ( RT_icefile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'RT_ice forcing',
     I      RT_icefile, RT_iceRepCycle, RT_iceperiod,
     I      RT_iceStartTime, useExfYearlyFields, addBlkLn, myThid )
       CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )
       CALL WRITE_0D_RL(RT_ice_exfremo_intercept,INDEX_NONE,
     &   'RT_ice_exfremo_intercept =',
     &   ' /* intercept for RT_ice forcing mean removal */')
       CALL WRITE_0D_RL(RT_ice_exfremo_slope,INDEX_NONE,
     &   'RT_ice_exfremo_slope =',
     &   ' /* slope for RT_ice forcing trend removal */')
       CALL WRITE_0D_RL(RT_inscal_ice,INDEX_NONE,
     &   'RT_inscal_ice =',
     &   ' /* scaling factor for RT_ice fields */')
      ELSE
       CALL WRITE_0D_RL(RT_iceconst,INDEX_NONE,
     &   'RT_iceconst =',
     &   ' /* constant RT_ice forcing */')
      ENDIF

      IF ( RT_icefile.NE.' ' .OR. RT_iceconst.NE.0D0 ) THEN
       CALL WRITE_0D_C(RT_icemask,-1,INDEX_NONE,
     &   'RT_icemask =',
     &   ' /* mask for RT_ice forcing */')
      ENDIF

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )

      CALL WRITE_0D_RL(RT_refract_water,INDEX_NONE,
     &'RT_refract_water =',
     &' /* refractive index of water */')
      CALL WRITE_0D_RL(RT_rmud_max,INDEX_NONE,
     &'RT_rmud_max =',
     &' /* cutoff for inverse cosine of solar zenith angle */')
      CALL WRITE_1D_RL(RT_wbEdges,nlam,INDEX_NONE,
     &'RT_wbEdges =',
     &' /* waveband edges [nm] */')
      CALL WRITE_1D_RL(RT_wbRefWLs,nlam,INDEX_NONE,
     &'RT_wbRefWLs =',
     &' /* reference wavelengths for wavebands [nm] */')
      CALL WRITE_1D_RL(RT_wbWidths,nlam,INDEX_NONE,
     &'RT_wbWidths =',
     &' /* waveband widths [nm] */')
      CALL WRITE_0D_RL(RT_wbTotalWidth,INDEX_NONE,
     &'RT_wbTotalWidth =',
     &' /* total width of all wavebands [nm] */')
      CALL WRITE_0D_I(RT_kmax,INDEX_NONE,
     &'RT_kmax =',
     &' /* maximum depth index for radtrans computations */')
      CALL WRITE_0D_L(RT_useOASIMrmud,INDEX_NONE,
     &'RT_useOASIMrmud =',
     &' /* use mean solar zenith angle from OASIM */')
      CALL WRITE_0D_L(RT_useMeanCosSolz,INDEX_NONE,
     &'RT_useMeanCosSolz =',
     &' /* flag for using mean daytime cosine of solar zenith angle */')
      CALL WRITE_0D_L(RT_useNoonSolz,INDEX_NONE,
     &'RT_useNoonSolz =',
     &' /* flag for using noon solar zenith angle */')
      CALL WRITE_0D_RL(RT_sfcIrrThresh,INDEX_NONE,
     &'RT_sfcIrrThresh =',
     &' /* minimum irradiance for radiative transfer computations */')
      CALL WRITE_1D_RL(RT_oasimWgt,nlam,INDEX_NONE,
     &'RT_oasimWgt =',
     &' /* weight multiplying each waveband from OASIM */')
      CALL WRITE_0D_RL(RT_rmus,INDEX_NONE,
     &'RT_rmus =',
     &' /* mean inv. cosine of zenith angle for dwnwrd diff. irr. */')
      CALL WRITE_0D_RL(RT_rmuu,INDEX_NONE,
     &'RT_rmuu =',
     &' /* mean inv. cosine of zenith angle for upward diff. irr. */')
      CALL WRITE_0D_RL(RT_rd,INDEX_NONE,
     &'RT_rd =',
     &' /* mean upward scattering fraction for downward diff. irr. */')
      CALL WRITE_0D_RL(RT_ru,INDEX_NONE,
     &'RT_ru =',
     &' /* mean downward scattering fraction for upward diff. irr. */')
      CALL WRITE_0D_L(RT_useSEAICE,INDEX_NONE,
     &'RT_useSEAICE =',
     &' /* use ice fraction from seaice package */')
      CALL WRITE_0D_L(RT_haveIce,INDEX_NONE,
     &'RT_haveIce =',
     &' /* whether iceFile iceConst have been provided */')
      CALL WRITE_1D_RL(RT_WtouEins,nlam,INDEX_NONE,
     &'RT_WtouEins =',
     &' /* conversion factors for irradiance to PAR */')

C ----------------------------------------------------------------------
      _END_MASTER(myThid)

C Everyone else must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_RADTRANS */

      RETURN
      END
