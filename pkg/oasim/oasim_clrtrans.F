#include "OASIM_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: OASIM_CLRTRANS

C     !INTERFACE:
      SUBROUTINE OASIM_CLRTRANS(
     I        cosunz,rm,rmp,ta,wa,asym,
     O        Td,Ts,
     I        myThid)

C     !DESCRIPTION:
C     Model for atmospheric transmittance of solar irradiance through
C     a cloudless maritime atmosphere.  Computes direct and diffuse
C     separately.  From Gregg and Carder (1990) Limnology and
C     Oceanography 35(8): 1657-1675.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "OASIM_SIZE.h"
#include "OASIM_INTERNAL.h"

C     !INPUT PARAMETERS:
      _RL cosunz,rm,rmp
      _RL ta(nlt),asym(nlt),wa(nlt)
      INTEGER myThid

C     !OUTPUT PARAMETERS:
c     Td :: spectral clear sky direct transmittance
c     Ts :: spectral clear sky diffuse transmittance
      _RL Td(nlt),Ts(nlt)
CEOP

#ifdef ALLOW_OASIM

C     !LOCAL VARIABLES:
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER l
      _RL afs,bfs
      _RL rtra,alg,Fa,tarm,atra,taa,tas,dray,daer

c  Compute spectral transmittance
      DO l = 1,nlt
c    Rayleigh
       rtra = EXP(-thray(l)*rmp)       !transmittance
c   Aerosols
       alg = log(1.0 _d 0-asym(l))
       afs = alg*(1.459 _d 0+alg*(.1595 _d 0+alg*.4129 _d 0))
       bfs = alg*(.0783 _d 0+alg*(-.3824 _d 0-alg*.5874 _d 0))
       IF (ta(l) .LT. 0.0 _d 0 .OR. wa(l) .LT. 0.0 _d 0)THEN
        WRITE(msgBuf,'(A)') 'OASIM_CLRTRANS: error in ta or omega'
        CALL PRINT_ERROR( msgBuf , myThid)
        WRITE(msgBuf,'(2A,I3,1P3E15.6)') 'OASIM_CLRTRANS: ',
     &       'l,ta,wa,asym = ',l,ta(l),wa(l),asym(l)
        CALL PRINT_ERROR( msgBuf , myThid)
       ENDIF
       Fa = 1.0 _d 0 - 0.5 _d 0*EXP((afs+bfs*cosunz)*cosunz)
       IF (Fa .LT. 0.0 _d 0)THEN
        WRITE(msgBuf,'(A)') 'OASIM_CLRTRANS: error in Fa'
        CALL PRINT_ERROR( msgBuf , myThid)
        WRITE(msgBuf,'(2A,I3,1P3E15.6)') 'OASIM_CLRTRANS: ',
     &       'l,ta,wa,asym = ',l,ta(l),wa(l),asym(l)
        CALL PRINT_ERROR( msgBuf , myThid)
       ENDIF
       tarm = ta(l)*rm
       atra = EXP(-tarm)
       taa = EXP(-(1.0 _d 0-wa(l))*tarm)
       tas = EXP(-wa(l)*tarm)
c  Direct transmittance
       Td(l) = rtra*atra
c
c   Diffuse transmittance
       dray = taa*0.5 _d 0*(1.0 _d 0-rtra**.95 _d 0)
       daer = rtra**1.5 _d 0*taa*Fa*(1.0 _d 0-tas)
c
c  Total diffuse
       Ts(l) = dray + daer
c
      ENDDO

#endif /* ALLOW_OASIM */

      RETURN
      END
