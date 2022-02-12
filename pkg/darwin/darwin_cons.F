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
#include "SURFACE.h"
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
#ifdef EXACT_CONSERV
      _RL tileEPRC(nSx,nSy)
      _RL tileEPRN(nSx,nSy)
      _RL tileEPRP(nSx,nSy)
      _RL tileEPRFe(nSx,nSy)
      _RL tileEPRSi(nSx,nSy)
#endif
#ifdef DARWIN_ALLOW_CARBON
      _RL tiletotA(nSx,nSy)
      _RL tileAlkSrc(nSx,nSy)
      _RL tiletotO(nSx,nSy)
      _RL tileO2prod(nSx,nSy)
      _RL tileO2cons(nSx,nSy)
      _RL tilesfcflxO(nSx,nSy)
      _RL tilevirflxA(nSx,nSy)
#ifdef EXACT_CONSERV
      _RL tileEPRA(nSx,nSy)
      _RL tileEPRO(nSx,nSy)
#endif
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
      _RL tmpEPRC
      _RL tmpEPRN
      _RL tmpEPRP
      _RL tmpEPRFe
      _RL tmpEPRSi
#ifdef DARWIN_ALLOW_CARBON
      _RL tmptotA
      _RL tmpAlkSrc
      _RL tmptotO
      _RL tmpO2prod
      _RL tmpO2cons
      _RL tmpsfcflxO
      _RL tmpvirflxA
      _RL tmpEPRA
      _RL tmpEPRO
#endif
      _RL vol, voltot, dvol
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
      tmpEPRC = 0 _d 0
      tmpEPRN = 0 _d 0
      tmpEPRP = 0 _d 0
      tmpEPRFe = 0 _d 0
      tmpEPRSi = 0 _d 0
#ifdef DARWIN_ALLOW_CARBON
      tmptotA = 0 _d 0
      tmpAlkSrc = 0 _d 0
      tmptotO = 0 _d 0
      tmpO2prod = 0 _d 0
      tmpO2cons = 0 _d 0
      tmpsfcflxO = 0 _d 0
      tmpvirflxA = 0 _d 0
      tmpEPRA = 0 _d 0
      tmpEPRO = 0 _d 0
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
#ifdef EXACT_CONSERV
       tileEPRC(bi,bj) = 0. _d 0
       tileEPRN(bi,bj) = 0. _d 0
       tileEPRP(bi,bj) = 0. _d 0
       tileEPRFe(bi,bj) = 0. _d 0
       tileEPRSi(bi,bj) = 0. _d 0
#endif
#ifdef DARWIN_ALLOW_CARBON
       tiletotA(bi,bj) = 0. _d 0
       tileAlkSrc(bi,bj) = 0. _d 0
       tiletotO(bi,bj) = 0. _d 0
       tileO2prod(bi,bj) = 0. _d 0
       tileO2cons(bi,bj) = 0. _d 0
       tilesfcflxO(bi,bj) = 0. _d 0
       tilevirflxA(bi,bj) = 0. _d 0
#ifdef EXACT_CONSERV
       tileEPRA(bi,bj) = 0. _d 0
       tileEPRO(bi,bj) = 0. _d 0
#endif
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

C compute surface flux from EmPmR with local ptracer concentration
C before thermodynamics; will store totals in common block and apply
C after thermodynamics
#ifdef EXACT_CONSERV
        IF (nonlinFreeSurf.GT.0 .AND. stage.EQ.0) THEN
C volume change due to precip, evap and runoff
         dvol = PmEpR(i,j,bi,bj)*mass2rUnit*area*PTRACERS_dtLev(ks)
c carbon NLFS fluxes
         IF (PTRACERS_EvPrRn(iDIC).EQ.UNSET_RL)
     &   tileEPRC(bi,bj)=tileEPRC(bi,bj)+Ptracer(i,j,ks,bi,bj,iDIC)*dvol
         IF (PTRACERS_EvPrRn(iDOC).EQ.UNSET_RL)
     &   tileEPRC(bi,bj)=tileEPRC(bi,bj)+Ptracer(i,j,ks,bi,bj,iDOC)*dvol
         IF (PTRACERS_EvPrRn(iPOC).EQ.UNSET_RL)
     &   tileEPRC(bi,bj)=tileEPRC(bi,bj)+Ptracer(i,j,ks,bi,bj,iPOC)*dvol
         IF (PTRACERS_EvPrRn(iPIC).EQ.UNSET_RL)
     &   tileEPRC(bi,bj)=tileEPRC(bi,bj)+Ptracer(i,j,ks,bi,bj,iPIC)*dvol
         DO np=1,nplank
          iTr=ic+np-1
          IF (PTRACERS_EvPrRn(iTr).EQ.UNSET_RL)
     &     tileEPRC(bi,bj)=tileEPRC(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)
     &                                    *(1+R_PICPOC(np))*dvol
         ENDDO
