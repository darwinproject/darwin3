#include "OASIM_OPTIONS.h"
#include "EXF_OPTIONS.h"

CBOP
C !ROUTINE: OASIM_CHECK

C !INTERFACE: ==========================================================
      SUBROUTINE OASIM_CHECK( myThid )

C !DESCRIPTION:
C     Check oasim parameters,

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
#include "OASIM_SIZE.h"
#include "OASIM_PARAMS.h"
#include "OASIM_EXF_PARAMS.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid

C !OUTPUT PARAMETERS: ==================================================
C  none
CEOP

#ifdef ALLOW_OASIM

C !LOCAL VARIABLES: ====================================================
      LOGICAL haveAny,addBlkLn
      INTEGER oUnit, l, errCount
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      CHARACTER*1 blkLin

      _BEGIN_MASTER(myThid)

C ======================================================================
C     check for errors in configuration

C ======================================================================
C     log OASIM runtime parameters

      blkLin = ' '
      addBlkLn = .FALSE.

      WRITE(msgBuf,'(A)') 'OASIM_CHECK: #define ALLOW_OASIM'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                    SQUEEZE_RIGHT , myThid )

C ======================================================================
C     exf forcing parameters

      CALL WRITE_0D_L(useoasimYearlyFields,INDEX_NONE,
     &'useoasimYearlyFields =',
     &' /* whether files are per year with _YYYY suffix */')

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                    SQUEEZE_RIGHT , myThid )

C--   aerTau
      IF ( aerTaufile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'aerTau forcing',
     I      aerTaufile, aerTauRepCycle, aerTauperiod,
     I      aerTauStartTime, useExfYearlyFields, addBlkLn, myThid )
       CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )
       CALL WRITE_1D_RL(aerTau_exfremo_intercept,nlt,INDEX_NONE,
     &   'aerTau_exfremo_intercept =',
     &   ' /* intercept for aerTau forcing mean removal */')
       CALL WRITE_1D_RL(aerTau_exfremo_slope,nlt,INDEX_NONE,
     &   'aerTau_exfremo_slope =',
     &   ' /* slope for aerTau forcing trend removal */')
       CALL WRITE_1D_RL(aerTau_inscal,nlt,INDEX_NONE,
     &   'aerTau_inscal =',
     &   ' /* scaling factor for aerTau fields */')
      ELSE
       CALL WRITE_1D_RL(aerTauconst,nlt,INDEX_NONE,
     &   'aerTauconst =',
     &   ' /* constant aerTau forcing */')
      ENDIF

      haveAny = aerTauFile.NE.' '
      DO l=1,nlt
       IF (aerTauconst(l).NE.0 _d 0) haveAny = .TRUE.
      ENDDO
      IF ( haveAny ) THEN
       CALL WRITE_0D_C(aerTaumask,-1,INDEX_NONE,
     &   'aerTaumask =',
     &   ' /* mask for aerTau forcing */')
      ENDIF

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )

C--   asymp
      IF ( asympfile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'asymp forcing',
     I      asympfile, asympRepCycle, asympperiod,
     I      asympStartTime, useExfYearlyFields, addBlkLn, myThid )
       CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )
       CALL WRITE_1D_RL(asymp_exfremo_intercept,nlt,INDEX_NONE,
     &   'asymp_exfremo_intercept =',
     &   ' /* intercept for asymp forcing mean removal */')
       CALL WRITE_1D_RL(asymp_exfremo_slope,nlt,INDEX_NONE,
     &   'asymp_exfremo_slope =',
     &   ' /* slope for asymp forcing trend removal */')
       CALL WRITE_1D_RL(asymp_inscal,nlt,INDEX_NONE,
     &   'asymp_inscal =',
     &   ' /* scaling factor for asymp fields */')
      ELSE
       CALL WRITE_1D_RL(asympconst,nlt,INDEX_NONE,
     &   'asympconst =',
     &   ' /* constant asymp forcing */')
      ENDIF

      haveAny = asympFile.NE.' '
      DO l=1,nlt
       IF (asympconst(l).NE.0 _d 0) haveAny = .TRUE.
      ENDDO
      IF ( haveAny ) THEN
       CALL WRITE_0D_C(asympmask,-1,INDEX_NONE,
     &   'asympmask =',
     &   ' /* mask for asymp forcing */')
      ENDIF

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )

C--   ssalb
      IF ( ssalbfile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'ssalb forcing',
     I      ssalbfile, ssalbRepCycle, ssalbperiod,
     I      ssalbStartTime, useExfYearlyFields, addBlkLn, myThid )
       CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )
       CALL WRITE_1D_RL(ssalb_exfremo_intercept,nlt,INDEX_NONE,
     &   'ssalb_exfremo_intercept =',
     &   ' /* intercept for ssalb forcing mean removal */')
       CALL WRITE_1D_RL(ssalb_exfremo_slope,nlt,INDEX_NONE,
     &   'ssalb_exfremo_slope =',
     &   ' /* slope for ssalb forcing trend removal */')
       CALL WRITE_1D_RL(ssalb_inscal,nlt,INDEX_NONE,
     &   'ssalb_inscal =',
     &   ' /* scaling factor for ssalb fields */')
      ELSE
       CALL WRITE_1D_RL(ssalbconst,nlt,INDEX_NONE,
     &   'ssalbconst =',
     &   ' /* constant ssalb forcing */')
      ENDIF

      haveAny = ssalbFile.NE.' '
      DO l=1,nlt
       IF (ssalbconst(l).NE.0 _d 0) haveAny = .TRUE.
      ENDDO
      IF ( haveAny ) THEN
       CALL WRITE_0D_C(ssalbmask,-1,INDEX_NONE,
     &   'ssalbmask =',
     &   ' /* mask for ssalb forcing */')
      ENDIF

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )

C--   cldcov
      IF ( cldcovfile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'cldcov forcing',
     I      cldcovfile, cldcovRepCycle, cldcovperiod,
     I      cldcovStartTime, useExfYearlyFields, addBlkLn, myThid )
       CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )
       CALL WRITE_0D_RL(cldcov_exfremo_intercept,INDEX_NONE,
     &   'cldcov_exfremo_intercept =',
     &   ' /* intercept for cldcov forcing mean removal */')
       CALL WRITE_0D_RL(cldcov_exfremo_slope,INDEX_NONE,
     &   'cldcov_exfremo_slope =',
     &   ' /* slope for cldcov forcing trend removal */')
       CALL WRITE_0D_RL(cldcov_inscal,INDEX_NONE,
     &   'cldcov_inscal =',
     &   ' /* scaling factor for cldcov fields */')
      ELSE
       CALL WRITE_0D_RL(cldcovconst,INDEX_NONE,
     &   'cldcovconst =',
     &   ' /* constant cldcov forcing */')
      ENDIF

      IF ( cldcovfile.NE.' ' .OR. cldcovconst.NE.0D0 ) THEN
       CALL WRITE_0D_C(cldcovmask,-1,INDEX_NONE,
     &   'cldcovmask =',
     &   ' /* mask for cldcov forcing */')
      ENDIF

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )

C--   cldlwp
      IF ( cldlwpfile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'cldlwp forcing',
     I      cldlwpfile, cldlwpRepCycle, cldlwpperiod,
     I      cldlwpStartTime, useExfYearlyFields, addBlkLn, myThid )
       CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )
       CALL WRITE_0D_RL(cldlwp_exfremo_intercept,INDEX_NONE,
     &   'cldlwp_exfremo_intercept =',
     &   ' /* intercept for cldlwp forcing mean removal */')
       CALL WRITE_0D_RL(cldlwp_exfremo_slope,INDEX_NONE,
     &   'cldlwp_exfremo_slope =',
     &   ' /* slope for cldlwp forcing trend removal */')
       CALL WRITE_0D_RL(cldlwp_inscal,INDEX_NONE,
     &   'cldlwp_inscal =',
     &   ' /* scaling factor for cldlwp fields */')
      ELSE
       CALL WRITE_0D_RL(cldlwpconst,INDEX_NONE,
     &   'cldlwpconst =',
     &   ' /* constant cldlwp forcing */')
      ENDIF

      IF ( cldlwpfile.NE.' ' .OR. cldlwpconst.NE.0D0 ) THEN
       CALL WRITE_0D_C(cldlwpmask,-1,INDEX_NONE,
     &   'cldlwpmask =',
     &   ' /* mask for cldlwp forcing */')
      ENDIF

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )

C--   cldre
      IF ( cldrefile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'cldre forcing',
     I      cldrefile, cldreRepCycle, cldreperiod,
     I      cldreStartTime, useExfYearlyFields, addBlkLn, myThid )
       CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )
       CALL WRITE_0D_RL(cldre_exfremo_intercept,INDEX_NONE,
     &   'cldre_exfremo_intercept =',
     &   ' /* intercept for cldre forcing mean removal */')
       CALL WRITE_0D_RL(cldre_exfremo_slope,INDEX_NONE,
     &   'cldre_exfremo_slope =',
     &   ' /* slope for cldre forcing trend removal */')
       CALL WRITE_0D_RL(cldre_inscal,INDEX_NONE,
     &   'cldre_inscal =',
     &   ' /* scaling factor for cldre fields */')
      ELSE
       CALL WRITE_0D_RL(cldreconst,INDEX_NONE,
     &   'cldreconst =',
     &   ' /* constant cldre forcing */')
      ENDIF

      IF ( cldrefile.NE.' ' .OR. cldreconst.NE.0D0 ) THEN
       CALL WRITE_0D_C(cldremask,-1,INDEX_NONE,
     &   'cldremask =',
     &   ' /* mask for cldre forcing */')
      ENDIF

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )

C--   pres
      IF ( presfile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'pres forcing',
     I      presfile, presRepCycle, presperiod,
     I      presStartTime, useExfYearlyFields, addBlkLn, myThid )
       CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )
       CALL WRITE_0D_RL(pres_exfremo_intercept,INDEX_NONE,
     &   'pres_exfremo_intercept =',
     &   ' /* intercept for pres forcing mean removal */')
       CALL WRITE_0D_RL(pres_exfremo_slope,INDEX_NONE,
     &   'pres_exfremo_slope =',
     &   ' /* slope for pres forcing trend removal */')
       CALL WRITE_0D_RL(pres_inscal,INDEX_NONE,
     &   'pres_inscal =',
     &   ' /* scaling factor for pres fields */')
      ELSE
       CALL WRITE_0D_RL(presconst,INDEX_NONE,
     &   'presconst =',
     &   ' /* constant pres forcing */')
      ENDIF

      IF ( presfile.NE.' ' .OR. presconst.NE.0D0 ) THEN
       CALL WRITE_0D_C(presmask,-1,INDEX_NONE,
     &   'presmask =',
     &   ' /* mask for pres forcing */')
      ENDIF

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )

C--   oawind
      IF ( oawindfile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'oawind forcing',
     I      oawindfile, oawindRepCycle, oawindperiod,
     I      oawindStartTime, useExfYearlyFields, addBlkLn, myThid )
       CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )
       CALL WRITE_0D_RL(oawind_exfremo_intercept,INDEX_NONE,
     &   'oawind_exfremo_intercept =',
     &   ' /* intercept for oawind forcing mean removal */')
       CALL WRITE_0D_RL(oawind_exfremo_slope,INDEX_NONE,
     &   'oawind_exfremo_slope =',
     &   ' /* slope for oawind forcing trend removal */')
       CALL WRITE_0D_RL(oawind_inscal,INDEX_NONE,
     &   'oawind_inscal =',
     &   ' /* scaling factor for oawind fields */')
      ELSE
       CALL WRITE_0D_RL(oawindconst,INDEX_NONE,
     &   'oawindconst =',
     &   ' /* constant oawind forcing */')
      ENDIF

      IF ( oawindfile.NE.' ' .OR. oawindconst.NE.0D0 ) THEN
       CALL WRITE_0D_C(oawindmask,-1,INDEX_NONE,
     &   'oawindmask =',
     &   ' /* mask for oawind forcing */')
      ENDIF

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )

C--   relhum
      IF ( relhumfile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'relhum forcing',
     I      relhumfile, relhumRepCycle, relhumperiod,
     I      relhumStartTime, useExfYearlyFields, addBlkLn, myThid )
       CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )
       CALL WRITE_0D_RL(relhum_exfremo_intercept,INDEX_NONE,
     &   'relhum_exfremo_intercept =',
     &   ' /* intercept for relhum forcing mean removal */')
       CALL WRITE_0D_RL(relhum_exfremo_slope,INDEX_NONE,
     &   'relhum_exfremo_slope =',
     &   ' /* slope for relhum forcing trend removal */')
       CALL WRITE_0D_RL(relhum_inscal,INDEX_NONE,
     &   'relhum_inscal =',
     &   ' /* scaling factor for relhum fields */')
      ELSE
       CALL WRITE_0D_RL(relhumconst,INDEX_NONE,
     &   'relhumconst =',
     &   ' /* constant relhum forcing */')
      ENDIF

      IF ( relhumfile.NE.' ' .OR. relhumconst.NE.0D0 ) THEN
       CALL WRITE_0D_C(relhummask,-1,INDEX_NONE,
     &   'relhummask =',
     &   ' /* mask for relhum forcing */')
      ENDIF

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )

C--   ozone
      IF ( ozonefile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'ozone forcing',
     I      ozonefile, ozoneRepCycle, ozoneperiod,
     I      ozoneStartTime, useExfYearlyFields, addBlkLn, myThid )
       CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )
       CALL WRITE_0D_RL(ozone_exfremo_intercept,INDEX_NONE,
     &   'ozone_exfremo_intercept =',
     &   ' /* intercept for ozone forcing mean removal */')
       CALL WRITE_0D_RL(ozone_exfremo_slope,INDEX_NONE,
     &   'ozone_exfremo_slope =',
     &   ' /* slope for ozone forcing trend removal */')
       CALL WRITE_0D_RL(ozone_inscal,INDEX_NONE,
     &   'ozone_inscal =',
     &   ' /* scaling factor for ozone fields */')
      ELSE
       CALL WRITE_0D_RL(ozoneconst,INDEX_NONE,
     &   'ozoneconst =',
     &   ' /* constant ozone forcing */')
      ENDIF

      IF ( ozonefile.NE.' ' .OR. ozoneconst.NE.0D0 ) THEN
       CALL WRITE_0D_C(ozonemask,-1,INDEX_NONE,
     &   'ozonemask =',
     &   ' /* mask for ozone forcing */')
      ENDIF

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )

C--   wv
      IF ( wvfile.NE.' ' ) THEN
       CALL EXF_FLD_SUMMARY( 'wv forcing',
     I      wvfile, wvRepCycle, wvperiod,
     I      wvStartTime, useExfYearlyFields, addBlkLn, myThid )
       CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )
       CALL WRITE_0D_RL(wv_exfremo_intercept,INDEX_NONE,
     &   'wv_exfremo_intercept =',
     &   ' /* intercept for wv forcing mean removal */')
       CALL WRITE_0D_RL(wv_exfremo_slope,INDEX_NONE,
     &   'wv_exfremo_slope =',
     &   ' /* slope for wv forcing trend removal */')
       CALL WRITE_0D_RL(wv_inscal,INDEX_NONE,
     &   'wv_inscal =',
     &   ' /* scaling factor for wv fields */')
      ELSE
       CALL WRITE_0D_RL(wvconst,INDEX_NONE,
     &   'wvconst =',
     &   ' /* constant wv forcing */')
      ENDIF

      IF ( wvfile.NE.' ' .OR. wvconst.NE.0D0 ) THEN
       CALL WRITE_0D_C(wvmask,-1,INDEX_NONE,
     &   'wvmask =',
     &   ' /* mask for wv forcing */')
      ENDIF

      CALL PRINT_MESSAGE( blkLin, standardMessageUnit,
     &                     SQUEEZE_RIGHT , myThid )

      CALL WRITE_0D_C(oasim_atmoFile,-1,INDEX_NONE,
     &'oasim_atmoFile =',
     &' /* filename for spectra of extraterrestrial irradiance and'
     &' atomspheric gases */')
      CALL WRITE_0D_C(oasim_waterFile,-1,INDEX_NONE,
     &'oasim_waterFile =',
     &' /* filename for water absorption and scattering spectra */')
      CALL WRITE_0D_C(oasim_slingoFile,-1,INDEX_NONE,
     &'oasim_slingoFile =',
     &' /* filename for cloud parameters */')

      CALL WRITE_0D_RL(oasim_dTsolz,INDEX_NONE,
     &'oasim_dTsolz =',
     &' /* sub-timestep for mean solar zenith angle computation [s] */')
      CALL WRITE_0D_RL(oasim_am,INDEX_NONE,
     &'oasim_am =',
     &' /* air-mass parameter for navaer aerosol model */')
      CALL WRITE_0D_RL(oasim_Vi,INDEX_NONE,
     &'oasim_Vi =',
     &' /* visibility for navaer aerosol model [km] */')
      CALL WRITE_0D_RL(oasim_fixedSolz,INDEX_NONE,
     &'oasim_fixedSolz =',
     &' /* fixed solar zenith angle to use (for debugging) */')
      CALL WRITE_0D_RL(oasim_fixedLon,INDEX_NONE,
     &'oasim_fixedLon =',
     &' /* fixed longitude to use (for legacy mode) */')
      CALL WRITE_0D_RL(oasim_monitorFreq,INDEX_NONE,
     &'oasim_monitorFreq =',
     &' /* monitor frequency for OASIM package */')
      CALL WRITE_0D_RL(oasim_rmus,INDEX_NONE,
     &'oasim_rmus =',
     &' /* inverse mean zenith cosine of diffuse downwelling irr. */')

C ----------------------------------------------------------------------
      _END_MASTER(myThid)

C Everyone else must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_RADTRANS */

      RETURN
      END
