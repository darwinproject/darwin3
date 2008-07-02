C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_fields_load.F,v 1.8 2008/07/02 19:07:36 jahn Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "GCHEM_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

CStartOfInterFace
      SUBROUTINE DARWIN_FIELDS_LOAD (
     I           myIter,myTime,myThid)

C     /==========================================================\
C     | SUBROUTINE DARWIN_FIELDS_LOAD                            |
C     | o Read in fields needed for ice fraction and             |
C     | iron aeolian flux terms, PAR and nut_wvel                |
C     | adapted from NPZD2Fe - Stephanie Dutkiewicz 2005         |
C     |==========================================================|
      IMPLICIT NONE

C     == GLobal variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_IO.h"
c#include "GCHEM.h"
#ifdef ALLOW_SEAICE
#include "SEAICE.h"
#endif
#ifdef ALLOW_THSICE
#include "THSICE_VARS.h"
#endif

C     == Routine arguments ==
      INTEGER myIter
      _RL myTime
      INTEGER myThid
C     == Local variables ==
C     msgBuf    - Informational/error meesage buffer
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      COMMON/ darwin_load / 
     &    fice0, fice1, featmos0, featmos1, sur_par0, sur_par1
#ifdef NUT_SUPPLY
     &    ,  nut_wvel0, nut_wvel1
#endif
      _RS fice0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS fice1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS featmos0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS featmos1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS sur_par0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS sur_par1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
#ifdef NUT_SUPPLY
      _RS nut_wvel0 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx,nSy)
      _RS nut_wvel1 (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nR,nSx,nSy)
#endif
       INTEGER bi,bj,i,j,k,intime0,intime1
      _RL aWght,bWght,rdt
      _RL tmp1Wght, tmp2Wght
      INTEGER nForcingPeriods,Imytm,Ifprd,Ifcyc,Iftm
c
c
      IF ( darwin_ForcingPeriod .NE. 0. _d 0 ) THEN

C First call requires that we initialize everything to zero for safety
cQQQ need to check timing
       IF ( myIter .EQ. nIter0 ) THEN
         CALL LEF_ZERO( fice0,myThid )
         CALL LEF_ZERO( fice1,myThid )
         CALL LEF_ZERO( featmos0,myThid )
         CALL LEF_ZERO( featmos1,myThid )
         CALL LEF_ZERO( sur_par0,myThid )
         CALL LEF_ZERO( sur_par1,myThid )
#ifdef NUT_SUPPLY
         DO bj = myByLo(myThid), myByHi(myThid)
          DO bi = myBxLo(myThid), myBxHi(myThid)
           DO j=1-Oly,sNy+Oly
            DO i=1-Olx,sNx+Olx
             DO k=1,nR
               nut_wvel0(i,j,k,bi,bj) = 0. _d 0
               nut_wvel1(i,j,k,bi,bj) = 0. _d 0
             ENDDO
            ENDDO
           ENDDO
          ENDDO
         ENDDO
#endif
       ENDIF


C Now calculate whether it is time to update the forcing arrays
       rdt=1. _d 0 / deltaTclock
       nForcingPeriods=
     &  int(darwin_ForcingCycle/darwin_ForcingPeriod+0.5 _d 0)
       Imytm=int(myTime*rdt+0.5 _d 0)
       Ifprd=int(darwin_ForcingPeriod*rdt+0.5 _d 0)
       Ifcyc=int(darwin_ForcingCycle*rdt+0.5 _d 0)
       Iftm=mod( Imytm+Ifcyc-Ifprd/2,Ifcyc)

       intime0=int(Iftm/Ifprd)
       intime1=mod(intime0+1,nForcingPeriods)
       tmp1Wght = FLOAT( Iftm-Ifprd*intime0 )
       tmp2Wght = FLOAT( Ifprd )
       aWght =  tmp1Wght / tmp2Wght
       bWght = 1. _d 0 - aWght

       intime0=intime0+1
       intime1=intime1+1


cQQ something funny about timing here - need nIter0+1
c   but seems okay for remaining timesteps
       IF (
     &   Iftm-Ifprd*(intime0-1) .EQ. 0
     &   .OR. myIter .EQ. nIter0
     &    ) THEN


        _BEGIN_MASTER(myThid)

