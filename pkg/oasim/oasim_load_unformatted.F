#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OASIM_LOAD_UNFORMATTED

C     !INTERFACE:
      SUBROUTINE OASIM_LOAD_UNFORMATTED( myTime, myIter, myThid )

C     !DESCRIPTION:
C     Load input fields OASIM state package.
C     For now very simple-minded: no interplation, fields stay the same
C     throughout month.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_PARAMS.h"
#include "OASIM_FIELDS.h"
#ifdef ALLOW_CAL
#include "cal.h"
#endif

C     !INPUT PARAMETERS:
C     myTime   :: Current time of simulation ( s )
C     myIter   :: Current iteration number in simulation
C     myThid   :: my Thread Id number
      _RL     myTime
      INTEGER myIter, myThid
CEOP

#ifdef ALLOW_OASIM
#ifdef OASIM_READ_UNFORMATTED
C     !LOCAL VARIABLES:
      LOGICAL newmonth
      INTEGER imon, year
#ifdef ALLOW_CAL
      INTEGER iday, imono, secs, lp, wd, currentdate(4)
#else
      _RL monsec
      PARAMETER( monsec = 2592000.0 _d 0 )
#endif
#ifdef OASIM_OUTPUT_FORCING
      CHARACTER*(MAX_LEN_FNAM) fileout
      INTEGER l
#endif

#ifdef ALLOW_CAL
      CALL cal_GetDate( myiter-1,mytime-deltaTclock,currentdate,mythid )
      CALL cal_convDate( currentdate,year,imono,iday,secs,lp,wd,myThid )
      CALL cal_GetDate( myiter, mytime, currentdate, mythid )
      CALL cal_convDate( currentdate,year,imon,iday,secs,lp,wd,myThid )
      newmonth = imon .NE. imono
c      ndmo = nDayMonth(imon, currentdate(3))
#else
C     assume run starts Jan.1 of oasim_startYear and month has 30 days
      imon = FLOOR((myTime+0.5 _d 0*deltaTclock)/monsec)
      newmonth = imon .NE. FLOOR((myTime-0.5 _d 0*deltaTclock)/monsec)
      year = imon/12
      imon = imon - 12*year + 1
      year = oasim_startYear + year
c      ndmo = 30
#endif

C     keep the same field throughout the month
      IF ( myIter .EQ. nIter0 .OR. newmonth ) THEN
        CALL OASIM_READ( year, imon, myThid )

#ifdef OASIM_OUTPUT_FORCING
        WRITE(fileout,'(A,I4)')'o_ccov_', year
        CALL WRITE_REC_XY_RL(fileout, ccov, imon, myIter, myThid )
        WRITE(fileout,'(A,I4)')'o_rlwp_', year
        CALL WRITE_REC_XY_RL(fileout, rlwp, imon, myIter, myThid )
        WRITE(fileout,'(A,I4)')'o_cdre_', year
        CALL WRITE_REC_XY_RL(fileout, cdre, imon, myIter, myThid )
        WRITE(fileout,'(A,I4)')'o_slp_', year
        CALL WRITE_REC_XY_RL(fileout, slp, imon, myIter, myThid )
        WRITE(fileout,'(A,I4)')'o_wsm_', year
        CALL WRITE_REC_XY_RL(fileout, wsm, imon, myIter, myThid )
        WRITE(fileout,'(A,I4)')'o_rh_', year
        CALL WRITE_REC_XY_RL(fileout, rh, imon, myIter, myThid )
        WRITE(fileout,'(A,I4)')'o_oz_', year
        CALL WRITE_REC_XY_RL(fileout, oz, imon, myIter, myThid )
        WRITE(fileout,'(A,I4)')'o_wv_', year
        CALL WRITE_REC_XY_RL(fileout, wv, imon, myIter, myThid )
        DO l=1,nlt
         WRITE(fileout,'(A,I3.3,A,I4)')'o_taua', l, '_', year
         CALL WRITE_REC_XY_RL(fileout, taua(1-OLx,1-OLy,1,1,l), imon,
     &         myIter, myThid)
         WRITE(fileout,'(A,I3.3,A,I4)')'o_asymp', l, '_', year
         CALL WRITE_REC_XY_RL(fileout, asymp(1-OLx,1-OLy,1,1,l), imon,
     &         myIter, myThid)
         WRITE(fileout,'(A,I3.3,A,I4)')'o_ssalb', l, '_', year
         CALL WRITE_REC_XY_RL(fileout, ssalb(1-OLx,1-OLy,1,1,l), imon,
     &         myIter, myThid)
        ENDDO
