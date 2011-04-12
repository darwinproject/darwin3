C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_diags.F,v 1.15 2011/04/12 19:21:36 jahn Exp $
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

      _RL Nfixtot, PPtot, Denittot

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
         CALL TIMEAVE_NORMALIZ(Denitave, DAR_timeave, nR ,
     &                 bi,bj,myThid)

#ifdef DAR_DIAG_ACDOM
         CALL TIMEAVE_NORMALIZ(aCDOMave, DAR_timeave, nR ,
     &                 bi,bj,myThid)
#endif
#ifdef DAR_DIAG_IRR
         do ii = 1,tlam
          CALL TIMEAVE_NORMALIZ(Edave(1-Olx,1-Oly,1,1,1,ii),
     &                          DAR_timeave,nR,bi,bj,myThid)
          CALL TIMEAVE_NORMALIZ(Esave(1-Olx,1-Oly,1,1,1,ii),
     &                          DAR_timeave,nR,bi,bj,myThid)
          CALL TIMEAVE_NORMALIZ(Euave(1-Olx,1-Oly,1,1,1,ii),
     &                          DAR_timeave,nR,bi,bj,myThid)
          CALL TIMEAVE_NORMALIZ(Eutave(1-Olx,1-Oly,1,1,1,ii),
     &                          DAR_timeave,nR,bi,bj,myThid)
         enddo
#endif
#ifdef DAR_DIAG_ABSORP
         do ii = 1,tlam
          CALL TIMEAVE_NORMALIZ(aave(1-Olx,1-Oly,1,1,1,ii),
     &                          DAR_timeave,nR,bi,bj,myThid)
         enddo
#endif
#ifdef DAR_DIAG_SCATTER
         do ii = 1,tlam
          CALL TIMEAVE_NORMALIZ(btave(1-Olx,1-Oly,1,1,1,ii),
     &                          DAR_timeave,nR,bi,bj,myThid)
          CALL TIMEAVE_NORMALIZ(bbave(1-Olx,1-Oly,1,1,1,ii),
     &                          DAR_timeave,nR,bi,bj,myThid)
         enddo
#endif
#ifdef DAR_DIAG_PART_SCATTER
         do ii = 1,tlam
          CALL TIMEAVE_NORMALIZ(apartave(1-Olx,1-Oly,1,1,1,ii),
     &                          DAR_timeave,nR,bi,bj,myThid)
          CALL TIMEAVE_NORMALIZ(btpartave(1-Olx,1-Oly,1,1,1,ii),
     &                          DAR_timeave,nR,bi,bj,myThid)
          CALL TIMEAVE_NORMALIZ(bbpartave(1-Olx,1-Oly,1,1,1,ii),
     &                          DAR_timeave,nR,bi,bj,myThid)
         enddo
#endif

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
c
#ifdef DAR_DIAG_GROW
         do np=1,npmax
           CALL TIMEAVE_NORMALIZ(Growave(1-Olx,1-Oly,1,1,1,np),
     &                          DAR_timeave, nR ,
     &                 bi,bj,myThid)
           CALL TIMEAVE_NORMALIZ(Growsqave(1-Olx,1-Oly,1,1,1,np),
     &                          DAR_timeave, nR ,
     &                 bi,bj,myThid)
         enddo
#endif
#ifdef ALLOW_DIAZ
c
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

#ifdef CALC_RATE_TOTALS
       call tracer_sumvol(
     &             PPave, nR, PPtot, myThid )
       PPtot=PPtot*120. _d 0 * 12. _d 0* 1. _d -3* 31536000. _d 0
     &                      *1. _d-15
       call tracer_sumvol(
     &             Nfixave, nR, Nfixtot, myThid )
       Nfixtot=Nfixtot*14. _d 0 *1. _d -3* 31536000. _d 0
     &                      *1 _d -12
       call tracer_sumvol(
     &             Denitave, nR, Denittot, myThid )
       Denittot=Denittot*14. _d 0 *1. _d -3* 31536000. _d 0
     &                      *1 _d -12
       write(30,*) 'PPtot', PPtot
       write(30,*) 'Nfixtot', Nfixtot
       write(30,*) 'Denittot', Denittot
#endif

       
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
         CALL WRITE_FLD_XYZ_RL('DAR_Denittave.',suff,Denitave,
     &        myIter,myThid)
#ifdef DAR_DIAG_ACDOM
         CALL WRITE_FLD_XYZ_RL('DAR_aCDOMtave',suff,aCDOMave,
     &        myIter,myThid)
