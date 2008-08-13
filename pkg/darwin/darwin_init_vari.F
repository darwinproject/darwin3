C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_init_vari.F,v 1.14 2008/08/13 21:29:10 stephd Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "GCHEM_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

c ==========================================================
c SUBROUTINE DARWIN_INIT_VARI()
c initialize stuff for generalized plankton model
c adapted from NPZD2Fe - Mick Follows, Fall 2005
c               modified - Stephanie Dutkiewicz, Spring 2006
c ==========================================================
c 
        SUBROUTINE DARWIN_INIT_VARI(myThid)

        IMPLICIT NONE

#include "SIZE.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN.h"
c#include "GCHEM.h"
#include "DARWIN_IO.h"

c ANNA define params for WAVEBANDS
#ifdef WAVEBANDS
#include "WAVEBANDS_PARAMS.h"
#endif


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
      INTEGER IniUnit1, IniUnit2

        INTEGER bi, bj, k
 
        INTEGER np
        INTEGER nz
c ANNA need nl for wavebands
#ifdef WAVEBANDS
        integer i,ilam
        integer nl

c ANNA for interpolation
         _RL cu_area
         _RL waves_diff
         _RL light_diff
         _RL alpha_diff
         _RL squ_part
         _RL tri_part
         _RL seg_area
         _RL alpha_mean(npmax)

#endif

CEOP

        WRITE(msgBuf,'(A)')
     &  '// ======================================================='
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') '// Darwin init variables >>> START <<<'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)')
     &  '// ======================================================='
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )

c test....................
c       write(6,*)'testing in npzd2fe_init_vari '
c test....................
     

c set up ecosystem coefficients
c
c seed randomization
        CALL DARWIN_RANDOM_INIT(darwin_seed, myThid)

c initialize total number of functional groups tried
         ngroups = 0
         do np = 1, npmax
#ifdef ALLOW_MUTANTS
            call darwin_generate_mutants(MyThid, np)
#else
            call darwin_generate_phyto(MyThid, np)
#endif
         end do

c %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#ifdef OLD_GRAZE
c    for zooplankton
c assume zoo(1) = small, zoo(2) = big
c then grazing efficiency according to size
         zoosize(1) = 0.0 _d 0
         zoosize(2) = 1.0 _d 0
         IF ( nzmax.GT.2 ) THEN
           WRITE(msgBuf,'(2A,I5)') 'DARWIN_INIT_VARIA: ',
     &       'nzmax = ', nzmax
           CALL PRINT_ERROR( msgBuf , 1)
           WRITE(msgBuf,'(2A)') 'DARWIN_INIT_VARIA: ',
     &       'please provide size info for nz > 2'
           CALL PRINT_ERROR( msgBuf , 1)
           STOP 'ABNORMAL END: S/R DARWIN_INIT_VARIA'
         ENDIF

c grazing rates according to "allometry"
c big grazers preferentially eat big phyto etc...
         do np=1,npmax
           do nz=1,nzmax
             if(zoosize(nz) .eq. physize(np))then
               graze(np,nz) = GrazeFast 
             else 
               graze(np,nz) = GrazeSlow 
             end if
             if (diatom(np).eq.1) then
               graze(np,nz)= graze(np,nz)*diatomgraz
             else
               if (physize(np).eq.1) then
                 graze(np,nz)= graze(np,nz)*olargegraz
               endif
             endif
           end do
         end do

c zooplankton export/mortality       
c small zooplankton (zoosize = 0.) lower export fraction
         do nz = 1, nzmax
           if(zoosize(nz) .eq. 0.0)then 
             ExportFracZ(nz) = ZooexfacSmall
             mortzoo(nz) = ZoomortSmall
           else
             ExportFracZ(nz) = ZooexfacBig
             mortzoo(nz) = ZoomortBig
           endif
         end do
#endif


c ANNA call WAVEBANDS_INIT_VARI to assign variable parameters      
#ifdef WAVEBANDS
            call WAVEBANDS_INIT_VARI(MyThid)
#endif

c ANNA get alphachl from mQyield / aphy_chl
c ANNA must do this after params are assigned, but before written out
c ANNA use aphy_chl_ps for growth. To turn off, simply set same coefs as aphy_chl in input files.
#ifdef GEIDER
#ifndef WAVEBANDS
         do np = 1,npmax
          alphachl(np) = mQyield(np) * aphy_chl_ave 
c C:CHl minimum: chosen to be Chl:C at high light (2000uEin/m2/s) and
c  no temp/nutrient limitation
          chl2cmin(np)=chl2cmax(np)/
     &            (1+(chl2cmax(np)*alphachl(np)*2000. _d 0)/
     &               (2*pcmax(np)))
c         chl2cmin(np)=0. _d 0
         enddo
#else
         do np = 1,npmax
c ANNA for wavebands only, re-set mQyield to be constant for all np's
c ANNA i.e. let alpha vary only with aphy_chl_ps
c ANNA value is mean of vals for big and small.
          mQyield(np) = 4.0 _d -5
          do nl = 1,tlam
           alphachl_nl(np,nl) = mQyield(np) * aphy_chl_ps(np,nl)
          end do