#endif
      ENDIF

#endif /* OASIM_READ_UNFORMATTED */
#endif /* ALLOW_OASIM */

      RETURN
      END


#ifdef OASIM_READ_UNFORMATTED
C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: OASIM_READ

C     !INTERFACE:
      SUBROUTINE OASIM_READ( year, imo, myThid )

C     !DESCRIPTION:
C     Read oasim data into local arrays

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "GRID.h"
#include "PARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_IO_SIZE.h"
#include "OASIM_PARAMS.h"
#include "OASIM_FIELDS.h"
#include "OASIM_INTERNAL.h"

C     !INPUT PARAMETERS:
C     myThid   :: my Thread Id number
      INTEGER year, imo
      INTEGER myThid
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      INTEGER i,j,bi,bj,il,jl,l,laer
      _RL w
      _RL slpin(iatm,jatm),wsmin(iatm,jatm),rhin(iatm,jatm)
      _RL ozin(iatm,jatm),wvin(iatm,jatm)
      _RL ccovin(icd,jcd),cldtcin(icd,jcd),rlwpin(icd,jcd)
      _RL cdrein(icd,jcd)
      REAL*4 tauain(icd,jcd,nltaer),asympin(icd,jcd,nltaer)
      REAL*4 ssalbin(icd,jcd,nltaer)

      CALL OASIM_READ_CLOUDS(year,imo, ccovin,cldtcin,rlwpin,cdrein,
     &                       myThid)
      CALL OASIM_READ_GASES(year,imo, slpin,wsmin,rhin,ozin,wvin,myThid)
      CALL OASIM_READ_AEROSOLS(year,imo, tauain,asympin,ssalbin,myThid)

      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)
      DO j=1,sNy
      DO i=1,sNx
        il = FLOOR(MOD(XC(i,j,bi,bj) + 180.0 _d 0, 360.0 _d 0)) + 1
        jl = FLOOR((YC(i,j,bi,bj) + 90.0 _d 0)) + 1
        ccov (i,j,bi,bj) = ccovin (il,jl)
        rlwp (i,j,bi,bj) = rlwpin (il,jl)
        cdre (i,j,bi,bj) = cdrein (il,jl)
        slp  (i,j,bi,bj) = slpin  (il,jl)
        wsm  (i,j,bi,bj) = wsmin  (il,jl)
        rh   (i,j,bi,bj) = rhin   (il,jl)
        oz   (i,j,bi,bj) = ozin   (il,jl)
        wv   (i,j,bi,bj) = wvin   (il,jl)
        DO l=1,nlt
          laer = iaer(l)
          w = waer(l)
          taua (i,j,bi,bj,l) = w*tauain (il,jl,laer-1)
     &                    + (1-w)*tauain (il,jl,laer)
          asymp(i,j,bi,bj,l) = w*asympin(il,jl,laer-1)
     &                    + (1-w)*asympin(il,jl,laer)
          ssalb(i,j,bi,bj,l) = w*ssalbin(il,jl,laer-1)
     &                    + (1-w)*ssalbin(il,jl,laer)
        ENDDO
      ENDDO
      ENDDO
      ENDDO
      ENDDO

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: OASIM_READ_CLOUDS

C     !INTERFACE:
      SUBROUTINE OASIM_READ_CLOUDS(year,imo,
     O             ccov1,cldtc1,rlwp1,cdre1,mythid)

C     !DESCRIPTION:
C     Read cloud data from modcldYYYY.dat and cldYYYY.dat
C
C     - ccov1, rlwp1 taken from oasim_cloudCoverFile (ISCCP) if exists
C       else from oasim_cloudCoverClimFile
C     - cldtc1, cdre1 taken from oasim_modisCloudFile if exists and has
C       any valid data, else from oasim_cloudClimFile
C
C     cldtc1 is not actually used by the cloud model, the optical
C     thickness is computed from rlwp1 and cdre1.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_IO_SIZE.h"
#include "OASIM_PARAMS.h"

