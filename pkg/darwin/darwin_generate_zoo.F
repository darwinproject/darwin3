#include "CPP_OPTIONS.h"
#include "PTRACERS_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

c ==========================================================
c SUBROUTINE DARWIN_GENERATE_ZOO
c generate parameters for zooplankton
c initial simple 2 species setup
c         Stephanie Dutkiewicz Spring 2009
c ==========================================================
        SUBROUTINE DARWIN_GENERATE_ZOO(myThid)

        implicit none
#include "EEPARAMS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN_PARAMS.h"
#include "DARWIN.h"



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

        _RL dm
        _RL volp
        _RL PI
        INTEGER np
        INTEGER nz
        INTEGER signvar
        PARAMETER ( PI    = 3.14159265358979323844D0   )

CEOP
c

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
             if (diacoc(np).eq.1) then
               graze(np,nz)= graze(np,nz)*diatomgraz
             endif
             if (diacoc(np).eq.2) then
               graze(np,nz)= graze(np,nz)*coccograz
             endif
             if (diacoc(np).eq.0.and.physize(np).eq.1) then
               graze(np,nz)= graze(np,nz)*olargegraz
             endif
           end do
         end do

c zooplankton export/mortality
c small zooplankton (zoosize = 0.) lower export fraction
         do nz = 1, nzmax
           if(zoosize(nz) .eq. 0.0)then
             ExportFracZ(nz) = ZooexfacSmall
             mortzoo(nz) = ZoomortSmall
             mortzoo2(nz) = ZoomortSmall2
           else
             ExportFracZ(nz) = ZooexfacBig
             mortzoo(nz) = ZoomortBig
             mortzoo2(nz) = ZoomortBig2
           endif
         end do
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
         mortzoo2(1) = ZoomortSmall2
         mortzoo2(2) = ZoomortBig2
         ExportFracGraz(1)=ExGrazFracSmall
         ExportFracGraz(2)=ExGrazFracBig
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
c size of phytoplankton
           if(zoosize(nz).eq. 1.0 _d 0)then
             dm = 300. _d 0  ! diameter (micrometer)
           else
             dm = 30. _d 0  ! diameter (micrometer)
           end if
c phytoplankton volume in micrometers cubed
           volp=4. _d 0/3. _d 0 *PI*(dm/2. _d 0)**3 _d 0
c
c common block variables (in m and m3)
           zoo_esd(nz)=dm* 1. _d -6
           zoo_vol(nz)=volp* 1. _d -18
c palatibity according to "allometry"
c big grazers preferentially eat big phyto etc...
           do np=1,npmax
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
             if (diacoc(np).eq.1. _d 0) then
               palat(np,nz)= palat(np,nz)*diatomgraz
             endif
c coccolithophes less palatible
             if (diacoc(np).eq.2. _d 0) then
               palat(np,nz)= palat(np,nz)*coccograz
             endif
c other large phyto less palatible
             if (diacoc(np).eq.0. _d 0 .and.physize(np).eq.1. _d 0) then
               palat(np,nz)= palat(np,nz)*olargegraz
             endif
c need something in here for tricho
           enddo
          enddo
#endif 

        RETURN
        END
#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/

c ===========================================================
