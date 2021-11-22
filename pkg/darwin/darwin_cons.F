#include "DARWIN_OPTIONS.h"

CBOP
C !ROUTINE: DARWIN_CONS
C !INTERFACE: ==========================================================
      SUBROUTINE DARWIN_CONS(stage,myTime,myIter,myThid)

C !DESCRIPTION:
C     Check conservation in the model

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PTRACERS_FIELDS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
#include "DARWIN_FIELDS.h"
#include "DARWIN_EXF_FIELDS.h"

C !INPUT PARAMETERS: ===================================================
      INTEGER stage
      _RL myTime
      INTEGER myIter
      INTEGER myThid
CEOP

#ifdef DARWIN_ALLOW_CONS

C !LOCAL VARIABLES: ====================================================
      _RL tilevol(nSx,nSy)
      _RL tiletotC(nSx,nSy)
      _RL tiletotN(nSx,nSy)
      _RL tiletotP(nSx,nSy)
      _RL tiletotFe(nSx,nSy)
      _RL tiletotSi(nSx,nSy)
      _RL tiletotNfix(nSx,nSy)
      _RL tiletotNdenit(nSx,nSy)
      _RL tiletotscavFe(nSx,nSy)
      _RL tileminFeLoss(nSx,nSy)
      _RL tilesfcflxFe(nSx,nSy)
      _RL tilesedflxFe(nSx,nSy)
      _RL tilesfcflxC(nSx,nSy)
      _RL tilevirflxC(nSx,nSy)
#ifdef DARWIN_BOTTOM_SINK
      _RL tileBotSnkC(nSx,nSy)
      _RL tileBotSnkN(nSx,nSy)
      _RL tileBotSnkP(nSx,nSy)
      _RL tileBotSnkFe(nSx,nSy)
      _RL tileBotSnkSi(nSx,nSy)
#endif
#ifdef DARWIN_ALLOW_CARBON
      _RL tiletotA(nSx,nSy)
      _RL tileAlkSrc(nSx,nSy)
      _RL tiletotO(nSx,nSy)
      _RL tileO2prod(nSx,nSy)
      _RL tileO2cons(nSx,nSy)
      _RL tilesfcflxO(nSx,nSy)
      _RL tilevirflxA(nSx,nSy)
#endif
      _RL tmptotC
      _RL tmptotN
      _RL tmptotP
      _RL tmptotFe
      _RL tmptotSi
      _RL tmptotNfix
      _RL tmptotNdenit
      _RL tmptotscavFe
      _RL tmpminFeLoss
      _RL tmpsfcflxFe
      _RL tmpsedflxFe
      _RL tmpsfcflxC
      _RL tmpvirflxC
      _RL tmpBotSnkC
      _RL tmpBotSnkN
      _RL tmpBotSnkP
      _RL tmpBotSnkFe
      _RL tmpBotSnkSi
#ifdef DARWIN_ALLOW_CARBON
      _RL tmptotA
      _RL tmpAlkSrc
      _RL tmptotO
      _RL tmpO2prod
      _RL tmpO2cons
      _RL tmpsfcflxO
      _RL tmpvirflxA
#endif
      _RL vol, voltot
      _RL area

      INTEGER i,j,k,bi,bj,ks
      INTEGER np, iTr

      ks = 1

      tmptotC = 0 _d 0
      tmptotN = 0 _d 0
      tmptotP = 0 _d 0
      tmptotFe = 0 _d 0
      tmptotSi = 0 _d 0
      tmptotNfix = 0 _d 0
      tmptotNdenit = 0 _d 0
      tmptotscavFe = 0 _d 0
      tmpminFeLoss = 0 _d 0
      tmpsfcflxFe = 0 _d 0
      tmpsedflxFe = 0 _d 0
      tmpsfcflxC = 0 _d 0
      tmpvirflxC = 0 _d 0
      tmpBotSnkC = 0 _d 0
      tmpBotSnkN = 0 _d 0
      tmpBotSnkP = 0 _d 0
      tmpBotSnkFe = 0 _d 0
      tmpBotSnkSi = 0 _d 0
#ifdef DARWIN_ALLOW_CARBON
      tmptotA = 0 _d 0
      tmpAlkSrc = 0 _d 0
      tmptotO = 0 _d 0
      tmpO2prod = 0 _d 0
      tmpO2cons = 0 _d 0
      tmpsfcflxO = 0 _d 0
      tmpvirflxA = 0 _d 0
