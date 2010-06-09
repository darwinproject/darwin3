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
c tnabp = number of types of absorption spectra for phyto
c         must match number of types in input data file for phyto absorption spectra
c
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
c
c
c n.b. some info about input data is in the headers inside the input files.
c n.b. final column in input fles reserved for backscatter coeffs. Currently 0.
c n.b. local PARwl and PARwupl are assigned in darwin_forcing.F and darwin_plankton.F

c         integer tlam,tnabp
c         PARAMETER (tlam=13)
c         PARAMETER (tnabp=4) 
 
         COMMON/wavebands_params/aphy_chl
     &         ,aphy_chl_ps
     &         ,alphachl_nl
     &         ,aw,bw,ap,bp,ap_ps
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