#endif
#ifdef DAR_DIAG_IRR
         do ii = 1,tlam
           WRITE(suff,'(A5,I2.2,A1,I10.10)') 'Edave',
     &           ii,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           Edave(1-Olx,1-Oly,1,1,1,ii),
     &           myIter,myThid)
           WRITE(suff,'(A5,I2.2,A1,I10.10)') 'Esave',
     &           ii,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           Esave(1-Olx,1-Oly,1,1,1,ii),
     &           myIter,myThid)
           WRITE(suff,'(A5,I2.2,A1,I10.10)') 'Euave',
     &           ii,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           Euave(1-Olx,1-Oly,1,1,1,ii),
     &           myIter,myThid)
           WRITE(suff,'(A8,I2.2,A1,I10.10)') 'Eutopave',
     &           ii,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           Eutave(1-Olx,1-Oly,1,1,1,ii),
     &           myIter,myThid)
         enddo
#endif
#ifdef DAR_DIAG_ABSORP
         do ii = 1,tlam
           WRITE(suff,'(A4,I2.2,A1,I10.10)') 'aave',
     &           ii,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           aave(1-Olx,1-Oly,1,1,1,ii),
     &           myIter,myThid)
         enddo
#endif
#ifdef DAR_DIAG_SCATTER
         do ii = 1,tlam
           WRITE(suff,'(A5,I2.2,A1,I10.10)') 'btave',
     &           ii,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           btave(1-Olx,1-Oly,1,1,1,ii),
     &           myIter,myThid)
           WRITE(suff,'(A5,I2.2,A1,I10.10)') 'bbave',
     &           ii,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           bbave(1-Olx,1-Oly,1,1,1,ii),
     &           myIter,myThid)
         enddo
#endif
#ifdef DAR_DIAG_PART_SCATTER
         do ii = 1,tlam
           WRITE(suff,'(A8,I2.2,A1,I10.10)') 'apartave',
     &           ii,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           apartave(1-Olx,1-Oly,1,1,1,ii),
     &           myIter,myThid)
           WRITE(suff,'(A9,I2.2,A1,I10.10)') 'btpartave',
     &           ii,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           btpartave(1-Olx,1-Oly,1,1,1,ii),
     &           myIter,myThid)
           WRITE(suff,'(A9,I2.2,A1,I10.10)') 'bbpartave',
     &           ii,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           bbpartave(1-Olx,1-Oly,1,1,1,ii),
     &           myIter,myThid)
         enddo
#endif

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
c
#ifdef DAR_DIAG_GROW
         do np=1,npmax
           WRITE(suff,'(A7,I2.2,A1,I10.10)') 'Growave',
     &           np,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           Growave(1-Olx,1-Oly,1,1,1,np),
     &           myIter,myThid)
         enddo
         do np=1,npmax
           WRITE(suff,'(A7,I2.2,A1,I10.10)') 'Growsqave',
     &           np,'.',myIter
           CALL WRITE_FLD_XYZ_RL(suff,' ',
     &           Growsqave(1-Olx,1-Oly,1,1,1,np),
     &           myIter,myThid)
         enddo
#endif
c
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
         CALL MNC_CW_RL_W(
     &        pf,'dar_tave',0,0,'dar_Denit_ave',Denitave,myThid)
#ifdef DAR_DIAG_ACDOM
         CALL MNC_CW_RL_W(
     &        pf,'dar_tave',0,0,'dar_aCDOM_ave',aCDOMave,myThid)
#endif
#ifdef DAR_DIAG_IRR
         do ii = 1,tlam
            DO jj = 1,MAX_LEN_FNAM
              name(jj:jj) = ' '
            ENDDO
            WRITE(name,'(a,i2.2)') 'dar_Ed',ii
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           Edave(1-OLx,1-OLy,1,1,1,ii),myThid)
            WRITE(name,'(a,i2.2)') 'dar_Es',ii
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           Esave(1-OLx,1-OLy,1,1,1,ii),myThid)
            WRITE(name,'(a,i2.2)') 'dar_Eu',ii
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           Euave(1-OLx,1-OLy,1,1,1,ii),myThid)
            WRITE(name,'(a,i2.2)') 'dar_Eutop',ii
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           Eutave(1-OLx,1-OLy,1,1,1,ii),myThid)
         enddo
#endif
#ifdef DAR_DIAG_ABSORP
         do ii = 1,tlam
            DO jj = 1,MAX_LEN_FNAM
              name(jj:jj) = ' '
            ENDDO
            WRITE(name,'(a,i2.2)') 'dar_a',ii
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           aave(1-OLx,1-OLy,1,1,1,ii),myThid)
         enddo
#endif
#ifdef DAR_DIAG_SCATTER
         do ii = 1,tlam
            DO jj = 1,MAX_LEN_FNAM
              name(jj:jj) = ' '
            ENDDO
            WRITE(name,'(a,i2.2)') 'dar_bt',ii
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           btave(1-OLx,1-OLy,1,1,1,ii),myThid)
            WRITE(name,'(a,i2.2)') 'dar_bb',ii
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           bbave(1-OLx,1-OLy,1,1,1,ii),myThid)
         enddo
