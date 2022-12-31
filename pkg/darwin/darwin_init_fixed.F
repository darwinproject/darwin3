#include "DARWIN_OPTIONS.h"
#include "EXF_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: DARWIN_INIT_FIXED

C     !INTERFACE:
      SUBROUTINE DARWIN_INIT_FIXED( myThid )

C     !DESCRIPTION:
C     Initialize wavebands and read in absorption/scattering spectra

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#ifdef ALLOW_RADTRANS
#include "RADTRANS_SIZE.h"
#include "RADTRANS_PARAMS.h"
#endif
#ifdef ALLOW_DARWIN
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_RADTRANS.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
#endif

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_DARWIN

C     !LOCAL VARIABLES:
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      integer iUnit, oUnit1, oUnit2, k, jp
      integer idummy
#ifdef ALLOW_RADTRANS
      character*80 title
      integer ios, i, l, ilambda
      _RL lambdain, ain, apsin, bin, bbin, ain_mgC
#endif

      CALL DARWIN_EXF_INIT_FIXED(myThid)

#ifdef ALLOW_DIAGNOSTICS
      IF ( useDiagnostics ) THEN
        CALL DARWIN_DIAGNOSTICS_INIT( myThid )
      ENDIF
#endif

      _BEGIN_MASTER(myThid)

      IF (darwin_linFSConserve) PTRACERS_calcSurfCor = .TRUE.

#ifdef DARWIN_IRON_SED_SOURCE_VARIABLE
      kMinFeSed = 2
#else
      kMinFeSed = 1
#endif
      kMaxFeSed = 0
      DO k=1,Nr
        IF (RF(k) .GT. -depthFeSed) kMaxFeSed = k
      ENDDO

#ifdef DARWIN_ALLOW_HYDROTHERMAL_VENTS
      kMinFeVent = Nr + 1
      DO k=Nr,1,-1
        IF (RC(k) .LE. -depthFeVent) kMinFeVent = k
      ENDDO
#endif


#ifdef ALLOW_RADTRANS

C read water absorption data
      DO l = 1, nlam
        aw(l) = -1.0 _d 0
        bw(l) = -1.0 _d 0
      ENDDO
      IF (darwin_waterAbsorbFile .NE. ' '  ) THEN
        CALL MDSFINDUNIT( iUnit, myThid )
        OPEN(iUnit,FILE=darwin_waterabsorbFile,
     &       STATUS='old',FORM='formatted')
C       skip header
        DO i = 1,6
         READ(iUnit,'(A50)')title
        ENDDO
        ios = 0
        DO WHILE (ios .EQ. 0)
         READ(iUnit,'(I5,F15.4,F10.4)',IOSTAT=ios) ilambda,ain,bin
         IF (ios .EQ. 0) THEN
          lambdain = ilambda
          DO l = 1,nlam
           IF (lambdain .GE. RT_wbEdges(l) .AND.
     &         lambdain .LE. RT_wbEdges(l+1)) THEN
            aw(l) = ain
            bw(l) = bin
           ENDIF
          ENDDO
         ENDIF
        ENDDO
        CLOSE(iUnit)
      ELSE
        WRITE(msgBuf,'(A)')
     &   'DARWIN_INIT_FIXED: need to specify water absorption file'
        CALL PRINT_ERROR( msgBuf, myThid )
        STOP 'ABNORMAL END: S/R DARWIN_INIT_FIXED'
      ENDIF
C     check that all wavebands have been read
      DO l = 1, nlam
        IF (aw(l) .LT. 0.0) THEN
          WRITE(msgBuf,'(2A)') 'DARWIN_INIT_FIXED: ',
     &     "could not read water absorption data for band "
          CALL PRINT_ERROR( msgBuf, myThid )
          WRITE(msgBuf,'(A,I3,2F8.3)') 'DARWIN_INIT_FIXED: ',
     &     l,RT_wbEdges(l),RT_wbEdges(l+1)
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_INIT_FIXED'
        ENDIF
      ENDDO
C     write summary
      WRITE(msgBuf,'(A)') 'DARWIN_INIT_FIXED: water spectra:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      WRITE(msgBuf,'(A,A)') 'DARWIN_INIT_FIXED: ',
     &     ' lam aw             bw'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      DO l = 1,nlam
        WRITE(msgBuf,'(A,F4.0,F15.4,F10.4)') 'DARWIN_INIT_FIXED: ',
     &     RT_wbRefWLs(l), aw(l), bw(l)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, 1 )
      ENDDO
      WRITE(msgBuf,'(A)') 'DARWIN_INIT_FIXED:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )


