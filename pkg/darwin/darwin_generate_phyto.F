C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_generate_phyto.F,v 1.10 2008/08/26 14:46:10 jahn Exp $
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
c         Anna Hickman Summer 2008
c ==========================================================
        SUBROUTINE DARWIN_GENERATE_PHYTO(myThid, np)

        implicit none
#include "EEPARAMS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN.h"


c ANNA define WAVEBANDS variables
#ifdef WAVEBANDS
#include "WAVEBANDS_PARAMS.h"
#endif



C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
        INTEGER myThid

C     === Functions ===
      _RL DARWIN_RANDOM
      EXTERNAL DARWIN_RANDOM
      _RL DARWIN_RANDOM_NORMAL
      EXTERNAL DARWIN_RANDOM_NORMAL

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
        standin=0. _d 0

c length of day (seconds)
        pday = 86400.0 _d 0

c each time generate another functional group add one to ngroups
        ngroups = ngroups + 1

c RANDOM NUMBERS
c phyto either "small" (physize(np)=0.0) or "big" (physize(np)=1.0)
c at this point independent of whether diatom or not
        RandNo = darwin_random(myThid)
        if(RandNo .gt. 0.500 _d 0)then
          physize(np) = 1.0 _d 0
        else
          physize(np) = 0.0 _d 0
        end if
c
c phyto either diatoms (diatom=1.0) and use silica or not (diatom=0.0)
c if they are large
        if (physize(np).eq.1.0 _d 0) then
          RandNo = darwin_random(myThid)
          if(RandNo .gt. 0.500 _d 0)then
            diatom(np) = 1.0 _d 0
          else
            diatom(np) = 0.0 _d 0
          end if
        else
           diatom(np) = 0.0 _d 0
        endif
c TEST ...........................................
c       diatom(np) = 0.0 _d 0
c       write(msgBuf,'(A,I4,A)')
c    &     'generate Phyto: np = ',np,' FIXED - no DIAZO'
c       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
c    &                      SQUEEZE_RIGHT , mythid)
c TEST ...........................................



c phyto either diazotrophs (diazotroph=1.0) or not (diazotroph=0.0)
        RandNo = darwin_random(myThid)
        if(RandNo .gt. 0.6700 _d 0)then
          diazotroph(np) = 1.0 _d 0
        else
          diazotroph(np) = 0.0 _d 0
        end if
c TEST ...........................................
#ifndef ALLOW_DIAZ
        diazotroph(np) = 0.0 _d 0
        write(msgBuf,'(A,I4,A)')
     &     'generate Phyto: np = ',np,' FIXED - no DIAZO'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT , mythid)
#endif
c TEST ...........................................


c growth rates
        RandNo = darwin_random(myThid)
c big/small phyto growth rates..
        if(physize(np) .eq. 1.0 _d 0)then
          growthdays = Biggrow +Randno*Biggrowrange
        else
          growthdays = Smallgrow +RandNo*Smallgrowrange
        end if
c but diazotrophs always slower due to energetics
        if(diazotroph(np) .eq. 1.0 _d 0) then
            growthdays = growthdays * diaz_growfac
        endif 
c now convert to a growth rate
        if (growthdays.gt.0. _d 0) then
         mu(np) = 1.0 _d 0/(growthdays*pday)
        else
         mu(np) = 0. _d 0
        endif

c mortality and export fraction rates
        RandNo = darwin_random(myThid)
c big/small phyto mortality rates..
        if(physize(np) .eq. 1.0 _d 0)then
          mortdays = Bigmort +Randno*Bigmortrange
          ExportFracP(np)=Bigexport
        else
          mortdays = Smallmort +RandNo*Smallmortrange
          ExportFracP(np)=Smallexport
        end if
c now convert to a mortality rate
        if (mortdays.gt.0. _d 0) then
          mortphy(np) = 1.0 _d 0/(mortdays*pday)
        else
          mortphy(np) = 0. _d 0
        endif



c nutrient source 
         if(diazotroph(np) .ne. 1.0 _d 0)then
           RandNo = darwin_random(myThid)
           if (physize(np).eq.1.0 _d 0) then   
             nsource(np) = 3
           else
             if(RandNo .gt. 0.670 _d 0)then
               nsource(np) = 1
             elseif(RandNo .lt. 0.33 _d 0)then
               nsource(np) = 2
             else
               nsource(np) = 3
             endif
c ANNA shift bias away from pros. Now equal chance of being HL, LL, Syn, Euk.
c ANNA i.e. now 50% chance of being Pro (nsource 1 or 2, with 50% change of each being HL)
c ANNA i.e. and 50% chance of being non-Pro (nsource 3, with 50% chance of non-pro being Syn)
c           if(RandNo .gt. 0.50 _d 0)then
c             nsource(np) = 3
c           elseif(RandNo .lt. 0.25 _d 0)then
c             nsource(np) = 2
c           else
c             nsource(np) = 1
c           endif 
          endif
        else
              nsource(np) = 0
        end if 

