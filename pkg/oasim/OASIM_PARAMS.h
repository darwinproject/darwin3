#ifdef ALLOW_OASIM

C--   COMMON /OASIM_FILENAMES/
C     oasim_atmoFile        :: filename for spectra of extraterrestrial irradiance and atomspheric gases
C     oasim_waterFile       :: filename for water absorption and scattering spectra
C     oasim_slingoFile      :: filename for cloud parameters
      CHARACTER*(MAX_LEN_FNAM) oasim_atmoFile
      CHARACTER*(MAX_LEN_FNAM) oasim_waterFile
      CHARACTER*(MAX_LEN_FNAM) oasim_slingoFile
#ifdef OASIM_READ_UNFORMATTED
      CHARACTER*(MAX_LEN_FNAM) oasim_modisCloudFile
      CHARACTER*(MAX_LEN_FNAM) oasim_cloudClimFile
      CHARACTER*(MAX_LEN_FNAM) oasim_cloudCoverFile
      CHARACTER*(MAX_LEN_FNAM) oasim_cloudCoverClimFile
      CHARACTER*(MAX_LEN_FNAM) oasim_opticsFile
      CHARACTER*(MAX_LEN_FNAM) oasim_aerosolFile
      CHARACTER*(MAX_LEN_FNAM) oasim_aerosolClimFile
      CHARACTER*(MAX_LEN_FNAM) oasim_aerTauFile
      CHARACTER*(MAX_LEN_FNAM) oasim_aerTauClimFile
#endif /* OASIM_READ_UNFORMATTED */
      COMMON /OASIM_FILENAMES/
#ifdef OASIM_READ_UNFORMATTED
     &       oasim_modisCloudFile,
     &       oasim_cloudClimFile,
     &       oasim_cloudCoverFile,
     &       oasim_cloudCoverClimFile,
     &       oasim_opticsFile,
     &       oasim_aerosolFile,
     &       oasim_aerosolClimFile,
     &       oasim_aerTauFile,
     &       oasim_aerTauClimFile,
#endif /* OASIM_READ_UNFORMATTED */
     &       oasim_atmoFile,
     &       oasim_waterFile,
     &       oasim_slingoFile

C--   COMMON /OASIM_PARAMS_I/
C     oasim_startYear    :: year of iteration 0 when cal package is not used
      INTEGER oasim_startYear
      COMMON /OASIM_PARAMS_I/
     &       oasim_startYear

C--   COMMON /OASIM_PARAMS_R/
C     oasim_dTsolz       :: sub-timestep for mean solar zenith angle computation [s]
C     oasim_am           :: air-mass parameter for navaer aerosol model
C     oasim_Vi           :: visibility for navaer aerosol model [km]
C     oasim_fixedSolz    :: fixed solar zenith angle to use (for debugging)
C     oasim_fixedLon     :: fixed longitude to use (for legacy mode)
C     oasim_rmus         :: inverse mean zenith cosine of diffuse downwelling irradiance
C     oasim_monitorFreq  :: monitor frequency for OASIM package
      _RL oasim_dTsolz
      _RL oasim_am, oasim_Vi
      _RL oasim_fixedSolz
      _RL oasim_fixedLon
      _RL oasim_rmus
      _RL oasim_monitorFreq
      COMMON /OASIM_PARAMS_R/
     &       oasim_dTsolz,
     &       oasim_am, oasim_Vi,
     &       oasim_fixedSolz,
     &       oasim_fixedLon,
     &       oasim_rmus,
     &       oasim_monitorFreq

#endif /* ALLOW_OASIM */
