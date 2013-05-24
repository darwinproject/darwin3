
#include "CPP_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

c ==========================================================
c SUBROUTINE DARWIN_CHECK_CHL()
c initialize Chl is not set and check that not too much or too little
c  --- steph spring 2010
c ==========================================================
c 
        SUBROUTINE DARWIN_CHECK_CHL(myThid)

        IMPLICIT NONE

#include "SIZE.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DARWIN_SIZE.h"
#include "SPECTRAL_SIZE.h"
#include "DARWIN.h"
#include "DARWIN_IO.h"
#include "DARWIN_FIELDS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "PTRACERS_FIELDS.h"
#ifdef OASIM
#include "SPECTRAL.h"
#endif


C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid

C     !LOCAL VARIABLES:
C     === Local variables ===
C     msgBuf    - Informational/error meesage buffer
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER IniUnit1, IniUnit2

        INTEGER bi, bj, k, i, j, iPAR
 
        INTEGER np

        INTEGER ilam

        _RL phytmp, chltmp, chl2ctmp, pcm
        _RL PARlocal, lite
        _RL atten
CEOP

#ifdef GEIDER

        WRITE(msgBuf,'(A)')
     &  '// ======================================================='
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') '// Darwin check Chl >>> START <<<'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)')
     &  '// ======================================================='
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )

C     do not overwrite pickup
      IF (nIter0 .EQ. PTRACERS_Iter0) THEN

       call DARWIN_FIELDS_LOAD(0,0. _d 0,myThid)

c check Chl fields are reasonable
          DO bj = myByLo(myThid), myByHi(myThid)
          DO bi = myBxLo(myThid), myBxHi(myThid)
           DO j=1-Oly,sNy+Oly
            DO i=1-Olx,sNx+Olx
             atten= 0. _d 0
#if defined(WAVEBANDS) && defined(OASIM)
c if spectral use wavebands to give a single surface PAR
             lite= 0. _d 0
             DO ilam=1,tlam
              lite=lite+WtouEins(ilam)*(oasim_ed(i,j,ilam,bi,bj)+
     &                             oasim_es(i,j,ilam,bi,bj))
             ENDDO    
#else
             lite=sur_par(i,j,bi,bj)
#endif

             DO k=1,nR
              if (HFacC(i,j,k,bi,bj).gt.0. _d 0) then
               atten= atten + (k0 )*5. _d -1*drF(k)
               if (k.gt.1)then
                atten = atten + (k0)*5. _d -1*drF(k-1)
               endif
               PARlocal = lite*exp(-atten)
               DO np=1,npmax
#ifdef DYNAMIC_CHL
                chltmp=Ptracer(i,j,k,bi,bj,iChl+np-1)
#else
                chltmp=0.0 _d 0
#endif
                phytmp=Ptracer(i,j,k,bi,bj,iPhy+np-1)
c if initialized to zero, set to balanced growth
c with no nutrient or temperature limitation
c (Eq. A15 Geider et al 1997)
                if (chltmp.eq.0. _d 0) then
                     pcm=pcmax(np)  !*limit(np)*phytoTempFunction(np)
                     chl2ctmp=chl2cmax(np)/
     &                       (1+(chl2cmax(np)*alphachl(np)*PARlocal)/
     &                       (2*pcm))
                     chltmp=phytmp*R_PC(np)*chl2ctmp
                endif
c check not too high or too low
                chltmp=max(chltmp, phytmp*R_PC(np)*chl2cmin(np))
                chltmp=min(chltmp, phytmp*R_PC(np)*chl2cmax(np))
#ifdef DYNAMIC_CHL
                Ptracer(i,j,k,bi,bj,iChl+np-1)=chltmp
#else
                Chl_phy(i,j,k,bi,bj,np)=chltmp
#endif
                if (k.eq.1.and.i.eq.1.and.j.eq.1) print*,'initial Chl',
     &                        chltmp, phytmp
               ENDDO
              endif 
             ENDDO
            ENDDO
           ENDDO
          ENDDO
          ENDDO

C     nIter0
      ENDIF
#endif

        WRITE(msgBuf,'(A)')
     &  '// ======================================================='
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') '// Darwin check chl >>> END <<<'
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

