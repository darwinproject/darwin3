.. include:: ../defs.hrst

.. _Spectral:

Spectral Light
^^^^^^^^^^^^^^

Spectral light throughout the water column is computed following
:cite:`dutkiewicz:2015`.  The :ref:`sub_phys_pkg_radtrans` has to be enabled
and will attenuate light using intrinsic optical properties provided by the
darwin package.  They are computed from concentrations of plankton, particles
and CDOM:

.. math::

    a_l &= a^{\op{w}}_l + a^{\op{plank}}_l
         + a^{\op{part}}_{\op{P}l} P_{\op{part}} + a^{\op{CDOM}}_l

    b_l &= b^{\op{w}}_l + b^{\op{plank}}_l
         + b^{\op{part}}_{\op{P}l} P_{\op{part}}

    b_{\op{b}l} &= \left[ \tilde b^{\op{w}}_{\op{b}} b^{\op{w}}_l
                        + b^{\op{plank}}_{\op{b}l}
                        + b^{\op{part}}_{\op{b}\op{P}l} P_{\op{part}}
                   \right]_{\ge b_{\op{b}}^{\min}}

Water IOPs, :math:`a^{\op{w}}_l` and :math:`b^{\op{w}}_l`, are read in from
:varlink:`darwin_waterAbsorbFile`.  Plankton IOPs are computed from
individual functional types,

.. math::

   a^{\op{plank}}_l &= \sum_j \op{Chl}_j a^{\op{chl}}_{\op{phy}j,l}
                     + \sum_j 12\, c_j a^{\op{C}}_{\op{phy}j,l}

   b^{\op{plank}}_l &= \sum_j 12\, c_j b^{\op{C}}_{\op{phy}j,l}

   b^{\op{plank}}_{\op{b}l} &= \sum_j 12\, c_j b^{\op{C}}_{\op{b}\op{phy}j,l}

The spectra are selected based on optical type, :varlink:`grp_aptype`, from
spectra read in from :varlink:`darwin_phytoAbsorbFile`.  Usually, phytoplankton
absorption spectra are given per amount of Chlorophyll, via
:math:`a^{\op{chl}}_{\op{phy}j,l}`, while bacteria absorption spectra are given
in terms of carbon, via :math:`a^{\op{C}}_{\op{phy}j,l}`.  Note that all
plankton types can have carbon-specific absorption and scattering, but only
phytoplankton can have Chlorophyll-specific absorption.  With
:varlink:`DARWIN_SCATTER_CHL` defined, scattering and backscattering spectra
are assumed to be per mg Chl and only available for phytoplankton.

The particulate spectra, :math:`a^{\op{part}}_{\op{P}l}`, ..., are read in from
:varlink:`darwin_particleAbsorbFile`.  :math:`P_{\op{part}}` is particulate
organic matter in phosphorus units, including a recalcitrant component,

.. math::

   P_{\op{part}} = \op{POP} + \frac{1}{120} \op{POC}_{\op{recalc}}
   \;.

Absorption by CDOM is computed from the CDOM tracer and a recalcitrant
component,

.. math::

   a^{\op{CDOM}}_l = c_{\op{CDOM}} e^{\op{CDOM}}_l (\op{CDOM}
                   + \op{CDOM}_{\op{recalc}})
   \;,

if :varlink:`DARWIN_ALLOW_CDOM` is defined, and estimated from that of water
and plankton otherwise,

.. math::

   a^{\op{CDOM}}_l = f_{\op{aCDOM}} e^{\op{CDOM}}_l
       ( a^{\op{w}}_{l_{\op{aCDOM}}} + a^{\op{plank}\prime}_{l_{\op{aCDOM}}} )
   \;.

Here, the primed quantity does not contain contributions from carbon-specific
absorption and :math:`l_{\op{aCDOM}}` is the index of the waveband in which
:math:`\lambda_{\op{aCDOM}}` falls.  The spectral dependence in both cases is

.. math::

   e^{\op{CDOM}}_l = \mathrm{e}^{-S_{\op{DOM}}(\lambda_l - \lambda_{\op{aCDOM}})}