C read phyto absorption data
C   phyto input data files must have a column for absorption by PS pigs
C   easiest way to 'turn off' PS for growth is to put same values in both abs columns
      DO i = 1, nopt
       DO l = 1, nlam
        aphy_chl_type   (i,l) = -1.0 _d 0
        aphy_chl_ps_type(i,l) = -1.0 _d 0
        aphy_mgC_type   (i,l) = -1.0 _d 0
        bphy_mgC_type   (i,l) = -1.0 _d 0
        bbphy_mgC_type  (i,l) = -1.0 _d 0
       ENDDO
      ENDDO
      IF (darwin_phytoAbsorbFile .NE. ' '  ) THEN
        CALL MDSFINDUNIT( iUnit, myThid )
        OPEN(iUnit,FILE=darwin_phytoAbsorbFile,
     &       STATUS='old',FORM='formatted')
C       skip global header
        DO i = 1,6
         READ(iUnit,'(A50)')title
        ENDDO
C       phytoplanktontype header
        READ(iUnit,'(A50)')title
        DO i = 1,nopt
         ios = 0
         IF (darwin_allomSpectra) THEN
           READ(iUnit,'(I4,3F10.0,F20.0,F10.0)')
     &       idummy,asize(i),apsize(i),bsize(i),bbsize(i),asize_mgC(i)
         ENDIF
         DO WHILE (ios .EQ. 0)
          READ(iUnit,'(I4,3F10.0,F20.0,F10.0)',IOSTAT=ios)
     &                ilambda,ain,apsin,bin,bbin,ain_mgC
C         next phyto type header will trigger error and move on to next i
          IF (ios .EQ. 0) THEN
           lambdain = ilambda
           DO l = 1,nlam
            IF (lambdain .GE. RT_wbEdges(l) .AND.
     &          lambdain .LE. RT_wbEdges(l+1)) THEN
             aphy_chl_type   (i,l) = ain
             aphy_chl_ps_type(i,l) = apsin
             bphy_mgC_type   (i,l) = bin
             bbphy_mgC_type  (i,l) = bbin
             aphy_mgC_type   (i,l) = ain_mgC
            ENDIF
           ENDDO
          ENDIF
         ENDDO
        ENDDO
        CLOSE(iUnit)
      ELSE
        WRITE(msgBuf,'(A)')
     &   'DARWIN_INIT_FIXED: need to specify plankton absorption file'
        CALL PRINT_ERROR( msgBuf, myThid )
        STOP 'ABNORMAL END: S/R DARWIN_INIT_FIXED'
      ENDIF
C     check that all wavebands have been read
      DO i = 1, nopt
       DO l = 1, nlam
        IF (aphy_chl_type(i,l) .LT. 0.0) THEN
          WRITE(msgBuf,'(2A)') 'DARWIN_INIT_FIXED: ',
     &     "could not read phyto absorption data for type,band "
          CALL PRINT_ERROR( msgBuf, myThid )
          WRITE(msgBuf,'(A,2I3,2F8.3)') 'DARWIN_INIT_FIXED: ',
     &     i,l,RT_wbEdges(l),RT_wbEdges(l+1)
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_INIT_FIXED'
        ENDIF
       ENDDO
      ENDDO
C     write summary
      WRITE(msgBuf,'(A)') 'DARWIN_INIT_FIXED: phyto spectra:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      DO i = 1,nopt
        WRITE(msgBuf,'(A,I4)') 'DARWIN_INIT_FIXED: type ', i
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
        WRITE(msgBuf,'(A,A)') 'DARWIN_INIT_FIXED: ',
     &     ' lam ap        ap_ps     bp        bbp            ap_mgC'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
        DO l = 1,nlam
          WRITE(msgBuf,'(A,F4.0,3F10.4,F20.9,F10.6)')
     &     'DARWIN_INIT_FIXED: ',
     &     RT_wbRefWLs(l), aphy_chl_type(i,l), aphy_chl_ps_type(i,l),
     &     bphy_mgC_type(i,l), bbphy_mgC_type(i,l), aphy_mgC_type(i,l)
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, 1 )
        ENDDO
        WRITE(msgBuf,'(A)') 'DARWIN_INIT_FIXED:'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      ENDDO


