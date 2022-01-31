.. include:: ../defs.hrst

.. _Light:

Non-spectral Light
^^^^^^^^^^^^^^^^^^

To have non-spectral light, disable the radtrans package.

There are three alternatives for incoming PAR at the surface: if
:varlink:`PARfile` is set, it is read in from files (it can also be set to a
constant, :varlink:`PARconst`); if :varlink:`darwin_useQsw`\ =T, it is computed
from model shortwave radiation,

.. math::

   I(0) = -f_{\op{PAR}} c_{\op{PAR}} Q_{SW}
   \;;

otherwise, it is computed as a function of latitude using solar declination,
see :filelink:`~pkg/darwin/darwin_insol.F`.  Note that this only works for
lat-lon grids.

Incoming PAR is reduced by the fraction of the ocean surface covered
by ice, unless model shortwave radiation, which has seaice already taken into
account, is used,

.. math::

   I(0) = (1 - f_{\op{ice}}) I_{\op{in}}
   \;.

The ice cover fraction, :math:`f_{\op{ice}}`, is taken from the seaice
package if compiled, and read in from :varlink:`icefile` otherwise.

PAR is attenuated by water and chlorophyll,

.. math::

   I(r) = I(0) \op{e}^{-\int_0^r k_{\op{w}} + k_{\op{Chl}} \op{Chl} \,\mathrm{d}r}

If :varlink:`DARWIN_AVPAR` is defined, the resulting function is averaged
over the thickness of a grid layer.  When no chlorophyll tracer is used (#undef
:varlink:`DARWIN_ALLOW_CHLQUOTA`), it is computed from total phytoplankton
carbon biomass.  With :varlink:`DARWIN_ALLOW_GEIDER`, it is taken from the
computation at the previous time step, without, a fixed Chlorophyll-to-C ratio,
:varlink:`R_ChlC`, is used.

.. csv-table:: Non-spectral light parameters
   :delim: &
   :widths: 18,12,14,16,40
   :header: Param, Symbol, Default, Units, Description

   :varlink:`parfrac`    & :math:`f_{\op{PAR}}` & 0.4      &                    & fraction of Qsw that is PAR
   :varlink:`parconv`    & :math:`c_{\op{PAR}}` & 1/0.2174 & µEin/s/W           & conversion from W/m2 to uEin/m2/s
   :varlink:`katten_w`   & :math:`k_{\op{w}}`   & 0.04     & 1/m                & attenuation coefficient of water
   :varlink:`katten_Chl` & :math:`k_{\op{Chl}}` & 0.04     & m\ :sup:`2`/mg Chl & attenuation coefficient of chlorophyll
   :varlink:`aphy_chl_ave` &                    & 0.02     & m\ :sup:`2`/mg Chl & Chl-specific absorption coefficient for photosynthesis
