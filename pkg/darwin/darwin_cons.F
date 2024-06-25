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
#include "FFIELDS.h"
#include "SURFACE.h"
#include "DYNVARS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PTRACERS_FIELDS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_INDICES.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN_TRAITS.h"
#include "DARWIN_FIELDS.h"
#include "DARWIN_EXF_PARAMS.h"
#include "DARWIN_EXF_FIELDS.h"

C !INPUT PARAMETERS: ===================================================
      INTEGER stage
      _RL myTime
      INTEGER myIter
      INTEGER myThid
CEOP

#ifdef DARWIN_ALLOW_CONS

C !FUNCTIONS: ==========================================================
      LOGICAL  DIAGNOSTICS_IS_ON
      EXTERNAL DIAGNOSTICS_IS_ON

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
      _RL tileventflxFe(nSx,nSy)
      _RL tilesfcflxC(nSx,nSy)
      _RL tilevirflxC(nSx,nSy)
#ifdef DARWIN_BOTTOM_SINK
      _RL tileBotSnkC(nSx,nSy)
      _RL tileBotSnkN(nSx,nSy)
      _RL tileBotSnkP(nSx,nSy)
      _RL tileBotSnkFe(nSx,nSy)
      _RL tileBotSnkSi(nSx,nSy)
#endif
#ifdef DARWIN_NUTRIENT_RUNOFF
      _RL tilerunoffC(nSx,nSy)
      _RL tilerunoffN(nSx,nSy)
      _RL tilerunoffP(nSx,nSy)
      _RL tilerunoffFe(nSx,nSy)
      _RL tilerunoffSi(nSx,nSy)
#ifdef DARWIN_ALLOW_CARBON
      _RL tilerunoffA(nSx,nSy)
#endif
#endif
      _RL tileFSC(nSx,nSy)
      _RL tileFSN(nSx,nSy)
      _RL tileFSP(nSx,nSy)
      _RL tileFSFe(nSx,nSy)
      _RL tileFSSi(nSx,nSy)
      _RL tilePER(nSx,nSy)
      _RL tileEPRC(nSx,nSy)
      _RL tileEPRN(nSx,nSy)
      _RL tileEPRP(nSx,nSy)
      _RL tileEPRFe(nSx,nSy)
      _RL tileEPRSi(nSx,nSy)
#ifdef DARWIN_ALLOW_CARBON
      _RL tiletotA(nSx,nSy)
      _RL tileAlkSrc(nSx,nSy)
      _RL tiletotO(nSx,nSy)
      _RL tileO2prod(nSx,nSy)
      _RL tileO2cons(nSx,nSy)
      _RL tilesfcflxO(nSx,nSy)
      _RL tilevirflxA(nSx,nSy)
      _RL tilesedflxC(nSx,nSy)
      _RL tilesedflxA(nSx,nSy)
      _RL tilesedflxO(nSx,nSy)
      _RL tileFSA(nSx,nSy)
      _RL tileFSO(nSx,nSy)
      _RL tileEPRA(nSx,nSy)
      _RL tileEPRO(nSx,nSy)
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
      _RL tmpventflxFe
      _RL tmpsfcflxC
      _RL tmpvirflxC
      _RL tmpsedflxC
      _RL tmpsedflxA
      _RL tmpsedflxO
      _RL tmpBotSnkC
      _RL tmpBotSnkN
      _RL tmpBotSnkP
      _RL tmpBotSnkFe
      _RL tmpBotSnkSi
      _RL tmprunoffC
      _RL tmprunoffN
      _RL tmprunoffP
      _RL tmprunoffFe
      _RL tmprunoffSi
      _RL tmprunoffA
      _RL tmpFSC
      _RL tmpFSN
      _RL tmpFSP
      _RL tmpFSFe
      _RL tmpFSSi
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
      _RL tmpFSA
      _RL tmpFSO
      _RL tmpEPRA
      _RL tmpEPRO
#endif
      _RL vol, voltot, dvol
      _RL area, areadt, fac

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
      tmpventflxFe = 0 _d 0
      tmpsfcflxC = 0 _d 0
      tmpvirflxC = 0 _d 0
      tmpsedflxC = 0 _d 0
      tmpsedflxA = 0 _d 0
      tmpsedflxO = 0 _d 0
      tmpBotSnkC = 0 _d 0
      tmpBotSnkN = 0 _d 0
      tmpBotSnkP = 0 _d 0
      tmpBotSnkFe = 0 _d 0
      tmpBotSnkSi = 0 _d 0
      tmprunoffC = 0 _d 0
      tmprunoffN = 0 _d 0
      tmprunoffP = 0 _d 0
      tmprunoffFe = 0 _d 0
      tmprunoffSi = 0 _d 0
      tmprunoffA = 0 _d 0
      tmpFSC = 0 _d 0
      tmpFSN = 0 _d 0
      tmpFSP = 0 _d 0
      tmpFSFe = 0 _d 0
      tmpFSSi = 0 _d 0
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
      tmpFSA = 0 _d 0
      tmpFSO = 0 _d 0
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
       tileventflxFe(bi,bj) = 0. _d 0
       tilesfcflxC(bi,bj) = 0. _d 0
       tilevirflxC(bi,bj) = 0. _d 0
#ifdef DARWIN_BOTTOM_SINK
       tileBotSnkC(bi,bj) = 0. _d 0
       tileBotSnkN(bi,bj) = 0. _d 0
       tileBotSnkP(bi,bj) = 0. _d 0
       tileBotSnkFe(bi,bj) = 0. _d 0
       tileBotSnkSi(bi,bj) = 0. _d 0
#endif
#ifdef DARWIN_NUTRIENT_RUNOFF
       tilerunoffC(bi,bj) = 0. _d 0
       tilerunoffN(bi,bj) = 0. _d 0
       tilerunoffP(bi,bj) = 0. _d 0
       tilerunoffFe(bi,bj) = 0. _d 0
       tilerunoffSi(bi,bj) = 0. _d 0
#ifdef DARWIN_ALLOW_CARBON
       tilerunoffA(bi,bj) = 0. _d 0
#endif
#endif
       tileFSC(bi,bj) = 0. _d 0
       tileFSN(bi,bj) = 0. _d 0
       tileFSP(bi,bj) = 0. _d 0
       tileFSFe(bi,bj) = 0. _d 0
       tileFSSi(bi,bj) = 0. _d 0
       tilePER(bi,bj) = 0. _d 0
       tileEPRC(bi,bj) = 0. _d 0
       tileEPRN(bi,bj) = 0. _d 0
       tileEPRP(bi,bj) = 0. _d 0
       tileEPRFe(bi,bj) = 0. _d 0
       tileEPRSi(bi,bj) = 0. _d 0