#endif

      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)
 
       tilevol(bi,bj) = 0. _d 0
       tiletotC(bi,bj) = 0. _d 0
       tiletotN(bi,bj) = 0. _d 0
       tiletotP(bi,bj) = 0. _d 0
       tiletotFe(bi,bj) = 0. _d 0
       tiletotSi(bi,bj) = 0. _d 0
       tiletotNfix(bi,bj) = 0. _d 0
       tiletotNdenit(bi,bj) = 0. _d 0
       tiletotscavFe(bi,bj) = 0. _d 0
       tileminFeLoss(bi,bj) = 0. _d 0
       tilesfcflxFe(bi,bj) = 0. _d 0
       tilesedflxFe(bi,bj) = 0. _d 0
       tilesfcflxC(bi,bj) = 0. _d 0
       tilevirflxC(bi,bj) = 0. _d 0
#ifdef DARWIN_BOTTOM_SINK
       tileBotSnkC(bi,bj) = 0. _d 0
       tileBotSnkN(bi,bj) = 0. _d 0
       tileBotSnkP(bi,bj) = 0. _d 0
       tileBotSnkFe(bi,bj) = 0. _d 0
       tileBotSnkSi(bi,bj) = 0. _d 0
#endif
#ifdef DARWIN_ALLOW_CARBON
       tiletotA(bi,bj) = 0. _d 0
       tileAlkSrc(bi,bj) = 0. _d 0
       tiletotO(bi,bj) = 0. _d 0
       tileO2prod(bi,bj) = 0. _d 0
       tileO2cons(bi,bj) = 0. _d 0
       tilesfcflxO(bi,bj) = 0. _d 0
       tilevirflxA(bi,bj) = 0. _d 0
#endif

       DO k=1,Nr
       DO j=1,sNy
       DO i=1,sNx
c-----------------------------------------------------------------------
        vol=rA(i,j,bi,bj)*drF(k)*hFacC(i,j,k,bi,bj)
        tilevol(bi,bj)=tilevol(bi,bj)+vol

c carbon budget
        tiletotC(bi,bj)=tiletotC(bi,bj)+Ptracer(i,j,k,bi,bj,iDIC)*vol
        tiletotC(bi,bj)=tiletotC(bi,bj)+Ptracer(i,j,k,bi,bj,iDOC)*vol
        tiletotC(bi,bj)=tiletotC(bi,bj)+Ptracer(i,j,k,bi,bj,iPOC)*vol
        tiletotC(bi,bj)=tiletotC(bi,bj)+Ptracer(i,j,k,bi,bj,iPIC)*vol
        DO np=1,nplank
         iTr=ic+np-1
         tiletotC(bi,bj)=tiletotC(bi,bj)+Ptracer(i,j,k,bi,bj,iTr)
     &                                  *(1+R_PICPOC(np))*vol
        ENDDO
#ifdef DARWIN_ALLOW_CSTORE
        DO np=1,nPhoto
         iTr=ich+np-1
         tiletotC(bi,bj)=tiletotC(bi,bj)+Ptracer(i,j,k,bi,bj,iTr)*vol
        ENDDO
#endif
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
        tiletotC(bi,bj)=tiletotC(bi,bj)+Ptracer(i,j,k,bi,bj,iCDOM)
     &                                 *vol
# else
        tiletotC(bi,bj)=tiletotC(bi,bj)+Ptracer(i,j,k,bi,bj,iCDOM)
     &                                 *R_CP_CDOM*vol
# endif
#endif

c Nitrogen budget
        tiletotN(bi,bj)=tiletotN(bi,bj)+Ptracer(i,j,k,bi,bj,iNO3)*vol
        tiletotN(bi,bj)=tiletotN(bi,bj)+Ptracer(i,j,k,bi,bj,iNH4)*vol
        tiletotN(bi,bj)=tiletotN(bi,bj)+Ptracer(i,j,k,bi,bj,iNO2)*vol
        tiletotN(bi,bj)=tiletotN(bi,bj)+Ptracer(i,j,k,bi,bj,iDON)*vol
        tiletotN(bi,bj)=tiletotN(bi,bj)+Ptracer(i,j,k,bi,bj,iPON)*vol
        DO np=1,nplank
#ifdef DARWIN_ALLOW_NQUOTA
         iTr=in+np-1
         tiletotN(bi,bj)=tiletotN(bi,bj)+Ptracer(i,j,k,bi,bj,iTr)*vol
#else
         iTr=ic+np-1
         tiletotN(bi,bj)=tiletotN(bi,bj)+Ptracer(i,j,k,bi,bj,iTr)
     &                                  *R_NC(np)*vol
