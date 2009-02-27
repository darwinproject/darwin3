C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_fe_chem.F,v 1.7 2009/02/27 19:04:27 jahn Exp $
C $Name:  $

c#include "DIC_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

CStartOfInterFace
      SUBROUTINE DARWIN_Fe_CHEM(
     I           bi,bj,iMin,iMax,jMin,jMax,
     U           fe,
     O           freefe,
     I           myIter, myThid )
C     /==========================================================\
C     | SUBROUTINE Fe_chem                                       |
C     |                                                          |
C     | o Calculate L,FeL,Fe concentration                       |
C     | Stephanie Dutkiewicz, 2004
C     |   following from code by Payal Parekh
C     |==========================================================|
      IMPLICIT NONE

C     == GLobal variables ==
#include "SIZE.h"
#include "DYNVARS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DARWIN_SIZE.h"
#include "DARWIN.h"
#include "DARWIN_IO.h"

C     == Routine arguments ==                
C     bi, bj, iMin, iMax, jMin, jMax - Range of points for which calculation
C                                      results will be set.
C     myThid - Instance number for this innvocation of CALC_GT
      _RL  freefe(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL  fe(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      INTEGER bi,bj,iMin,iMax,jMin,jMax
      INTEGER myIter,myThid
CEndOfInterface


      INTEGER I,J,K
      _RL  lig, FeL

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCc
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCc
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCc
CC
CC ADAPTED FROM PAYAL
CC
CC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCc
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCc
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCc

C ligand balance in surface layer
C in surface layer

       DO j=jmin,jmax
        DO i=imin,imax
         DO k=1,nR
          IF(hFacC(i,j,k,bi,bj) .gt. 0.0 _d 0)THEN

C   Ligand,FeL,Fe calculation
            
              lig=(-ligand_stab*fe (i,j,k)+
     &              ligand_stab*ligand_tot-1. _d 0
     &             +((ligand_stab*fe (i,j,k)
     &                -ligand_stab*ligand_tot+1. _d 0)**2+4. _d 0
     &               *ligand_stab*ligand_tot)**0.5 _d 0)
     &            /(2. _d 0*ligand_stab)
 
              FeL = ligand_tot-lig
              freefe(i,j,k) = fe (i,j,k)-FeL
#ifdef MINFE
              freefe(i,j,k) = min(freefe(i,j,k),freefemax)
              fe(i,j,k) = FeL+freefe(i,j,k)
#endif
          END IF  
         ENDDO
        ENDDO
       ENDDO    
c
        RETURN
        END                      