C     !INPUT PARAMETERS:
      INTEGER year, imo
      INTEGER mythid

C     !OUTPUT PARAMETERS:
C     ccov1  :: cloud cover in percent
C     rlwp1  :: liquid water path
C     cldtc1 :: optical thickness
C     cdre1  :: effective droplet radius
      _RL cldtc1(icd,jcd), cdre1(icd,jcd)
      _RL ccov1(icd,jcd), rlwp1(icd,jcd)
CEOP

#ifdef ALLOW_OASIM

C     !FUNCTIONS:
      INTEGER  ILNBLNK
      EXTERNAL ILNBLNK

C     !LOCAL VARIABLES:
      REAL*4 ccovm(icd,jcd),cldtcm(icd,jcd)
      REAL*4 rlwpm(icd,jcd),cdrem(icd,jcd)
      REAL*4 ccovi(icd,jcd),cldtci(icd,jcd)
      REAL*4 rlwpi(icd,jcd)
      INTEGER*4 imc, jmc
      INTEGER i, ic, ierrmodcld, il, immo, iUnit
      INTEGER j, j1, jc, jc1, m, l, nre, ios
      _RL avgisccp, avgre, refac, sumre, covmax, taumax
      CHARACTER*(MAX_LEN_FNAM) fileout
      CHARACTER*(MAX_LEN_MBUF) msgBuf

c Use MODIS clouds for re and tc
      ierrmodcld = 1

      CALL MDSFINDUNIT(iUnit, myThid)

c  Try transient data if given
      il = ILNBLNK( oasim_modisCloudFile )
      WRITE(fileout,'(a,i4.4,a)')
     &     oasim_modisCloudFile(1:il),year,'.dat'
      IF ( debugLevel .GE. debLevB ) THEN
        il = ILNBLNK( fileout )
        WRITE(msgBuf,'(A,A)')
     &   ' OASIM_FIELDS_LOAD: opening global file: ',fileout(1:il)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT , myThid)
      ENDIF
      OPEN(iUnit,FILE=fileout,STATUS='old',FORM='unformatted',
     &     CONVERT='LITTLE_ENDIAN',IOSTAT=ios)
      IF (ios .eq. 0) THEN
      READ(iUnit)imc,jmc
c  Read out up until and including present month
      DO m = 1,imo
       READ(iUnit)ccovm,cldtcm,rlwpm,cdrem
      ENDDO
c  Check for valid data
      DO j = 1,jcd
       DO i = 1,icd
        IF (ccovm(i,j) .GT. 0.0 _d 0)ierrmodcld = 0
       ENDDO
      ENDDO
      ELSE
       il = ILNBLNK( fileout )
       WRITE(msgBuf,'(3A)') 'OASIM_FIELDS_LOAD:',
     &   ' could not open modisCloudFile,', fileout(1:il)
       CALL PRINT_MESSAGE( msgBuf , errorMessageUnit,
     &                     SQUEEZE_RIGHT , myThid)
       WRITE(msgBuf,'(2A)') 'OASIM_FIELDS_LOAD:',
     &   ' trying climatology'
       CALL PRINT_MESSAGE( msgBuf , errorMessageUnit,
     &                     SQUEEZE_RIGHT , myThid)
      ENDIF
      CLOSE(iUnit)
c  If no valid data, try climatological data if given
      IF (ierrmodcld .eq. 1 .AND. oasim_cloudClimFile.NE.' ') THEN
        il = ILNBLNK( oasim_cloudClimFile )
        WRITE(fileout,'(a)')
     &       oasim_cloudClimFile(1:il)
        IF ( debugLevel .GE. debLevB ) THEN
          il = ILNBLNK( fileout )
          WRITE(msgBuf,'(A,A)')
     &     ' OASIM_FIELDS_LOAD: opening global file: ',fileout(1:il)
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                        SQUEEZE_RIGHT , myThid)
        ENDIF
        OPEN(iUnit,FILE=fileout,STATUS='old',FORM='unformatted',
     &       CONVERT='LITTLE_ENDIAN')
        READ(iUnit)imc,jmc
c  Read out up until and including present month
        DO m = 1,imo
         READ(iUnit)ccovm,cldtcm,rlwpm,cdrem
        ENDDO
        CLOSE(iUnit)
        ierrmodcld = 0
      ENDIF
      IF (ierrmodcld .eq. 0) THEN
        cldtc1 = cldtcm
