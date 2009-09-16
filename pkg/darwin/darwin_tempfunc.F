
#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

c ====================================================================
c SUBROUTINE DARWIN_TEMPFUNC
c ====================================================================

       SUBROUTINE DARWIN_TEMPFUNC(
     I                    Tlocal,
     O                    phytoTempFunction,
#ifndef QUOTA
     O                    zooTempFunction,
#endif
     O                    reminTempFunction,
     I                    myThid)

         implicit none
#ifdef QUOTA
#include "QUOTA_SIZE.h"
#include "QUOTA.h"
#else
#include "DARWIN_SIZE.h"
#include "DARWIN.h"
#endif
#include "DARWIN_PARAMS.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
       INTEGER myThid
       _RL phytoTempFunction(npmax)
#ifndef QUOTA
       _RL zooTempFunction(nzmax)
#endif
       _RL reminTempFunction
       _RL Tlocal

c local
       _RL Tkel
       _RL TempAe, Tempref, TempCoeff
       INTEGER np, nz

c OLDVERSION used in Follows et al (2007) - without max of 1
c OLDVERSION used in Dutkiewicz et al (2009), Hickman et al, 
c                    Monteiro etal, Barton et al
c TEMP_RANGE gives all phyto a  specific temperature range
c            if undefined, then full Eppley/Arrenhius curve used

#undef NOTEMP
#define TEMP_RANGE
#define OLDVERSION   
#undef  VERSION2

c if two species setup we don't want specific temperature ranges
#ifdef  TWO_SPECIES_SETUP
#undef TEMP_RANGE 
#endif
c
c ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c +++++++++++++++++++ VERSION 1 +++++++++++++++++++++++++++++++++++++++
c steph's version 1 (pseudo-Eppley)
#ifdef OLDVERSION
c plankton growth function (unitless)
          do np=1, npmax
cswd -- this gives Eppley curve only
             phytoTempFunction(np) = 
     &                      (phytoTempExp1(np)**Tlocal)
#ifdef TEMP_RANGE
cswd -- temperature range
             phytoTempFunction(np) = phytoTempFunction(np) *
     &                      (exp(- phytoTempExp2(np)*
     &                      (abs(Tlocal - phytoTempOptimum(np)))**
     &                                         phytoDecayPower(np))) 
#endif
             phytoTempFunction(np) = phytoTempFunction(np) - tempnorm
             phytoTempFunction(np) = phytoTempCoeff(np)*
     &                  max(phytoTempFunction(np), 1. _d -10)
             phytoTempFunction(np) = min(phytoTempFunction(np),1. _d 0)
          enddo
#ifndef QUOTA
          do nz = 1,nzmax
c              zooTempFunction(nz) = zooTempCoeff(nz)*EXP(
c    &             zooTempExp(nz)*(Tlocal - zooTempOptimum(nz)))
            zooTempFunction(nz) = 1.0 _d 0
          end do
#endif
          reminTempFunction = 1.0 _d 0
#endif
c ++++++++++++++ END VERSION 1 +++++++++++++++++++++++++++++++++++++++
c++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c
c ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c +++++++++++++++++++ VERSION 2 +++++++++++++++++++++++++++++++++++++++
c steph's version 2 (pseudo-Arrenhius)
#ifdef VERSION2
          Tkel=273.15 _d 0
          TempAe=-4000. _d 0
          Tempref=293.15 _d 0
          tempnorm= 0. _d 0
          TempCoeff=0.5882 _d 0
          do np=1, npmax
             phytoTempCoeff(np) = TempCoeff
cswd -- this gives Arrenhius curve only
             phytoTempFunction(np) =
     &                  exp(TempAe*(1. _d 0/(Tlocal+Tkel) -
     &                                   1. _d 0/(Tempref) ) )  
#ifdef TEMP_RANGE
cswd -- temperature range
             phytoTempFunction(np) = phytoTempFunction(np) *
     &                      (exp(- phytoTempExp2(np)*
     &                      (abs(Tlocal - phytoTempOptimum(np)))**
     &                                         phytoDecayPower(np)))
#endif
             phytoTempFunction(np) = phytoTempFunction(np) - tempnorm
             phytoTempFunction(np) = phytoTempCoeff(np)*
     &                  max(phytoTempFunction(np), 1. _d -10)
         enddo
#ifndef QUOTA
         do nz = 1,nzmax
              zooTempFunction(nz) = 
     &                  exp(TempAe*(1/(Tlocal+Tkel) -
     &                                   1/(Tempref) ) )
              zooTempFunction(nz) = zooTempFunction(nz) - tempnorm
              zooTempFunction(nz) = TempCoeff*
     &                  max(zooTempFunction(nz), 1. _d -10)
c              zooTempFunction(nz) = 1. _d 0
         end do
#endif
         reminTempFunction = exp(TempAe*(1/(Tlocal+Tkel) -
     &                                   1/(Tempref) ) )
         reminTempFunction = reminTempFunction  - tempnorm
         reminTempFunction = TempCoeff*
     &                  max(reminTempFunction, 1. _d -10)
c        reminTempFunction = 1. _d 0
#endif
c ++++++++++++++ END VERSION 2 +++++++++++++++++++++++++++++++++++++++
c++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c
c ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c +++++++++++++++++++  NO TEMP LIMITATION +++++++++++++++++++++++++++++
#ifdef NOTEMP
         do np=1, npmax
              phytoTempFunction(np) = 1.0 _d 0
         enddo
#ifndef QUOTA
         do nz = 1,nzmax
              zooTempFunction(nz) = 1.0 _d 0
         end do
#endif
         reminTempFunction = 1.0 _d 0
#endif
c +++++++++++++  END NO TEMP LIMITATION +++++++++++++++++++++++++++++
c ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c 

         RETURN
         END
#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/
c ==================================================================
