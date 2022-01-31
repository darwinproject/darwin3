.. include:: ../defs.hrst

.. _sub_phys_pkg_radtrans:

RADTRANS package
----------------

Introduction
~~~~~~~~~~~~

The :filelink:`radtrans package <pkg/radtrans>` models spectral light
throughout the water column.  Incoming irradiances below the sea surface, split
into several wavebands and between direct (beam) and diffuse components, are
read in or provided by another package.  The irradiances are optionally
reduced based on ice cover.  The radtrans package then solves for these two
downwelling components and a diffuse upwelling component to obtain a solution
to the radiative transfer equations, based on intrinsic optical properties
provided by another package (for instance the :ref:`sub_phys_pkg_darwin`).
Spectral radiances at the vertical layer boundaries are returned to the calling
package.


Compiling and Running
~~~~~~~~~~~~~~~~~~~~~

Compiling
^^^^^^^^^

Include the word ``radtrans`` in ``packages.conf`` in your code directory.
This will automatically include the exf package.  Unless you are using the
:varlink:`RT_useMeanCosSolz` runtime option, you will also neet to include
the :ref:`sub_phys_pkg_sun`.

Set compile-time options for radtrans in file
:filelink:`~pkg/radtrans/RADTRANS_OPTIONS.h` (see table below).

Adjust the number of wavebands in :filelink:`~pkg/radtrans/RADTRANS_SIZE.h`.

In :filelink:`~pkg/exf/EXF_OPTIONS.h` you may want to undef
:varlink:`ALLOW_CLIMSST_RELAXATION` and :varlink:`ALLOW_CLIMSSS_RELAXATION`.

.. tabularcolumns:: |l|L|

.. csv-table:: CPP options for the radtrans package
   :delim: &
   :widths: auto
   :header: CPP option, description

   :varlink:`RADTRANS_DIAG_SOLUTION` & make diagnostics for the parameters of the light field solution available


Running
^^^^^^^

You will need to set :varlink:`useRADTRANS` = .TRUE. in ``data.pkg``.

Runtime Parameters
''''''''''''''''''

Runtime parameters are set in ``data.radtrans`` in these namelists:

.. csv-table::
   :delim: &
   :widths: auto
   :header: Namelist, Description

   :varlink:`RADTRANS_FORCING_PARAMS`  & parameters related to forcing and initialization
   :varlink:`RADTRANS_INTERP_PARAMS`   & parameters for interpolation of forcing fields (only used if :varlink:`USE_EXF_INTERPOLATION` is defined)
   :varlink:`RADTRANS_PARAMS`          & general parameters

Forcing fields are read in using the exf package.  How is controled by the
namelist RADTRANS_FORCING_PARAMS.  The forcing fields are:

.. csv-table:: Darwin forcing fields
   :delim: &
   :widths: 10,12,78
   :header: Name, Units, Description

   Ed(*l*) & W m\ :sup:`--2`           & Downward direct (beam) irradiance below the sea surface for waveband *l* (waveband total)
   Es(*l*) & W m\ :sup:`--2`           & Downward diffuce irradiance below the sea surface for waveband *l* (waveband total)
   ice     & m\ :sup:`2`\ /m\ :sup:`2` & fraction of sea surface covered by ice; used to reduce the irradiance entering the ocean

Each forcing field has a set of parameters.
These work as in the exf package, see :numref:`tab_phys_pkg_exf_runtime_attributes`,
except timing parameters for Ed and Es are set together:

.. csv-table:: Namelist RADTRANS_FORCING_PARAMS
   :delim: &
   :widths: auto
   :header:  Name, Default, Description

   :varlink:`RT_Edfile`\ (l)               & ' '                    & filename for direct irradiance; if left empty no file will be read; RT_Ed_const will be used instead
   :varlink:`RT_Esfile`\ (l)               & ' '                    & filename for direct irradiance; if left empty no file will be read; RT_Es_const will be used instead
   :varlink:`RT_Ed_const`\ (l)             & 0.0                    & constant that will be used if no file is read
   :varlink:`RT_Es_const`\ (l)             & 0.0                    & constant that will be used if no file is read
   :varlink:`RT_E_period`                  & 0.0                    & interval in seconds between two records
   :varlink:`RT_E_RepCycle`                & :varlink:`repeatCycle` & repeat cycle in seconds; only available if :varlink:`useOasimYearlyFields` is .FALSE.
   :varlink:`RT_E_StartTime`               & UNSET_RL               & time in seconds of first record from the beginning of the model integration or, if useRTYearlyFields, from the beginning of year
   :varlink:`RT_E_startdate1`              & 0                      & date/time of first record when using the cal package; format: YYYYMMDD; start year (YYYY), month (MM), day (YY)
   :varlink:`RT_E_startdate2`              & 0                      & format: HHMMSS; start hour (HH), minute (MM), second(SS)
   :varlink:`RT_E_mask`                    & 'c'                    & grid point for masking: ' ' = no masking; 'c' = centered mask; 'w' = western mask; 's' = southern
   :varlink:`RT_Ed_exfremo_intercept`\ (l) & 0.0                    & can be used to remove global mean
   :varlink:`RT_Es_exfremo_intercept`\ (l) & 0.0                    & can be used to remove global mean
   :varlink:`RT_Ed_exfremo_slope`\ (l)     & 0.0                    & can be used to remove global trend
   :varlink:`RT_Es_exfremo_slope`\ (l)     & 0.0                    & can be used to remove global trend
   :varlink:`RT_inscal_Ed`\ (l)            & 1.0                    & optional rescaling of input fields to adjust units
   :varlink:`RT_inscal_Es`\ (l)            & 1.0                    & optional rescaling of input fields to adjust units

