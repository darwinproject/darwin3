#include "DARWIN_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: DARWIN_READ_PICKUP

C     !INTERFACE:
      SUBROUTINE DARWIN_READ_PICKUP( myIter, myThid )

C     !DESCRIPTION:
C     Reads current state of DARWIN from a pickup file

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_FIELDS.h"

C     !INPUT PARAMETERS:
C     myIter            :: time-step number
C     myThid            :: thread number
      INTEGER myIter
      INTEGER myThid

#ifdef ALLOW_DARWIN
#if defined(DARWIN_ALLOW_CARBON) || ((defined(DARWIN_ALLOW_GEIDER) || defined(ALLOW_RADTRANS)) && !defined(DARWIN_ALLOW_CHLQUOTA))

C     !LOCAL VARIABLES:
C     fn          :: character buffer for creating filename
C     fp          :: precision of pickup files
C     filePrec    :: pickup-file precision (read from meta file)
C     nbFields    :: number of fields in pickup file (read from meta file)
C     missFldList :: List of missing fields   (attempted to read but not found)
C     missFldDim  :: Dimension of missing fields list array: missFldList
C     nMissing    :: Number of missing fields (attempted to read but not found)
C     j           :: loop index
C     nj          :: record number
C     ioUnit      :: temp for writing msg unit
C     msgBuf      :: Informational/error message buffer
      INTEGER fp
      INTEGER filePrec, nbFields
      INTEGER missFldDim, nMissing
      INTEGER j, nj, ioUnit, np
      PARAMETER( missFldDim = 12 )
      CHARACTER*(MAX_LEN_FNAM) fn
      CHARACTER*(8) fldName
      CHARACTER*(8) missFldList(missFldDim)
      CHARACTER*(MAX_LEN_MBUF) msgBuf
CEOP

      _BARRIER

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

       IF ( pickupSuff.EQ.' ' ) THEN
        WRITE(fn,'(A,I10.10)') 'pickup_darwin.',myIter
       ELSE
        WRITE(fn,'(A,A10)')    'pickup_darwin.',pickupSuff
       ENDIF
       fp = precFloat64

       CALL READ_MFLDS_SET(
     I                      fn,
     O                      nbFields, filePrec,
     I                      Nr, myIter, myThid )
       _BEGIN_MASTER( myThid )
       IF ( nbFields.GE.0 .AND. filePrec.NE.fp ) THEN
         WRITE(msgBuf,'(2A,I4)') 'DARWIN_READ_PICKUP: ',
     &    'pickup-file binary precision do not match !'
         CALL PRINT_ERROR( msgBuf, myThid )
         WRITE(msgBuf,'(A,2(A,I4))') 'DARWIN_READ_PICKUP: ',
     &    'file prec.=', filePrec, ' but expecting prec.=', fp
         CALL PRINT_ERROR( msgBuf, myThid )
         STOP 'ABNORMAL END: S/R DARWIN_READ_PICKUP (data-prec Pb)'
       ENDIF
       _END_MASTER( myThid )

       IF ( nbFields.LE.0 ) THEN
