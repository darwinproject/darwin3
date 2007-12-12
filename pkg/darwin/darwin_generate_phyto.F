C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_generate_phyto.F,v 1.3 2007/12/12 18:44:28 jahn Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "GCHEM_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

c ==========================================================
c SUBROUTINE DARWIN_GENERATE_PHYTO
c generate parameters for "functional group" of phyto (index np)
c using a "Monte Carlo" approach
c         Mick Follows, Scott Grant Fall/Winter 2005
c         Stephanie Dutkiewicz Spring/Summer 2005
c ==========================================================
        SUBROUTINE DARWIN_GENERATE_PHYTO(myThid, np)

        implicit none
#include "EEPARAMS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
        INTEGER myThid

C     === Functions ===
      _RL DARWIN_RANDOM
      EXTERNAL DARWIN_RANDOM

C     !LOCAL VARIABLES:
C     === Local variables ===
C     msgBuf    - Informational/error meesage buffer
      CHARACTER*(MAX_LEN_MBUF) msgBuf

        _RL RandNo
        _RL growthdays
        _RL mortdays
        _RL pday
        _RL year
        _RL month
        _RL fiveday
        _RL rtime
        _RL standin
        INTEGER np
        INTEGER nz
        INTEGER signvar
CEOP
c
        standin=0.d0

c length of day (seconds)
        pday = 86400.0d0

c each time generate another functional group add one to ngroups
        ngroups = ngroups + 1

c RANDOM NUMBERS
c phyto either "small" (physize(np)=0.0) or "big" (physize(np)=1.0)
c at this point independent of whether diatom or not
        RandNo = darwin_random(myThid)
        if(RandNo .gt. 0.500d0)then
          physize(np) = 1.0d0
        else
          physize(np) = 0.0d0
        end if
c
c phyto either diatoms (diatom=1.0) and use silica or not (diatom=0.0)
c if they are large
        if (physize(np).eq.1.0d0) then
          RandNo = darwin_random(myThid)
          if(RandNo .gt. 0.500d0)then
            diatom(np) = 1.0d0
          else
            diatom(np) = 0.0d0
          end if
        else
           diatom(np) = 0.0d0
        endif
c TEST ...........................................
c       diatom(np) = 0.0d0
c       write(msgBuf,'(A,I4,A)')
c    &     'generate Phyto: np = ',np,' FIXED - no DIAZO'
c       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
c    &                      SQUEEZE_RIGHT , mythid)
c TEST ...........................................



c phyto either diazotrophs (diazotroph=1.0) or not (diazotroph=0.0)
        RandNo = darwin_random(myThid)
        if(RandNo .gt. 0.6700d0)then
          diazotroph(np) = 1.0d0
        else
          diazotroph(np) = 0.0d0
        end if
c TEST ...........................................
#ifndef ALLOW_DIAZ
        diazotroph(np) = 0.0d0
        write(msgBuf,'(A,I4,A)')
     &     'generate Phyto: np = ',np,' FIXED - no DIAZO'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT , mythid)
#endif
c TEST ...........................................


c growth rates
        RandNo = darwin_random(myThid)
c big/small phyto growth rates..
        if(physize(np) .eq. 1.0d0)then
          growthdays = Biggrow +Randno*Biggrowrange
        else
          growthdays = Smallgrow +RandNo*Smallgrowrange
        end if
c but diazotrophs always slower due to energetics
        if(diazotroph(np) .eq. 1.0) then
            growthdays = growthdays * diaz_growfac
        endif 
c now convert to a growth rate
        if (growthdays.gt.0.d0) then
         mu(np) = 1.0d0/(growthdays*pday)
        else
         mu(np) = 0.d0
        endif

c mortality and export fraction rates
        RandNo = darwin_random(myThid)
c big/small phyto mortality rates..
        if(physize(np) .eq. 1.0d0)then
          mortdays = Bigmort +Randno*Bigmortrange
          ExportFracP(np)=Bigexport
        else
          mortdays = Smallmort +RandNo*Smallmortrange
          ExportFracP(np)=Smallexport
        end if
c now convert to a mortality rate
        if (mortdays.gt.0.d0) then
          mortphy(np) = 1.0d0/(mortdays*pday)
        else
          mortphy(np) = 0.d0
        endif



c nutrient source 
         if(diazotroph(np) .ne. 1.0)then
           RandNo = darwin_random(myThid)
           if (physize(np).eq.1.0d0) then   
             nsource(np) = 3
           else
            if(RandNo .gt. 0.670d0)then
              nsource(np) = 1
            elseif(RandNo .lt. 0.33d0)then
              nsource(np) = 2
            else
              nsource(np) = 3
            endif 
           endif
         else
              nsource(np) = 0
         end if 

c..........................................................
c generate phyto Temperature Function parameters  
c.......................................................
        phytoTempCoeff(np) = tempcoeff1
        phytoTempExp1(np) = tempcoeff3
        if(physize(np) .eq. 1.0d0)then
          phytoTempExp2(np) = tempcoeff2_big
        else
          phytoTempExp2(np) = tempcoeff2_small
        endif

        RandNo = darwin_random(myThid)