Interpolation parameters are set in namelist RADTRANS_INTERP_PARAMS.
See the exf package on how to set them.


General parameters are set in namelist RADTRANS_PARAMS:

.. csv-table:: Namelist RADTRANS_PARAMS
   :delim: &
   :widths: auto
   :header: Name, Default, Units, Description

   :varlink:`RT_refract_water`  & 1.341   &                 & refractive index of water
   :varlink:`RT_rmud_max`       & 1.5     &                 & cutoff for inverse cosine of solar zenith angle
   :varlink:`RT_wbEdges`        &         & nm              & waveband edges
   :varlink:`RT_wbRefWLs`       &         & nm              & reference wavelengths for wavebands
   :varlink:`RT_kmax`           & Nr      &                 & maximum depth index for radtrans computations
   :varlink:`RT_useMeanCosSolz` & .FALSE. &                 & flag for using mean daytime cosine of solar zenith angle; if false use noon zenith angle
   :varlink:`RT_sfcIrrThresh`   & 1E-4    & W m\ :sup:`--2` & minimum irradiance for radiative transfer computations



Diagnostics
~~~~~~~~~~~

.. table::
   :widths: 16,18,12,54

   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | **Name**    | **Code**         | **Units**               | **Description**                                         |
   +=============+==================+=========================+=========================================================+
   | rmud        | ``SM_P____L1``   | 1                       | inverse cosine of solar zenith angle                    |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | Rirr###     | ``SM_P____L1``   | 1                       | irradiance reflectance for waveband ###                 |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | Ed###       | ``SMRP____LR``   | W/m\ :sup:`2`           | direct irradiance for waveband ###                      |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | Es###       | ``SMRP____LR``   | W/m\ :sup:`2`           | diffuse downwelling irradiance for waveband ###         |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | Eu###       | ``SMRP____LR``   | W/m\ :sup:`2`           | diffuse upwelling irradiance for waveband ###           |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | E###        | ``SMRP____MR``   | W/m\ :sup:`2`           | vector irradiance waveband ###                          |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | E0F###      | ``SMRP____LR``   | W/m\ :sup:`2`           | scalar irradiance at W point waveband ###               |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | Estop###    | ``SMRP____LR``   | W/m\ :sup:`2`           | diffuse downwelling irradiance for waveband ###         |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | Eubot###    | ``SMRP____LR``   | W/m\ :sup:`2`           | diffuse upwelling irradiance for waveband ###           |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | amp1_###    | ``SMR_____MR``   | W/m\ :sup:`2`           | amplitude of d-w increasing mode for waveband ###       |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | amp2_###    | ``SMR_____MR``   | W/m\ :sup:`2`           | amplitude of d-w decreasing mode for waveband ###       |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | x_###       | ``SMR_____MR``   | W/m\ :sup:`2`           | amplitude of direct in diffuse for waveband ###         |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | y_###       | ``SMR_____MR``   | W/m\ :sup:`2`           | amplitude of direct in upward for waveband ###          |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | r1_###      | ``SMRP____MR``   | 1                       | R coefficient of d-w increasing mode for waveband ###   |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | r2_###      | ``SMRP____MR``   | 1                       | R coefficient of d-w decreasing mode for waveband ###   |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | att1_###    | ``SMRP____MR``   | 1/m                     | attenuation of d-w increasing mode for waveband ###     |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | att2_###    | ``SMRP____MR``   | 1/m                     | attenuation of d-w decreasing mode for waveband ###     |
   +-------------+------------------+-------------------------+---------------------------------------------------------+
   | RTice       | ``SM_P____MR``   | m\ :sup:`2`/m\ :sup:`2` | ice area fraction in radtrans package                   |
   +-------------+------------------+-------------------------+---------------------------------------------------------+


Call tree
~~~~~~~~~

::

   the_model_main
   initialise_fixed
     packages_readparms
       radtrans_readparms
     packages_init_fixed
       radtrans_init_fixed
         radtrans_diagnostics_init
   the_main_loop
     initialise_varia
       packages_init_variables
         radtrans_init_varia
         gchem_init_vari
           darwin_init_varia
             darwin_init_chl
               darwin_light_radtrans
                 radtrans_calc...
     main_do_loop
       forward_step
         load_fields_driver
           radtrans_fields_load
             radtrans_monitor
         gchem_forcing_sep
           darwin_forcing
             darwin_light_radtrans
               radtrans_calc
                 radtrans_declination_spencer
                 radtrans_solz_daytime
                 radtrans_rmud_below
                 radtrans_solve
                   radtrans_solve_tridiag
