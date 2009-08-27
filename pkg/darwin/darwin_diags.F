C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_diags.F,v 1.8 2009/08/27 18:41:30 stephd Exp $
C $Name:  $

#include "DARWIN_OPTIONS.h"

CStartOfInterface
      SUBROUTINE DARWIN_DIAGS( myTime, myIter, myThid )
C     /==========================================================\
C     | SUBROUTINE DARWIN_DIAGS                                  |
C     | o Do DARWIN diagnostic output                           |
C     |==========================================================|
C     \==========================================================/
      IMPLICIT NONE

C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#include "DARWIN_SIZE.h"
#include "DARWIN.h"
#include "DARWIN_IO.h"

C     == Routine arguments ==
C     myTime - Current time of simulation ( s )
C     myIter - Iteration number
C     myThid -  Number of this instance of INI_FORCING
      _RL     myTime
      INTEGER myIter
      INTEGER myThid
CEndOfInterface


C     == Local variables ==
      LOGICAL  DIFFERENT_MULTIPLE
      EXTERNAL DIFFERENT_MULTIPLE
      INTEGER bi, bj, k
      INTEGER np
      INTEGER ii,jj,ilnb
      CHARACTER*(MAX_LEN_MBUF) suff
      CHARACTER*(1) pf
      CHARACTER*(MAX_LEN_FNAM) name
C     Functions
      INTEGER ILNBLNK


#ifdef ALLOW_DARWIN

      IF ( writeBinaryPrec .EQ. precFloat64 ) THEN
        pf(1:1) = 'D'
      ELSE
        pf(1:1) = 'R'
      ENDIF

#ifdef ALLOW_TIMEAVE

C     Dump files and restart average computation if needed
      IF ( DIFFERENT_MULTIPLE(taveFreq,myTime,deltaTClock).
     &                               and.myIter.ne.nIter0 ) THEN
         
C      Normalize by integrated time
       DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
         CALL TIMEAVE_NORMALIZ(PARave, DAR_timeave, nR ,
     &                 bi,bj,myThid)
         CALL TIMEAVE_NORMALIZ(PPave, DAR_timeave, nR ,
     &                 bi,bj,myThid)
         CALL TIMEAVE_NORMALIZ(Chlave, DAR_timeave, nR ,
     &                 bi,bj,myThid)
         CALL TIMEAVE_NORMALIZ(Nfixave, DAR_timeave, nR ,
     &                 bi,bj,myThid)

c ANNA_TAVE
#ifdef WAVES_DIAG_PCHL
         do np=1,npmax
           CALL TIMEAVE_NORMALIZ(Pchlave(1-Olx,1-Oly,1,1,1,np), 
     &                          DAR_timeave, nR ,
     &                 bi,bj,myThid)
c           CALL TIMEAVE_NORMALIZ(Pchlave(1-Olx,1-Oly,1,1,1,np),
c     &                          DAR_timeave, nR ,
c     &                 bi,bj,myThid)
         enddo
#endif
c ANNA end TAVE

#ifdef DAR_DIAG_RSTAR
         do np=1,npmax
           CALL TIMEAVE_NORMALIZ(Rstarave(1-Olx,1-Oly,1,1,1,np), 
     &                          DAR_timeave, nR ,
     &                 bi,bj,myThid)
           CALL TIMEAVE_NORMALIZ(RNstarave(1-Olx,1-Oly,1,1,1,np),
     &                          DAR_timeave, nR ,
     &                 bi,bj,myThid)
         enddo
#endif
#ifdef DAR_DIAG_DIVER
          CALL TIMEAVE_NORMALIZ(Diver1ave(1-Olx,1-Oly,1,1,1),
     &                          DAR_timeave, nR ,
     &                 bi,bj,myThid)
          CALL TIMEAVE_NORMALIZ(Diver2ave(1-Olx,1-Oly,1,1,1),
     &                          DAR_timeave, nR ,
     &                 bi,bj,myThid)
          CALL TIMEAVE_NORMALIZ(Diver3ave(1-Olx,1-Oly,1,1,1),
     &                          DAR_timeave, nR ,
     &                 bi,bj,myThid)
          CALL TIMEAVE_NORMALIZ(Diver4ave(1-Olx,1-Oly,1,1,1),
     &                          DAR_timeave, nR ,
     &                 bi,bj,myThid)
#endif