C read particle absorption data
C initialize particle absorption coefficient
      DO l = 1, nlam
        apart(l) = -1.0 _d 0
        bpart(l) = -1.0 _d 0
        bbpart(l) = -1.0 _d 0
      ENDDO
      IF (darwin_particleAbsorbFile .NE. ' '  ) THEN
        CALL MDSFINDUNIT( iUnit, myThid )
        OPEN(iUnit,FILE=darwin_particleAbsorbFile,
     &       STATUS='old',FORM='formatted')
C       skip header
        DO i = 1,6
         READ(iUnit,'(A50)')title
        ENDDO
        ios = 0
        DO WHILE (ios .EQ. 0)
         READ(iUnit,'(I4,3F15.0)',IOSTAT=ios) ilambda,ain,bin,bbin
         IF (ios .EQ. 0) THEN
          lambdain = ilambda
          DO l = 1,nlam
           IF (lambdain .GE. RT_wbEdges(l) .AND.
     &         lambdain .LE. RT_wbEdges(l+1)) THEN
            apart(l) = ain
            bpart(l) = bin
            bbpart(l) = bbin
            apart_P(l) = ain/darwin_part_size_P
            bpart_P(l) = bin/darwin_part_size_P
            bbpart_P(l) = bbin/darwin_part_size_P
           ENDIF
          ENDDO
         ENDIF
        ENDDO
        CLOSE(iUnit)
      ELSE
        WRITE(msgBuf,'(A)')
     &   'DARWIN_INIT_FIXED: need to specify particle absorption file'
        CALL PRINT_ERROR( msgBuf, myThid )
        STOP 'ABNORMAL END: S/R DARWIN_INIT_FIXED'
      ENDIF
C     check that all wavebands have been read
      DO l = 1, nlam
        IF (apart(l) .LT. 0.0) THEN
          WRITE(msgBuf,'(2A)') 'DARWIN_INIT_FIXED: ',
     &     "could not read particle for band "
          CALL PRINT_ERROR( msgBuf, myThid )
          WRITE(msgBuf,'(A,I3,2F8.3)') 'DARWIN_INIT_FIXED: ',
     &     l,RT_wbEdges(l),RT_wbEdges(l+1)
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_INIT_FIXED'
        ENDIF
      ENDDO
C     write summary
      WRITE(msgBuf,'(A)') 'DARWIN_INIT_FIXED: particulate spectra:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      WRITE(msgBuf,'(A,A)') 'DARWIN_INIT_FIXED: ',
     &     ' lam apart          bpart          bbpart'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      DO l = 1,nlam
        WRITE(msgBuf,'(A,F4.0,1P3G15.6)')'DARWIN_INIT_FIXED: ',
     &     RT_wbRefWLs(l), apart(l), bpart(l), bbpart(l)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, 1 )
      ENDDO
      WRITE(msgBuf,'(A)') 'DARWIN_INIT_FIXED:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
c
      WRITE(msgBuf,'(2A)') 'DARWIN_INIT_FIXED: particulate spectra ',
     &                    'in phosphorus units:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      WRITE(msgBuf,'(A,A)') 'DARWIN_INIT_FIXED: ',
     &     ' lam apart_P        bpart_P        bbpart_P'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
      DO l = 1,nlam
        WRITE(msgBuf,'(A,F4.0,2F15.9,F15.12)') 'DARWIN_INIT_FIXED: ',
     &     RT_wbRefWLs(l), apart_P(l), bpart_P(l), bbpart_P(l)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, 1 )
      ENDDO
      WRITE(msgBuf,'(A)') 'DARWIN_INIT_FIXED:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, 1 )
c


      DO l = 1,nlam
        exCDOM(l)=EXP(-darwin_Sdom*(RT_wbRefWLs(l)-darwin_lambda_aCDOM))
      ENDDO