#ifdef DARWIN_ALLOW_CARBON
       tiletotA(bi,bj) = 0. _d 0
       tileAlkSrc(bi,bj) = 0. _d 0
       tiletotO(bi,bj) = 0. _d 0
       tileO2prod(bi,bj) = 0. _d 0
       tileO2cons(bi,bj) = 0. _d 0
       tilesfcflxO(bi,bj) = 0. _d 0
       tilevirflxA(bi,bj) = 0. _d 0
       tilesedflxC(bi,bj) = 0. _d 0
       tilesedflxA(bi,bj) = 0. _d 0
       tilesedflxO(bi,bj) = 0. _d 0
       tileFSA(bi,bj) = 0. _d 0
       tileFSO(bi,bj) = 0. _d 0
       tileEPRA(bi,bj) = 0. _d 0
       tileEPRO(bi,bj) = 0. _d 0
#endif

       DO k=1,Nr
       DO j=1,sNy
       DO i=1,sNx
C ======================================================================
C Compute totals for each chemical element

        vol=rA(i,j,bi,bj)*drF(k)*hFacC(i,j,k,bi,bj)
        tilevol(bi,bj)=tilevol(bi,bj)+vol

C Carbon budget
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

C ======================================================================
C 3-d conservation corrections
C       accumulate cons corrections only once per time step
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

C      enddo i,j,k
       ENDDO
       ENDDO
       ENDDO

C ======================================================================
C 2-d conservation corrections
       DO j=1,sNy
       DO i=1,sNx
        area=rA(i,j,bi,bj)*maskInC(i,j,bi,bj)
        IF (stage .EQ. 0) THEN
        tilesedflxFe(bi,bj)=tilesedflxFe(bi,bj)+ironSedFlx(i,j,bi,bj)
     &                                         *area
#ifdef DARWIN_ALLOW_HYDROTHERMAL_VENTS
        tileventflxFe(bi,bj)=tileventflxFe(bi,bj)+ironVentFlx(i,j,bi,bj)
     &                                           *area
#endif
#ifdef DARWIN_ALLOW_CARBON
        tilesfcflxC(bi,bj)=tilesfcflxC(bi,bj)+carbSfcFlx(i,j,bi,bj)*area
        tilesfcflxO(bi,bj)=tilesfcflxO(bi,bj)+oxySfcFlx(i,j,bi,bj)*area
#ifdef ALLOW_OLD_VIRTUALFLUX
        tilevirflxC(bi,bj)=tilevirflxC(bi,bj)+carbVirFlx(i,j,bi,bj)*area
        tilevirflxA(bi,bj)=tilevirflxA(bi,bj)+alkVirFlx(i,j,bi,bj)*area
#endif
#ifdef DARWIN_ALLOW_RADI
        tilesedflxC(bi,bj)=tilesedflxC(bi,bj)+radiFluxC(i,j,bi,bj)*area
        tilesedflxA(bi,bj)=tilesedflxA(bi,bj)+radiFluxA(i,j,bi,bj)*area
        tilesedflxO(bi,bj)=tilesedflxO(bi,bj)+radiFLuxO(i,j,bi,bj)*area
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
#ifdef DARWIN_NUTRIENT_RUNOFF
        tilerunoffC(bi,bj) = tilerunoffC(bi,bj) + DOCrunoff(i,j,bi,bj)
     &                   *PTRACERS_dtLev(ks)*area
        tilerunoffN(bi,bj) = tilerunoffN(bi,bj) + DONrunoff(i,j,bi,bj)
     &                   *PTRACERS_dtLev(ks)*area
        tilerunoffP(bi,bj) = tilerunoffP(bi,bj) + DOPrunoff(i,j,bi,bj)
     &                   *PTRACERS_dtLev(ks)*area
        tilerunoffN(bi,bj) = tilerunoffN(bi,bj) + DINrunoff(i,j,bi,bj)
     &                   *PTRACERS_dtLev(ks)*area
        tilerunoffP(bi,bj) = tilerunoffP(bi,bj) + IPrunoff(i,j,bi,bj)
     &                   *PTRACERS_dtLev(ks)*area*R_DIP_IP_runoff
        tilerunoffSi(bi,bj)= tilerunoffSi(bi,bj)+ DSirunoff(i,j,bi,bj)
     &                   *PTRACERS_dtLev(ks)*area
        tilerunoffC(bi,bj) = tilerunoffC(bi,bj) + POCrunoff(i,j,bi,bj)
     &                   *PTRACERS_dtLev(ks)*area
        tilerunoffN(bi,bj) = tilerunoffN(bi,bj) + PONrunoff(i,j,bi,bj)
     &                   *PTRACERS_dtLev(ks)*area
        tilerunoffP(bi,bj) = tilerunoffP(bi,bj) + POPrunoff(i,j,bi,bj)
     &                   *PTRACERS_dtLev(ks)*area
        tilerunoffC(bi,bj) = tilerunoffC(bi,bj) + DICrunoff(i,j,bi,bj)
     &                   *PTRACERS_dtLev(ks)*area
#ifdef DARWIN_ALLOW_CARBON
        tilerunoffA(bi,bj) = tilerunoffA(bi,bj) + DICrunoff(i,j,bi,bj)
     &                   *PTRACERS_dtLev(ks)*area*R_ALK_DIC_runoff
#endif
        tilerunoffFe(bi,bj)= tilerunoffFe(bi,bj)+ IPrunoff(i,j,bi,bj)
     &         *PTRACERS_dtLev(ks)*area*R_DIP_IP_runoff*R_DFe_DIP_runoff
        tilerunoffFe(bi,bj)= tilerunoffFe(bi,bj)+ DOPrunoff(i,j,bi,bj)
     &                   *PTRACERS_dtLev(ks)*area*R_DOFe_DOP_runoff
        tilerunoffFe(bi,bj)= tilerunoffFe(bi,bj)+ POPrunoff(i,j,bi,bj)
     &                   *PTRACERS_dtLev(ks)*area*R_POFe_POP_runoff
#endif
        ENDIF

C ======================================================================
C compute change in local ptracer concentration due to neglected volume
C change with linear implicit free surface.  Compute before
C thermodynamics; will store totals in common block and apply after
C thermodynamics.
        IF (stage.EQ.0 .AND. implicitFreeSurface .AND.
     &      nonlinFreeSurf.EQ.0 .AND. .NOT.DARWIN_linFSConserve) THEN
         dvol = -wVel(i,j,ks,bi,bj)*area*PTRACERS_dtLev(ks)
