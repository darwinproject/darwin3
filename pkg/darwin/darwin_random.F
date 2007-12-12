C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_random.F,v 1.2 2007/12/12 18:54:50 jahn Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "GCHEM_OPTIONS.h"

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

c ==========================================================
c SUBROUTINE DARWIN_RANDOM_INIT(seed)
c initializes the random number generator
c seed must be positive
c NOTE: not thread-safe yet!!!
c ==========================================================
c 
      SUBROUTINE DARWIN_RANDOM_INIT(seed, myThid)

      IMPLICIT NONE

#include "EEPARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C  myThid               :: thread number
      INTEGER seed
      INTEGER myThid

C     !FUNCTIONS:
C     == Functions ==
#ifdef PORT_RAND
      real*8 port_rand
      external port_rand
#endif
#ifdef IFORT
      real*4 RAND
      EXTERNAL RAND
#endif

C     !LOCAL VARIABLES:
C     == Local variables ==
C     msgBuf    - Informational/error meesage buffer
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      _RL RandNo
      INTEGER nrand
#ifdef PORT_RAND
      REAL*8 Dseed
#else
      INTEGER Iseed
#endif
      INTEGER IRand
      CHARACTER*16 random_name
CEOP

      IF (myThid .GT. 1) THEN
        CALL PRINT_ERROR('DARWIN_RANDOM_INIT: threading no supported',
     &      myThid)
        STOP 'ABNORMAL END: S/R DARWIN_RANDOM_INIT'
      END IF

      IF (seed .LE. 0) THEN
        CALL PRINT_ERROR('DARWIN_RANDOM_INIT: seed must be positive'
     &                  , myThid)
      END IF

#ifdef PORT_RAND
      Dseed = seed
      RandNo = port_rand(Dseed)
C need to call again to get a non-zero random number
      Dseed = -1.D0
      RandNo = port_rand(Dseed)
      random_name = 'port_rand'
#else
#ifdef OLDSEED
      Iseed = seed
      do nrand = 1,Iseed
        Irand = 0
        RandNo = rand(Irand)
      end do
      random_name = 'rand/oldseed'
#else
      Iseed = -seed
      RandNo = rand(Iseed)
      random_name = 'rand'
#endif
#endif

      WRITE(msgbuf,'(A,A,I10,X,F20.16)')
     &   'QQ random ', random_name, seed, RandNo
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , myThid)

      RETURN 
      END

c ==========================================================
c FUNCTION DARWIN_RANDOM()
c returns a uniform random number between 0 and 1
c ==========================================================
c 
      FUNCTION DARWIN_RANDOM(myThid)

      IMPLICIT NONE

#include "EEPARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C  DARWIN_RANDOM        :: uniform random number
C  myThid               :: thread number
      _RL DARWIN_RANDOM
      INTEGER myThid

C     !FUNCTIONS:
C     == Functions ==
#ifdef PORT_RAND
      real*8 port_rand
      external port_rand
#endif
#ifdef IFORT
      real*4 RAND
      EXTERNAL RAND
#endif

C     !LOCAL VARIABLES:
C     == Local variables ==
#ifdef PORT_RAND
      real*8 Dseed
#else
      INTEGER Iseed
#endif
CEOP

      IF (myThid .GT. 1) THEN
        CALL PRINT_ERROR('DARWIN_RANDOM: threading no supported',
     &      myThid)
        STOP 'ABNORMAL END: S/R DARWIN_RANDOM'
      END IF

#ifdef PORT_RAND
      Dseed = -1
      darwin_random = port_rand(Dseed)
#else
      Iseed = 0
      darwin_random = rand(Iseed)
#endif

      RETURN 
      END 

c ==========================================================
c FUNCTION DARWIN_RANDOM_NORMAL()
c returns a normally distributed random number with mean 0 and stddev 1
c ==========================================================
c 
      FUNCTION DARWIN_RANDOM_NORMAL(myThid)

      IMPLICIT NONE

#include "EEPARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C  DARWIN_RANDOM_NORMAL :: normally distributed random number
C  myThid               :: thread number
      _RL DARWIN_RANDOM_NORMAL
      INTEGER myThid

C     !FUNCTIONS:
C     == Functions ==
#ifdef PORT_RAND
      real*8 port_rand_norm
      external port_rand_norm
#endif
#ifdef IFORT
      real*4 RAND
      EXTERNAL RAND
#endif

C     !LOCAL VARIABLES:
C     == Local variables ==
#ifdef PORT_RAND
      real*8 Dseed
#else
      INTEGER Iseed
      real*8 uniform
      real*8 normal
#endif
CEOP

      IF (myThid .GT. 1) THEN
        CALL PRINT_ERROR('DARWIN_RANDOM: threading no supported',
     &      myThid)
        STOP 'ABNORMAL END: S/R DARWIN_RANDOM'
      END IF

#ifdef PORT_RAND
      Dseed = -1
      darwin_random_normal = port_rand_norm(Dseed)
#else
      Iseed = 0
      uniform = rand(Iseed)
      CALL invnormal(normal, uniform, 0.d0, 1.d0)
      darwin_random_normal = normal
#endif

      RETURN 
      END 
#endif  /*DARWIN*/
#endif  /*ALLOW_PTRACERS*/
c ==========================================================

