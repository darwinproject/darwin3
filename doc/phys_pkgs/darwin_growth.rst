.. include:: ../defs.hrst

.. _Growth:

Growth
^^^^^^

Without :varlink:`DARWIN_ALLOW_GEIDER`, the carbon-specific growth rate is

.. math::

   P^{\mathrm{C}}_j = P_{{\mathrm{C}},j}^{\max} \gamma^{\op{nut}}_j
   \gamma^{\op{light}}_j f^{{{\text{phy}}}}_j(T) \gamma_{\op{pCO2}}

where

.. math::

   \gamma^{\op{light}}_j = (1 - \mathrm{e}^{-k^{\op{sat}}_{\op{PAR}j} I}) \cdot
          \mathrm{e}^{-k^{\op{inh}}_{\op{PAR}j} I} \cdot n^{\op{light}}_j

and :math:`n^{\op{light}}_j` normalizes the maximum of
:math:`\gamma^{\op{light}}_j` with respect to :math:`I` to unity.  For
:math:`\gamma^{\op{nut}}_j`, see :numref:`Uptake`, for
:math:`f^{\op{phy}}_j(T)`, see :numref:`Temperature`.
:math:`\gamma_{\op{pCO2}}` is currently set to 1 in the code.

..
   n^{\op{light}}_j = \frac{k^{\op{sat}}_{\op{PAR}j}+k^{\op{inh}}_{\op{PAR}j}}
                           {k^{\op{sat}}_{\op{PAR}j}}
         \left( \frac{k^{\op{inh}}_{\op{PAR}j}}{k^{\op{sat}}_{\op{PAR}j}
                + k^{\op{inh}}_{\op{PAR}j}}
         \right)^{-k^{\op{inh}}_{\op{PAR}j}/k^{\op{sat}}_{\op{PAR}j}}


With :varlink:`DARWIN_ALLOW_GEIDER`,

.. math::

   P^{\mathrm{C}}_j = P^{{\mathrm{C}}{\op{m}}}_j \left(
       1 - \exp\left\{ -\frac{\gamma^{\op{QFe}}_j
                        \langle\alpha I\rangle_j
                        \op{Chl\text{:}C}_j }{ P^{{\mathrm{C}}{\op{m}}}_j }
               \right\}
     \right) \gamma^{{{\text{inhib}}}}_j
     \qquad\text{if } I_{\op{tot}}>I_{\min}

where

.. math::

   \langle\alpha I\rangle_j = \sum_{l=1}^{\op{nlam}} \alpha^{\op{Chl}}_{j,l} I_l
   \quad\text{and}\quad
   I_{\op{tot}} = \sum_{l=1}^{\op{nlam}} I_l

and :math:`I_l` is photosynthetically active radiation.  The Chlorophyll
a-specific initial slope of the photosynthesis-light curve is computed from the
maximum quantum yield of carbon fixation and the coefficient of absorption by
photosynthetically active pigments (see :numref:`Spectral`),

.. math::

   \alpha^{\op{Chl}}_{j,l} = \Phi_{\op{m}j} a^{\op{chl}}_{\op{ps}j,l}
   \;.

Without the radtrans package, spectral PAR, :math:`I_l`, is replaced by total
PAR and the spectral absorption coefficient by an average one,
:varlink:`aphy_chl_ave`.  The maximum growth rate is

.. math::

   P^{{\mathrm{C}}{\op{m}}}_j = P_{{\mathrm{C}},j}^{\max} \gamma^{\op{nut}}_j
                                f^{{{\text{phy}}}}_j(T) \gamma_{\op{pCO2}}
   \;.

The iron limitation term, :math:`\gamma^{\op{QFe}}_j`, is discussed in
:numref:`Uptake`.

With :varlink:`DARWIN_ALLOW_CHLQUOTA`, :math:`\op{Chl\text{:}C}_j` is computed
from plankton Chlorophyll and carbon tracers.  Without,

.. math::

   \op{Chl\text{:}C}_j = \op{Chl\text{:}C}_j^{\op{acclim}}

where