c find mean 
          cu_area = 0.d0
          do nl = 1,(tlam-1)
            waves_diff = pwaves(nl+1)-pwaves(nl)
            alpha_diff = alphachl_nl(np,nl+1)-alphachl_nl(np,nl)
            squ_part = waves_diff * alphachl_nl(np,nl+1)
            tri_part = waves_diff * alpha_diff * 5.D-1
            seg_area = squ_part - tri_part
            cu_area = cu_area + seg_area
          end do
          alpha_mean(np) = cu_area / (pwaves(tlam) - pwaves(1))

          chl2cmin(np)=chl2cmax(np)/
     &            (1+(chl2cmax(np)* alpha_mean(np) *2000. _d 0)/
     &               (2*pcmax(np)))
        end do
#endif
#endif
c ANNA endif

c write out initial phyto characteristics
#ifndef GEIDER
         CALL MDSFINDUNIT( IniUnit1, mythid )
         open(IniUnit1,file='plankton-ini-char.dat',status='unknown')
         CALL MDSFINDUNIT( IniUnit2, mythid )
         open(IniUnit2,file='plankton_ini_char_nohead.dat',
     &        status='unknown')
#ifdef OLD_GRAZE
         write(IniUnit1,*)'diat diaz size   mu  mort   Rnp  Rfep   Rsip
     & wsink  KsP  KsN   KsFe    KsSi     g1      g2     Kpar  Kinh
     &  Topt nsrc np'
         do np = 1, npmax
           write(IniUnit1,110)diatom(np),diazotroph(np),physize(np),
     &                   1.0/(mu(np)*86400.), 1.0/(mortphy(np)*86400.),
     &                   R_NP(np),R_FeP(np)*1000.,R_SiP(np),
     &                   wsink(np),
     &                   KsatPO4(np),KsatNO3(np),KsatFeT(np)*1000.
     &                  ,KsatSi(np),
     &                   graze(np,1),graze(np,2),
     &                   KsatPAR(np),Kinhib(np),
     &                   phytoTempOptimum(np),nsource(np),np
            write(IniUnit2,110)diatom(np),diazotroph(np),physize(np),
     &                   1.0/(mu(np)*86400.),1.0/(mortphy(np)*86400.),
     &                   R_NP(np),R_FeP(np)*1000.,R_SiP(np),
     &                   wsink(np),
     &                   KsatPO4(np),KsatNO3(np),KsatFeT(np)*1000.
     &                  ,KsatSi(np),
     &                   graze(np,1),graze(np,2),
     &                   KsatPAR(np),Kinhib(np),
     &                   phytoTempOptimum(np),nsource(np),np
         end do
#else
         write(IniUnit1,*)'diat diaz size mu mort Rnp Rfep Rsip wsink
     & KsP KsN   KsFe   KsSi    palat1 palat2  Kpar  Kinh  Topt  nsrc
     & np'
         do np = 1, npmax
           write(IniUnit1,111)diatom(np),diazotroph(np),physize(np),
     &                   1.0/(mu(np)*86400.), 1.0/(mortphy(np)*86400.),
     &                   R_NP(np),R_FeP(np)*1000.,R_SiP(np),
     &                   wsink(np),
     &                   KsatPO4(np),KsatNO3(np),KsatFeT(np)*1000.
     &                  ,KsatSi(np),
     &                   palat(np,1),palat(np,2),
     &                   KsatPAR(np),Kinhib(np),
     &                   phytoTempOptimum(np),nsource(np),np
            write(IniUnit2,111)diatom(np),diazotroph(np),physize(np),
     &                   1.0/(mu(np)*86400.),1.0/(mortphy(np)*86400.),
     &                   R_NP(np),R_FeP(np)*1000.,R_SiP(np),
     &                   wsink(np),
     &                   KsatPO4(np),KsatNO3(np),KsatFeT(np)*1000.
     &                  ,KsatSi(np),
     &                   palat(np,1),palat(np,2),
     &                   KsatPAR(np),Kinhib(np),
     &                   phytoTempOptimum(np),nsource(np),np
         end do
#endif
#endif