#ifndef DARWIN_ALLOW_CDOM
C initialize CDOM absorption coefficient
      laCDOM = -1
      DO l = 1,nlam
        IF (darwin_lambda_aCDOM .GE. RT_wbEdges(l) .AND.
     &      darwin_lambda_aCDOM .LE. RT_wbEdges(l+1)) THEN
          laCDOM = l
        ENDIF
      ENDDO
      IF (laCDOM .LE. 0) THEN
        WRITE(msgBuf,'(2A)') 'DARWIN_INIT_FIXED: ',
     &   "could not read find aCDOM reference waveband with frequency"
        CALL PRINT_ERROR( msgBuf, myThid )
        WRITE(msgBuf,'(A,F8.3)') 'DARWIN_INIT_FIXED: ',
     &   darwin_lambda_aCDOM
        CALL PRINT_ERROR( msgBuf, myThid )
        STOP 'ABNORMAL END: S/R DARWIN_INIT_FIXED'
      ELSE
        WRITE(msgBuf,'(A,I3)')
     &        'DARWIN_INIT_FIXED: laCDOM = ', laCDOM
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, 1 )
      ENDIF
#endif

#endif /* ALLOW_RADTRANS */

C ======================================================================
      CALL DARWIN_RANDOM_INIT(darwin_seed, myThid)

#ifdef DARWIN_RANDOM_TRAITS
      CALL DARWIN_GENERATE_RANDOM(myThid)
#else
      CALL DARWIN_GENERATE_ALLOMETRIC(myThid)
#endif

C ======================================================================
C read (overrides generated) and write trait namelists

      WRITE(msgBuf,'(A)') ' DARWIN_INIT_FIXED: opening data.traits'
      CALL PRINT_MESSAGE(msgBuf, standardMessageUnit,
     &                   SQUEEZE_RIGHT , 1)

      CALL MDSFINDUNIT( iUnit, myThid )
      CALL OPEN_COPY_DATA_FILE(
     I                   'data.traits', 'DARWIN_INIT_FIXED',
     O                   iUnit,
     I                   myThid )

      IF ( myProcId.EQ.0 .AND. myThid.EQ.1 ) THEN
        CALL MDSFINDUNIT( oUnit1, mythid )
        open(oUnit1,file='darwin_traits.txt',status='unknown')
      ELSE
        oUnit1 = -1
      ENDIF

      CALL DARWIN_READ_TRAITS(iUnit, oUnit1, myThid)

      IF ( oUnit1 .GE. 0 ) THEN
        close(oUnit1)
      ENDIF
#ifdef SINGLE_DISK_IO
      CLOSE(iUnit)
#else
      CLOSE(iUnit,STATUS='DELETE')
#endif /* SINGLE_DISK_IO */

      WRITE(msgBuf,'(A)') ' ==================================='
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )

C ======================================================================
C deprecation checks

#ifndef DARWIN_ALLOW_EXUDE
      DO jp = 1, nPlank
       IF (ExportFracExude(jp) .NE. DARWIN_UNINIT_RL) THEN
        WRITE(msgBuf,'(2A)')'ExportFracExude can only be used with ',
     &     'DARWIN_ALLOW_EXUDE.'
        CALL PRINT_ERROR( msgBuf, myThid )
        WRITE(msgBuf,'(2A)')'Use ExportFracMort and ExportFracMort2 ',
     &     'for export due to mortality.'
        CALL PRINT_ERROR( msgBuf, myThid )
        STOP 'ABNORMAL END: S/R DARWIN_INIT_FIXED'
       ENDIF
      ENDDO
#endif

C ======================================================================
C write some traits to files

#ifdef ALLOW_RADTRANS

      IF ( myProcId.EQ.0 ) THEN


C set spectra for individual plankton according to optical type
C file for aptypes assigned via coin flips
      CALL MDSFINDUNIT( oUnit1, myThid )
      OPEN(oUnit1,file='p-ini-char-aptype.dat',status='unknown')
      CALL MDSFINDUNIT( oUnit2, myThid )
      OPEN(oUnit2,file='p_ini_char_aptype_nohead.dat',status='unknown')
      WRITE(oUnit1,*)'np   aptype'
      DO jp = 1,nPhoto
        WRITE(oUnit1,'(2I5)') jp, aptype(jp)
        WRITE(oUnit2,'(2I5)') jp, aptype(jp)
      ENDDO
      CLOSE(oUnit1)
      CLOSE(oUnit2)

