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
      _RL tmptotC
      _RL tmptotP
      _RL tmptotN
      _RL tmptotSi
      _RL tmptotFe
      _RL tmpsfcflxC
      _RL tmpvirflxC
      _RL tmpsfcflxFe
      _RL tmpsedflxFe
      _RL tmptotNfix
      _RL tmptotNdenit
      _RL tmptotscavFe
      _RL tmpminFeLoss
#ifdef DARWIN_ALLOW_CARBON
      _RL tmptotA
      _RL tmptotO
      _RL tmpsfcflxA
      _RL tmpsfcflxO
#endif
      _RL vol, voltot
      _RL area

      INTEGER i,j,k,bi,bj
      INTEGER np, iTr
c
      tmptotC = 0. _d 0
      tmptotP = 0. _d 0
      tmptotN = 0. _d 0
      tmptotFe = 0. _d 0
      tmptotSi = 0. _d 0
      tmpsfcflxC = 0. _d 0
      tmpvirflxC = 0. _d 0
      tmpsfcflxFe = 0. _d 0
      tmpsedflxFe = 0. _d 0
      tmptotNfix = 0. _d 0
      tmptotNdenit = 0. _d 0
      tmptotscavFe = 0. _d 0
      tmpminFeLoss = 0. _d 0
#ifdef DARWIN_ALLOW_CARBON
      tmptotA = 0. _d 0
      tmptotO = 0. _d 0
      tmpsfcflxA = 0. _d 0
      tmpsfcflxO = 0. _d 0
#endif
      voltot = 0. _d 0

      DO bj=myByLo(myThid),myByHi(myThid)
      DO bi=myBxLo(myThid),myBxHi(myThid)
 
        DO k=1,Nr
        DO i=1,sNx
        DO j=1,sNy
c-----------------------------------------------------------------
          area=rA(i,j,bi,bj)*maskInC(i,j,bi,bj)
          vol=rA(i,j,bi,bj)*drF(k)*hFacC(i,j,k,bi,bj)
          voltot=voltot+vol

c carbon budget
          tmptotC=tmptotC+Ptracer(i,j,k,bi,bj,iDIC)*vol
          tmptotC=tmptotC+Ptracer(i,j,k,bi,bj,iDOC)*vol
          tmptotC=tmptotC+Ptracer(i,j,k,bi,bj,iPOC)*vol
          tmptotC=tmptotC+Ptracer(i,j,k,bi,bj,iPIC)*vol
          DO np=1,nplank
           iTr=ic+np-1
           tmptotC=tmptotC+Ptracer(i,j,k,bi,bj,iTr)*(1+R_PICPOC(np))*vol
          ENDDO
#ifdef DARWIN_ALLOW_CSTORE
          DO np=1,nPhoto
           iTr=ich+np-1
           tmptotC=tmptotC+Ptracer(i,j,k,bi,bj,iTr)*vol
          ENDDO
#endif
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
          tmptotC=tmptotC+Ptracer(i,j,k,bi,bj,iCDOM)*vol
# else
          tmptotC=tmptotC+Ptracer(i,j,k,bi,bj,iCDOM)*R_CP_CDOM*vol
# endif
#endif

c Phosphorus budget
          tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,iPO4)*vol
          tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,iDOP)*vol
          tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,iPOP)*vol
          DO np=1,nplank
#ifdef DARWIN_ALLOW_PQUOTA
            iTr=ip+np-1
            tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,iTr)*vol
#else
            iTr=ic+np-1
            tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,iTr)*R_PC(np)*vol
#endif
          ENDDO
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
          tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,iCDOM)*R_PC_CDOM*vol
# else
          tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,iCDOM)*vol
# endif
#endif

c Nitrogen budget
          tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iNO3)*vol
          tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iNH4)*vol
          tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iNO2)*vol
          tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iDON)*vol
          tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iPON)*vol
          DO np=1,nplank
#ifdef DARWIN_ALLOW_NQUOTA
            iTr=in+np-1
            tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iTr)*vol
#else
            iTr=ic+np-1
            tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iTr)*R_NC(np)*vol
#endif
          ENDDO
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
          tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iCDOM)*R_NC_CDOM*vol
# else
          tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iCDOM)*R_NP_CDOM*vol
# endif
#endif

c Iron budget
          tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,iFeT)*vol
          tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,iDOFe)*vol
          tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,iPOFe)*vol
          DO np=1,nplank
#ifdef DARWIN_ALLOW_FEQUOTA
            iTr=ife+np-1
            tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,iTr)*vol
#else
            iTr=ic+np-1
            tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,iTr)*R_FeC(np)*vol
#endif
          ENDDO
#ifdef DARWIN_ALLOW_CDOM
# ifdef DARWIN_CDOM_UNITS_CARBON
          tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,iCDOM)*R_FeC_CDOM*vol
# else
          tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,iCDOM)*R_FeP_CDOM*vol
# endif
#endif

c Silica budget
          tmptotSi=tmptotSi+Ptracer(i,j,k,bi,bj,iSiO2)*vol
          tmptotSi=tmptotSi+Ptracer(i,j,k,bi,bj,iPOSi)*vol
          DO np=1,nplank
#ifdef DARWIN_ALLOW_SIQUOTA
            iTr=isi+np-1
            tmptotSi=tmptotSi+Ptracer(i,j,k,bi,bj,iTr)*vol
#else
            iTr=ic+np-1
            tmptotSi=tmptotSi+Ptracer(i,j,k,bi,bj,iTr)*R_SiC(np)*vol
#endif
          ENDDO