c   Normalize re to ISCCP avg = (10.0 _d 0+11.8 _d 0)/2um = mean of Kiehl and Han
        sumre = 0.0 _d 0
        nre = 0
        DO j = 1,jcd
        DO i = 1,icd
         IF (cdrem(i,j) .GE. 0.0 _d 0)THEN
          sumre = sumre + cdrem(i,j)
          nre = nre+1
         ENDIF
        ENDDO
        ENDDO
        avgre = sumre/float(nre)
        avgisccp = (10.0 _d 0+11.8 _d 0)/2.0 _d 0
        refac = avgisccp/avgre
        DO j = 1,jcd
         DO i = 1,icd
          IF (cdrem(i,j) .GE. 0.0 _d 0)THEN
           cdre1(i,j) = refac*cdrem(i,j)
          ELSE
           cdre1(i,j) = cdrem(i,j)
          ENDIF
         ENDDO
        ENDDO
      ENDIF
c Use ISCCP clouds for cover and LWP
      il = ILNBLNK( oasim_cloudCoverFile )
      WRITE(fileout,'(a,i4.4,a)')
     &     oasim_cloudCoverFile(1:il),year,'.dat'
      IF ( debugLevel .GE. debLevB ) THEN
        il = ILNBLNK( fileout )
        WRITE(msgBuf,'(A,A)')
     &   ' OASIM_FIELDS_LOAD: opening global file: ',fileout(1:il)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT , myThid)
      ENDIF
      OPEN(iUnit,FILE=fileout,STATUS='old',FORM='unformatted',
     &     CONVERT='LITTLE_ENDIAN',IOSTAT=ios)
      IF (ios .ne. 0) THEN
       il = ILNBLNK( fileout )
       WRITE(msgBuf,'(3A)') 'OASIM_FIELDS_LOAD:',
     &   ' could not open CloudCoverFile,', fileout(1:il)
       CALL PRINT_MESSAGE( msgBuf , errorMessageUnit,
     &                     SQUEEZE_RIGHT , myThid)
       WRITE(msgBuf,'(2A)') 'OASIM_FIELDS_LOAD:',
     &   ' trying climatology'
       CALL PRINT_MESSAGE( msgBuf , errorMessageUnit,
     &                     SQUEEZE_RIGHT , myThid)
       OPEN(iUnit,FILE=OASIM_CloudCoverClimFile,STATUS='old',
     &      FORM='unformatted',CONVERT='LITTLE_ENDIAN',IOSTAT=ios)
      ENDIF
      READ(iUnit)imc,jmc
c  Read out up until and including present month
      DO m = 1,imo
       READ(iUnit)ccovi,cldtci,rlwpi
      ENDDO
      CLOSE(iUnit)
      ccov1 = ccovi
      rlwp1 = rlwpi
      IF (ierrmodcld .eq. 1)THEN
       cdre1 = -1.0 _d 10
      ENDIF
c
      taumax = -9999.0
      covmax = -9999.0
c
C fill in data outside range of satellite from last valid point in the
C south and north
      DO jc = 1,jcd
       DO ic = 1,icd
        IF (ccov1(ic,jc) .LT. 0.0 _d 0)THEN
         jc1 = max(jc-1,1)
         ccov1(ic,jc) = ccov1(ic,jc1)
        ENDIF
        IF (ccov1(ic,jc) .LT. 0.0 _d 0)THEN
         jc1 = jc+1
         jc1 = min(jc1,jcd)
         DO WHILE (ccov1(ic,jc1) .LT. 0.0 _d 0 .AND. jc1 .LT. jcd)
          jc1 = jc1+1
         ENDDO
         ccov1(ic,jc) = ccov1(ic,jc1)
        ENDIF
c
        IF (cldtc1(ic,jc) .LT. 0.0 _d 0)THEN
         jc1 = max(jc-1,1)
         cldtc1(ic,jc) = cldtc1(ic,jc1)
        ENDIF
        IF (cldtc1(ic,jc) .LT. 0.0 _d 0)THEN
         jc1 = jc+1
         jc1 = min(jc1,jcd)
         DO WHILE (cldtc1(ic,jc1) .LT. 0.0 _d 0 .AND. jc1 .LT. jcd)
          jc1 = jc1+1
         ENDDO
         cldtc1(ic,jc) = cldtc1(ic,jc1)
        ENDIF
