#ifdef ALLOW_DARWIN

CBOP
C     !ROUTINE: DARWIN_EXF_FIELDS_FIELDS.h
C     !INTERFACE:
C #include DARWIN_EXF_FIELDS_FIELDS.h

C     !DESCRIPTION:
C Contains fields for darwin package read through exf
C
C Requires: SIZE.h

      COMMON /darwin_fields_c/
     &    PARfile,
     &    ironfile,
     &    icefile,
     &    windfile,
     &    pCO2file,
     &    DOCrunofffile,
     &    DONrunofffile,
     &    DOPrunofffile,
     &    DINrunofffile,
     &    IPrunofffile,
     &    DSirunofffile,
     &    POCrunofffile,
     &    POPrunofffile,
     &    PONrunofffile,
     &    DICrunofffile

      CHARACTER*128 PARfile
      CHARACTER*128 ironfile
      CHARACTER*128 icefile
      CHARACTER*128 windfile
      CHARACTER*128 pCO2file
      CHARACTER*128 DOCrunofffile
      CHARACTER*128 DONrunofffile
      CHARACTER*128 DOPrunofffile
      CHARACTER*128 DINrunofffile
      CHARACTER*128 IPrunofffile
      CHARACTER*128 DSirunofffile
      CHARACTER*128 POCrunofffile
      CHARACTER*128 POPrunofffile
      CHARACTER*128 PONrunofffile
      CHARACTER*128 DICrunofffile

      COMMON /darwin_fields_r/
     &    PAR0, PAR1, surfPAR,
     &    iron0, iron1, inputFe,
     &    ice0, ice1, iceFrac,
     &    wind0, wind1, windSpeed,
     &    pCO20, pCO21, atmospCO2,
     &    DOCrunoff0,DOCrunoff1,DOCrunoff,
     &    DONrunoff0,DONrunoff1,DONrunoff,
     &    DOPrunoff0,DOPrunoff1,DOPrunoff,
     &    DINrunoff0,DINrunoff1,DINrunoff,
     &    IPrunoff0,IPrunoff1,IPrunoff,
     &    DSirunoff0,DSirunoff1,DSirunoff,
     &    POCrunoff0,POCrunoff1,POCrunoff,
     &    POPrunoff0,POPrunoff1,POPrunoff,
     &    PONrunoff0,PONrunoff1,PONrunoff,
     &    DICrunoff0,DICrunoff1,DICrunoff

      _RL PAR0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL PAR1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL surfPAR(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL iron0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL iron1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL inputFe(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL ice0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL ice1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL iceFrac(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL wind0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL wind1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL windSpeed(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL pCO20(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL pCO21(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL atmospCO2(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL DOCrunoff0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL DOCrunoff1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL DOCrunoff(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL DONrunoff0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL DONrunoff1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL DONrunoff(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL DOPrunoff0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL DOPrunoff1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL DOPrunoff(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL DINrunoff0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL DINrunoff1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL DINrunoff(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL IPrunoff0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL IPrunoff1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL IPrunoff(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL DSirunoff0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL DSirunoff1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL DSirunoff(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL POCrunoff0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL POCrunoff1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL POCrunoff(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL POPrunoff0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL POPrunoff1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL POPrunoff(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL PONrunoff0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL PONrunoff1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL PONrunoff(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      _RL DICrunoff0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL DICrunoff1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL DICrunoff(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

CEOP

#endif /* ALLOW_DARWIN */

