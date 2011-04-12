c ANNA WAVEBANDS_PARAMS.h define key paramters for wavebands
c ANNA WAVEBANDS_PARAMS.h set number of wavebands, number of absorption 'types' here
c
c description: Key parameters for wavebands
c      Anna Hickman Spring/Summer 2008
c      
c Set parameters:
c tlam = number of wavebands
c        must match number of wavebands in input datafiles
c        must be the same for all data types (water, phyto, CDOM, surface spectra)
C        (set in SPECTRAL_SIZE.h)
c tnabp = number of types of absorption spectra for phyto
c         must match number of types in input data file for phyto absorption spectra

         INTEGER tnabp
         PARAMETER (tnabp=4)

c Input and assigned data:
c pwaves       = actual values of wavebands (nm)
c aw           = absoprtion spectra for water (m-1)
c bw           = backscatter spectra for water (currently zero)
c ap           = absorptnion spectra for phyto types (m2 (mgchla)-1)
c                total absorption is used in light attenuation
c ap_ps        = as above but absorption of photosynthetic (PS) pigments only (m2 (mgchla)-1)
c                absorption by psc only is used in growth
c bp           = backscatter spectra for phytoplankton types (currently zero)
c sf           = PAR-normalised surface light spectrum
c                intenities per nm and sum = 1 (uE m-2 s-1 (nm)-1)
c wb_width     = width of wavebands (nm)
c acdom        = absorption spectra for cdom (assumed constant) (m-1)
c ap_type      = absorption 'type' of phytoplankton assigned in darwin_generate_phyto.F
c aphy_chl     = absorption spectra assigned base on 'type' for each phtyo (chl normalised)
c aphy_chl_ps  = as above but absorption spectra given is that by photosynthetic (PS) pigs only
c                aphy_chl and aphy_chl_psc assigned in wavebands_init_vari.F
c alphachl_nl  = slope of PI curve calulated in darwin_init_vari.F
c                one value for each wavelength (same units as non-wavebands alphachl)
c darwin_diag_acdom_ilam :: waveband to write to diagnostics
c
c n.b. some info about input data is in the headers inside the input files.
c n.b. final column in input fles reserved for backscatter coeffs. Currently 0.
c n.b. local PARwl and PARwupl are assigned in darwin_forcing.F and darwin_plankton.F
 
         COMMON/wavebands_params/aphy_chl
     &         ,aphy_chl_ps
     &         ,alphachl_nl
     &         ,aw,bw,ap,bp,ap_ps,bbp
     &         ,wb_width,wb_totalWidth
#ifndef OASIM
     &         ,sf
#endif
#ifdef DAR_CALC_ACDOM
     &         ,darwin_Sdom          ! used in acdom calculations
     &         ,excdom               ! CDOM exponent
#else
     &         ,acdom
#endif
         COMMON/wavebands_params_i/ap_type
     &         ,pwaves
#ifdef DAR_CALC_ACDOM
     &         ,nl450                ! what is this? used in acdom calculations
#endif
#ifdef DAR_DIAG_ACDOM
     &         ,darwin_diag_acdom_ilam    ! waveband to write to diagnostic
#endif
                      

         INTEGER ap_type(npmax)
         INTEGER pwaves(tlam)
 
         _RL aphy_chl(npmax,tlam),aphy_chl_ps(npmax,tlam)
         _RL alphachl_nl(npmax,tlam)
         _RL ap(tnabp,tlam),ap_ps(tnabp,tlam),bp(tnabp,tlam)
         _RL bbp(tnabp,tlam)
         _RL aw(tlam),bw(tlam)
         _RL wb_width(tlam)
         _RL wb_totalWidth
#ifndef OASIM
         _RL sf(tlam)
#endif
#ifdef DAR_CALC_ACDOM
         _RL darwin_Sdom        ! used in acdom calculations 
         _RL excdom(tlam)         ! CDOM exponent
         INTEGER nl450                ! what is this? it's the nl number for 450nm used in acdom calculations
#else
         _RL acdom(tlam)