:numref:`tab_phys_pkgs_darwin_spectral` summarizes the model parameters
relevant to spectral light.


.. csv-table:: Spectral light parameters
   :delim: &
   :widths: auto
   :class: longtable
   :header: Param, Symbol, Default, Units, Description
   :name: tab_phys_pkgs_darwin_spectral

   :varlink:`darwin_bbmin`        & :math:`b_{\op{b}}^{\min}`          & 0.0002  & 1/m                  & minimum backscattering ratio
   :varlink:`darwin_bbw`          & :math:`\tilde b_{\op{b}}^{\op{w}}` & 0.5     &                      & backscattering ratio of water
   :varlink:`darwin_RPOC`         & :math:`\op{POC}_{\op{recalc}}`     & 0.0     & mmol C/m\ :sup:`3`   & recalcitrant POC concentration
   :varlink:`darwin_rCDOM`        & :math:`\op{CDOM}_{\op{recalc}}`    & 0.0     & mmol P/m\ :sup:`3`   & recalcitrant CDOM concentration
                                  &                                    & 0.0     & mmol C/m\ :sup:`3`   & - if #define DARWIN_CDOM_UNITS_CARBON
   :varlink:`CDOMcoeff`           & :math:`c_{\op{CDOM}}`              & 100.0   & m\ :sup:`2` / mmol P & P-specific absorption coefficient of CDOM at :math:`\lambda_{\op{CDOM}}`
                                  &                                    & 100/120 & m\ :sup:`2` / mmol C & - if #define DARWIN_CDOM_UNITS_CARBON
   :varlink:`darwin_lambda_aCDOM` & :math:`\lambda_{\op{aCDOM}}`       & 450.0   & nm                   & reference wavelength for CDOM absorption spectra
   :varlink:`darwin_Sdom`         & :math:`S_{\op{DOM}}`               & 0.014   & 1/nm                 & coefficient for CDOM absorption spectra
   :varlink:`darwin_aCDOM_fac`    & :math:`f_{\op{aCDOM}}`             & 0.2     &                      & factor for computing aCDOM from water+Chlorophyll absorption
   :varlink:`darwin_part_size_P`  & :math:`q^{\op{part}}_{\op{P}}`     & 1E-15   & mmol P / particle    & conversion factor for particle absorption and scattering spectra

.. csv-table:: Spectral light traits
   :delim: &
   :widths: 16,16,12,18,38
   :class: longtable
   :header: Trait, Param, Symbol, Units, Description

   :varlink:`aphy_chl`    & via :varlink:`grp_aptype` & :math:`a^{\op{chl}}_{\op{phy}j,l}`     & m\ :sup:`2` (mg Chl)\ :sup:`--1` & phytoplankton Chl-specific absorption coefficient
   :varlink:`aphy_chl_ps` & via :varlink:`grp_aptype` & :math:`a^{\op{chl}}_{\op{ps}j,l}`      & m\ :sup:`2` (mg Chl)\ :sup:`--1` & part of :varlink:`aphy_chl` that is used in photosynthesis
   :varlink:`aphy_mgC`    & via :varlink:`grp_aptype` & :math:`a^{\op{C}}_{\op{phy}j,l}`       & m\ :sup:`2` (mg C)\ :sup:`--1`   & plankton carbon-specific absorption coefficient
   :varlink:`bphy_mgC`    & via :varlink:`grp_aptype` & :math:`b^{\op{C}}_{\op{phy}j,l}`       & m\ :sup:`2` (mg C)\ :sup:`--1`   & carbon-specific total scattering coefficient
   :varlink:`bbphy_mgC`   & via :varlink:`grp_aptype` & :math:`b^{\op{C}}_{\op{b}\op{phy}j,l}` & m\ :sup:`2` (mg C)\ :sup:`--1`   & carbon-specific backscattering coefficient


Format of optical spectra files
'''''''''''''''''''''''''''''''