c file of total absorption spectra
c rows = pwaves, columns = jp      
      open(oUnit1,file='p-ini-char-apspec.dat',status='unknown')
      open(oUnit2,file='p_ini_char_apspec_nohead.dat',status='unknown')
      write(oUnit1,*)'Rows = pwaves. Columns = jp'
      write(oUnit1,*)'pwaves found in pwaves-check.dat'
      write(oUnit1,*)'col_1 to col_<nPhoto>'
      write(oUnit1,*)'is absorption aphy_chl (m-2 mg chla-1)'
      do l=1,nlam
       write(oUnit1,9999)(aphy_chl(jp,l),jp=1,nPhoto)
       write(oUnit2,9999)(aphy_chl(jp,l),jp=1,nPhoto)
      enddo
c make sure outfile is defined above with the correct size
      close(oUnit1)
      close(oUnit2)

c file of spectra for carbon-specific total absorption
c rows = pwaves, columns = jp      
      open(oUnit1,file='p-ini-char-apspec-mgC.dat',status='unknown')
      open(oUnit2,file='p_ini_char_apspec_mgC_nohead.dat',
     &     status='unknown')
      write(oUnit1,*)'Rows = pwaves. Columns = jp'
      write(oUnit1,*)'pwaves found in pwaves-check.dat'
      write(oUnit1,*)'col_1 to col_<nPhoto>'
      write(oUnit1,*)'is absorption aphy_mgC*1e3 (m-2 mg C-1)'
      do l=1,nlam
       write(oUnit1,9999)(aphy_mgC(jp,l)*1e3,jp=1,nplank)
       write(oUnit2,9999)(aphy_mgC(jp,l)*1e3,jp=1,nplank)
      enddo
c make sure outfile is defined above with the correct size
      close(oUnit1)
      close(oUnit2)

c file for absorption spectra of PS's only
c rows = pwaves, columns = jp
      open(oUnit1,file='p-ini-char-apspec-psc.dat',status='unknown')
      open(oUnit2,file='p_ini_char_apspec_psc_nohead.dat',
     &     status='unknown')
      write(oUnit1,*)'Rows = pwaves. Columns = jp'
      write(oUnit1,*)'pwaves found in pwaves-check.dat'
      write(oUnit1,*)'Is absoprtion by photosynthetic'
      write(oUnit1,*)'pigments only aphy_chl_ps (m-2 mg chla-1)'
      do l=1,nlam
       write(oUnit1,9999)(aphy_chl_ps(jp,l),jp=1,nPhoto)
       write(oUnit2,9999)(aphy_chl_ps(jp,l),jp=1,nPhoto)
      enddo
      close(oUnit1)
      close(oUnit2)

c file of total scattering spectra
c rows = pwaves, columns = jp
      open(oUnit1,file='p-ini-char-btspec.dat',status='unknown')
      open(oUnit2,file='p_ini_char_btspec_nohead.dat',status='unknown')
      write(oUnit1,*)'Rows = pwaves. Columns = jp'
      write(oUnit1,*)'pwaves found in pwaves-check.dat'
      write(oUnit1,*)'col_1 to col_<nPlank>'
      write(oUnit1,*)'is total scattering bphy_mgC (m-2 mg C-1)'
      do l=1,nlam
       write(oUnit1,9999)(bphy_mgC(jp,l),jp=1,nplank)
       write(oUnit2,9999)(bphy_mgC(jp,l),jp=1,nplank)
      enddo
c make sure outfile is defined above with the correct size
      close(oUnit1)
      close(oUnit2)

c file of total scattering spectra
c rows = pwaves, columns = jp
      open(oUnit1,file='p-ini-char-bbspec.dat',status='unknown')
      open(oUnit2,file='p_ini_char_bbspec_nohead.dat',status='unknown')
      write(oUnit1,*)'Rows = pwaves. Columns = jp'
      write(oUnit1,*)'pwaves found in pwaves-check.dat'
      write(oUnit1,*)'col_1 to col_<nPlank>'
      write(oUnit1,*)'is backscattering bphy_mgC*1e4 (m-2 mg C-1)'
      do l=1,nlam
       write(oUnit1,9999)(bbphy_mgC(jp,l)*1e4,jp=1,nplank)
       write(oUnit2,9999)(bbphy_mgC(jp,l)*1e4,jp=1,nplank)
      enddo
c make sure outfile is defined above with the correct size
      close(oUnit1)
      close(oUnit2)

9999  format(9999f10.4)

C     IF ( myProcId.EQ.0 ) THEN
      ENDIF

#endif /* ALLOW_RADTRANS */

C ======================================================================

      _END_MASTER(myThid)

C Everyone else must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_DARWIN */

      RETURN
      END