#endif
        ENDDO
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
        tiletotN(bi,bj)=tiletotN(bi,bj)+Ptracer(i,j,k,bi,bj,iCDOM)
     &                                 *R_NC_CDOM*vol
# else
        tiletotN(bi,bj)=tiletotN(bi,bj)+Ptracer(i,j,k,bi,bj,iCDOM)
     &                                 *R_NP_CDOM*vol
# endif
#endif

c Phosphorus budget
        tiletotP(bi,bj)=tiletotP(bi,bj)+Ptracer(i,j,k,bi,bj,iPO4)*vol
        tiletotP(bi,bj)=tiletotP(bi,bj)+Ptracer(i,j,k,bi,bj,iDOP)*vol
        tiletotP(bi,bj)=tiletotP(bi,bj)+Ptracer(i,j,k,bi,bj,iPOP)*vol
        DO np=1,nplank
#ifdef DARWIN_ALLOW_PQUOTA
         iTr=ip+np-1
         tiletotP(bi,bj)=tiletotP(bi,bj)+Ptracer(i,j,k,bi,bj,iTr)*vol
#else
         iTr=ic+np-1
         tiletotP(bi,bj)=tiletotP(bi,bj)+Ptracer(i,j,k,bi,bj,iTr)
     &                                  *R_PC(np)*vol
#endif
        ENDDO
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
        tiletotP(bi,bj)=tiletotP(bi,bj)+Ptracer(i,j,k,bi,bj,iCDOM)
     &                                 *R_PC_CDOM*vol
# else
        tiletotP(bi,bj)=tiletotP(bi,bj)+Ptracer(i,j,k,bi,bj,iCDOM)*vol

# endif
#endif

c Iron budget
        tiletotFe(bi,bj)=tiletotFe(bi,bj)+Ptracer(i,j,k,bi,bj,iFeT)*vol
        tiletotFe(bi,bj)=tiletotFe(bi,bj)+Ptracer(i,j,k,bi,bj,iDOFe)*vol
        tiletotFe(bi,bj)=tiletotFe(bi,bj)+Ptracer(i,j,k,bi,bj,iPOFe)*vol
        DO np=1,nplank
#ifdef DARWIN_ALLOW_FEQUOTA
         iTr=ife+np-1
         tiletotFe(bi,bj)=tiletotFe(bi,bj)+Ptracer(i,j,k,bi,bj,iTr)*vol
#else
         iTr=ic+np-1
         tiletotFe(bi,bj)=tiletotFe(bi,bj)+Ptracer(i,j,k,bi,bj,iTr)
     &                                    *R_FeC(np)*vol
#endif
        ENDDO
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
        tiletotFe(bi,bj)=tiletotFe(bi,bj)+Ptracer(i,j,k,bi,bj,iCDOM)
     &                                   *R_FeC_CDOM*vol
# else
        tiletotFe(bi,bj)=tiletotFe(bi,bj)+Ptracer(i,j,k,bi,bj,iCDOM)
     &                                   *R_FeP_CDOM*vol
# endif
#endif

c Silica budget
        tiletotSi(bi,bj)=tiletotSi(bi,bj)+Ptracer(i,j,k,bi,bj,iSiO2)*vol
        tiletotSi(bi,bj)=tiletotSi(bi,bj)+Ptracer(i,j,k,bi,bj,iPOSi)*vol
        DO np=1,nplank
#ifdef DARWIN_ALLOW_SIQUOTA
         iTr=isi+np-1
         tiletotSi(bi,bj)=tiletotSi(bi,bj)+Ptracer(i,j,k,bi,bj,iTr)*vol
#else
         iTr=ic+np-1
         tiletotSi(bi,bj)=tiletotSi(bi,bj)+Ptracer(i,j,k,bi,bj,iTr)
     &                                    *R_SiC(np)*vol
#endif
        ENDDO
c-----------------------------------------------------------------------
#ifdef DARWIN_ALLOW_CARBON
c alkalinity budget
        tiletotA(bi,bj)=tiletotA(bi,bj)+Ptracer(i,j,k,bi,bj,iALK)*vol
c oxygem budget
        tiletotO(bi,bj)=tiletotO(bi,bj)+Ptracer(i,j,k,bi,bj,iO2)*vol
c corrections
        IF (stage .EQ. 0) THEN
         tileAlkSrc(bi,bj)=tileAlkSrc(bi,bj)+DARWIN_AlkSrc(i,j,k,bi,bj)
     &                                      *vol
         tileO2prod(bi,bj)=tileO2prod(bi,bj)+DARWIN_O2prod(i,j,k,bi,bj)
     &                                      *vol
         tileO2cons(bi,bj)=tileO2cons(bi,bj)+DARWIN_O2cons(i,j,k,bi,bj)
     &                                      *vol
        ENDIF