The spectra files have 6 header lines which will be ignored.  The format of the
data lines for each file is given in :numref:`tab_phys_pkg_darwin_spectra`.
The plankton spectra file contains multiple sections for the different optical
types.  Each starts with one line with reference sizes (ESD in microns; same
format, first column ignored), followed by a line for each waveband.  The
section used for each type is selected by :varlink:`grp_aptype`.

.. csv-table:: Format of data lines in optical spectra files
   :delim: &
   :widths: auto
   :class: longtable
   :header: File, Format, variables
   :name: tab_phys_pkg_darwin_spectra

   :varlink:`darwin_waterAbsorbFile`    & (I5,F15,F10)             & :math:`\lambda_l`, :math:`a^{\op{w}}_l`, :math:`b^{\op{w}}_l`
   :varlink:`darwin_particleAbsorbFile` & (I4,F15,F15,F15)         & :math:`\lambda_l`, :math:`a^{\op{part}}_{l}`, :math:`b^{\op{part}}_{l}`, :math:`b^{\op{part}}_{\op{b}l}`
   :varlink:`darwin_phytoAbsorbFile`    & (I4,F10,F10,F10,F20,F10) & :math:`\lambda_l`, :math:`a^{\op{chl}}_{\op{phy}l}`, :math:`a^{\op{chl}}_{\op{ps}l}`, :math:`b^{\op{C}}_{\op{phy}l}`, :math:`b^{\op{C}}_{\op{b}\op{phy}l}`, :math:`a^{\op{C}}_{\op{phy}l}`
                                        &                          & first line in sec: \*, :math:`d^{\op{a}}`, \*, :math:`d^{\op{b}}`, \*, :math:`d^{\op{aC}}`

Particle spectra are read in units of m\ :sup:`2`/particle and converted to
m\ :sup:`2`/mmol P using a fixed conversion factor,

.. math::

   a^{\op{part}}_{\op{P}l}       &= a^{\op{part}}_{l}/q^{\op{part}}_{\op{P}}

   b^{\op{part}}_{\op{P}l}       &= b^{\op{part}}_{l}/q^{\op{part}}_{\op{P}}

   b^{\op{part}}_{\op{b}\op{P}l} &= b^{\op{part}}_{\op{b}l}/q^{\op{part}}_{\op{P}}


.. _allomSpectra:

Allometric scaling of absorption and scattering spectra
'''''''''''''''''''''''''''''''''''''''''''''''''''''''

If :varlink:`darwin_allomSpectra` is set to .TRUE., read-in absorption and
scattering spectra for each optical type :math:`i` (grp_aptype) are
scaled according to size before being assigned to a specific model plankton
type :math:`j` following :cite:`dutkiewicz:2020`.  Reference sizes for
absorption and scattering are read in as effective spherical diameters,
:math:`d^{\op{a}}_i`, :math:`d^{\op{aC}}_i`, :math:`d^{\op{b}}_i`, and
converted to volumes, :math:`V^{\op{a}}_i`, :math:`V^{\op{aC}}_i`,
:math:`V^{\op{b}}_i` via :math:`V=\frac{\pi}{6}d^3`.

Absorption
++++++++++

Read-in absorption spectra, :math:`a^{\op{meas}}_i`, are scaled in terms of volume,

.. math::

      a^{\op{chl}}_{\op{phy}j,l} &= a^{\op{meas}}_{i l} \cdot
                      (V_j/V^{\op{a}}_i)^{s^{\op{a}}}
      \;,

      a^{\op{chl}}_{\op{ps}j,l} &= a^{\op{ps\ meas}}_{i l} \cdot
                                (V_j/V^{\op{a}}_i)^{s^{\op{a}}}
      \;.

Carbon-specific absorption is scaled similarly but with a different reference size,

.. math::

      a^{\op{C}}_{\op{phy}j,l} = a^{\op{C\,meas}}_{i l} \cdot
                              (V_j/V^{\op{aC}}_i)^{s^{\op{a}}}
      \;.

Total scattering
++++++++++++++++

Total scattering coefficients are converted from carbon to cell-density specific
using the relation between volume and carbon content of :cite:`montagnes:1994`,

.. math::

   Q^{\op{C}} = a^{\op{C}}_{\op{cell}} V^{b^{\op{C}}_{\op{cell}}}
   \;.