c.....................................................
c ANNA make selections for WAVEBANDS 
c.....................................................
#ifdef WAVEBANDS
c for now, choice of four absorption spectra types
c pros get either 'HL' or 'LL'
c small others get 'syn' or 'euk'
c large get 'euk'
c each 'type', once assigned, gets given actual values in wavebands_init_vari.F

c ANNA_Q could use tricho abs and scattering spectra (Subramanian et al. 1999)
c ANNA_Q think diaz is turned off for now
c Diaz will be 0 if not defined, and will have nsource = 0. 
         if (nsource(np).eq.0) then   !if diazotroph
          if (physize(np).eq.1.0d0) then !if BIG
          ap_type(np) = 1                !euk (assume diatom association)
          else                           !or
          ap_type(np) = 2                !syn (for now - tricho has billins)
          end if
         end if        

         RandNo = darwin_random(myThid)
         if (nsource(np).eq.3) then !if all three sources (NO3)
          if (physize(np).eq.1.0d0) then !if BIG 
          ap_type(np) = 1                !euk
          else                           !if SMALL
           if (RandNo.gt.0.500d0) then
           ap_type(np) = 1               !euk
           else                          !or
           ap_type(np) = 2               !Syn       
           end if
          end if
         endif
 
         RandNo = darwin_random(myThid)
         if (nsource(np).eq.2) then !if NH4 only
          if (RandNo.gt.0.500d0) then
          ap_type(np) = 3               !Pro HL   
          else                          !or
          ap_type(np) = 4               !Pro LL                 
          end if
         end if

         RandNo = darwin_random(myThid)
         if (nsource(np).eq.1) then !if NH4 & NO2
          if (RandNo.gt.0.500d0) then
          ap_type(np) = 3               !Pro HL   
          else                          !or
          ap_type(np) = 4               !Pro LL                 
          end if
         end if

#else
c ANNA number of RandNo's carreid out MUST MATCH regardless of wavebands or not.
C ANNA the number of RandNo statements here MUST MATCH the number done above

c        RandNo = darwin_random(myThid)
c        RandNo = darwin_random(myThid)
c        RandNo = darwin_random(myThid)

#endif
c ANNA endif


c..........................................................
c generate phyto Temperature Function parameters  
c.......................................................
        phytoTempCoeff(np) = tempcoeff1
        phytoTempExp1(np) = tempcoeff3
        if(physize(np) .eq. 1.0 _d 0)then
          phytoTempExp2(np) = tempcoeff2_big
        else
          phytoTempExp2(np) = tempcoeff2_small
        endif

        RandNo = darwin_random(myThid)
cswd    phytoTempOptimum(np) = 30.0 _d 0 - RandNo*28.0 _d 0 
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
        if(diatom(np) .eq. 1.0 _d 0)then
          R_SiP(np) =  val_R_SiP_diatom
        else
          R_SiP(np) = 0.0 _d 0
        end if
c set N:P and iron requirement according to diazotroph status
        if(diazotroph(np) .eq. 1.0 _d 0)then
          R_NP(np) = val_R_NP_diaz
          R_FeP(np) =  val_RFeP_diaz
        else
          R_NP(np) = val_R_NP
          R_FeP(np) = val_RFeP
        end if
c set C:P ratio
          R_PC(np) = val_R_PC
c set sinking rates according to allometry
        if(physize(np) .eq. 1.0 _d 0)then
           wsink(np) = BigSink
        else 
           wsink(np) = SmallSink
        end if 
c half-saturation coeffs 

        RandNo = darwin_random(myThid)
        if(physize(np) .eq. 1.0 _d 0)then
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

#ifndef GEIDER
cNEW Light parameters:
c     ksatPAR {0.1 - 1.3}
c     0.35=Av High Light Adapted, 0.8=Av Low Light Adapted
c     kinhib  {0.0 - 3.0}
c     0.5 =Av High Light Adapted, 2.0=Av Low Light Adapted
c High Light Groups for Large size:
              if(physize(np) .eq. 1.0 _d 0)then
                 RandNo = darwin_random_normal(myThid)
                 ksatPAR(np) = abs(Bigksatpar+Bigksatparstd*RandNo)

                 RandNo = darwin_random_normal(myThid)
                 kinhib(np) = abs(Bigkinhib+Bigkinhibstd*RandNo)
              else
c QQ remove someday
                 RandNo = darwin_random(myThid)