#ifdef GEIDER
c ANNA outputs mQyield as 10^(4) mmol C (uEin)-1  
         CALL MDSFINDUNIT( IniUnit1, mythid )
         open(IniUnit1,file='gplankton-ini-char.dat',status='unknown')
         CALL MDSFINDUNIT( IniUnit2, mythid )
         open(IniUnit2,file='gplankton_ini_char_nohead.dat',
     &        status='unknown')
         write(IniUnit1,*)'diat diaz size pcmax mort Rnp Rfep Rsip wsink
     & KsP KsN   KsFe   KsSi    palat1 palat2 mQY(-4) chl2c  Topt  nsrc
     & np'
         do np = 1, npmax
           write(IniUnit1,111)diatom(np),diazotroph(np),physize(np),
     &                 1.0/(pcmax(np)*86400.), 1.0/(mortphy(np)*86400.),
     &                   R_NP(np),R_FeP(np)*1000.,R_SiP(np),
     &                   wsink(np),
     &                   KsatPO4(np),KsatNO3(np),KsatFeT(np)*1000.
     &                  ,KsatSi(np),
     &                   palat(np,1),palat(np,2),
     &                   mQyield(np)*1e4,chl2cmax(np),
     &                   phytoTempOptimum(np),nsource(np),np
            write(IniUnit2,111)diatom(np),diazotroph(np),physize(np),
     &                 1.0/(pcmax(np)*86400.), 1.0/(mortphy(np)*86400.),
     &                   R_NP(np),R_FeP(np)*1000.,R_SiP(np),
     &                   wsink(np),
     &                   KsatPO4(np),KsatNO3(np),KsatFeT(np)*1000.
     &                  ,KsatSi(np),
     &                   palat(np,1),palat(np,2),
     &                   mQyield(np)*1e4,chl2cmax(np),
     &                   phytoTempOptimum(np),nsource(np),np
         end do
#endif

         close(IniUnit2)
         close(IniUnit1)
 110     format(3f4.0,f6.2,4f4.0,f5.1,4f7.3,2e11.2,2f9.4,f6.1,2i5)
 111     format(3f4.0,f6.2,4f4.0,f5.1,4f7.3,2f6.1,2f9.4,f6.1,2i5)

         CALL LEF_ZERO( fice,myThid )
         CALL LEF_ZERO( inputFe,myThid )
         CALL LEF_ZERO( sur_par,myThid )
#ifdef NUT_SUPPLY
         DO bj = myByLo(myThid), myByHi(myThid)
          DO bi = myBxLo(myThid), myBxHi(myThid)
           DO j=1-Oly,sNy+Oly
            DO i=1-Olx,sNx+Olx
             DO k=1,nR
               nut_wvel(i,j,k,bi,bj) = 0. _d 0
             ENDDO
            ENDDO
           ENDDO
          ENDDO
         ENDDO
#endif

c
#ifdef ALLOW_TIMEAVE
c set arrays to zero if first timestep
        DO bj = myByLo(myThid), myByHi(myThid)
         DO bi = myBxLo(myThid), myBxHi(myThid)
          CALL TIMEAVE_RESET(PARave,   Nr,  bi, bj, myThid)
          CALL TIMEAVE_RESET(PPave,   Nr,  bi, bj, myThid)
          CALL TIMEAVE_RESET(Chlave,   Nr,  bi, bj, myThid)
          CALL TIMEAVE_RESET(Nfixave,   Nr,  bi, bj, myThid)
#ifdef DAR_DIAG_RSTAR
          do np=1,npmax
           CALL TIMEAVE_RESET(Rstarave(1-OLx,1-OLy,1,1,1,np),
     &                                      Nr,bi,bj,myThid)
           CALL TIMEAVE_RESET(RNstarave(1-OLx,1-OLy,1,1,1,np),
     &                                      Nr,bi,bj,myThid)
          enddo
#endif
#ifdef DAR_DIAG_DIVER
          CALL TIMEAVE_RESET(Diver1ave,   Nr,  bi, bj, myThid)
          CALL TIMEAVE_RESET(Diver2ave,   Nr,  bi, bj, myThid)
          CALL TIMEAVE_RESET(Diver3ave,   Nr,  bi, bj, myThid)
          CALL TIMEAVE_RESET(Diver4ave,   Nr,  bi, bj, myThid)
#endif
c         CALL TIMEAVE_RESET(SURave,   1,  bi, bj, myThid)
          WRITE(msgbuf,'(A)')
     &      'QQ start timeave'
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                        SQUEEZE_RIGHT , mythid)

          do k=1,Nr
            DAR_TimeAve(bi,bj,k)=0. _d 0
          enddo
         ENDDO
        ENDDO
#endif /* ALLOW_TIMEAVE */

#ifdef CHECK_CONS
coj find unused units for darwin_cons output
        CALL MDSFINDUNIT( DAR_cons_unit1, mythid )
        open(DAR_cons_unit1,file='darwin_cons_P.txt',status='unknown')
        CALL MDSFINDUNIT( DAR_cons_unit2, mythid )
        open(DAR_cons_unit2,file='darwin_cons_N.txt',status='unknown')
        CALL MDSFINDUNIT( DAR_cons_unit3, mythid )
        open(DAR_cons_unit3,file='darwin_cons_Fe.txt',status='unknown')
        CALL MDSFINDUNIT( DAR_cons_unit4, mythid )
        open(DAR_cons_unit4,file='darwin_cons_Si.txt',status='unknown')
#endif

c test....................
c       write(6,*)'finishing darwin_init_vari '
c test....................
        WRITE(msgBuf,'(A)')
     &  '// ======================================================='
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') '// Darwin init variables >>> END <<<'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)')
     &  '// ======================================================='
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )


         RETURN 
         END 
#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/
c ==========================================================