C      If the above condition is met then we need to read in
C      data for the period ahead and the period behind myTime.
        WRITE(msgBuf,'(A,1P1E20.12,X,I10)')
     &    'S/R DARWIN_FIELDS_LOAD: Reading forcing data',
     &                 myTime,myIter
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )

       IF ( darwin_iceFile .NE. ' '  ) THEN
         CALL READ_REC_XY_RS( darwin_iceFile,fice0,intime0,
     &        myIter,myThid ) 
         CALL READ_REC_XY_RS( darwin_IceFile,fice1,intime1,
     &        myIter,myThid )
       ENDIF
       IF ( darwin_ironFile .NE. ' '  ) THEN
         CALL READ_REC_XY_RS( darwin_ironFile,featmos0,intime0, 
     &        myIter,myThid )
         CALL READ_REC_XY_RS( darwin_ironFile,featmos1,intime1,
     &        myIter,myThid )
       ENDIF
       IF ( darwin_PARFile .NE. ' '  ) THEN
         CALL READ_REC_XY_RS( darwin_PARFile,sur_par0,intime0,
     &        myIter,myThid )
         CALL READ_REC_XY_RS( darwin_PARFile,sur_par1,intime1,
     &        myIter,myThid )
       ENDIF
#ifdef NUT_SUPPLY
       IF ( darwin_nutWVelFile .NE. ' '  ) THEN
         CALL READ_REC_XYZ_RS( darwin_nutWVelFile,nut_wvel0,intime0,
     &        myIter,myThid )
         CALL READ_REC_XYZ_RS( darwin_nutWVelFile,nut_wvel1,intime1,
     &        myIter,myThid )
       ENDIF
#endif


       _END_MASTER(myThid)
C
       _EXCH_XY_R4(fice0, myThid )
       _EXCH_XY_R4(fice1, myThid )
       _EXCH_XY_R4(featmos0, myThid )
       _EXCH_XY_R4(featmos1, myThid )
       _EXCH_XY_R4(sur_par0, myThid )
       _EXCH_XY_R4(sur_par1, myThid )
#ifdef NUT_SUPPLY
       _EXCH_XYZ_R4(nut_wvel0, myThid )
       _EXCH_XYZ_R4(nut_wvel1, myThid )
#endif

C
       ENDIF

       DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
         DO j=1-Oly,sNy+Oly
          DO i=1-Olx,sNx+Olx
cQQ need to include ice moel here, if used
#ifdef ALLOW_THSICE
             FIce(i,j,bi,bj) = iceMask(i,j,bi,bj)
#else
#ifdef ALLOW_SEAICE
             FIce(i,j,bi,bj) = AREA(i,j,1,bi,bj)
#else
           IF ( darwin_iceFile .NE. ' '  ) THEN
            fice(i,j,bi,bj)   = bWght*fice0(i,j,bi,bj)
     &                         +aWght*fice1(i,j,bi,bj)
           ELSE
            fice(i,j,bi,bj)  = 0. _d 0
           ENDIF
#endif
#endif
           IF ( darwin_ironFile .NE. ' '  ) THEN
            inputFe(i,j,bi,bj)   = bWght*featmos0(i,j,bi,bj)
     &                            +aWght*featmos1(i,j,bi,bj)
c convert to mmol/m2/s
            inputFe(i,j,bi,bj)   = 1000.d0*inputFe(i,j,bi,bj)
           ELSE
            inputFe(i,j,bi,bj)  = 0. _d 0
           ENDIF
c light (load as Ein/m2/d; convert to uEin/m2/s)
           IF ( darwin_PARFile .NE. ' '  ) THEN
            sur_par(i,j,bi,bj)   = bWght*sur_par0(i,j,bi,bj)
     &                         +aWght*sur_par1(i,j,bi,bj)
            sur_par(i,j,bi,bj) = sur_par(i,j,bi,bj)*1. _d 6/86400. _d 0
           ELSE
            sur_par(i,j,bi,bj)  =  200. _d 0*maskC(i,j,1,bi,bj)
           ENDIF
#ifdef NUT_SUPPLY
c artificial wvel for nutrient supply in 1-d and 2-d models
            IF ( darwin_nutWVelFile .NE. ' '  ) THEN
             DO k=1,nR
               nut_wvel(i,j,k,bi,bj) = bWght*nut_wvel0(i,j,k,bi,bj)
     &                         +aWght*nut_wvel1(i,j,k,bi,bj)
             ENDDO
            ENDIF
#endif
c
          ENDDO
         ENDDO
        ENDDO
       ENDDO

C endif for periodicForcing
       ENDIF

      RETURN
      END
#endif
#endif