.. math::
   :label: chl2cacclim

   \op{Chl\text{:}C}_j^{\op{acclim}} = \left[
         \frac{\op{Chl\text{:}C}^{\max}_j}
              {1 + \op{Chl\text{:}C}^{\max}_j\langle\alpha I\rangle_j
                   /(2P^{{\mathrm{C}}{\op{m}}}_j)}
       \right]_{\op{Chl\text{:}C}^{\min}_j}^{\op{Chl\text{:}C}^{\max}_j}

If :math:`P^{{\mathrm{C}}{\op{m}}}_j=0`, we set
:math:`\op{Chl\text{:}C}_j^{\op{acclim}}=\op{Chl\text{:}C}^{\min}_j`.  With the
readtrans package,

.. math::

   \op{Chl\text{:}C}^{\min}_j = \frac{\op{Chl\text{:}C}^{\max}_j}
      { 1 + 2000 \op{Chl\text{:}C}^{\max}_j \overline\alpha_j
            /(2 P^{\max}_{\op{C},j}) }
   \;,

otherwise zero.  Here,

.. math::

   \overline{\alpha}_j = \sum_l \Delta\lambda_l \alpha^{\op{Chl}}_{j,l} \Big/
                           \sum_l \Delta\lambda_l
     \;.

Photo inhibition is parameterized as

.. math::

   \gamma^{{{\text{inhib}}}}_j = \begin{cases}
       c^{\op{inhib}}_j \cdot \op{EkoverE} & \text{if } \op{EkoverE} \le 1 \\
       1                                   & \text{otherwise}
     \end{cases}

where

.. math::

   \op{EkoverE} = \frac{P^{{\mathrm{C}}{\op{m}}}_j/(\op{Chl\text{:}C}_j\cdot\overline{\alpha}_j)}
                  {\langle\alpha I\rangle_j/\overline{\alpha}_j}
   \;.

:numref:`tab_phys_pkgs_darwin_growth` summarized the parameters relevant for
growth.

.. csv-table:: Growth parameters
   :delim: &
   :widths: auto
   :class: longtable
   :header: Trait, Param, Symbol, Default, Units, Description
   :name: tab_phys_pkgs_darwin_growth

   :varlink:`ksatPAR`     & :varlink:`a_ksatPAR`        & :math:`k^{\op{sat}}_{\op{PAR}}`   & 0.012                    & m\ :sup:`2` s μEin\ :sup:`-1`   & saturation coefficient for PAR
   :varlink:`kinhPAR`     & :varlink:`a_kinhPAR`        & :math:`k^{\op{inh}}_{\op{PAR}}`   & 0.006                    & m\ :sup:`2` s μEin\ :sup:`-1`   & inhibition coefficient for PAR
   :varlink:`PCmax`       & :varlink:`a <a_PCmax>`,\ :varlink:`b_PCmax`      & :math:`P^{\op{max}}_{\op{C}j}`    & (1/day) V\ :sup:`--0.15` & 1/s                             & maximum carbon-specific growth rate
                          & :varlink:`PARmin`           & :math:`I_{\min}`                  & 0.1                      & μEin/m\ :sup:`2`/s              & minimum light for photosynthesis
   :varlink:`mQyield`     & :varlink:`a_mQyield`        & :math:`\Phi_j`                    & 0.000075                 & mmol C (μEin)\ :sup:`-1`        & maximum quantum yield
   :varlink:`chl2cmax`    & :varlink:`a_chl2cmax`       & :math:`\op{Chl\text{:}C}^{\op{max}}_j` & 0.3                 & mg Chl (mmol C)\ :sup:`-1`      & maximum Chlorophyll-carbon ratio
   :varlink:`inhibGeider` & :varlink:`a_inhibGeider`    & :math:`c^{\op{inhib}}_j`          & 0.0                      &                                 & photo-inhibition coefficient for Geider growth
   :varlink:`aphy_chl_ps` & :varlink:`aphy_chl_ps_type` & :math:`a^{\op{chl}}_{\op{ps}j,l}` & read in                  & m\ :sup:`2` (mg Chl)\ :sup:`-1` & absorption by PS active pigments

:varlink:`aphy_chl_ps` is assigned from :varlink:`aphy_chl_ps_type` via
:varlink:`grp_aptype`.  The type-specific spectra are read in from
:varlink:`darwin_phytoAbsorbFile` and optionally scaled allometrically, see
:ref:`allomSpectra`.