C-      No meta-file or old meta-file without List of Fields
        ioUnit = errorMessageUnit
        IF ( pickupStrictlyMatch ) THEN
          WRITE(msgBuf,'(4A)') 'DARWIN_READ_PICKUP: ',
     &      'no field-list found in meta-file',
     &      ' => cannot check for strick-matching'
          CALL PRINT_ERROR( msgBuf, myThid )
          WRITE(msgBuf,'(4A)') 'DARWIN_READ_PICKUP: ',
     &      'try with " pickupStrictlyMatch=.FALSE.,"',
     &      ' in file: "data", NameList: "PARM03"'
          CALL PRINT_MESSAGE( msgBuf, ioUnit, SQUEEZE_RIGHT, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_READ_PICKUP'
        ELSE
          WRITE(msgBuf,'(4A)') 'WARNING >> DARWIN_READ_PICKUP: ',
     &      ' no field-list found'
          CALL PRINT_MESSAGE( msgBuf, ioUnit, SQUEEZE_RIGHT, myThid )
         IF ( nbFields.EQ.-1 ) THEN
C-      No meta-file
          WRITE(msgBuf,'(4A)') 'WARNING >> ',
     &      ' try to read pickup as currently written'
          CALL PRINT_MESSAGE( msgBuf, ioUnit, SQUEEZE_RIGHT, myThid )
         ELSE
          WRITE(msgBuf,'(4A)') 'DARWIN_READ_PICKUP: ',
     &      'no field-list found in meta-file'
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_READ_PICKUP'
         ENDIF
        ENDIF
       ENDIF

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

       IF ( nbFields.EQ.0 ) THEN
C---   Old way to read pickup not supported
          WRITE(msgBuf,'(2A)') 'DARWIN_READ_PICKUP: ',
     &      'please provide a meta file with a field list'
          STOP 'ABNORMAL END: S/R DARWIN_READ_PICKUP'
       ELSE
C---   New way to read DARWIN pickup:
        nj = 0
C---    read DARWIN 3-D fields for restart
#ifdef DARWIN_ALLOW_CARBON
        fldName = 'pH'
        CALL READ_MFLDS_3D_RL( fldName, pH, nj, fp, Nr, myIter, myThid )
#endif
#if (defined(DARWIN_ALLOW_GEIDER) || defined(ALLOW_RADTRANS)) && !defined(DARWIN_ALLOW_CHLQUOTA)
#ifdef ALLOW_RADTRANS
        DO np = 1, nPhoto
         fldName(1:6) = 'ChlPhy'
         fldName(7:8) = PTRACERS_ioLabel(np)
         CALL READ_MFLDS_3D_RL( fldName, ChlPrev(1-OLx,1-OLy,1,1,1,np),
     &                          nj, fp, Nr, myIter, myThid )
        ENDDO
#else
        CALL READ_MFLDS_3D_RL( 'Chl     ', ChlPrev,
     &                         nj, fp, Nr, myIter, myThid )
#endif
#endif
C--    end: new way to read pickup file
       ENDIF

C--    Check for missing fields:
       nMissing = missFldDim
       CALL READ_MFLDS_CHECK(
     O                     missFldList,
     U                     nMissing,
     I                     myIter, myThid )
       IF ( nMissing.GT.missFldDim ) THEN
         WRITE(msgBuf,'(2A,I4)') 'DARWIN_READ_PICKUP: ',
     &     'missing fields list has been truncated to', missFldDim
         CALL PRINT_ERROR( msgBuf, myThid )
         STOP 'ABNORMAL END: S/R DARWIN_READ_PICKUP (list-size Pb)'
       ENDIF
       IF ( nMissing.GE.1 ) THEN
        ioUnit = errorMessageUnit
        DO j=1,nMissing
         WRITE(msgBuf,'(4A)') 'DARWIN_READ_PICKUP: ',
     &       'cannot restart without field "',missFldList(nj),'"'
         CALL PRINT_ERROR( msgBuf, myThid )
        ENDDO
        STOP 'ABNORMAL END: S/R DARWIN_READ_PICKUP'
       ENDIF

C--    Update overlap regions:
#ifdef DARWIN_ALLOW_CARBON
        CALL EXCH_3D_RL( pH, 1, myThid )
#endif
#if defined(DARWIN_ALLOW_GEIDER) && !defined(DARWIN_ALLOW_CHLQUOTA)
#ifdef ALLOW_RADTRANS
        DO np = 1, nPhoto
         CALL EXCH_3D_RL( ChlPrev(1-OLx,1-OLy,1,1,1,np), Nr, myThid )
        ENDDO
#else
        CALL EXCH_3D_RL( ChlPrev, Nr, myThid )
#endif
#endif

#endif /* pickup needed */
#endif /* ALLOW_DARWIN */

      RETURN
      END
