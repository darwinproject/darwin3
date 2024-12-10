#include "RW_OPTIONS.h"

      SUBROUTINE READ_FLD_XYZ_RS( pref,suff,field,myIter,myThid)
C READ_FLD_XYZ_RS is a "front-end" interface to the low-level I/O
C routines. It assumes single record files.
      IMPLICIT NONE
C Global
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
C Arguments
      CHARACTER*(*) pref,suff
      _RS field(1-Olx:sNx+Olx,1-Oly:sNy+Oly,Nr,nSx,nSy)
      INTEGER myIter
      INTEGER myThid
C Functions
      INTEGER ILNBLNK,IFNBLNK
C Local
      LOGICAL useCurrentDir
      _RL dummyRL(1)
      CHARACTER*(2) fType
      INTEGER nNz
      INTEGER iRec
      INTEGER s1Lo,s1Hi,s2Lo,s2Hi
      CHARACTER*(MAX_LEN_FNAM) fullName
C
C--   Build file name
C     Name has form 'prefix.suffix'
C     e.g. U.0000000100
      s1Lo = IFNBLNK(pref)
      s1Hi = ILNBLNK(pref)
      IF ( suff .EQ. ' ' ) THEN
       WRITE( fullName, '(A)' ) pref(s1Lo:s1Hi)
      ELSE
       s2Lo = IFNBLNK(suff)
       s2Hi = ILNBLNK(suff)
       WRITE( fullName, '(A,A)' ) pref(s1Lo:s1Hi),suff(s2Lo:s2Hi)
      ENDIF

      useCurrentDir = .FALSE.
      fType='RS'
      nNz=Nr
      iRec=1
#ifdef ALLOW_MDSIO
      CALL MDS_READ_FIELD(
     I                     fullName, readBinaryPrec, useCurrentDir,
     I                     fType, nNz, 1, nNz,
     O                     dummyRL, field,
     I                     iRec, myThid )
#endif
      RETURN
      END