#ifdef ALLOW_DIAZ
#ifdef DAR_DIAG_NFIXP
         do np=1,npmax
           CALL TIMEAVE_NORMALIZ(NfixPave(1-Olx,1-Oly,1,1,1,np),
     &                          DAR_timeave, nR ,
     &                 bi,bj,myThid)
         enddo
#endif
#endif
        ENDDO
       ENDDO
       
       IF ( PTRACERS_timeave_mdsio )  THEN
         WRITE(suff,'(I10.10)') myIter
         CALL WRITE_FLD_XYZ_RL('DAR_PARtave.',suff,PARave,         
     &        myIter,myThid)
         CALL WRITE_FLD_XYZ_RL('DAR_PPtave.',suff,PPave,
     &        myIter,myThid)
         CALL WRITE_FLD_XYZ_RL('DAR_Chltave.',suff,Chlave,
     &        myIter,myThid)
         CALL WRITE_FLD_XYZ_RL('DAR_Nfixtave.',suff,Nfixave,
     &        myIter,myThid)
c ANNA_TAVE
#ifdef WAVES_DIAG_PCHL
         do np=1,npmax
           WRITE(suff,'(A7,I2.2,A1,I10.10)') 'Pchlave',
     &           np,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           Pchlave(1-Olx,1-Oly,1,1,1,np),
     &           myIter,myThid)
         enddo
#endif
c ANNA end TAVE
#ifdef DAR_DIAG_RSTAR
         do np=1,npmax
           WRITE(suff,'(A7,I2.2,A1,I10.10)') 'Rstarave',
     &           np,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           Rstarave(1-Olx,1-Oly,1,1,1,np),
     &           myIter,myThid)
         enddo
         do np=1,npmax
           WRITE(suff,'(A7,I2.2,A1,I10.10)') 'RNstarave',
     &           np,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           RNstarave(1-Olx,1-Oly,1,1,1,np),
     &           myIter,myThid)
         enddo
#endif
#ifdef DAR_DIAG_DIVER
         WRITE(suff,'(I10.10)') myIter
         CALL WRITE_FLD_XYZ_RL('DAR_Diver1tave.',suff,Diver1ave,
     &        myIter,myThid)
         CALL WRITE_FLD_XYZ_RL('DAR_Diver2tave.',suff,Diver2ave,
     &        myIter,myThid)
         CALL WRITE_FLD_XYZ_RL('DAR_Diver3tave.',suff,Diver3ave,
     &        myIter,myThid)
         CALL WRITE_FLD_XYZ_RL('DAR_Diver4tave.',suff,Diver4ave,
     &        myIter,myThid)
#endif
#ifdef ALLOW_DIAZ
#ifdef DAR_DIAG_NFIXP
         do np=1,npmax
           WRITE(suff,'(A7,I2.2,A1,I10.10)') 'NfixPave',
     &           np,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           NfixPave(1-Olx,1-Oly,1,1,1,np),
     &           myIter,myThid)
         enddo
#endif
#endif
       ENDIF

#ifdef ALLOW_MNC
       IF ( PTRACERS_timeave_mnc ) THEN
         CALL MNC_CW_SET_UDIM('dar_tave', -1, myThid)
         CALL MNC_CW_RL_W_S('D','dar_tave',0,0,'T',myTime,myThid)
         CALL MNC_CW_SET_UDIM('dar_tave', 0, myThid)
         CALL MNC_CW_I_W_S('I','dar_tave',0,0,'iter',myIter,myThid)
         CALL MNC_CW_RL_W(
     &        pf,'dar_tave',0,0,'dar_PAR_ave',PARave,myThid)
         CALL MNC_CW_RL_W(
     &        pf,'dar_tave',0,0,'dar_PP_ave',PPave,myThid)
         CALL MNC_CW_RL_W(
     &        pf,'dar_tave',0,0,'dar_Chl_ave',Chlave,myThid)
         CALL MNC_CW_RL_W(
     &        pf,'dar_tave',0,0,'dar_Nfix_ave',Nfixave,myThid)
c ANNA_TAVE
#ifdef WAVES_DIAG_PCHL
         do np=1,npmax
            ii=PTRACERS_numInUse-npmax+np
            DO jj = 1,MAX_LEN_FNAM
              name(jj:jj) = ' '
            ENDDO
            ilnb = ILNBLNK(PTRACERS_names(ii))
            WRITE(name,'(a,a)') 'dar_Pchl_',PTRACERS_names(ii)(1:ilnb)
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           Pchlave(1-OLx,1-OLy,1,1,1,np),myThid)
         enddo