C Carbon imp.FS corrections
         tileFSC(bi,bj)=tileFSC(bi,bj)+Ptracer(i,j,ks,bi,bj,iDIC)*dvol
         tileFSC(bi,bj)=tileFSC(bi,bj)+Ptracer(i,j,ks,bi,bj,iDOC)*dvol
         tileFSC(bi,bj)=tileFSC(bi,bj)+Ptracer(i,j,ks,bi,bj,iPOC)*dvol
         tileFSC(bi,bj)=tileFSC(bi,bj)+Ptracer(i,j,ks,bi,bj,iPIC)*dvol
         DO np=1,nplank
          iTr=ic+np-1
          tileFSC(bi,bj)=tileFSC(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)
     &                                 *(1+R_PICPOC(np))*dvol
         ENDDO
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
         tileFSC(bi,bj)=tileFSC(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                *dvol
# else
         tileFSC(bi,bj)=tileFSC(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                *R_CP_CDOM*dvol
# endif
#endif

C Nitrogen imp.FS corrections
         tileFSN(bi,bj)=tileFSN(bi,bj)+Ptracer(i,j,ks,bi,bj,iNO3)*dvol
         tileFSN(bi,bj)=tileFSN(bi,bj)+Ptracer(i,j,ks,bi,bj,iNH4)*dvol
         tileFSN(bi,bj)=tileFSN(bi,bj)+Ptracer(i,j,ks,bi,bj,iNO2)*dvol
         tileFSN(bi,bj)=tileFSN(bi,bj)+Ptracer(i,j,ks,bi,bj,iDON)*dvol
         tileFSN(bi,bj)=tileFSN(bi,bj)+Ptracer(i,j,ks,bi,bj,iPON)*dvol
         DO np=1,nplank
#ifdef DARWIN_ALLOW_NQUOTA
          iTr=in+np-1
          tileFSN(bi,bj)=tileFSN(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)*dvol
#else
          iTr=ic+np-1
          tileFSN(bi,bj)=tileFSN(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)
     &                                 *R_NC(np)*dvol
#endif
         ENDDO
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
         tileFSN(bi,bj)=tileFSN(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                *R_NC_CDOM*dvol
# else
         tileFSN(bi,bj)=tileFSN(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                *R_NP_CDOM*dvol
# endif
#endif

C Phosphorus imp.FS corrections
         tileFSP(bi,bj)=tileFSP(bi,bj)+Ptracer(i,j,ks,bi,bj,iPO4)*dvol
         tileFSP(bi,bj)=tileFSP(bi,bj)+Ptracer(i,j,ks,bi,bj,iDOP)*dvol
         tileFSP(bi,bj)=tileFSP(bi,bj)+Ptracer(i,j,ks,bi,bj,iPOP)*dvol
         DO np=1,nplank
#ifdef DARWIN_ALLOW_PQUOTA
          iTr=ip+np-1
          tileFSP(bi,bj)=tileFSP(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)*dvol
#else
          iTr=ic+np-1
          tileFSP(bi,bj)=tileFSP(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)
     &                                 *R_PC(np)*dvol
#endif
         ENDDO
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
         tileFSP(bi,bj)=tileFSP(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                *R_PC_CDOM*dvol
# else
         tileFSP(bi,bj)=tileFSP(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                *dvol
# endif
#endif

C Iron imp.FS corrections
         tileFSFe(bi,bj)=tileFSFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iFeT)
     &                                  *dvol
         tileFSFe(bi,bj)=tileFSFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iDOFe)
     &                                  *dvol
         tileFSFe(bi,bj)=tileFSFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iPOFe)
     &                                  *dvol
         DO np=1,nplank
#ifdef DARWIN_ALLOW_FEQUOTA
          iTr=ife+np-1
          tileFSFe(bi,bj)=tileFSFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)
     &                                   *dvol
#else
          iTr=ic+np-1
          tileFSFe(bi,bj)=tileFSFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)
     &                                   *R_FeC(np)*dvol
#endif
         ENDDO
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
         tileFSFe(bi,bj)=tileFSFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                  *R_FeC_CDOM*dvol
# else
         tileFSFe(bi,bj)=tileFSFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                  *R_FeP_CDOM*dvol
# endif
#endif

C Silica imp.FS corrections
         tileFSSi(bi,bj)=tileFSSi(bi,bj)+Ptracer(i,j,ks,bi,bj,iSiO2)
     &                                  *dvol
         tileFSSi(bi,bj)=tileFSSi(bi,bj)+Ptracer(i,j,ks,bi,bj,iPOSi)
     &                                  *dvol
         DO np=1,nplank
#ifdef DARWIN_ALLOW_SIQUOTA
          iTr=isi+np-1
          tileFSSi(bi,bj)=tileFSSi(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)
     &                                   *dvol
#else
          iTr=ic+np-1
          tileFSSi(bi,bj)=tileFSSi(bi,bj)+Ptracer(i,j,ks,bi,bj,iTr)
     &                                     *R_SiC(np)*dvol
#endif
         ENDDO

C Alkalinity and oxygen imp.FS corrections
#ifdef DARWIN_ALLOW_CARBON
         tileFSA(bi,bj)=tileFSA(bi,bj)+Ptracer(i,j,ks,bi,bj,iALK)*dvol
         tileFSO(bi,bj)=tileFSO(bi,bj)+Ptracer(i,j,ks,bi,bj,iO2)*dvol
#endif

C       endif stage 0, implicitFreeSurface, etc
        ENDIF

C ======================================================================
C Compute surface flux from EmPmR with local ptracer concentration
C before thermodynamics; will store totals in common block and apply
C after thermodynamics.
C Case 1: Non-linear free surface with real fresh-water flux
#ifdef EXACT_CONSERV
        IF (stage.EQ.0 .AND. (nonlinFreeSurf.GT.0 .OR. usingPCoords)
     &      .AND. useRealFreshWaterFlux) THEN
         dvol = PmEpR(i,j,bi,bj)*mass2rUnit*area*PTRACERS_dtLev(ks)
         tilePER(bi,bj) = tilePER(bi,bj) + dvol
C Carbon E-P-R fluxes
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
         IF (PTRACERS_EvPrRn(iCDOM).EQ.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
          tileEPRC(bi,bj)=tileEPRC(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *dvol
# else
          tileEPRC(bi,bj)=tileEPRC(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *R_CP_CDOM*dvol
# endif
         ENDIF
#endif

C Nitrogen E-P-R fluxes
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
         IF (PTRACERS_EvPrRn(iCDOM).EQ.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
          tileEPRN(bi,bj)=tileEPRN(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *R_NC_CDOM*dvol
# else
          tileEPRN(bi,bj)=tileEPRN(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *R_NP_CDOM*dvol
# endif
         ENDIF
#endif

C Phosphorus E-P-R fluxes
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
         IF (PTRACERS_EvPrRn(iCDOM).EQ.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
          tileEPRP(bi,bj)=tileEPRP(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *R_PC_CDOM*dvol
# else
          tileEPRP(bi,bj)=tileEPRP(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *dvol
# endif
         ENDIF
#endif

C Iron E-P-R fluxes
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
         IF (PTRACERS_EvPrRn(iCDOM).EQ.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
          tileEPRFe(bi,bj)=tileEPRFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                     *R_FeC_CDOM*dvol
# else
          tileEPRFe(bi,bj)=tileEPRFe(bi,bj)+Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                     *R_FeP_CDOM*dvol
# endif
         ENDIF
#endif

C Silica E-P-R fluxes
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

C Alkalinity and oxygen E-P-R fluxes
#ifdef DARWIN_ALLOW_CARBON
         IF (PTRACERS_EvPrRn(iALK).EQ.UNSET_RL)
     &   tileEPRA(bi,bj)=tileEPRA(bi,bj)+Ptracer(i,j,ks,bi,bj,iALK)*dvol
         IF (PTRACERS_EvPrRn(iO2).EQ.UNSET_RL)
     &   tileEPRO(bi,bj)=tileEPRO(bi,bj)+Ptracer(i,j,ks,bi,bj,iO2)*dvol
#endif

C       endif stage 0, etc
        ENDIF
#endif /* EXACT_CONSERV */

C ======================================================================
C Compute surface flux from EmPmR with local ptracer concentration
C before thermodynamics; will store totals in common block and apply
C after thermodynamics.
C Case 2: linear implicit free surface or no real fresh-water flux
        IF (stage.EQ.0) THEN
C minic conditionals in PTRACERS_FORCING_SURF
#ifdef EXACT_CONSERV
        IF ( .NOT.((nonlinFreeSurf.GT.0 .OR. usingPCoords)
     &             .AND. useRealFreshWaterFlux) ) THEN
#else /* EXACT_CONSERV */
        IF (.TRUE.) THEN
#endif /* EXACT_CONSERV */
        dvol = -EmPmR(i,j,bi,bj)*mass2rUnit*area*PTRACERS_dtLev(ks)
        tilePER(bi,bj) = tilePER(bi,bj) + dvol
C       if convertFW2Salt=-1., current values are replaced by
C       ptracers_EvPrRn, so Ptracer enters with a minus sign.
        IF (convertFW2Salt .EQ. -1.) THEN
C Carbon E-P-R fluxes
         IF (PTRACERS_EvPrRn(iDIC).NE.UNSET_RL)
     &   tileEPRC(bi,bj)=tileEPRC(bi,bj)-Ptracer(i,j,ks,bi,bj,iDIC)*dvol
         IF (PTRACERS_EvPrRn(iDOC).NE.UNSET_RL)
     &   tileEPRC(bi,bj)=tileEPRC(bi,bj)-Ptracer(i,j,ks,bi,bj,iDOC)*dvol
         IF (PTRACERS_EvPrRn(iPOC).NE.UNSET_RL)
     &   tileEPRC(bi,bj)=tileEPRC(bi,bj)-Ptracer(i,j,ks,bi,bj,iPOC)*dvol
         IF (PTRACERS_EvPrRn(iPIC).NE.UNSET_RL)
     &   tileEPRC(bi,bj)=tileEPRC(bi,bj)-Ptracer(i,j,ks,bi,bj,iPIC)*dvol
         DO np=1,nplank
          iTr=ic+np-1
          IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL)
     &     tileEPRC(bi,bj)=tileEPRC(bi,bj)-Ptracer(i,j,ks,bi,bj,iTr)
     &                                    *(1+R_PICPOC(np))*dvol
         ENDDO
#ifdef DARWIN_ALLOW_CDOM
         IF (PTRACERS_EvPrRn(iCDOM).NE.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
          tileEPRC(bi,bj)=tileEPRC(bi,bj)-Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *dvol
# else
          tileEPRC(bi,bj)=tileEPRC(bi,bj)-Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *R_CP_CDOM*dvol
# endif
         ENDIF
#endif

C Nitrogen E-P-R fluxes
         IF (PTRACERS_EvPrRn(iNO3).NE.UNSET_RL)
     &   tileEPRN(bi,bj)=tileEPRN(bi,bj)-Ptracer(i,j,ks,bi,bj,iNO3)*dvol
         IF (PTRACERS_EvPrRn(iNH4).NE.UNSET_RL)
     &   tileEPRN(bi,bj)=tileEPRN(bi,bj)-Ptracer(i,j,ks,bi,bj,iNH4)*dvol
         IF (PTRACERS_EvPrRn(iNO2).NE.UNSET_RL)
     &   tileEPRN(bi,bj)=tileEPRN(bi,bj)-Ptracer(i,j,ks,bi,bj,iNO2)*dvol
         IF (PTRACERS_EvPrRn(iDON).NE.UNSET_RL)
     &   tileEPRN(bi,bj)=tileEPRN(bi,bj)-Ptracer(i,j,ks,bi,bj,iDON)*dvol
         IF (PTRACERS_EvPrRn(iPON).NE.UNSET_RL)
     &   tileEPRN(bi,bj)=tileEPRN(bi,bj)-Ptracer(i,j,ks,bi,bj,iPON)*dvol
         DO np=1,nplank
#ifdef DARWIN_ALLOW_NQUOTA
          iTr=in+np-1
          IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL)
     &    tileEPRN(bi,bj)=tileEPRN(bi,bj)-Ptracer(i,j,ks,bi,bj,iTr)*dvol
#else
          iTr=ic+np-1
          IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL)
     &     tileEPRN(bi,bj)=tileEPRN(bi,bj)-Ptracer(i,j,ks,bi,bj,iTr)
     &                                    *R_NC(np)*dvol
#endif
         ENDDO
#ifdef DARWIN_ALLOW_CDOM
         IF (PTRACERS_EvPrRn(iCDOM).NE.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
          tileEPRN(bi,bj)=tileEPRN(bi,bj)-Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *R_NC_CDOM*dvol
# else
          tileEPRN(bi,bj)=tileEPRN(bi,bj)-Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *R_NP_CDOM*dvol
# endif
         ENDIF
#endif

C Phosphorus E-P-R fluxes
         IF (PTRACERS_EvPrRn(iPO4).NE.UNSET_RL)
     &   tileEPRP(bi,bj)=tileEPRP(bi,bj)-Ptracer(i,j,ks,bi,bj,iPO4)*dvol
         IF (PTRACERS_EvPrRn(iDOP).NE.UNSET_RL)
     &   tileEPRP(bi,bj)=tileEPRP(bi,bj)-Ptracer(i,j,ks,bi,bj,iDOP)*dvol
         IF (PTRACERS_EvPrRn(iPOP).NE.UNSET_RL)
     &   tileEPRP(bi,bj)=tileEPRP(bi,bj)-Ptracer(i,j,ks,bi,bj,iPOP)*dvol
         DO np=1,nplank
#ifdef DARWIN_ALLOW_PQUOTA
          iTr=ip+np-1
          IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL)
     &    tileEPRP(bi,bj)=tileEPRP(bi,bj)-Ptracer(i,j,ks,bi,bj,iTr)*dvol
#else
          iTr=ic+np-1
          IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL)
     &     tileEPRP(bi,bj)=tileEPRP(bi,bj)-Ptracer(i,j,ks,bi,bj,iTr)
     &                                    *R_PC(np)*dvol
#endif
         ENDDO
#ifdef DARWIN_ALLOW_CDOM
         IF (PTRACERS_EvPrRn(iCDOM).NE.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
          tileEPRP(bi,bj)=tileEPRP(bi,bj)-Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *R_PC_CDOM*dvol
# else
          tileEPRP(bi,bj)=tileEPRP(bi,bj)-Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                   *dvol
# endif
         ENDIF
#endif

C Iron E-P-R fluxes
         IF (PTRACERS_EvPrRn(iFeT).NE.UNSET_RL)
     &   tileEPRFe(bi,bj)=tileEPRFe(bi,bj)-Ptracer(i,j,ks,bi,bj,iFeT)
     &                                    *dvol
         IF (PTRACERS_EvPrRn(iDOFe).NE.UNSET_RL)
     &   tileEPRFe(bi,bj)=tileEPRFe(bi,bj)-Ptracer(i,j,ks,bi,bj,iDOFe)
     &                                    *dvol
         IF (PTRACERS_EvPrRn(iPOFe).NE.UNSET_RL)
     &   tileEPRFe(bi,bj)=tileEPRFe(bi,bj)-Ptracer(i,j,ks,bi,bj,iPOFe)
     &                                    *dvol
         DO np=1,nplank
#ifdef DARWIN_ALLOW_FEQUOTA
          iTr=ife+np-1
          IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL)
     &     tileEPRFe(bi,bj)=tileEPRFe(bi,bj)-Ptracer(i,j,ks,bi,bj,iTr)
     &                                      *dvol
#else
          iTr=ic+np-1
          IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL)
     &     tileEPRFe(bi,bj)=tileEPRFe(bi,bj)-Ptracer(i,j,ks,bi,bj,iTr)
     &                                      *R_FeC(np)*dvol
#endif
         ENDDO
#ifdef DARWIN_ALLOW_CDOM
         IF (PTRACERS_EvPrRn(iCDOM).NE.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
          tileEPRFe(bi,bj)=tileEPRFe(bi,bj)-Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                     *R_FeC_CDOM*dvol
# else
          tileEPRFe(bi,bj)=tileEPRFe(bi,bj)-Ptracer(i,j,ks,bi,bj,iCDOM)
     &                                     *R_FeP_CDOM*dvol
# endif
         ENDIF
#endif

C Silica E-P-R fluxes
         IF (PTRACERS_EvPrRn(iSiO2).NE.UNSET_RL)
     &    tileEPRSi(bi,bj)=tileEPRSi(bi,bj)-Ptracer(i,j,ks,bi,bj,iSiO2)
     &                                     *dvol
         IF (PTRACERS_EvPrRn(iPOSi).NE.UNSET_RL)
     &    tileEPRSi(bi,bj)=tileEPRSi(bi,bj)-Ptracer(i,j,ks,bi,bj,iPOSi)
     &                                     *dvol
         DO np=1,nplank
#ifdef DARWIN_ALLOW_SIQUOTA
          iTr=isi+np-1
          IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL)
     &     tileEPRSi(bi,bj)=tileEPRSi(bi,bj)-Ptracer(i,j,ks,bi,bj,iTr)
     &                                      *dvol
#else
          iTr=ic+np-1
          IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL)
     &     tileEPRSi(bi,bj)=tileEPRSi(bi,bj)-Ptracer(i,j,ks,bi,bj,iTr)
     &                                      *R_SiC(np)*dvol
#endif
         ENDDO

C Alkalinity and oxygen E-P-R fluxes
#ifdef DARWIN_ALLOW_CARBON
         IF (PTRACERS_EvPrRn(iALK).NE.UNSET_RL)
     &   tileEPRA(bi,bj)=tileEPRA(bi,bj)-Ptracer(i,j,ks,bi,bj,iALK)*dvol
         IF (PTRACERS_EvPrRn(iO2).NE.UNSET_RL)
     &   tileEPRO(bi,bj)=tileEPRO(bi,bj)-Ptracer(i,j,ks,bi,bj,iO2)*dvol
#endif
C       endif convertFW2Salt
        ENDIF
C       endif NLFS, etc
        ENDIF
C       endif stage 0 and implicitFreeSurface
        ENDIF

C      enddo i,j
       ENDDO
       ENDDO

C     enddo bi,bj
      ENDDO
      ENDDO

C ======================================================================
C Combine per-tile sums

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
       CALL GLOBAL_SUM_TILE_RL(tileventflxFe,tmpventflxFe,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilesfcflxC,tmpsfcflxC,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilevirflxC,tmpvirflxC,myThid)
#ifdef DARWIN_ALLOW_CARBON
       CALL GLOBAL_SUM_TILE_RL(tileAlkSrc,tmpAlkSrc,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileO2prod,tmpO2prod,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileO2cons,tmpO2cons,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilesfcflxO,tmpsfcflxO,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilevirflxA,tmpvirflxA,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilesedflxC,tmpsedflxC,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilesedflxA,tmpsedflxA,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilesedflxO,tmpsedflxO,myThid)
#endif
#ifdef DARWIN_BOTTOM_SINK
       CALL GLOBAL_SUM_TILE_RL(tileBotSnkC,tmpBotSnkC,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileBotSnkN,tmpBotSnkN,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileBotSnkP,tmpBotSnkP,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileBotSnkFe,tmpBotSnkFe,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileBotSnkSi,tmpBotSnkSi,myThid)
#endif
C store totals in common block to retrieve at stage 1
       CALL GLOBAL_SUM_TILE_RL(tileFSC,totFSC,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileFSN,totFSN,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileFSP,totFSP,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileFSFe,totFSFe,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileFSSi,totFSSi,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilePER,totPER,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileEPRC,totEPRC,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileEPRN,totEPRN,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileEPRP,totEPRP,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileEPRFe,totEPRFe,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileEPRSi,totEPRSi,myThid)
#ifdef DARWIN_ALLOW_CARBON
       CALL GLOBAL_SUM_TILE_RL(tileFSA,totFSA,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileFSO,totFSO,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileEPRA,totEPRA,myThid)
       CALL GLOBAL_SUM_TILE_RL(tileEPRO,totEPRO,myThid)
#endif
      ELSEIF (stage .EQ. 2) THEN
       CALL GLOBAL_SUM_TILE_RL(tilesfcflxFe,tmpsfcflxFe,myThid)
#ifdef DARWIN_NUTRIENT_RUNOFF
       CALL GLOBAL_SUM_TILE_RL(tilerunoffC,tmprunoffC,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilerunoffN,tmprunoffN,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilerunoffP,tmprunoffP,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilerunoffFe,tmprunoffFe,myThid)
       CALL GLOBAL_SUM_TILE_RL(tilerunoffSi,tmprunoffSi,myThid)
# ifdef DARWIN_ALLOW_CARBON
       CALL GLOBAL_SUM_TILE_RL(tilerunoffA,tmprunoffA,myThid)
# endif
#endif
      ENDIF

C ======================================================================
C Retrieve totals from stage 0 for lin.FS and E-P-R
      IF ( stage .EQ. 1 ) THEN

       tmpFSC = totFSC
       tmpFSN = totFSN
       tmpFSP = totFSP
       tmpFSFe = totFSFe
       tmpFSSi = totFSSi
# ifdef DARWIN_ALLOW_CARBON
       tmpFSA = totFSA
       tmpFSO = totFSO
# endif

       tmpEPRC = totEPRC
       tmpEPRN = totEPRN
       tmpEPRP = totEPRP
       tmpEPRFe = totEPRFe
       tmpEPRSi = totEPRSi
# ifdef DARWIN_ALLOW_CARBON
       tmpEPRA = totEPRA
       tmpEPRO = totEPRO
# endif

C ----------------------------------------------------------------------
C convertFW2Salt!=-1 uses PTRACERS_ref instead of Ptracer, subtract here

       IF (convertFW2Salt .NE. -1) THEN
C Carbon E-P-R fluxes
        IF (PTRACERS_EvPrRn(iDIC).NE.UNSET_RL)
     &   tmpEPRC = tmpEPRC - PTRACERS_ref(ks,iDIC)*totPER
        IF (PTRACERS_EvPrRn(iDOC).NE.UNSET_RL)
     &   tmpEPRC = tmpEPRC - PTRACERS_ref(ks,iDOC)*totPER
        IF (PTRACERS_EvPrRn(iPOC).NE.UNSET_RL)
     &   tmpEPRC = tmpEPRC - PTRACERS_ref(ks,iPOC)*totPER
        IF (PTRACERS_EvPrRn(iPIC).NE.UNSET_RL)
     &   tmpEPRC = tmpEPRC - PTRACERS_ref(ks,iPIC)*totPER
        DO np=1,nplank
         iTr=ic+np-1
         IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL)
     &    tmpEPRC = tmpEPRC+PTRACERS_EvPrRn(iTr)*(1+R_PICPOC(np))*totPER
        ENDDO
#ifdef DARWIN_ALLOW_CDOM
        IF (PTRACERS_EvPrRn(iCDOM).NE.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
         tmpEPRC = tmpEPRC + PTRACERS_ref(ks,iCDOM)*totPER
# else
         tmpEPRC = tmpEPRC + PTRACERS_ref(ks,iCDOM)*R_CP_CDOM*totPER
# endif
        ENDIF
#endif

C Nitrogen E-P-R fluxes
        IF (PTRACERS_EvPrRn(iNO3).NE.UNSET_RL)
     &   tmpEPRN = tmpEPRN - PTRACERS_ref(ks,iNO3)*totPER
        IF (PTRACERS_EvPrRn(iNH4).NE.UNSET_RL)
     &   tmpEPRN = tmpEPRN - PTRACERS_ref(ks,iNH4)*totPER
        IF (PTRACERS_EvPrRn(iNO2).NE.UNSET_RL)
     &   tmpEPRN = tmpEPRN - PTRACERS_ref(ks,iNO2)*totPER
        IF (PTRACERS_EvPrRn(iDON).NE.UNSET_RL)
     &   tmpEPRN = tmpEPRN - PTRACERS_ref(ks,iDON)*totPER
        IF (PTRACERS_EvPrRn(iPON).NE.UNSET_RL)
     &   tmpEPRN = tmpEPRN - PTRACERS_ref(ks,iPON)*totPER
        DO np=1,nplank
         IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL) THEN
#ifdef DARWIN_ALLOW_NQUOTA
          iTr=in+np-1
          tmpEPRN = tmpEPRN - PTRACERS_ref(ks,iTr)*totPER
#else
          iTr=ic+np-1
          tmpEPRN = tmpEPRN - PTRACERS_ref(ks,iTr)*R_NC(np)*totPER
#endif
         ENDIF
        ENDDO
#ifdef DARWIN_ALLOW_CDOM
        IF (PTRACERS_EvPrRn(iCDOM).NE.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
         tmpEPRN = tmpEPRN - PTRACERS_ref(ks,iCDOM)*totPER
# else
         tmpEPRN = tmpEPRN - PTRACERS_ref(ks,iCDOM)*R_NP_CDOM*totPER
# endif
        ENDIF
#endif

C Phosphorus E-P-R fluxes
        IF (PTRACERS_EvPrRn(iPO4).NE.UNSET_RL)
     &   tmpEPRP = tmpEPRP - PTRACERS_ref(ks,iPO4)*totPER
        IF (PTRACERS_EvPrRn(iDOP).NE.UNSET_RL)
     &   tmpEPRP = tmpEPRP - PTRACERS_ref(ks,iDOP)*totPER
        IF (PTRACERS_EvPrRn(iPOP).NE.UNSET_RL)
     &   tmpEPRP = tmpEPRP - PTRACERS_ref(ks,iPOP)*totPER
        DO np=1,nplank
         IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL) THEN
#ifdef DARWIN_ALLOW_PQUOTA
          iTr=ip+np-1
          tmpEPRP = tmpEPRP - PTRACERS_ref(ks,iTr)*totPER
#else
          iTr=ic+np-1
          tmpEPRP = tmpEPRP - PTRACERS_ref(ks,iTr)*R_PC(np)*totPER
#endif
         ENDIF
        ENDDO
#ifdef DARWIN_ALLOW_CDOM
        IF (PTRACERS_EvPrRn(iCDOM).NE.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
         tmpEPRP = tmpEPRP - PTRACERS_ref(ks,iCDOM)*R_PC_CDOM*totPER
# else
         tmpEPRP = tmpEPRP - PTRACERS_ref(ks,iCDOM)*totPER
# endif
        ENDIF
#endif

C Iron E-P-R fluxes
        IF (PTRACERS_EvPrRn(iFeT).NE.UNSET_RL)
     &   tmpEPRFe = tmpEPRFe - PTRACERS_ref(ks,iFeT)*totPER
        IF (PTRACERS_EvPrRn(iDOFe).NE.UNSET_RL)
     &   tmpEPRFe = tmpEPRFe - PTRACERS_ref(ks,iDOFe)*totPER
        IF (PTRACERS_EvPrRn(iPOFe).NE.UNSET_RL)
     &   tmpEPRFe = tmpEPRFe - PTRACERS_ref(ks,iPOFe)*totPER
        DO np=1,nplank
         IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL) THEN
#ifdef DARWIN_ALLOW_FEQUOTA
          iTr=ife+np-1
          tmpEPRFe = tmpEPRFe - PTRACERS_ref(ks,iTr)*totPER
#else
          iTr=ic+np-1
          tmpEPRFe = tmpEPRFe - PTRACERS_ref(ks,iTr)*R_FeC(np)*totPER
#endif
         ENDIF
        ENDDO
#ifdef DARWIN_ALLOW_CDOM
        IF (PTRACERS_EvPrRn(iCDOM).NE.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
         tmpEPRFe = tmpEPRFe - PTRACERS_ref(ks,iCDOM)*R_FeC_CDOM*totPER
# else
         tmpEPRFe = tmpEPRFe - PTRACERS_ref(ks,iCDOM)*R_FeP_CDOM*totPER
# endif
        ENDIF
#endif

C Silica E-P-R fluxes
        IF (PTRACERS_EvPrRn(iSiO2).NE.UNSET_RL)
     &   tmpEPRSi = tmpEPRSi - PTRACERS_ref(ks,iSiO2)*totPER
        IF (PTRACERS_EvPrRn(iPOSi).NE.UNSET_RL)
     &   tmpEPRSi = tmpEPRSi - PTRACERS_ref(ks,iPOSi)*totPER
        DO np=1,nplank
         IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL) THEN
#ifdef DARWIN_ALLOW_SIQUOTA
          iTr=isi+np-1
          tmpEPRSi = tmpEPRSi - PTRACERS_ref(ks,iTr)*totPER
#else
          iTr=ic+np-1
          tmpEPRSi = tmpEPRSi - PTRACERS_ref(ks,iTr)*R_SiC(np)*totPER
#endif
         ENDIF
        ENDDO

C Alkalinity and oxygen E-P-R fluxes
#ifdef DARWIN_ALLOW_CARBON
        IF (PTRACERS_EvPrRn(iALK).NE.UNSET_RL)
     &   tmpEPRA = tmpEPRA - PTRACERS_ref(ks,iALK)*totPER
        IF (PTRACERS_EvPrRn(iO2).NE.UNSET_RL)
     &   tmpEPRO = tmpEPRO - PTRACERS_ref(ks,iO2)*totPER
#endif
       ENDIF

C ----------------------------------------------------------------------
C Add EvPrRn for all cases

C Carbon E-P-R fluxes
        IF (PTRACERS_EvPrRn(iDIC).NE.UNSET_RL)
     &   tmpEPRC = tmpEPRC + PTRACERS_EvPrRn(iDIC)*totPER
        IF (PTRACERS_EvPrRn(iDOC).NE.UNSET_RL)
     &   tmpEPRC = tmpEPRC + PTRACERS_EvPrRn(iDOC)*totPER
        IF (PTRACERS_EvPrRn(iPOC).NE.UNSET_RL)
     &   tmpEPRC = tmpEPRC + PTRACERS_EvPrRn(iPOC)*totPER
        IF (PTRACERS_EvPrRn(iPIC).NE.UNSET_RL)
     &   tmpEPRC = tmpEPRC + PTRACERS_EvPrRn(iPIC)*totPER
        DO np=1,nplank
         iTr=ic+np-1
         IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL)
     &    tmpEPRC = tmpEPRC+PTRACERS_EvPrRn(iTr)*(1+R_PICPOC(np))*totPER
        ENDDO
#ifdef DARWIN_ALLOW_CDOM
        IF (PTRACERS_EvPrRn(iCDOM).NE.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
         tmpEPRC = tmpEPRC + PTRACERS_EvPrRn(iCDOM)*totPER
# else
         tmpEPRC = tmpEPRC + PTRACERS_EvPrRn(iCDOM)*R_CP_CDOM*totPER
# endif
        ENDIF
#endif

C Nitrogen E-P-R fluxes
        IF (PTRACERS_EvPrRn(iNO3).NE.UNSET_RL)
     &   tmpEPRN = tmpEPRN + PTRACERS_EvPrRn(iNO3)*totPER
        IF (PTRACERS_EvPrRn(iNH4).NE.UNSET_RL)
     &   tmpEPRN = tmpEPRN + PTRACERS_EvPrRn(iNH4)*totPER
        IF (PTRACERS_EvPrRn(iNO2).NE.UNSET_RL)
     &   tmpEPRN = tmpEPRN + PTRACERS_EvPrRn(iNO2)*totPER
        IF (PTRACERS_EvPrRn(iDON).NE.UNSET_RL)
     &   tmpEPRN = tmpEPRN + PTRACERS_EvPrRn(iDON)*totPER
        IF (PTRACERS_EvPrRn(iPON).NE.UNSET_RL)
     &   tmpEPRN = tmpEPRN + PTRACERS_EvPrRn(iPON)*totPER
        DO np=1,nplank
         IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL) THEN
#ifdef DARWIN_ALLOW_NQUOTA
          iTr=in+np-1
          tmpEPRN = tmpEPRN + PTRACERS_EvPrRn(iTr)*totPER
#else
          iTr=ic+np-1
          tmpEPRN = tmpEPRN + PTRACERS_EvPrRn(iTr)*R_NC(np)*totPER
#endif
         ENDIF
        ENDDO
#ifdef DARWIN_ALLOW_CDOM
        IF (PTRACERS_EvPrRn(iCDOM).NE.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
         tmpEPRN = tmpEPRN + PTRACERS_EvPrRn(iCDOM)*totPER
# else
         tmpEPRN = tmpEPRN + PTRACERS_EvPrRn(iCDOM)*R_NP_CDOM*totPER
# endif
        ENDIF
#endif

C Phosphorus E-P-R fluxes
        IF (PTRACERS_EvPrRn(iPO4).NE.UNSET_RL)
     &   tmpEPRP = tmpEPRP + PTRACERS_EvPrRn(iPO4)*totPER
        IF (PTRACERS_EvPrRn(iDOP).NE.UNSET_RL)
     &   tmpEPRP = tmpEPRP + PTRACERS_EvPrRn(iDOP)*totPER
        IF (PTRACERS_EvPrRn(iPOP).NE.UNSET_RL)
     &   tmpEPRP = tmpEPRP + PTRACERS_EvPrRn(iPOP)*totPER
        DO np=1,nplank
         IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL) THEN
#ifdef DARWIN_ALLOW_PQUOTA
          iTr=ip+np-1
          tmpEPRP = tmpEPRP + PTRACERS_EvPrRn(iTr)*totPER
#else
          iTr=ic+np-1
          tmpEPRP = tmpEPRP + PTRACERS_EvPrRn(iTr)*R_PC(np)*totPER
#endif
         ENDIF
        ENDDO
#ifdef DARWIN_ALLOW_CDOM
        IF (PTRACERS_EvPrRn(iCDOM).NE.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
         tmpEPRP = tmpEPRP + PTRACERS_EvPrRn(iCDOM)*R_PC_CDOM*totPER
# else
         tmpEPRP = tmpEPRP + PTRACERS_EvPrRn(iCDOM)*totPER
# endif
        ENDIF
#endif

C Iron E-P-R fluxes
        IF (PTRACERS_EvPrRn(iFeT).NE.UNSET_RL)
     &   tmpEPRFe = tmpEPRFe + PTRACERS_EvPrRn(iFeT)*totPER
        IF (PTRACERS_EvPrRn(iDOFe).NE.UNSET_RL)
     &   tmpEPRFe = tmpEPRFe + PTRACERS_EvPrRn(iDOFe)*totPER
        IF (PTRACERS_EvPrRn(iPOFe).NE.UNSET_RL)
     &   tmpEPRFe = tmpEPRFe + PTRACERS_EvPrRn(iPOFe)*totPER
        DO np=1,nplank
         IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL) THEN
#ifdef DARWIN_ALLOW_FEQUOTA
          iTr=ife+np-1
          tmpEPRFe = tmpEPRFe + PTRACERS_EvPrRn(iTr)*totPER
#else
          iTr=ic+np-1
          tmpEPRFe = tmpEPRFe + PTRACERS_EvPrRn(iTr)*R_FeC(np)*totPER
#endif
         ENDIF
        ENDDO
#ifdef DARWIN_ALLOW_CDOM
        IF (PTRACERS_EvPrRn(iCDOM).NE.UNSET_RL) THEN
# ifdef DARWIN_CDOM_UNITS_CARBON
         tmpEPRFe = tmpEPRFe + PTRACERS_EvPrRn(iCDOM)*R_FeC_CDOM*totPER
# else
         tmpEPRFe = tmpEPRFe + PTRACERS_EvPrRn(iCDOM)*R_FeP_CDOM*totPER
# endif
        ENDIF
#endif

C Silica E-P-R fluxes
        IF (PTRACERS_EvPrRn(iSiO2).NE.UNSET_RL)
     &   tmpEPRSi = tmpEPRSi + PTRACERS_EvPrRn(iSiO2)*totPER
        IF (PTRACERS_EvPrRn(iPOSi).NE.UNSET_RL)
     &   tmpEPRSi = tmpEPRSi + PTRACERS_EvPrRn(iPOSi)*totPER
        DO np=1,nplank
         IF (PTRACERS_EvPrRn(iTr).NE.UNSET_RL) THEN
#ifdef DARWIN_ALLOW_SIQUOTA
          iTr=isi+np-1
          tmpEPRSi = tmpEPRSi + PTRACERS_EvPrRn(iTr)*totPER
#else
          iTr=ic+np-1
          tmpEPRSi = tmpEPRSi + PTRACERS_EvPrRn(iTr)*R_SiC(np)*totPER
#endif
         ENDIF
        ENDDO

C Alkalinity and oxygen E-P-R fluxes
#ifdef DARWIN_ALLOW_CARBON
        IF (PTRACERS_EvPrRn(iALK).NE.UNSET_RL)
     &   tmpEPRA = tmpEPRA + PTRACERS_EvPrRn(iALK)*totPER
        IF (PTRACERS_EvPrRn(iO2).NE.UNSET_RL)
     &   tmpEPRO = tmpEPRO + PTRACERS_EvPrRn(iO2)*totPER
#endif

C     endif stage 1
      ENDIF

C ======================================================================
C write totals

      IF ( myProcId.EQ.0 .AND. myThid.EQ.1 ) THEN
C do not write ecosystem non-conservation terms before they are applied
        IF ((myIter.EQ.nIter0 .OR.
     &       (staggerTimeStep.AND.myIter.EQ.nIter0+1)) .AND.
     &      stage.EQ.0) THEN
         WRITE(DAR_cons_C_unit,'(A1,A11,A6,A20,8A24)')'#','iter',
     &      'stage','tot','mean','sfcflx','virtflx','botsnk','impFS',
     &      'EPR','runoff','sed'
         WRITE(DAR_cons_N_unit,'(A1,A11,A6,A20,7A24)')'#','iter',
     &      'stage','tot','mean','Nfix','Ndenit','botsnk','impFS','EPR',
     &      'runoff'
         WRITE(DAR_cons_P_unit,'(A1,A11,A6,A20,5A24)')'#','iter',
     &      'stage','tot','mean','botsnk','impFS','EPR','runoff'
         WRITE(DAR_cons_Fe_unit,'(A1,A11,A6,A20,10A24)')'#','iter',
     &      'stage','tot','mean','minFeLoss','scav','sfcflx','sedflx',
     &      'ventflx','botsnk','impFS','EPR','runoff'
         WRITE(DAR_cons_Si_unit,'(A1,A11,A6,A20,5A24)')'#','iter',
     &      'stage','tot','mean','botsnk','impFS','EPR','runoff'

#ifdef DARWIN_ALLOW_CARBON
         WRITE(DAR_cons_A_unit,'(A1,A11,A6,A20,7A24)')'#','iter',
     &      'stage','tot','mean','sfcflx','AlkSrc','impFS','EPR',
     &      'runoff'
     &     ,'sed'
         WRITE(DAR_cons_O_unit,'(A1,A11,A6,A20,7A24)')'#','iter',
     &     'stage','tot','mean','sfcflx','O2prod','O2cons','impFS','EPR'
     &     ,'sed'
#endif
        ENDIF

        WRITE(DAR_cons_C_unit,'(I12,I2,9E24.16)') myIter, stage,
     &     tmptotC, tmptotC/voltot, tmpsfcflxC, tmpvirflxC, -tmpBotSnkC,
     &     tmpFSC, tmpEPRC, tmprunoffC, tmpsedflxC
        WRITE(DAR_cons_N_unit,'(I12,I2,8E24.16)') myIter, stage,
     &     tmptotN, tmptotN/voltot, tmptotNfix, -tmptotNdenit,
     &     -tmpBotSnkN, tmpFSN, tmpEPRN, tmprunoffN
        WRITE(DAR_cons_P_unit,'(I12,I2,6E24.16)') myIter, stage,
     &     tmptotP, tmptotP/voltot, -tmpBotSnkP, tmpFSP,tmpEPRP,
     &     tmprunoffP
        WRITE(DAR_cons_Fe_unit,'(I12,I2,11E24.16)') myIter, stage,
     &     tmptotFe, tmptotFe/voltot, -tmpminFeLoss, -tmptotscavFe,
     &     tmpsfcflxFe, tmpsedflxFe, tmpventflxFe, -tmpBotSnkFe,
     &     tmpFSFe, tmpEPRFe, tmprunoffFe
        WRITE(DAR_cons_Si_unit,'(I12,I2,6E24.16)') myIter, stage,
     &     tmptotSi, tmptotSi/voltot, -tmpBotSnkSi, tmpFSSi, tmpEPRSi,
     &     tmprunoffSi
#ifdef DARWIN_ALLOW_CARBON
        WRITE(DAR_cons_A_unit,'(I12,I2,8E24.16)') myIter, stage,
     &     tmptotA, tmptotA/voltot, tmpvirflxA, tmpAlkSrc, tmpFSA,
     &     tmpEPRA, tmprunoffA, tmpsedflxA
        WRITE(DAR_cons_O_unit,'(I12,I2,8E24.16)') myIter, stage,
     &     tmptotO, tmptotO/voltot, tmpsfcflxO, tmpO2prod, -tmpO2cons,
     &     tmpFSO, tmpEPRO, tmpsedflxO
#endif
      ENDIF

#endif /* DARWIN_ALLOW_CONS */

      RETURN
      END