c
        IF (rlwp1(ic,jc) .LT. 0.0 _d 0)THEN
         jc1 = max(jc-1,1)
         rlwp1(ic,jc) = rlwp1(ic,jc1)
        ENDIF
        IF (rlwp1(ic,jc) .LT. 0.0 _d 0)THEN
         jc1 = jc+1
         jc1 = min(jc1,jcd)
         DO WHILE (rlwp1(ic,jc1) .LT. 0.0 _d 0 .AND. jc1 .LT. jcd)
          jc1 = jc1+1
         ENDDO
         rlwp1(ic,jc) = rlwp1(ic,jc1)
        ENDIF
c
        IF (ierrmodcld .eq. 0)THEN
         IF (cdre1(ic,jc) .LT. 0.0 _d 0)THEN
          jc1 = max(jc-1,1)
          cdre1(ic,jc) = cdre1(ic,jc1)
         ENDIF
         IF (cdre1(ic,jc) .LT. 0.0 _d 0)THEN
          jc1 = jc+1
          jc1 = min(jc1,jcd)
          DO WHILE (cdre1(ic,jc1) .LT. 0.0 _d 0 .AND. jc1 .LT. jcd)
           jc1 = jc1+1
          ENDDO
          cdre1(ic,jc) = cdre1(ic,jc1)
         ENDIF
        ENDIF
c   find min/max
        IF (ccov1(ic,jc) .GT. covmax)THEN
         covmax = ccov1(ic,jc)
        ENDIF
        IF (cldtc1(ic,jc) .GT. taumax)THEN
         taumax = cldtc1(ic,jc)
        ENDIF
       ENDDO
      ENDDO

      IF (taumax .LT. 0.0 _d 0)THEN
       cdre1 = -1.0 _d 10
       ierrmodcld = 1
      ENDIF

      IF (covmax .LE. 0.0 _d 0)THEN
       WRITE(msgBuf,'(2A,I4,X,I2)') 'OASIM_READ_CLOUDS: ',
     &      'invalid cloud data for ',year,imo
       CALL PRINT_ERROR( msgBuf , myThid)
       STOP 'ABNORMAL END: S/R OASIM_READ_CLOUDS: INVALID CLOUD DATA'
      ENDIF

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: OASIM_READ_GASES

C     !INTERFACE:
      SUBROUTINE OASIM_READ_GASES(year,imo,
     O      slp1,wsm1,rh1,oz1,wv1,
     I      mythid)

C     !DESCRIPTION:
C     Read gas concentrations from optYYYY.dat

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_IO_SIZE.h"
#include "OASIM_PARAMS.h"

C     !INPUT PARAMETERS:
      INTEGER year, imo
      INTEGER myThid

C     !OUTPUT PARAMETERS:
      _RL slp1(iatm,jatm),wsm1(iatm,jatm),rh1(iatm,jatm)
      _RL oz1(iatm,jatm),wv1(iatm,jatm)
CEOP

#ifdef ALLOW_OASIM

C     !FUNCTIONS:
      INTEGER  ILNBLNK
      EXTERNAL ILNBLNK

C     !LOCAL VARIABLES:
      REAL*4 slporg(iatm,jatm),wsmorg(iatm,jatm),rhorg(iatm,jatm)
      REAL*4 ozorg(iatm,jatm),wvorg(iatm,jatm)
      INTEGER*4 imc, jmc
      INTEGER i, il, iUnit
      INTEGER j, j1, m
      CHARACTER*(MAX_LEN_FNAM) fileout
      CHARACTER*(MAX_LEN_MBUF) msgBuf

      CALL MDSFINDUNIT(iUnit, myThid)

      il = ILNBLNK( oasim_opticsFile )
      WRITE(fileout,'(a,i4.4,a)')
     &     oasim_opticsFile(1:il),year,'.dat'
      IF ( debugLevel .GE. debLevB ) THEN
        il = ILNBLNK( fileout )
        WRITE(msgBuf,'(A,A)')
     &   ' OASIM_FIELDS_LOAD: opening global file: ',fileout(1:il)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT , myThid)
      ENDIF
      OPEN(iUnit,FILE=fileout,STATUS='old',FORM='unformatted',
     &     CONVERT='LITTLE_ENDIAN')
      READ(iUnit)imc,jmc
      DO m = 1,imo
       READ(iUnit)slporg,wsmorg,rhorg,ozorg,wvorg
      ENDDO
      CLOSE(iUnit)
