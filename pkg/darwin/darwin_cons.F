C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_cons.F,v 1.9 2010/05/04 19:36:36 stephd Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

c=============================================================
c subroutine DARWIN_cons
c check conservation in the model
C==============================================================
         SUBROUTINE DARWIN_Cons(
     &                  myIter,myTime,myThid)
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PTRACERS_FIELDS.h"
#include "GCHEM.h"
#include "DARWIN_SIZE.h"
#include "DARWIN.h"
#include "DARWIN_IO.h"
#include "DYNVARS.h"

C     === Global variables ===
       INTEGER myIter
       _RL myTime
       INTEGER myThid

#ifdef CHECK_CONS
C============== Local variables ============================================
       _RL tmptotP
       _RL tmptotN
       _RL tmptotSi
       _RL tmptotFe
#ifdef ALLOW_CARBON
       _RL tmptotC
       _RL tmptotA
       _RL tmptotO
#endif
       _RL vol, voltot

       INTEGER i,j,k,bi,bj
       INTEGER np, nz, npnum


      _BEGIN_MASTER(myThid)
c
         tmptotP=0. _d 0
         tmptotN=0. _d 0
         tmptotFe=0. _d 0
         tmptotSi=0. _d 0
#ifdef ALLOW_CARBON
         tmptotC=0. _d 0
         tmptotA=0. _d 0
         tmptotO=0. _d 0
#endif
         voltot=0. _d 0

        DO bj=myByLo(myThid),myByHi(myThid)
        DO bi=myBxLo(myThid),myBxHi(myThid)
 
         DO i=1,sNx
         DO j=1,sNy
          do k= 1, NR
c-----------------------------------------------------------------
           vol=rA(i,j,bi,bj)*drF(k)
           voltot=voltot+vol
c Phosphorus budget
           tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,iPO4)*vol    !PO4
           tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,iDOP)*vol    !DOP
           tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,iPOP)*vol   !POP
           do nz=1,nzmax
             tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,iZooP(nz))*vol    !ZOO1P
           enddo
           do np=1,npmax
              npnum=iPhy+np-1
              tmptotP=tmptotP+Ptracer(i,j,k,bi,bj,npnum)*vol  !Phy 
           enddo
c Nitrogen budget
           tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iNO3)*vol    !NO3
           tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iNH4)*vol   !NH4
           tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iNO2)*vol   !NO2
           tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iDON)*vol    !DON
           tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iPON)*vol   !PON
           do nz=1,nzmax
             tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,iZooN(nz))*vol    !ZOO1N
           enddo
           do np=1,npmax
              npnum=iPhy+np-1
              tmptotN=tmptotN+Ptracer(i,j,k,bi,bj,npnum)*R_NP(np)*vol  !Phy
           enddo
c Iron budget
           tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,iFeT)*vol    !Fet
           tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,iDOFe)*vol    !DOFe
           tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,iPOFe)*vol   !POFe
           do nz=1,nzmax
             tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,iZooFe(nz))*vol    !ZOO1Fe
           enddo
           do np=1,npmax
              npnum=iPhy+np-1
              tmptotFe=tmptotFe+Ptracer(i,j,k,bi,bj,npnum)*R_FeP(np)*vol  !Phy
           enddo
c Silica budget
           tmptotSi=tmptotSi+Ptracer(i,j,k,bi,bj,iSi)*vol    !Si
           tmptotSi=tmptotSi+Ptracer(i,j,k,bi,bj,iPOSi)*vol   !POSi
           do nz=1,nzmax
             tmptotSi=tmptotSi+Ptracer(i,j,k,bi,bj,iZooSi(nz))*vol    !ZOO1Si
           enddo
           do np=1,npmax
              npnum=iPhy+np-1
              tmptotSi=tmptotSi+Ptracer(i,j,k,bi,bj,npnum)*R_SiP(np)*vol  !Phy
           enddo
c------------------------------------------------------------
#ifdef ALLOW_CARBON
c carbon budget
           tmptotC=tmptotC+Ptracer(i,j,k,bi,bj,iDIC)*vol    !DIC
           tmptotC=tmptotC+Ptracer(i,j,k,bi,bj,iDOC)*vol    !DOC
           tmptotC=tmptotC+Ptracer(i,j,k,bi,bj,iPOC)*vol   !POC
           tmptotC=tmptotC+Ptracer(i,j,k,bi,bj,iPIC)*vol   !PIC
           do nz=1,nzmax
             tmptotC=tmptotC+Ptracer(i,j,k,bi,bj,iZooC(nz))*vol    !ZOOC
           enddo
           do np=1,npmax
              npnum=iPhy+np-1
              tmptotC=tmptotC+Ptracer(i,j,k,bi,bj,npnum)*R_PC(np)*vol  !Phy
           enddo
c alkalinity budget !!!!! NOT FULL BUDGET!!!!!
           tmptotA=tmptotA+Ptracer(i,j,k,bi,bj,iALK)*vol    !ALK
c oxygem budget !!!!!!!! NOT FULL BUDGET !!!!!!!!!!!
           tmptotO=tmptotO+Ptracer(i,j,k,bi,bj,iO2)*vol    !O2
#endif
          enddo
         ENDDO
         ENDDO
        ENDDO
        ENDDO

        _GLOBAL_SUM_RL(tmptotP,myThid)
        _GLOBAL_SUM_RL(tmptotN,myThid)
        _GLOBAL_SUM_RL(tmptotFe,myThid)
        _GLOBAL_SUM_RL(tmptotSi,myThid)
        _GLOBAL_SUM_RL(voltot,myThid)
#ifdef ALLOW_CARBON
        _GLOBAL_SUM_RL(tmptotC,myThid)
        _GLOBAL_SUM_RL(tmptotA,myThid)
        _GLOBAL_SUM_RL(tmptotO,myThid)
#endif


c       print*,'tmptotP',tmptotP
c       print*,'tmptotN',tmptotN
c       print*,'tmptotFe',tmptotFe
c       print*,'tmptotSi',tmptotSi
#ifdef ALLOW_CARBON
c       print*,'tmptotC',tmptotC
c       print*,'tmptotA',tmptotA
c       print*,'tmptotO',tmptotO
#endif

        write(DAR_cons_unit1,*), myIter, tmptotP, tmptotP/voltot
        write(DAR_cons_unit2,*), myIter, tmptotN, tmptotN/voltot
        write(DAR_cons_unit3,*), myIter, tmptotFe, tmptotFe/voltot
        write(DAR_cons_unit4,*), myIter, tmptotSi, tmptotSi/voltot
#ifdef ALLOW_CARBON
        write(DAR_cons_unit5,*), myIter, tmptotC, tmptotC/voltot
        write(DAR_cons_unit6,*), myIter, tmptotA, tmptotA/voltot
        write(DAR_cons_unit7,*), myIter, tmptotO, tmptotO/voltot
#endif

      _END_MASTER(myThid)

C--   Everyone else must wait
      _BARRIER
#endif
c
c -----------------------------------------------------
        RETURN
        END
#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/

C============================================================================
