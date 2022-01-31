.. include:: ../defs.hrst

.. _sub_phys_pkg_sun:

SUN package
-----------

Introduction
~~~~~~~~~~~~

The :filelink:`sun package <pkg/sun>` computes the solar zenith angle above the
sea surface for all grid center locations.  The computation follows Patt and
Gregg (1994) :cite:`patt:1994`.  The code has been adapted from the
`Ocean-Atmosphere Spectral Irradiance Model (OASIM)
<https://gmao.gsfc.nasa.gov/research/oceanbiology/software.php>`_.


Compiling and Running
~~~~~~~~~~~~~~~~~~~~~

Include the word ``sun`` in ``packages.conf`` in your code directory.
This will automatically include the :ref:`cal package <sub_phys_pkg_cal>`.

This is a utility package that does not have compile or runtime configuration
options.  It needs to be called by another package in order to do anything
useful.


Subroutines
~~~~~~~~~~~

.. csv-table::
   :delim: &
   :widths: auto

   sun_init_varia & creates arrays of up, north, and east vectors
   sun_sfcsolz    & computes solar zenith angle above the sea surface
   sun_jd         & converts calendar date to Julian day
   sun_ephparms   & computes ephemeris parameters
   sun_nutate     & computes the nutation in longitude and the obliquity
   sun_sun2000    & computes the sun vector in geocentric inertial coordinates
   sun_gha2000    & computes the Greenwich hour angle in degrees


Call tree
~~~~~~~~~

::

   the_model_main 
     the_main_loop 
       initialise_varia 
         packages_init_variables 
           sun_init_varia
       main_do_loop 
         forward_step 
           gchem_forcing_sep 
             darwin_forcing 
               darwin_light_radtrans
                 radtrans_calc 
                   sun_sfcsolz
                     sun_ephparms 
                     sun_nutate 
                     sun_sun2000 
                     sun_gha2000 
                     sun_jd 