#endif
#ifdef DAR_DIAG_PART_SCATTER
         do ii = 1,tlam
            DO jj = 1,MAX_LEN_FNAM
              name(jj:jj) = ' '
            ENDDO
            WRITE(name,'(a,i2.2)') 'dar_apart',ii
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           apartave(1-OLx,1-OLy,1,1,1,ii),myThid)
            WRITE(name,'(a,i2.2)') 'dar_btpart',ii
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           btpartave(1-OLx,1-OLy,1,1,1,ii),myThid)
            WRITE(name,'(a,i2.2)') 'dar_bbpart',ii
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           bbpartave(1-OLx,1-OLy,1,1,1,ii),myThid)
         enddo
#endif
c ANNA_TAVE
#ifdef WAVES_DIAG_PCHL
         do np=1,npmax
            ii=iPhy+np-1
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
            ii=iPhy+np-1
            DO jj = 1,MAX_LEN_FNAM
              name(jj:jj) = ' '
            ENDDO
            ilnb = ILNBLNK(PTRACERS_names(ii))
            WRITE(name,'(a,a)') 'dar_Rstar_',PTRACERS_names(ii)(1:ilnb)
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           Rstarave(1-OLx,1-OLy,1,1,1,np),myThid)
         enddo
         do np=1,npmax
            ii=iPhy+np-1
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
c
#ifdef DAR_DIAG_GROW
         do np=1,npmax
            ii=iPhy+np-1
            DO jj = 1,MAX_LEN_FNAM
              name(jj:jj) = ' '
            ENDDO
            ilnb = ILNBLNK(PTRACERS_names(ii))
            WRITE(name,'(a,a)') 'dar_Grow_',PTRACERS_names(ii)(1:ilnb)
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           Growave(1-OLx,1-OLy,1,1,1,np),myThid)
         enddo
         do np=1,npmax
            ii=iPhy+np-1
            DO jj = 1,MAX_LEN_FNAM
              name(jj:jj) = ' '
            ENDDO
            ilnb = ILNBLNK(PTRACERS_names(ii))
            WRITE(name,'(a,a)') 'dar_Growsq_',PTRACERS_names(ii)(1:ilnb)
            CALL MNC_CW_RL_W(pf,'dar_tave',0,0,name,
     &           Growsqave(1-OLx,1-OLy,1,1,1,np),myThid)
         enddo
#endif
c
#ifdef ALLOW_DIAZ
#ifdef DAR_DIAG_NFIXP
         do np=1,npmax
            ii=iPhy+np-1
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
         CALL TIMEAVE_RESET(Denitave,Nr,bi,bj,myThid)
#ifdef DAR_DIAG_ACDOM
         CALL TIMEAVE_RESET(aCDOMave,Nr,bi,bj,myThid)
#endif
#ifdef DAR_DIAG_IRR
         do ii = 1,tlam
           CALL TIMEAVE_RESET(Edave(1-OLx,1-OLy,1,1,1,ii),
     &                                    Nr,bi,bj,myThid)
           CALL TIMEAVE_RESET(Esave(1-OLx,1-OLy,1,1,1,ii),
     &                                    Nr,bi,bj,myThid)
           CALL TIMEAVE_RESET(Euave(1-OLx,1-OLy,1,1,1,ii),
     &                                    Nr,bi,bj,myThid)
           CALL TIMEAVE_RESET(Eutave(1-OLx,1-OLy,1,1,1,ii),
     &                                    Nr,bi,bj,myThid)
         enddo
#endif
#ifdef DAR_DIAG_ABSORP
         do ii = 1,tlam
           CALL TIMEAVE_RESET(aave(1-OLx,1-OLy,1,1,1,ii),
     &                                   Nr,bi,bj,myThid)
         enddo
#endif
#ifdef DAR_DIAG_SCATTER
         do ii = 1,tlam
           CALL TIMEAVE_RESET(btave(1-OLx,1-OLy,1,1,1,ii),
     &                                    Nr,bi,bj,myThid)
           CALL TIMEAVE_RESET(bbave(1-OLx,1-OLy,1,1,1,ii),
     &                                    Nr,bi,bj,myThid)
         enddo
#endif
#ifdef DAR_DIAG_PART_SCATTER
         do ii = 1,tlam
           CALL TIMEAVE_RESET(apartave(1-OLx,1-OLy,1,1,1,ii),
     &                                    Nr,bi,bj,myThid)
           CALL TIMEAVE_RESET(btpartave(1-OLx,1-OLy,1,1,1,ii),
     &                                    Nr,bi,bj,myThid)
           CALL TIMEAVE_RESET(bbpartave(1-OLx,1-OLy,1,1,1,ii),
     &                                    Nr,bi,bj,myThid)
         enddo
#endif
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
c
#ifdef DAR_DIAG_GROW
         do np=1,npmax
           CALL TIMEAVE_RESET(Growave(1-OLx,1-OLy,1,1,1,np),
     &                                      Nr,bi,bj,myThid)
         enddo
         do np=1,npmax
           CALL TIMEAVE_RESET(Growsqave(1-OLx,1-OLy,1,1,1,np),
     &                                      Nr,bi,bj,myThid)
         enddo
#endif
c
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