#endif
c ANNA end TAVE
#ifdef DAR_DIAG_RSTAR
         do np=1,npmax
            ii=PTRACERS_numInUse-npmax+np
            DO jj = 1,MAX_LEN_FNAM
              name(jj:jj) = ' '
            ENDDO
            ilnb = ILNBLNK(PTRACERS_names(ii))
            WRITE(name,'(a,a)') 'dar_Rstar_',PTRACERS_names(ii)(1:ilnb)
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           Rstarave(1-OLx,1-OLy,1,1,1,np),myThid)
         enddo
         do np=1,npmax
            ii=PTRACERS_numInUse-npmax+np
            DO jj = 1,MAX_LEN_FNAM
              name(jj:jj) = ' '
            ENDDO
            ilnb = ILNBLNK(PTRACERS_names(ii))
            WRITE(name,'(a,a)') 'dar_RNstar_',PTRACERS_names(ii)(1:ilnb)
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           RNstarave(1-OLx,1-OLy,1,1,1,np),myThid)
         enddo
#endif
#ifdef DAR_DIAG_DIVER
         CALL MNC_CW_RL_W(
     &        pf,'dar_tave',0,0,'dar_Diver1_ave',Diver1ave,myThid)
         CALL MNC_CW_RL_W(
     &        pf,'dar_tave',0,0,'dar_Diver2_ave',Diver2ave,myThid)
         CALL MNC_CW_RL_W(
     &        pf,'dar_tave',0,0,'dar_Diver3_ave',Diver3ave,myThid)
         CALL MNC_CW_RL_W(
     &        pf,'dar_tave',0,0,'dar_Diver4_ave',Diver4ave,myThid)
#endif
#ifdef ALLOW_DIAZ
#ifdef DAR_DIAG_NFIXP
         do np=1,npmax
            ii=PTRACERS_numInUse-npmax+np
            DO jj = 1,MAX_LEN_FNAM
              name(jj:jj) = ' '
            ENDDO
            ilnb = ILNBLNK(PTRACERS_names(ii))
            WRITE(name,'(a,a)') 'dar_NfixP_',PTRACERS_names(ii)(1:ilnb)
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           NfixPave(1-OLx,1-OLy,1,1,1,np),myThid)
         enddo
#endif
#endif
       ENDIF
#endif

C      Reset averages to zero
       DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
         CALL TIMEAVE_RESET(PARave,Nr,bi,bj,myThid)
         CALL TIMEAVE_RESET(PPave,Nr,bi,bj,myThid)
         CALL TIMEAVE_RESET(Chlave,Nr,bi,bj,myThid)
         CALL TIMEAVE_RESET(Nfixave,Nr,bi,bj,myThid)
c ANNA_TAVE 
#ifdef WAVES_DIAG_PCHL
         do np=1,npmax
           CALL TIMEAVE_RESET(Pchlave(1-OLx,1-OLy,1,1,1,np),
     &                                      Nr,bi,bj,myThid)
         enddo
#endif
c ANNA and TAVE
#ifdef DAR_DIAG_RSTAR
         do np=1,npmax
           CALL TIMEAVE_RESET(Rstarave(1-OLx,1-OLy,1,1,1,np),
     &                                      Nr,bi,bj,myThid)
         enddo
         do np=1,npmax
           CALL TIMEAVE_RESET(RNstarave(1-OLx,1-OLy,1,1,1,np),
     &                                      Nr,bi,bj,myThid)
         enddo
#endif
#ifdef DAR_DIAG_DIVER
         CALL TIMEAVE_RESET(Diver1ave,Nr,bi,bj,myThid)
         CALL TIMEAVE_RESET(Diver2ave,Nr,bi,bj,myThid)
         CALL TIMEAVE_RESET(Diver3ave,Nr,bi,bj,myThid)
         CALL TIMEAVE_RESET(Diver4ave,Nr,bi,bj,myThid)
#endif
#ifdef ALLOW_DIAZ
#ifdef DAR_DIAG_NFIXP
         do np=1,npmax
           CALL TIMEAVE_RESET(NfixPave(1-OLx,1-OLy,1,1,1,np),
     &                                      Nr,bi,bj,myThid)
         enddo
#endif
#endif
         do k=1,Nr
           DAR_TimeAve(bi,bj,k)=0.d0
         enddo
        ENDDO
       ENDDO
         
      ENDIF

#endif /* ALLOW_TIMEAVE */
      
#endif /* ALLOW_DARWIN */
      
      RETURN
      END
