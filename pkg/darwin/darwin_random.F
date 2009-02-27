C $Header: /u/gcmpack/MITgcm_contrib/darwin/pkg/darwin/darwin_random.F,v 1.8 2009/02/27 19:04:27 jahn Exp $
C $Name:  $

#include "CPP_OPTIONS.h"
#include "DARWIN_OPTIONS.h"

#ifdef PORT_RAND
#ifdef OLDSEED
      These lines are here intentionally to cause a compile-time error:
      If you really want to use PORT_RAND with OLDSEED, comment them out.
#endif
#endif

#ifdef ALLOW_PTRACERS
#ifdef ALLOW_DARWIN

CBOP
C     !ROUTINE: DARWIN_RANDOM_INIT
C     !INTERFACE:
      SUBROUTINE DARWIN_RANDOM_INIT(seed, myThid)
C     !DESCRIPTION: \bv
C     *==========================================================*
C     | SUBROUTINE DARWIN_RANDOM_INIT
C     | o Initializes the random number generator.
C     |   seed must be positive.
C     |   NOTE: not thread-safe yet!!!
C     *===========================================================
C     | Algorithms:
C     | - With PORT_RAND defined, this uses port_rand.f, which is
C     |   Knuth's portable random number generator [see Numerical
C     |   Recipes, Ch.7.1: ran3].
C     |   We use the floating-point version.
C     |   In order to obtain unique sequences of random numbers,
C     |   the seed should be between 1 and 1618032.
C     | - With PORT_RAND undefined, it uses the system's RAND 
C     |   function.  See the system documentation for ranges, etc.
C     *==========================================================*
C     \ev

C     !USES:
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
Coj   these are needed for the Intel compiler, define the macro IFORT
Coj   in your optfile if you want to use it
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
      Dseed = float(seed)
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

CBOP
C     !ROUTINE: DARWIN_RANDOM
C     !INTERFACE:
      FUNCTION DARWIN_RANDOM(myThid)
C     !DESCRIPTION: \bv
C     *==========================================================*
C     | FUNCTION DARWIN_RANDOM
c     | o returns a uniform random number between 0 and 1
C     *==========================================================*
C     \ev

C     !USES:
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
      Dseed = -1.d0
      darwin_random = port_rand(Dseed)
#else
      Iseed = 0
      darwin_random = rand(Iseed)
#endif

      RETURN 
      END 

CBOP
C     !ROUTINE: DARWIN_RANDOM_NORMAL
C     !INTERFACE:
      FUNCTION DARWIN_RANDOM_NORMAL(myThid)
C     !DESCRIPTION: \bv
C     *==========================================================*
C     | FUNCTION DARWIN_RANDOM_NORMAL
C     | o returns a normally distributed random number with
C     |   mean 0 and stddev 1
C     *==========================================================*
C     \ev

C     !USES:
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
      Dseed = -1.d0
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