c
      DO j = 1,jatm
       DO i = 1,iatm
        slp1(i,j) = slporg(i,j)
        rhorg(i,j) = min(rhorg(i,j),100.0 _d 0)  !prevent excess saturation
C       fill in north and south
        IF (ozorg(i,j) .LT. 0.0 _d 0)THEN
         j1 = max(j-1,1)
         ozorg(i,j) = ozorg(i,j1)
        ENDIF
        IF (ozorg(i,j) .LT. 0.0 _d 0)THEN
         j1 = j+1
         j1 = min(j1,jatm)
         DO WHILE (ozorg(i,j1) .LT. 0.0 _d 0 .AND. j1 .LT. jatm)
          j1 = j1+1
         ENDDO
         ozorg(i,j) = ozorg(i,j1)
        ENDIF
        wsm1(i,j) = wsmorg(i,j)
        rh1(i,j) = rhorg(i,j)
        oz1(i,j) = ozorg(i,j)
        wv1(i,j) = wvorg(i,j)
       ENDDO
      ENDDO

#endif /* ALLOW_OASIM */

      RETURN
      END


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: OASIM_READ_AEROSOLS

C     !INTERFACE:
      SUBROUTINE OASIM_READ_AEROSOLS(year,imo,
     O                               taua1,asymp1,ssalb1,
     I                               mythid)

C     !DESCRIPTION:
C     Read in aerosols from modaerYYYYMM.dat

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_IO_SIZE.h"
#include "OASIM_PARAMS.h"

C     !INPUT PARAMETERS:
      INTEGER year, imo
      INTEGER myThid

C     !OUTPUT PARAMETERS:
      REAL*4 taua1(icd,jcd,nltaer),asymp1(icd,jcd,nltaer)
      REAL*4 ssalb1(icd,jcd,nltaer)
CEOP

#ifdef ALLOW_OASIM

C     !FUNCTIONS:
      INTEGER  ILNBLNK
      EXTERNAL ILNBLNK

C     !LOCAL VARIABLES:
      INTEGER il,ios,i,j,l,immo,iUnit
      _RL flagam
      DATA flagam /-0.01 _d 0/
      REAL*4 avhrrtau(iatm,jatm),avhrrtauclim(iatm,jatm)
      _RL facaer(nltaer)
      CHARACTER*(MAX_LEN_FNAM) fileout
      CHARACTER*(MAX_LEN_MBUF) msgBuf

      CALL MDSFINDUNIT(iunit, myThid)

c try modis aerosol file
      taua1 = flagam
      il = ILNBLNK( oasim_aerosolFile )
      WRITE(fileout,'(a,i4.4,i2.2,a)')
     &     oasim_aerosolFile(1:il),year,imo,'.dat'
      IF ( debugLevel .GE. debLevB ) THEN
        il = ILNBLNK( fileout )
        WRITE(msgBuf,'(A,A)')
     &   ' OASIM_FIELDS_LOAD: opening global file: ',fileout(1:il)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT , myThid)
      ENDIF
      OPEN(iUnit,FILE=fileout,STATUS='old',FORM='unformatted',
     &     CONVERT='LITTLE_ENDIAN',IOSTAT=ios)
      IF (ios .eq. 0) THEN
c   sucess!
        READ(iUnit)taua1,asymp1,ssalb1
       CLOSE(iUnit)
      ELSE
       CLOSE(iUnit)
