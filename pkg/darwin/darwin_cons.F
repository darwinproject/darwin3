C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_cons.F,v 1.5 2008/07/02 19:07:36 jahn Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "GCHEM_OPTIONS.h"

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
       _RL vol, voltot

       INTEGER i,j,k,bi,bj
       INTEGER np, nz, npnum


      _BEGIN_MASTER(myThid)
c
         tmptotP=0. _d 0
         tmptotN=0. _d 0
         tmptotFe=0. _d 0
         tmptotSi=0. _d 0
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
          enddo
         ENDDO
         ENDDO
        ENDDO
        ENDDO

        _GLOBAL_SUM_R8(tmptotP,myThid)
        _GLOBAL_SUM_R8(tmptotN,myThid)
        _GLOBAL_SUM_R8(tmptotFe,myThid)
        _GLOBAL_SUM_R8(tmptotSi,myThid)

        print*,'tmptotP',tmptotP
        print*,'tmptotN',tmptotN
        print*,'tmptotFe',tmptotFe
        print*,'tmptotSi',tmptotSi

        write(DAR_cons_unit1,*), myIter, tmptotP, tmptotP/voltot
        write(DAR_cons_unit2,*), myIter, tmptotN, tmptotN/voltot
        write(DAR_cons_unit3,*), myIter, tmptotFe, tmptotFe/voltot
        write(DAR_cons_unit4,*), myIter, tmptotSi, tmptotSi/voltot

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