c Low Light Groups for Small size:
                 RandNo = darwin_random_normal(myThid)
                 ksatPAR(np) = abs(smallksatpar+smallksatparstd*RandNo)

                 RandNo = darwin_random_normal(myThid)
                 kinhib(np) = abs(smallkinhib+smallkinhibstd*RandNo)
              endif
         write(msgBuf,'(A,I4,A,1P1G24.15E3)')
     &     'generate Phyto: np = ',np,' ksatPAR    =', ksatPAR(np)
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT , mythid)
         write(msgBuf,'(A,I4,A,1P1G24.15E3)')
     &     'generate Phyto: np = ',np,' kinhib     =', kinhib(np)
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT , mythid)
#endif

#ifdef GEIDER
        RandNo = darwin_random(myThid)
c big/small phyto growth rates..
        if(physize(np) .eq. 1.0 _d 0)then
          growthdays = Biggrow +Randno*Biggrowrange
        else
          growthdays = Smallgrow +RandNo*Smallgrowrange
        end if
c but diazotrophs always slower due to energetics
        if(diazotroph(np) .eq. 1.0 _d 0) then
            growthdays = growthdays * diaz_growfac
        endif
c now convert to a growth rate
        if (growthdays.gt.0. _d 0) then
         pcmax(np) = 1.0 _d 0/(growthdays*pday)
        else
         pcmax(np) = 0. _d 0
        endif
c
        RandNo = darwin_random(myThid)

c big/small phyto PI slope (chl specific)
c        if(physize(np) .eq. 1.0 _d 0)then
c          alphachl(np) = Bigalphachl +Randno*Bigalphachlrange
c        else
c          alphachl(np) = Smallalphachl +RandNo*Smallalphachlrange
c        end if

c ANNA gieder via mQyield instead of alpha
c big/small phyto Maximum Quantum Yield
        if(physize(np) .eq. 1.0 _d 0)then
          mQyield(np) = BigmQyield +Randno*BigmQyieldrange
        else
          mQyield(np) = SmallmQyield +RandNo*SmallmQyieldrange
        end if

        RandNo = darwin_random(myThid)
c big/small phyto C:Chl max
        if(physize(np) .eq. 1.0 _d 0)then
          chl2cmax(np) = Bigchl2cmax +Randno*Bigchl2cmaxrange
        else
          chl2cmax(np) = Smallchl2cmax +RandNo*Smallchl2cmaxrange
        end if

         write(msgBuf,'(A,I4,A,1P1G24.15E3)')
     &     'generate Phyto: np = ',np,' pcmax    =', pcmax(np)
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT , mythid)
c         write(msgBuf,'(A,I4,A,1P1G24.15E3)')
c     &     'generate Phyto: np = ',np,' alphachl    =', alphachl(np)
c ANNA CHANGED TO MQYIELD from ALPHACHL
c ANNA STEPH msgBuf changed for mQyield?
         write(msgBuf,'(A,I4,A,1P1G24.15E3)')
     &     'generate Phyto: np = ',np,' mQyield    =', mQyield(np)
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT , mythid)
         write(msgBuf,'(A,I4,A,1P1G24.15E3)')
     &     'generate Phyto: np = ',np,' chl2cmax     =', chl2cmax(np)
         CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT , mythid)
#endif

#ifndef OLD_GRAZE
c    for zooplankton
c assume zoo(1) = small, zoo(2) = big
         zoosize(1) = 0.0 _d 0
         zoosize(2) = 1.0 _d 0
         grazemax(1) = GrazeFast
         grazemax(2) = GrazeFast
         ExportFracZ(1)=ZooexfacSmall
         ExportFracZ(2)=ZooexfacBig
         mortzoo(1) = ZoomortSmall
         mortzoo(2) = ZoomortBig
         ExportFracGraz(1)=ExGrazFracbig
         ExportFracGraz(2)=ExGrazFracsmall
         IF ( nzmax.GT.2 ) THEN
           WRITE(msgBuf,'(2A,I5)') 'DARWIN_GENERATE_PHYTO: ',
     &       'nzmax = ', nzmax
           CALL PRINT_ERROR( msgBuf , 1)
           WRITE(msgBuf,'(2A)') 'DARWIN_GENERATE_PHYTO: ',
     &       'please provide size info for nz > 2'
           CALL PRINT_ERROR( msgBuf , 1)
           STOP 'ABNORMAL END: S/R DARWIN_GENERATE_PHYTO'
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
              if (physize(np).eq.0. _d 0) then
                asseff(np,nz)=GrazeEffhi
              else
                asseff(np,nz)=GrazeEfflow
              endif
           endif
c diatoms even less palatible
           if (diatom(np).eq.1. _d 0) then
               palat(np,nz)= palat(np,nz)*diatomgraz
           endif
          enddo
#endif 

        RETURN
        END
#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/

c ===========================================================