cswd    phytoTempOptimum(np) = 30.0d0 - RandNo*28.0d0 
        phytoTempOptimum(np) = tempmax - RandNo*temprange
        phytoDecayPower(np) = tempdecay
        
        write(msgBuf,'(A,I4,A,1P1G24.15E3)')
     &     'generate Phyto: np = ',np,' Topt       =',
     &     phytoTempOptimum(np)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT , mythid)

c ...............................................
        write(msgBuf,'(A,I4,A,1P1G24.15E3)')
     &     'generate Phyto: np = ',np,' growthdays =', growthdays
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT , mythid)
c ...............................................

c stoichiometric ratios for each functional group of phyto 
c relative to phosphorus  - the base currency nutrient
c set Si:P
        if(diatom(np) .eq. 1.0)then
          R_SiP(np) =  val_R_SiP_diatom
        else
          R_SiP(np) = 0.0d0
        end if
c set N:P and iron requirement according to diazotroph status
        if(diazotroph(np) .eq. 1.0)then
          R_NP(np) = val_R_NP_diaz
          R_FeP(np) =  val_RFeP_diaz
        else
          R_NP(np) = val_R_NP
          R_FeP(np) = val_RFeP
        end if
c set sinking rates according to allometry
        if(physize(np) .eq. 1.0)then
           wsink(np) = BigSink
        else 
           wsink(np) = SmallSink
        end if 
c half-saturation coeffs 

        RandNo = darwin_random(myThid)
        if(physize(np) .eq. 1.0)then
           ksatPO4(np) = BigPsat + RandNo*BigPsatrange
        else
c          ksatPO4(np) = SmallPsat + RandNo*SmallPsatrange
c          if (nsource(np).lt.3) then
c            ksatPO4(np) = ksatPO4(np)*prochlPsat
c           endif
           if (nsource(np).eq.3.or.nsource(np).eq.0) then
             ksatPO4(np) = SmallPsat + RandNo*SmallPsatrange
           else
             ksatPO4(np) = ProcPsat + RandNo*ProcPsatrange
           endif
        endif
        ksatNO3(np) = ksatPO4(np)*R_NP(np)
        ksatNO2(np) = ksatNO3(np)*ksatNO2fac 
c Made ksatNH4 smaller since it is the preferred source
        ksatNH4(np) = ksatNO3(np)*ksatNH4fac
        ksatFeT(np) = ksatPO4(np)*R_FeP(np)
        ksatSi(np)  = val_ksatsi

cNEW Light parameters:
c     ksatPAR {0.1 - 1.3}
c     0.35=Av High Light Adapted, 0.8=Av Low Light Adapted
c     kinhib  {0.0 - 3.0}
c     0.5 =Av High Light Adapted, 2.0=Av Low Light Adapted
c High Light Groups for Large size:
              if(physize(np) .eq. 1.0d0)then
                 RandNo = darwin_random(myThid)
                 call invnormal(standin,RandNo,Bigksatpar,Bigksatparstd)
                 ksatPAR(np) = abs(standin)

                 RandNo = darwin_random(myThid)
                 CALL invnormal(standin,RandNo,Bigkinhib,Bigkinhibstd)
                 kinhib(np) = abs(standin)
              else
c QQ remove someday
                 RandNo = darwin_random(myThid)
c Low Light Groups for Small size:
                 RandNo = darwin_random(myThid)
                 CALL invnormal(standin,RandNo,smallksatpar,
     &                                               smallksatparstd)
                 ksatPAR(np) = abs(standin)

                 RandNo = darwin_random(myThid)
                 CALL invnormal(standin,RandNo,smallkinhib,
     &                                                smallkinhibstd)
                 kinhib(np) = abs(standin)
              endif
         write(msgBuf,'(A,I4,A,1P1G24.15E3)')
     &     'generate Phyto: np = ',np,' ksatPAR    =', ksatPAR(np)
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT , mythid)
         write(msgBuf,'(A,I4,A,1P1G24.15E3)')
     &     'generate Phyto: np = ',np,' kinhib     =', kinhib(np)
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT , mythid)

#ifndef OLD_GRAZE
c    for zooplankton
c assume zoo(1) = small, zoo(2) = big
         zoosize(1) = 0.0d0
         zoosize(2) = 1.0d0
         grazemax(1) = GrazeFast
         grazemax(2) = GrazeFast
         ExportFracZ(1)=ZooexfacSmall
         ExportFracZ(2)=ZooexfacBig
         mortzoo(1) = ZoomortSmall
         mortzoo(2) = ZoomortBig
         ExportFracGraz(1)=ExGrazFracbig
         ExportFracGraz(2)=ExGrazFracsmall
c
          do nz=1,nzmax
c palatibity according to "allometry"
c big grazers preferentially eat big phyto etc...
           if (zoosize(nz).eq.physize(np)) then
              palat(np,nz)=palathi
              asseff(np,nz)=GrazeEffmod
           else
              palat(np,nz)=palatlo
              if (physize(np).eq.0.d0) then
                asseff(np,nz)=GrazeEffhi
              else
                asseff(np,nz)=GrazeEfflow
              endif
           endif
c diatoms even less palatible
           if (diatom(np).eq.1) then
               palat(np,nz)= palat(np,nz)*diatomgraz
           endif
          enddo
#endif 

        RETURN
        END
#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/

c ===========================================================