#endif

c-----------------------------------------------------------------------
c accumulate cons corrections only once per time step
        IF (stage .EQ. 0) THEN
         tiletotNfix(bi,bj)=tiletotNfix(bi,bj)+DARWIN_Nfix(i,j,k,bi,bj)
     &                                        *vol
         tiletotNdenit(bi,bj)=tiletotNdenit(bi,bj)
     &                       +DARWIN_Ndenit(i,j,k,bi,bj)*vol
         tiletotscavFe(bi,bj)=tiletotScavFe(bi,bj)
     &                       +DARWIN_partScav(i,j,k,bi,bj)*vol
         tileminFeLoss(bi,bj)=tileminFeLoss(bi,bj)
     &                       +DARWIN_minFeLoss(i,j,k,bi,bj)*vol
        ENDIF

       ENDDO
       ENDDO
       ENDDO

       DO j=1,sNy
       DO i=1,sNx
c-----------------------------------------------------------------------
        area=rA(i,j,bi,bj)*maskInC(i,j,bi,bj)
        IF (stage .EQ. 0) THEN
        tilesedflxFe(bi,bj)=tilesedflxFe(bi,bj)+ironSedFlx(i,j,bi,bj)
     &                                         *area
#ifdef DARWIN_ALLOW_CARBON
        tilesfcflxC(bi,bj)=tilesfcflxC(bi,bj)+carbSfcFlx(i,j,bi,bj)*area
        tilesfcflxO(bi,bj)=tilesfcflxO(bi,bj)+oxySfcFlx(i,j,bi,bj)*area
#ifdef ALLOW_OLD_VIRTUALFLUX
        tilevirflxC(bi,bj)=tilevirflxC(bi,bj)+carbVirFlx(i,j,bi,bj)*area
        tilevirflxA(bi,bj)=tilevirflxA(bi,bj)+alkVirFlx(i,j,bi,bj)*area
#endif
#endif
#ifdef DARWIN_BOTTOM_SINK
        tileBotSnkC(bi,bj)=tilebotsnkC(bi,bj)+botSnkC(i,j,bi,bj)*area
        tileBotSnkN(bi,bj)=tilebotsnkN(bi,bj)+botSnkN(i,j,bi,bj)*area
        tileBotSnkP(bi,bj)=tilebotsnkP(bi,bj)+botSnkP(i,j,bi,bj)*area
        tileBotSnkFe(bi,bj)=tilebotsnkFe(bi,bj)+botSnkFe(i,j,bi,bj)*area
        tileBotSnkSi(bi,bj)=tilebotsnkSi(bi,bj)+botSnkSi(i,j,bi,bj)*area
#endif
        ELSEIF (stage .EQ. 2) THEN
        tilesfcflxFe(bi,bj)=tilesfcflxFe(bi,bj)+alpfe*inputfe(i,j,bi,bj)
     &                                         *PTRACERS_dtLev(ks)*area
        ENDIF
       ENDDO
       ENDDO
      ENDDO
      ENDDO

      CALL GLOBAL_SUM_TILE_RL(tilevol,voltot,myThid)
      CALL GLOBAL_SUM_TILE_RL(tiletotC,tmptotC,myThid)
      CALL GLOBAL_SUM_TILE_RL(tiletotN,tmptotN,myThid)
      CALL GLOBAL_SUM_TILE_RL(tiletotP,tmptotP,myThid)
      CALL GLOBAL_SUM_TILE_RL(tiletotFe,tmptotFe,myThid)
      CALL GLOBAL_SUM_TILE_RL(tiletotSi,tmptotSi,myThid)
#ifdef DARWIN_ALLOW_CARBON
      CALL GLOBAL_SUM_TILE_RL(tiletotA,tmptotA,myThid)
      CALL GLOBAL_SUM_TILE_RL(tiletotO,tmptotO,myThid)
#endif
      IF (stage .EQ. 0) THEN
       CALL GLOBAL_SUM_TILE_RL(tiletotNfix,tmptotNfix,myThid)
       CALL GLOBAL_SUM_TILE_RL(tiletotNdenit,tmptotNdenit,myThid)
       CALL GLOBAL_SUM_TILE_RL(tiletotscavFe,tmptotscavFe,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileminFeLoss,tmpminFeLoss,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilesedflxFe,tmpsedflxFe,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilesfcflxC,tmpsfcflxC,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilevirflxC,tmpvirflxC,myThid)
