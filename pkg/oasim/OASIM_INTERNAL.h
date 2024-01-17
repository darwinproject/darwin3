#ifdef ALLOW_OASIM

CBOP
C     !ROUTINE: OASIM_INTERNAL.h
C     !INTERFACE:
C #include OASIM_INTERNAL.h
C
C     !DESCRIPTION:
C Contains internal fields for the oasim package
C
C Requires: OASIM_SIZE.h
CEOP

C constants:
C   COMMON /oasim_bcnst/
C   rad :: 180/pi
C   pi2 :: 2*pi
C   o24 :: 1/24
      _RL rad,pi2,o24
      COMMON /oasim_bcnst/ rad,pi2,o24

C units:
C   COMMON /oasim_bwq/
C   WtouEins :: spectral W to \mu Ein/s conversion factor
      _RL WtouEins(nlt)
      COMMON /oasim_bwq/ WtouEins

C spectral arrays for clrtrans:
C   COMMON /oasim_blam/
C   lam   :: wavelength [nm]
C   rlamu :: wavelength [um]
C   COMMON /oasim_bnlt/
C   Fobar :: extraterrestrial irradiance [W/m2]
C   thray :: Rayleigh optical thickness
C   oza   :: ozone absorption coeffient [1/cm]
C   awv   :: water vapor absorption coefficient [1/cm]
C   ao    :: O2 absorption coefficient [1/cm]
C   aco2  :: CO2 absorption coefficient [1/cm]
C   COMMON /oasim_bwat/
C   aw    :: water absorption coefficient [1/m]
C   bw    :: water scattering coefficient [1/m]
      INTEGER lam(nlt)
      _RL rlamu(nlt)
      _RL Fobar(nlt),thray(nlt),oza(nlt),awv(nlt),ao(nlt),aco2(nlt)
      _RL aw(nlt),bw(nlt)
      COMMON /oasim_blam/ rlamu,lam
      COMMON /oasim_bnlt/ Fobar,thray,oza,awv,ao,aco2
      COMMON /oasim_bwat/ aw,bw

C sfcrfl:
C   COMMON /oasim_bsfcrfl/
C   rn    :: index of refraction of pure seawater
C   roair :: density of air [g/m3]
      _RL rn, roair
      _RL wfac(nlt)
      COMMON /oasim_bsfcrfl/ wfac, rn, roair

C light:
C   COMMON /oasim_blight/
C   p0     :: standard pressure [mbar]
C   ozfac1 :: parameter for ozone-corrected path length
C   ozfac2 :: parameter for ozone-corrected path length
      _RL p0, ozfac1, ozfac2
      COMMON /oasim_blight/ p0,ozfac1,ozfac2

C aerosols:
      integer lamaer(nltaer), iaer(nlt)
      _RL waer(nlt)
      common /oasim_blamaer/ lamaer, iaer, waer

CEOP
#endif /* ALLOW_OASIM */
