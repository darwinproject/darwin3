#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_WRITE_PICKUP

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_WRITE_PICKUP( permPickup,
     I                             suff, myTime, myIter, myThid )

C !DESCRIPTION:
C     Writes PAR_day array (needed for a restart) to a pickup file

C !USES: ===============================================================
      IMPLICIT NONE
C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_FIELDS.h"

C !INPUT PARAMETERS: ===================================================
C     permPickup :: write a permanent pickup
C     suff       :: suffix for pickup file (eg. ckptA or 0000000010)
C     myTime     :: Current time in simulation
C     myIter     :: Current iteration number in simulation
C     myThid     :: My Thread Id number
      LOGICAL permPickup
      CHARACTER*(*) suff
      _RL     myTime
      INTEGER myIter
      INTEGER myThid
CEOP

#ifdef ALLOW_DARWIN
C add more ALLOWs here for other fields in pickup
#if defined(DARWIN_ALLOW_CARBON) || ((defined(DARWIN_ALLOW_GEIDER) || defined(ALLOW_RADTRANS)) && !defined(DARWIN_ALLOW_CHLQUOTA))

C     !LOCAL VARIABLES:
C     == Local variables ==
      CHARACTER*(MAX_LEN_FNAM) fn
      LOGICAL glf
      _RL     timList(1)
      INTEGER prec, irec, ifld, np
      INTEGER listDim, nWrFlds
      PARAMETER( listDim = 1+nPhoto )
      CHARACTER*(8) wrFldList(listDim)
      CHARACTER*(MAX_LEN_MBUF) msgBuf

c     IF ( DARWIN_pickup_write_mdsio ) THEN
        prec = precFloat64
        WRITE(fn,'(A,A)') 'pickup_darwin.',suff

        ifld = 0
        irec = 0

#ifdef DARWIN_ALLOW_CARBON
        ifld = ifld + 1
        irec = irec - 1
        CALL WRITE_REC_3D_RL( fn, prec, nR, pH, irec, myIter, myThid )
        IF (ifld.LE.listDim) wrFldList(ifld) = 'pH'
#endif

#if (defined(DARWIN_ALLOW_GEIDER) || defined(ALLOW_RADTRANS)) && !defined(DARWIN_ALLOW_CHLQUOTA)
#ifdef ALLOW_RADTRANS
        DO np = 1, nPhoto
        ifld = ifld + 1
        irec = irec - 1
        CALL WRITE_REC_3D_RL( fn, prec, nR,
     &                        ChlPrev(1-OLx,1-OLy,1,1,1,np),
     &                        irec, myIter, myThid )
        IF (ifld.LE.listDim) THEN
         wrFldList(ifld)(1:6) = 'ChlPhy'
         wrFldList(ifld)(7:8) = PTRACERS_ioLabel(np)
        ENDIF
        ENDDO
#else
        ifld = ifld + 1
        irec = irec - 1
        CALL WRITE_REC_3D_RL( fn, prec, nR, ChlPrev,
     &                        irec, myIter, myThid )
        IF (ifld.LE.listDim) THEN
         wrFldList(ifld) = 'Chl'
        ENDIF
#endif
#endif

C--------------------------
        nWrFlds = ifld
        IF ( nWrFlds.GT.listDim ) THEN
          WRITE(msgBuf,'(2A,I5,A)') 'DARWIN_WRITE_PICKUP: ',
     &     'trying to write ',nWrFlds,' fields'
          CALL PRINT_ERROR( msgBuf, myThid )
          WRITE(msgBuf,'(2A,I5,A)') 'DARWIN_WRITE_PICKUP: ',
     &     'field-list dimension (listDim=',listDim,') too small'
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R DARWIN_WRITE_PICKUP (list-size Pb)'
        ENDIF

#ifdef ALLOW_MDSIO
C     uses this specific S/R to write (with more informations) only meta
C     files
        glf  = globalFiles
        timList(1) = myTime
        irec = ABS(irec)
        CALL MDS_WR_METAFILES( fn, prec, glf, .FALSE.,
     &                         0, 0, nR, ' ',
     &                         nWrFlds, wrFldList,
     &                         1, timList, oneRL,
     &                         irec, myIter, myThid )
#endif /* ALLOW_MDSIO */
C--------------------------

c     ENDIF /* DARWIN_pickup_write_mdsio */

#endif /*  need pickup  */
#endif /*  ALLOW_DARWIN  */

      RETURN
      END