#ifdef DARWIN_ALLOW_CARBON
       CALL GLOBAL_SUM_TILE_RL(tileAlkSrc,tmpAlkSrc,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileO2prod,tmpO2prod,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileO2cons,tmpO2cons,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilesfcflxO,tmpsfcflxO,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilevirflxA,tmpvirflxA,myThid)
#endif
#ifdef DARWIN_BOTTOM_SINK
       CALL GLOBAL_SUM_TILE_RL(tileBotSnkC,tmpBotSnkC,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileBotSnkN,tmpBotSnkN,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileBotSnkP,tmpBotSnkP,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileBotSnkFe,tmpBotSnkFe,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileBotSnkSi,tmpBotSnkSi,myThid)
#endif
      ELSEIF (stage .EQ. 2) THEN
       CALL GLOBAL_SUM_TILE_RL(tilesfcflxFe,tmpsfcflxFe,myThid)
      ENDIF

      IF ( myProcId.EQ.0 .AND. myThid.EQ.1 ) THEN
C do not write ecosystem non-conservation terms before they are applied
        IF ((myIter.EQ.nIter0 .OR.
     &       (staggerTimeStep.AND.myIter.EQ.nIter0+1)) .AND.
     &      stage.EQ.0) THEN
         WRITE(DAR_cons_C_unit,'(A1,A11,A6,A20,4A24)')'#','iter',
     &      'stage','tot','mean','sfcflx','virtflx','botsnk'
         WRITE(DAR_cons_N_unit,'(A1,A11,A6,A20,4A24)')'#','iter',
     &      'stage','tot','mean','Nfix','Ndenit','botsnk'
         WRITE(DAR_cons_P_unit,'(A1,A11,A6,A20,2A24)')'#','iter',
     &      'stage','tot','mean','botsnk'
         WRITE(DAR_cons_Fe_unit,'(A1,A11,A6,A20,6A24)')'#','iter',
     &      'stage','tot','mean','minFeLoss','scav','sfcflx','sedflx',
     &      'botsnk'
         WRITE(DAR_cons_Si_unit,'(A1,A11,A6,A20,2A24)')'#','iter',
     &      'stage','tot','mean','botsnk'
#ifdef DARWIN_ALLOW_CARBON
         WRITE(DAR_cons_A_unit,'(A1,A11,A6,A20,4A24)')'#','iter',
     &      'stage','tot','mean','sfcflx','AlkSrc'
         WRITE(DAR_cons_O_unit,'(A1,A11,A6,A20,4A24)')'#','iter',
     &      'stage','tot','mean','sfcflx','O2prod','O2cons'
#endif
        ENDIF
        WRITE(DAR_cons_C_unit,'(I12,I2,5E24.16)') myIter, stage,
     &     tmptotC, tmptotC/voltot, tmpsfcflxC, tmpvirflxC, -tmpBotSnkC
        WRITE(DAR_cons_N_unit,'(I12,I2,5E24.16)') myIter, stage,
     &     tmptotN, tmptotN/voltot, tmptotNfix, -tmptotNdenit,
     &     -tmpBotSnkN
        WRITE(DAR_cons_P_unit,'(I12,I2,3E24.16)') myIter, stage,
     &     tmptotP, tmptotP/voltot, -tmpBotSnkP
        WRITE(DAR_cons_Fe_unit,'(I12,I2,7E24.16)') myIter, stage,
     &     tmptotFe, tmptotFe/voltot, -tmpminFeLoss, -tmptotscavFe,
     &     tmpsfcflxFe, tmpsedflxFe, -tmpBotSnkFe
        WRITE(DAR_cons_Si_unit,'(I12,I2,3E24.16)') myIter, stage,
     &     tmptotSi, tmptotSi/voltot, -tmpBotSnkSi
#ifdef DARWIN_ALLOW_CARBON
        WRITE(DAR_cons_A_unit,'(I12,I2,6E24.16)') myIter, stage,
     &     tmptotA, tmptotA/voltot, tmpvirflxA, tmpAlkSrc
        WRITE(DAR_cons_O_unit,'(I12,I2,6E24.16)') myIter, stage,
     &     tmptotO, tmptotO/voltot, tmpsfcflxO, tmpO2prod, -tmpO2cons
#endif
      ENDIF

C--   Everyone else must wait
      _BARRIER

#endif /* DARWIN_ALLOW_CONS */

      RETURN
      END

