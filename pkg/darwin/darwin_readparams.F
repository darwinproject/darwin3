C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_readparams.F,v 1.6 2009/03/04 20:40:42 jahn Exp $
C $Name:  $

#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_READPARMS

C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_READPARMS( myThid )

C !DESCRIPTION:
C     Initialize DARWIN parameters, read in data.darwin

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GCHEM.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_IO.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid

C !OUTPUT PARAMETERS: ==================================================
C  none

#ifdef ALLOW_DARWIN

C !LOCAL VARIABLES: ====================================================
C  iUnit		:: unit number for I/O
C  msgBuf		:: message buffer
      INTEGER iUnit
      CHARACTER*(MAX_LEN_MBUF) msgBuf
CEOP

      NAMELIST /DARWIN_FORCING/
     &           darwin_iceFile,
     &           darwin_ironFile,
     &           darwin_PARFile,
     &           darwin_nutWVelFile,
     &           darwin_PO4_relaxFile, darwin_NO3_relaxFile, 
     &           darwin_FeT_relaxFile, darwin_Si_relaxFile,
     &           darwin_PO4_fluxFile, darwin_NO3_fluxFile,
     &           darwin_FeT_fluxFile, darwin_Si_fluxFile,
     &           darwin_relaxscale,
     &           darwin_ForcingPeriod, darwin_ForcingCycle,
#ifdef ALLOW_PAR_DAY
     &           darwin_PARavPeriod,
#endif
     &           darwin_seed

C Set defaults values for parameters in DARWIN_IO.h
      darwin_iceFile=' '
      darwin_ironFile=' '
      darwin_PARFile=' '
      darwin_nutWVelFile=' '
      darwin_PO4_relaxFile=' '
      darwin_NO3_relaxFile=' '
      darwin_FeT_relaxFile=' '
      darwin_Si_relaxFile=' '
      darwin_PO4_fluxFile=' '
      darwin_NO3_fluxFile=' '
      darwin_FeT_fluxFile=' '
      darwin_Si_fluxFile=' '
      darwin_relaxscale=0. _d 0
      darwin_seed=0
#ifdef ALLOW_PAR_DAY
      darwin_PARavPeriod=86400. _d 0
#endif
c default periodic forcing to same as for GCHEM
      darwin_forcingPeriod=gchem_ForcingPeriod
      darwin_forcingCycle=gchem_ForcingCycle
C Open and read the data.darwin file
      _BEGIN_MASTER(myThid)
      WRITE(msgBuf,'(A)') ' DARWIN_READPARMS: opening data.darwin'
      CALL PRINT_MESSAGE(msgBuf, standardMessageUnit,
     &                   SQUEEZE_RIGHT , 1)
      CALL OPEN_COPY_DATA_FILE(
     I                   'data.darwin', 'DARWIN_READPARAMS',
     O                   iUnit,
     I                   myThid )
      READ(UNIT=iUnit,NML=DARWIN_FORCING)
#ifdef ALLOW_PAR_DAY
      darwin_PARnav = NINT(darwin_PARavPeriod*nsubtime/dTtracerLev(1))
#endif
      WRITE(msgBuf,'(A)')
     &  ' DARWIN_READPARMS: finished reading data.darwin'
      CALL PRINT_MESSAGE(msgBuf, standardMessageUnit,
     &                   SQUEEZE_RIGHT , 1)

C Close the open data file
      CLOSE(iUnit)

      _END_MASTER(myThid)

C Everyone else must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_DARWIN */

      RETURN
      END