c   failure:
c   Read AVHRR file and climatology
       il = ILNBLNK( fileout )
       WRITE(msgBuf,'(3A)') 'OASIM_FIELDS_LOAD:',
     &   ' could not open aerosolFile,', fileout(1:il)
       CALL PRINT_MESSAGE( msgBuf , errorMessageUnit,
     &                     SQUEEZE_RIGHT , myThid)
       WRITE(msgBuf,'(2A)') 'OASIM_FIELDS_LOAD:',
     &   ' trying aerTau file'
       CALL PRINT_MESSAGE( msgBuf , errorMessageUnit,
     &                     SQUEEZE_RIGHT , myThid)
       il = ILNBLNK( oasim_aerTauFile )
       WRITE(fileout,'(a,i4.4,a)')
     &      oasim_aerTauFile(1:il),year,'.dat'
       IF ( debugLevel .GE. debLevB ) THEN
         il = ILNBLNK( fileout )
         WRITE(msgBuf,'(A,A)')
     &    ' OASIM_FIELDS_LOAD: opening global file: ',fileout(1:il)
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT , myThid)
       ENDIF
       OPEN(iUnit,FILE=fileout,STATUS='old',FORM='unformatted',
     &      CONVERT='LITTLE_ENDIAN',IOSTAT=ios)
       IF (ios .ne. 0) THEN
        il = ILNBLNK( fileout )
        WRITE(msgBuf,'(3A)') 'OASIM_FIELDS_LOAD:',
     &    ' could not open aerTauFile,', fileout(1:il)
        CALL PRINT_ERROR( msgBuf , myThid)
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R OASIM_FIELDS_LOAD'
       ENDIF
       DO immo = 1,imo
        READ(iUnit)avhrrtau     !taua at 0.63um
       ENDDO
       CLOSE(iUnit)
c   get monthly climatology for missing data
       il = ILNBLNK( oasim_aerTauClimFile )
       WRITE(fileout,'(a)') oasim_aerTauClimFile(1:il)
       IF ( debugLevel .GE. debLevB ) THEN
         il = ILNBLNK( fileout )
         WRITE(msgBuf,'(A,A)')
     &    ' OASIM_FIELDS_LOAD: opening global file: ',fileout(1:il)
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT , myThid)
       ENDIF
       OPEN(iUnit,FILE=fileout,STATUS='old',FORM='unformatted',
     &      CONVERT='LITTLE_ENDIAN',IOSTAT=ios)
       IF (ios .ne. 0) THEN
        il = ILNBLNK( fileout )
        WRITE(msgBuf,'(3A)') 'OASIM_FIELDS_LOAD:',
     &    ' could not open aerTauClimFile,', fileout(1:il)
        CALL PRINT_ERROR( msgBuf , myThid)
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R OASIM_FIELDS_LOAD'
       ENDIF
       DO immo = 1,imo
        READ(iUnit)avhrrtauclim
       ENDDO
       CLOSE(iUnit)
       DO j = 1,jatm
        DO i = 1,iatm
         IF (avhrrtau(i,j) .LT. 0.0)THEN
          avhrrtau(i,j) = avhrrtauclim(i,j)
         ENDIF
        ENDDO
       ENDDO
c   read modis aerosol climatology for reference
       il = ILNBLNK( oasim_aerosolClimFile )
       WRITE(fileout,'(a,i2.2,a)')
     &     oasim_aerosolClimFile(1:il),imo,'.dat'
       IF ( debugLevel .GE. debLevB ) THEN
         il = ILNBLNK( fileout )
         WRITE(msgBuf,'(A,A)')
     &    ' OASIM_FIELDS_LOAD: opening global file: ',fileout(1:il)
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT , myThid)
       ENDIF
       OPEN(iUnit,FILE=fileout,STATUS='old',FORM='unformatted',
     &      CONVERT='LITTLE_ENDIAN')
       READ(iUnit)taua1,asymp1,ssalb1
       CLOSE(iUnit)
c     Closest OASIM band is 625 nm; AVHRR is 630 nm
       DO j = 1,jatm
        DO i = 1,iatm
         IF (avhrrtau(i,j) .GE. 0.0)THEN
          DO l = 1,nlt
           facaer(l) = taua1(i,j,l)/taua1(i,j,iAVHRR)
          ENDDO
c     subtract AVHRR bias (add a negative to a negative bias)
          taua1(i,j,iAVHRR) = avhrrtau(i,j) + 0.025   !625 nm
          DO l = 1,nlt
           taua1(i,j,l) = facaer(l)*taua1(i,j,iAVHRR)
          ENDDO
         ENDIF
        ENDDO
       ENDDO
      ENDIF

#endif /* ALLOW_OASIM */

      RETURN
      END
#endif /* OASIM_READ_UNFORMATTED */