c------------------------------------------------------------
#ifdef DARWIN_ALLOW_CARBON
c alkalinity budget !!!!! NOT FULL BUDGET!!!!!
          tmptotA=tmptotA+Ptracer(i,j,k,bi,bj,iALK)*vol
c oxygem budget !!!!!!!! NOT FULL BUDGET !!!!!!!!!!!
          tmptotO=tmptotO+Ptracer(i,j,k,bi,bj,iO2)*vol
#endif

          tmptotNfix=tmptotNfix+DARWIN_Nfix(i,j,k,bi,bj)*vol
          tmptotNdenit=tmptotNdenit+DARWIN_Ndenit(i,j,k,bi,bj)*vol
          tmptotscavFe=tmptotScavFe+DARWIN_partScav(i,j,k,bi,bj)*vol
          tmpminFeLoss=tmpminFeLoss+DARWIN_minFeLoss(i,j,k,bi,bj)*vol
        ENDDO
        ENDDO
        ENDDO

        DO i=1,sNx
        DO j=1,sNy
c-----------------------------------------------------------------
          area=rA(i,j,bi,bj)*maskInC(i,j,bi,bj)
          tmpsfcflxFe=tmpsfcflxFe+alpfe*inputfe(i,j,bi,bj)*area
          tmpsedflxFe=tmpsedflxFe+ironSedFlux(i,j,bi,bj)*area
#ifdef DARWIN_ALLOW_CARBON
          tmpsfcflxC=tmpsfcflxC+FluxCO2(i,j,bi,bj)*area
          tmpsfcflxO=tmpsfcflxO+FluxO2(i,j,bi,bj)*area
#ifdef ALLOW_OLD_VIRTUALFLUX
          tmpvirflxC=tmpvirflxC+VFluxCO2(i,j,bi,bj)*area
          tmpsfcflxA=tmpsfcflxA+VFluxAlk(i,j,bi,bj)*area
#endif
#endif
        ENDDO
        ENDDO
      ENDDO
      ENDDO

      _GLOBAL_SUM_RL(tmptotC,myThid)
      _GLOBAL_SUM_RL(tmptotP,myThid)
      _GLOBAL_SUM_RL(tmptotN,myThid)
      _GLOBAL_SUM_RL(tmptotFe,myThid)
      _GLOBAL_SUM_RL(tmptotSi,myThid)
      _GLOBAL_SUM_RL(voltot,myThid)
      _GLOBAL_SUM_RL(tmptotNfix,myThid)
      _GLOBAL_SUM_RL(tmptotNdenit,myThid)
      _GLOBAL_SUM_RL(tmptotscavFe,myThid)
      _GLOBAL_SUM_RL(tmpminFeLoss,myThid)
      _GLOBAL_SUM_RL(tmpsfcflxFe,myThid)
      _GLOBAL_SUM_RL(tmpsedflxFe,myThid)
#ifdef DARWIN_ALLOW_CARBON
      _GLOBAL_SUM_RL(tmptotA,myThid)
      _GLOBAL_SUM_RL(tmptotO,myThid)
      _GLOBAL_SUM_RL(tmpsfcflxC,myThid)
      _GLOBAL_SUM_RL(tmpsfcflxO,myThid)
#ifdef ALLOW_OLD_VIRTUALFLUX
      _GLOBAL_SUM_RL(tmpvirflxC,myThid)
      _GLOBAL_SUM_RL(tmpsfcflxA,myThid)
#endif
#endif

      IF ( myProcId.EQ.0 .AND. myThid.EQ.1 ) THEN
C do not write ecosystem non-conservation terms before they are applied
        IF ( stage .EQ. 0) THEN
         tmpsfcflxC = 0 _d 0
         tmpvirflxC = 0 _d 0
         tmptotNfix = 0 _d 0
         tmptotNdenit = 0 _d 0
         tmpminFeLoss = 0 _d 0
         tmptotscavFe = 0 _d 0
         tmpsfcflxFe = 0 _d 0
         tmpsedflxFe = 0 _d 0
#ifdef DARWIN_ALLOW_CARBON
         tmpsfcflxA = 0 _d 0
         tmpsfcflxO = 0 _d 0
#endif
        ENDIF
        WRITE(DAR_cons_C_unit,'(I12,4E24.16)'), myIter, tmptotC,
     &        tmptotC/voltot, tmpsfcflxC, tmpvirflxC
        WRITE(DAR_cons_P_unit,*), myIter, tmptotP, tmptotP/voltot
        WRITE(DAR_cons_N_unit,'(I12,4E24.16)'), myIter, tmptotN,
     &        tmptotN/voltot, tmptotNfix, -tmptotNdenit
        WRITE(DAR_cons_Fe_unit,'(I12,6E24.16)'), myIter, tmptotFe,
     &        tmptotFe/voltot, -tmpminFeLoss/deltaT, -tmptotscavFe,
     &        tmpsfcflxFe, tmpsedflxFe
        WRITE(DAR_cons_Si_unit,*), myIter, tmptotSi, tmptotSi/voltot
#ifdef DARWIN_ALLOW_CARBON
        WRITE(DAR_cons_A_unit,'(I12,3E24.16)'), myIter, tmptotA,
     &        tmptotA/voltot, tmpsfcflxA
        WRITE(DAR_cons_O_unit,'(I12,3E24.16)'), myIter, tmptotO,
     &        tmptotO/voltot, tmpsfcflxO
#endif
      ENDIF

C--   Everyone else must wait
      _BARRIER

#endif /* DARWIN_ALLOW_CONS */

      RETURN
      END