#ifdef DARWIN_ALLOW_CDOM
         IF (PTRACERS_EvPrRn(iCDOM).EQ.UNSET_RL)
# ifdef DARWIN_CDOM_UNITS_CARBON
     &    tileEPRC(bi,bj)=tileEPRC(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *dvol
# else
     &    tileEPRC(bi,bj)=tileEPRC(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *R_CP_CDOM*dvol
# endif
#endif

c Nitrogen NLFS fluxes
         IF (PTRACERS_EvPrRn(iNO3).EQ.UNSET_RL)
     &   tileEPRN(bi,bj)=tileEPRN(bi,bj)+Ptracer(i,j,ks,bi,bj,iNO3)*dvol
         IF (PTRACERS_EvPrRn(iNH4).EQ.UNSET_RL)
     &   tileEPRN(bi,bj)=tileEPRN(bi,bj)+Ptracer(i,j,ks,bi,bj,iNH4)*dvol
         IF (PTRACERS_EvPrRn(iNO2).EQ.UNSET_RL)
     &   tileEPRN(bi,bj)=tileEPRN(bi,bj)+Ptracer(i,j,ks,bi,bj,iNO2)*dvol
         IF (PTRACERS_EvPrRn(iDON).EQ.UNSET_RL)
     &   tileEPRN(bi,bj)=tileEPRN(bi,bj)+Ptracer(i,j,ks,bi,bj,iDON)*dvol
         IF (PTRACERS_EvPrRn(iPON).EQ.UNSET_RL)
     &   tileEPRN(bi,bj)=tileEPRN(bi,bj)+Ptracer(i,j,ks,bi,bj,iPON)*dvol
         DO np=1,nplank
#ifdef DARWIN_ALLOW_NQUOTA
          iTr=in+np-1
          IF (PTRACERS_EvPrRn(iTr).EQ.UNSET_RL)
     &    tileEPRN(bi,bj)=tileEPRN(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)*dvol
#else
          iTr=ic+np-1
          IF (PTRACERS_EvPrRn(iTr).EQ.UNSET_RL)
     &     tileEPRN(bi,bj)=tileEPRN(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)
     &                                    *R_NC(np)*dvol
#endif
         ENDDO
#ifdef DARWIN_ALLOW_CDOM
         IF (PTRACERS_EvPrRn(iCDOM).EQ.UNSET_RL)
# ifdef DARWIN_CDOM_UNITS_CARBON
     &    tileEPRN(bi,bj)=tileEPRN(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *R_NC_CDOM*dvol
# else
     &    tileEPRN(bi,bj)=tileEPRN(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *R_NP_CDOM*dvol
# endif
#endif

c Phosphorus NLFS fluxes
         IF (PTRACERS_EvPrRn(iPO4).EQ.UNSET_RL)
     &   tileEPRP(bi,bj)=tileEPRP(bi,bj)+Ptracer(i,j,ks,bi,bj,iPO4)*dvol
         IF (PTRACERS_EvPrRn(iDOP).EQ.UNSET_RL)
     &   tileEPRP(bi,bj)=tileEPRP(bi,bj)+Ptracer(i,j,ks,bi,bj,iDOP)*dvol
         IF (PTRACERS_EvPrRn(iPOP).EQ.UNSET_RL)
     &   tileEPRP(bi,bj)=tileEPRP(bi,bj)+Ptracer(i,j,ks,bi,bj,iPOP)*dvol
         DO np=1,nplank
#ifdef DARWIN_ALLOW_PQUOTA
          iTr=ip+np-1
          IF (PTRACERS_EvPrRn(iTr).EQ.UNSET_RL)
     &    tileEPRP(bi,bj)=tileEPRP(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)*dvol
#else
          iTr=ic+np-1
          IF (PTRACERS_EvPrRn(iTr).EQ.UNSET_RL)
     &     tileEPRP(bi,bj)=tileEPRP(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)
     &                                    *R_PC(np)*dvol
#endif
         ENDDO
#ifdef DARWIN_ALLOW_CDOM
         IF (PTRACERS_EvPrRn(iCDOM).EQ.UNSET_RL)
# ifdef DARWIN_CDOM_UNITS_CARBON
     &    tileEPRP(bi,bj)=tileEPRP(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *R_PC_CDOM*dvol
# else
     &    tileEPRP(bi,bj)=tileEPRP(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *dvol
# endif
#endif

c Iron NLFS fluxes
         IF (PTRACERS_EvPrRn(iFeT).EQ.UNSET_RL)
     &    tileEPRFe(bi,bj)=tileEPRFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iFeT)
     &                                     *dvol
         IF (PTRACERS_EvPrRn(iDOFe).EQ.UNSET_RL)
     &    tileEPRFe(bi,bj)=tileEPRFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iDOFe)
     &                                     *dvol
         IF (PTRACERS_EvPrRn(iPOFe).EQ.UNSET_RL)
     &    tileEPRFe(bi,bj)=tileEPRFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iPOFe)
     &                                     *dvol
         DO np=1,nplank
#ifdef DARWIN_ALLOW_FEQUOTA
          iTr=ife+np-1
          IF (PTRACERS_EvPrRn(iTr).EQ.UNSET_RL)
     &     tileEPRFe(bi,bj)=tileEPRFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)
     &                                      *dvol
#else
          iTr=ic+np-1
          IF (PTRACERS_EvPrRn(iTr).EQ.UNSET_RL)
     &     tileEPRFe(bi,bj)=tileEPRFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)
     &                                      *R_FeC(np)*dvol
#endif
         ENDDO
#ifdef DARWIN_ALLOW_CDOM
         IF (PTRACERS_EvPrRn(iCDOM).EQ.UNSET_RL)
# ifdef DARWIN_CDOM_UNITS_CARBON
     &    tileEPRFe(bi,bj)=tileEPRFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                     *R_FeC_CDOM*dvol
# else
     &    tileEPRFe(bi,bj)=tileEPRFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                     *R_FeP_CDOM*dvol
# endif
#endif

c Silica NLFS fluxes
         IF (PTRACERS_EvPrRn(iSiO2).EQ.UNSET_RL)
     &    tileEPRSi(bi,bj)=tileEPRSi(bi,bj)+Ptracer(i,j,ks,bi,bj,iSiO2)
     &                                     *dvol
         IF (PTRACERS_EvPrRn(iPOSi).EQ.UNSET_RL)
     &    tileEPRSi(bi,bj)=tileEPRSi(bi,bj)+Ptracer(i,j,ks,bi,bj,iPOSi)
     &                                     *dvol
         DO np=1,nplank
#ifdef DARWIN_ALLOW_SIQUOTA
          iTr=isi+np-1
          IF (PTRACERS_EvPrRn(iTr).EQ.UNSET_RL)
     &     tileEPRSi(bi,bj)=tileEPRSi(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)
     &                                      *dvol
#else
          iTr=ic+np-1
          IF (PTRACERS_EvPrRn(iTr).EQ.UNSET_RL)
     &     tileEPRSi(bi,bj)=tileEPRSi(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)
     &                                      *R_SiC(np)*dvol
#endif
         ENDDO
#ifdef DARWIN_ALLOW_CARBON
         IF (PTRACERS_EvPrRn(iALK).EQ.UNSET_RL)
     &   tileEPRA(bi,bj)=tileEPRA(bi,bj)+Ptracer(i,j,ks,bi,bj,iALK)*dvol
         IF (PTRACERS_EvPrRn(iO2).EQ.UNSET_RL)
     &   tileEPRO(bi,bj)=tileEPRO(bi,bj)+Ptracer(i,j,ks,bi,bj,iO2)*dvol
#endif
        ENDIF
#endif /* EXACT_CONSERV */
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
#ifdef EXACT_CONSERV
C store totals in common block to retrieve at stage 1
       CALL GLOBAL_SUM_TILE_RL(tileEPRC,totEPRC,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileEPRN,totEPRN,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileEPRP,totEPRP,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileEPRFe,totEPRFe,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileEPRSi,totEPRSi,myThid)
# ifdef DARWIN_ALLOW_CARBON
       CALL GLOBAL_SUM_TILE_RL(tileEPRA,totEPRA,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileEPRO,totEPRO,myThid)
# endif
#endif
      ELSEIF (stage .EQ. 2) THEN
       CALL GLOBAL_SUM_TILE_RL(tilesfcflxFe,tmpsfcflxFe,myThid)
      ENDIF

#ifdef EXACT_CONSERV
C retrieve totals from stage 0
      IF ( stage .EQ. 1 ) THEN
        tmpEPRC = totEPRC
        tmpEPRN = totEPRN
        tmpEPRP = totEPRP
        tmpEPRFe = totEPRFe
        tmpEPRSi = totEPRSi
# ifdef DARWIN_ALLOW_CARBON
        tmpEPRA = totEPRA
        tmpEPRO = totEPRO
# endif
      ENDIF
#endif

      IF ( myProcId.EQ.0 .AND. myThid.EQ.1 ) THEN
C do not write ecosystem non-conservation terms before they are applied
        IF ((myIter.EQ.nIter0 .OR.
     &       (staggerTimeStep.AND.myIter.EQ.nIter0+1)) .AND.
     &      stage.EQ.0) THEN
         WRITE(DAR_cons_C_unit,'(A1,A11,A6,A20,5A24)')'#','iter',
     &      'stage','tot','mean','sfcflx','virtflx','botsnk','EvPrRn'
         WRITE(DAR_cons_N_unit,'(A1,A11,A6,A20,5A24)')'#','iter',
     &      'stage','tot','mean','Nfix','Ndenit','botsnk','EvPrRn'
         WRITE(DAR_cons_P_unit,'(A1,A11,A6,A20,3A24)')'#','iter',
     &      'stage','tot','mean','botsnk','EvPrRn'
         WRITE(DAR_cons_Fe_unit,'(A1,A11,A6,A20,7A24)')'#','iter',
     &      'stage','tot','mean','minFeLoss','scav','sfcflx','sedflx',
     &      'botsnk','EvPrRn'
         WRITE(DAR_cons_Si_unit,'(A1,A11,A6,A20,3A24)')'#','iter',
     &      'stage','tot','mean','botsnk','EvPrRn'
#ifdef DARWIN_ALLOW_CARBON
         WRITE(DAR_cons_A_unit,'(A1,A11,A6,A20,4A24)')'#','iter',
     &      'stage','tot','mean','sfcflx','AlkSrc','EvPrRn'
         WRITE(DAR_cons_O_unit,'(A1,A11,A6,A20,5A24)')'#','iter',
     &      'stage','tot','mean','sfcflx','O2prod','O2cons','EvPrRn'
#endif
        ENDIF
        WRITE(DAR_cons_C_unit,'(I12,I2,6E24.16)') myIter, stage,
     &     tmptotC, tmptotC/voltot, tmpsfcflxC, tmpvirflxC, -tmpBotSnkC,
     &     tmpEPRC
        WRITE(DAR_cons_N_unit,'(I12,I2,6E24.16)') myIter, stage,
     &     tmptotN, tmptotN/voltot, tmptotNfix, -tmptotNdenit,
     &     -tmpBotSnkN, tmpEPRN
        WRITE(DAR_cons_P_unit,'(I12,I2,4E24.16)') myIter, stage,
     &     tmptotP, tmptotP/voltot, -tmpBotSnkP, tmpEPRP
        WRITE(DAR_cons_Fe_unit,'(I12,I2,8E24.16)') myIter, stage,
     &     tmptotFe, tmptotFe/voltot, -tmpminFeLoss, -tmptotscavFe,
     &     tmpsfcflxFe, tmpsedflxFe, -tmpBotSnkFe, tmpEPRFe
        WRITE(DAR_cons_Si_unit,'(I12,I2,4E24.16)') myIter, stage,
     &     tmptotSi, tmptotSi/voltot, -tmpBotSnkSi, tmpEPRSi
#ifdef DARWIN_ALLOW_CARBON
        WRITE(DAR_cons_A_unit,'(I12,I2,5E24.16)') myIter, stage,
     &     tmptotA, tmptotA/voltot, tmpvirflxA, tmpAlkSrc, tmpEPRA
        WRITE(DAR_cons_O_unit,'(I12,I2,6E24.16)') myIter, stage,
     &     tmptotO, tmptotO/voltot, tmpsfcflxO, tmpO2prod, -tmpO2cons,
     &     tmpEPRO
#endif
      ENDIF

C--   Everyone else must wait
      _BARRIER

#endif /* DARWIN_ALLOW_CONS */

      RETURN
      END

