C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_init_vari.F,v 1.5 2007/12/12 21:19:01 jahn Exp $
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
#include "GCHEM.h"
#include "DARWIN_IO.h"

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


        INTEGER bi, bj, k
 
        INTEGER np
        INTEGER nz
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
        CALL DARWIN_RANDOM_INIT(gchem_int1, myThid)

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

c write out initial phyto characteristics
         open(15,file='plankton-ini-char.dat',status='unknown')
         open(16,file='plankton_ini_char_nohead.dat',status='unknown')
#ifdef OLD_GRAZE
         write(15,*)'diat diaz size   mu  mort   Rnp  Rfep   Rsip wsink 
     &  KsP  KsN   KsFe    KsSi     g1      g2     Kpar  Kinh  Topt nsrc 
     & np'
         do np = 1, npmax
           write(15,110)diatom(np),diazotroph(np),physize(np),
     &                   1.0/(mu(np)*86400.), 1.0/(mortphy(np)*86400.),
     &                   R_NP(np),R_FeP(np)*1000.,R_SiP(np),
     &                   wsink(np),
     &                   KsatPO4(np),KsatNO3(np),KsatFeT(np)*1000.
     &                  ,KsatSi(np),
     &                   graze(np,1),graze(np,2),
     &                   KsatPAR(np),Kinhib(np),
     &                   phytoTempOptimum(np),nsource(np),np
            write(16,110)diatom(np),diazotroph(np),physize(np),
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
         write(15,*)'diat diaz size mu mort Rnp Rfep Rsip wsink KsP KsN
     &   KsFe   KsSi    palat1 palat2  Kpar  Kinh  Topt  nsrc np'
         do np = 1, npmax
           write(15,111)diatom(np),diazotroph(np),physize(np),
     &                   1.0/(mu(np)*86400.), 1.0/(mortphy(np)*86400.),
     &                   R_NP(np),R_FeP(np)*1000.,R_SiP(np),
     &                   wsink(np),
     &                   KsatPO4(np),KsatNO3(np),KsatFeT(np)*1000.
     &                  ,KsatSi(np),
     &                   palat(np,1),palat(np,2),
     &                   KsatPAR(np),Kinhib(np),
     &                   phytoTempOptimum(np),nsource(np),np
            write(16,111)diatom(np),diazotroph(np),physize(np),
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


         close(15)
         close(16)
 110     format(3f4.0,f6.2,4f4.0,f5.1,4f7.3,2e11.2,2f9.4,f6.1,2i5)
 111     format(3f4.0,f6.2,4f4.0,f5.1,4f7.3,2f6.1,2f9.4,f6.1,2i5)

c
#ifdef ALLOW_TIMEAVE
c set arrays to zero if first timestep
        DO bj = myByLo(myThid), myByHi(myThid)
         DO bi = myBxLo(myThid), myBxHi(myThid)
          CALL TIMEAVE_RESET(PARave,   Nr,  bi, bj, myThid)
          CALL TIMEAVE_RESET(PPave,   Nr,  bi, bj, myThid)
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

c

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