The cell-density-specific coefficients are then scaled in terms of diameter and
converted back to carbon specific,

.. math::

   b^{\op{C}}_{\op{phy}j,l} Q^{\op{C}}_j = b^{\op{meas}}_{i l} Q^{\op{C\,b}}_i \cdot
                    \left( d_j/d^{\op{b}}_i \right)^{s^{\op{b}}_{i l}}
   \;.

There are 2 slopes for small and large measured cell sizes:

.. math::

   s^{\op{b}}_{i l} = \begin{cases}
        s^{\op{bl}}_l
            & \text{if } d^{\op{b}}_i \ge 10^{\ell^{\op{b}}_l} \\
        s^{\op{bs}}_l
            & \text{else.}
     \end{cases}

Backscattering
++++++++++++++

We scale the non-spectral mean backscattering ratio using the reference
diameter for total scattering,

.. math::
   \tilde b_{\op{b}j} = \tilde b_{\op{b}i}^{\op{meas}} \cdot
                        \left( d_j/d^{\op{b}}_i \right)^{s^{\op{bbb}}}
   \;,

where

.. math::

   \tilde b_{\op{b}i}^{\op{meas}} =
     \frac{\sum_l b^{\op{meas}}_{\op{b}i l} \Delta\lambda_l}
          {\sum_l b^{\op{meas}}_{i l} \Delta\lambda_l}

and compute spectral backscattering from total scattering,

.. math::

   b^{\op{C}}_{\op{b}\op{phy}j,l} = b^{\op{C}}_{\op{phy}j,l} \tilde b_{\op{b}j}
     \;.

.. csv-table:: Allometric scaling parameters
   :delim: &
   :widths: auto
   :class: longtable
   :header: Param, Symbol, Default, Units, Description

   :varlink:`darwin_allomSpectra`      &                                & .FALSE.  &           & enable/disable allometric scaling of plankton absorption and scattering spectra
   :varlink:`darwin_aCarCell`          & :math:`a^{\op{C}}_{\op{cell}}` & 0.109E-9 & mg C/cell & coefficient coefficient for scaling plankton spectra
   :varlink:`darwin_bCarCell`          & :math:`b^{\op{C}}_{\op{cell}}` & 0.991    &           & coefficient coefficient for scaling plankton spectra
   :varlink:`darwin_absorpSlope`       & :math:`s^{\op{a}}`             & -0.075   &           & slope for scaled absorption spectra
   :varlink:`darwin_bbbSlope`          & :math:`s^{\op{bbb}}`           & -1.458   &           & slope for scaled backscattering ratio spectra
   :varlink:`darwin_scatSwitchSizeLog` & :math:`\ell^{\op{b}}_l`        & 0        & log(μm)   & log of size for switching slopes
   :varlink:`darwin_scatSlopeSmall`    & :math:`s^{\op{bs}}_l`          & 1.5      &           & slope for small plankton
   :varlink:`darwin_scatSlopeLarge`    & :math:`s^{\op{bl}}_l`          & 1.5      &           & slope for large plankton


Photosynthetically Active Radation
''''''''''''''''''''''''''''''''''

Radtrans provides spectral radiances in W m\ :sup:`-2` at vertical grid cell
boundaries, :math:`E_0^{\op{F}}`.  These are converted to photosynthetically
available radiation,

.. math::

   I^{\op{F}}_l = 10^{-3} \frac{\lambda_l}{N_{\op{A}}h c}
                         E^{\op{F}}_{0\,l}

where :math:`h=6.6256\cdot 10^{-34}`, :math:`c=2.998\cdot 10^8` and
:math:`N_{\op{A}}=6.023\cdot 10^{23}`, and the pre-factor is for converting
:math:`\lambda` from nm to m and the result from Ein to µEin.  PAR at the
grid-cell center is computed as a geometric mean,

.. math::

   I_l(r^{\op{C}}_k) = \sqrt{
       I^{\op{F}}_l(r^{\op{F}}_k)
       I^{\op{F}}_l(r^{\op{F}}_{k+1})}
   \;.

