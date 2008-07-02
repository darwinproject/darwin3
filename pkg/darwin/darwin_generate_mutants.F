C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_generate_mutants.F,v 1.3 2008/07/02 19:07:37 jahn Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "GCHEM_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

c ==========================================================
c SUBROUTINE DARWIN_GENERATE_MUTANTS
c generate parameters for "functional group" of phyto (index np)
c using a "Monte Carlo" approach
c         Mick Follows, Scott Grant Fall/Winter 2005
c         Stephanie Dutkiewicz Spring/Summer 2006
c modified to set up mutants
c         Jason Bragg Spring/Summer 2007
c ==========================================================
        SUBROUTINE DARWIN_GENERATE_MUTANTS(myThid, np)

        implicit none
#include "DARWIN_SIZE.h"
#include "DARWIN.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
        INTEGER myThid
CEOP

C     === Functions ===
      _RL DARWIN_RANDOM
      EXTERNAL DARWIN_RANDOM


c local variables
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

c Mutation --------------------------------------------------------
c Scheme to make 'npro' Pro ecotypes, each with 'numtax' sister taxa
c some muatation variables [jbmodif]

        INTEGER nsis  
        INTEGER npro
        INTEGER numtax
        INTEGER taxind         
        INTEGER threeNmut

#ifdef ALLOW_MUTANTS

c initialize mutation variables [jbmodif]
        npro = 60
        threeNmut = 1
        numtax = 4 
        taxind = mod(np,numtax) 

c end mutation ----------------------------------------------------


c
        standin=0.d0

c length of day (seconds)
        pday = 86400.0d0

c each time generate another functional group add one to ngroups
        ngroups = ngroups + 1


c Mutation --------------------------------------------------------
c Generate random variables if 1st sis, or non-Pro [jbmodif]
       if (np .gt. npro .or. taxind .eq. 1.0d0)then


c RANDOM NUMBERS
c phyto either "small" (physize(np)=0.0) or "big" (physize(np)=1.0)
c at this point independent of whether diatom or not

c make Pro small, randomize others [jbmodif]
      if(np.le.npro)physize(np) = 0.0d0
        if(np.gt.npro)then

        RandNo = darwin_random(myThid)
        if(RandNo .gt. 0.000d0)then
          physize(np) = 1.0d0
        else
          physize(np) = 0.0d0
        end if
      endif
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
c       write(6,*)'FIXED - no DIATOM '
c TEST ...........................................



c phyto either diazotrophs (diazotroph=1.0) or not (diazotroph=0.0)
        RandNo = darwin_random(myThid)
        if(RandNo .gt. 0.500d0)then
          diazotroph(np) = 1.0d0
        else
          diazotroph(np) = 0.0d0
        end if
c TEST ...........................................
#ifndef ALLOW_DIAZ
        diazotroph(np) = 0.0d0
        write(6,*)'FIXED - no DIAZO '
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
        mu(np) = 1.0d0/(growthdays*pday)

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
        mortphy(np) = 1.0d0/(mortdays*pday)



c nutrient source 
c if using threeNmut=1, all have nsource=3 [jbmodif]

        if(threeNmut.eq.1)then
            nsource(np)=3
        else 
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
        endif

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
        
        write(6,*)'generate Phyto: np = ',np,' Topt =',
     &    phytoTempOptimum(np)


c ...............................................
        write(6,*)'generate phyto: np = ',np,' growthdays = ',growthdays
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
c make pro ksat if pro [jbmodif]
c           if (nsource(np).eq.3) then 
            if (np .gt. npro)then
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
         write(6,*)'generate Phyto: np = ',np,' ksatPAR, kinhib =',
     &          ksatPAR(np), kinhib(np)

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
         IF ( nzmax.GT.2 ) THEN
           WRITE(msgBuf,'(2A,I5)') 'DARWIN_GENERATE_MUTANTS: ',
     &       'nzmax = ', nzmax
           CALL PRINT_ERROR( msgBuf , 1)
           WRITE(msgBuf,'(2A)') 'DARWIN_GENERATE_MUTANTS: ',
     &       'please provide size info for nz > 2'
           CALL PRINT_ERROR( msgBuf , 1)
           STOP 'ABNORMAL END: S/R DARWIN_GENERATE_MUTANTS'
         ENDIF
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

c end the if a 1st Pro or non-Pro
        endif

c Mutation --------------------------------------------
c make the Pro sister taxa 
c -----------------------------------------------------

      if (np .le. npro .and. taxind .ne. 1)then

c start by making mutants identical to their sister
        if (numtax .eq. 2)then
          if(taxind .eq. 0)nsis = np-1
        endif
  
        if (numtax .eq. 3)then
          if(taxind .eq. 2)nsis = np-1
          if(taxind .eq. 0)nsis = np-2
        endif

        if (numtax .eq. 4)then
          if(taxind .eq. 2)nsis = np-1
          if(taxind .eq. 3)nsis = np-2
          if(taxind .eq. 0)nsis = np-3
        endif


            physize(np) = physize(nsis)
            diatom(np)  = diatom(nsis)
            diazotroph(np) = diazotroph(nsis)
            mu(np) = mu(nsis)
            ExportFracP(np)=ExportFracP(nsis)
            mortphy(np) = mortphy(nsis)
            nsource(np) = nsource(nsis)
            phytoTempCoeff(np) = phytoTempCoeff(nsis)
            phytoTempExp1(np) = phytoTempExp1(nsis)
            phytoTempExp2(np) = phytoTempExp2(nsis)
            phytoTempOptimum(np) = phytoTempOptimum(nsis)
            phytoDecayPower(np) = phytoDecayPower(nsis)
            R_SiP(np) = R_SiP(nsis)
            R_NP(np) = R_NP(nsis)
            R_FeP(np) =  R_FeP(nsis)
            wsink(np) = wsink(nsis)
            ksatPO4(np) = ksatPO4(nsis)
            ksatNO3(np) = ksatNO3(nsis)
            ksatNO2(np) = ksatNO2(nsis) 
            ksatNH4(np) = ksatNH4(nsis)
            ksatFeT(np) = ksatFeT(nsis)
            ksatSi(np)  = ksatSi(nsis)
            ksatPAR(np) = ksatPAR(nsis)
            kinhib(np) = kinhib(nsis)

#ifndef OLD_GRAZE            
            do nz=1,nzmax
              palat(np,nz)=palat(nsis,nz)
              asseff(np,nz)=asseff(nsis,nz)
            enddo       
#endif

c then mutate
c here, make nsource mutants
            if(numtax .eq. 3)then
              if(taxind .eq. 1.0d0) nsource(np) = 3
              if(taxind .eq. 2.0d0) nsource(np) = 2 
              if(taxind .eq. 0.0d0) nsource(np) = 1 
            endif

            if(numtax .eq. 4)then
              if(taxind .eq. 1.0d0) nsource(np) = 3
              if(taxind .eq. 2.0d0) nsource(np) = 2
              if(taxind .eq. 3.0d0) nsource(np) = 1
              if(taxind .eq. 0.0d0) nsource(np) = 3 
            endif


c here, make mu and ksat mutants
c        if(taxind .eq. 2.0d0) mu(np) = mu(np)*1.1 
c        if(taxind .eq. 0.0d0) ksatPO4(np) = ksatPO4(np)*0.95 
      
       endif

#endif


        RETURN
        END
#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/

c ===========================================================