#endif
#ifdef DAR_DIAG_ACDOM
         INTEGER darwin_diag_acdom_ilam    ! waveband to write to diagnostic
#endif

#ifdef DAR_RADTRANS
C runtime parameters:
C
C     darwin_PAR_ilamLo   :: starting waveband index of PAR range (default 1)
C     darwin_PAR_ilamHi   :: end waveband index of PAR range (default tlam)
C     darwin_radmodThresh :: threshold for calling radmod (default 1E-4)
C     darwin_Dmax         :: depth at which Ed is zero (default 500 m)
C     darwin_rmus         :: inverse average cosine of downward diffuse radiation
C     darwin_rmuu         :: inverse average cosine of upward diffuse radiation
C     darwin_bbw          :: backscattering to forward scattering ratio for water
C     darwin_bbphy        :: backscattering to forward scattering ratio for Chlorophyll
C     darwin_bbmin        :: minimum backscattering coefficient (not ratio)
c     darwin_radtrans_kmax  :: deepest layer to compute irradiances in
c     darwin_radtrans_niter :: number of iterations for iterative improvement of radmod solution
c     darwin_part_size_P    :: phosphorus content of one particle. used to compute number of particles
C
      COMMON /DARWIN_RADTRANS_PARM_I/
     &       darwin_PAR_ilamLo, darwin_PAR_ilamHi
     &      ,darwin_radtrans_kmax
     &      ,darwin_radtrans_niter

      INTEGER darwin_PAR_ilamLo, darwin_PAR_ilamHi
      INTEGER darwin_radtrans_kmax
      INTEGER darwin_radtrans_niter

      COMMON /DARWIN_RADTRANS_PARM_R/
     &       darwin_radmodThresh, darwin_Dmax,
     &       darwin_rmus, darwin_rmuu,
     &       darwin_bbw,
     &       darwin_bbphy,
     &       darwin_bbmin,
     &       darwin_part_size_P

      _RL darwin_radmodThresh
      _RL darwin_Dmax
      _RL darwin_rmus, darwin_rmuu
      _RL darwin_bbw
      _RL darwin_bbphy(tnabp)
      _RL darwin_bbmin
      _RL darwin_part_size_P

C dependent/hardcoded parameters:
C
C     pid        :: pi
C     rad        :: conversion factor from radians to degree, 180/pi
C     bphy_chl   :: Chl-specific scattering coefficient for phyto
C     bbphy_chl  :: Chl-specific backscattering coefficient for phyto
C     apart      :: number-specific absorption coefficient for particles
C     bpart      :: number-specific scattering coefficient for particles
C     bbpart     :: number-specific backscattering coefficient for particles
C     apart_P    :: P-specific absorption coefficient for particles
C     bpart_P    :: P-specific scattering coefficient for particles
C     bbpart_P   :: P-specific backscattering coefficient for particles
C
      COMMON/DARWIN_RADTRANS_R/
     &        pid,rad     !radias and pi - use these rather than darwin versions for simplicity.
     &       ,bphy_chl    !scat coef for phyto
     &       ,bbphy_chl   !backscat coef for phyto
     &       ,apart, bpart, bbpart
     &       ,apart_P, bpart_P, bbpart_P

c not sure if some of these are necessary 
c SOME OF THESE parameter names are the same as WAVEBANDS, but have an added k dimension....
c the params aw, bw are only temporary in wavebands_1d .:. CHANGE THEM in WAVEBANDS_1D to something else
c this list mostly from light.F
c      _RL rod(tlam),ros(tlam)   !surface direct and diffuse reflectance !not here
      _RL pid,rad             !radias and pi - use these rather than darwin versions for simplicity.
      _RL bphy_chl(npmax,tlam) !scat coef for phyto
      _RL bbphy_chl(npmax,tlam) !backscat coef for phyto
      _RL apart(tlam)
      _RL bpart(tlam)
      _RL bbpart(tlam)
      _RL apart_P(tlam)
      _RL bpart_P(tlam)
      _RL bbpart_P(tlam)
#endif /* DAR_RADTRANS */

