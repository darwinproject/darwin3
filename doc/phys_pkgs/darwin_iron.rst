.. include:: ../defs.hrst

.. _Iron:

Iron chemistry
^^^^^^^^^^^^^^

The tracer representing inorganic iron in darwin is total dissolved inorganic
iron, FeT.  Its source terms are

.. math::

   S_{\op{Fe}} &= \delta_{k,1} \frac{\alpha_{\op{Fe}}}{\Delta r_{\mathrm{F}}h_{\mathrm{C}}} F_{\op{Fe}}
             + \delta_{\op{bottom}} \delta_{|r|\le d_{\op{sed}}}
               \frac{1}{\Delta r_{\mathrm{F}}h_{\mathrm{C}}} F_{\op{Fe}}^{{\text{sed}}}
               \\
             &+ \delta_{\op{bottom}} \delta_{|r|\ge d_{\op{vents}}}
               \frac{1}{\Delta r_{\mathrm{F}}h_{\mathrm{C}}} F_{\op{Fe}}^{{\text{vents}}}
             - r_{{\text{scav}}}\op{Fe}'

where :math:`\delta_{\op{bottom}}` selects the last ocean grid cell above the sea floor.


Dust deposition
'''''''''''''''

The first term is iron input at the surface from dust deposition.
The rate of dust deposition is read in from :varlink:`ironfile`.
:math:`\alpha_{\op{Fe}}` (:varlink:`alpfe`) is the solubility of iron dust;
set it to 1 if the deposition rate in :varlink:`ironfile` is already of
soluble iron.  :varlink:`darwin_inscal_iron` can be used to convert units on the fly.


Sedimentation
'''''''''''''

The second term represents iron input from sediments at the ocean floor.
It only occurs above :varlink:`depthfesed`.  The flux is either a fixed number,
:varlink:`fesedflux` or, if :varlink:`DARWIN_IRON_SED_SOURCE_VARIABLE` is defined,

.. math::

   F_{\op{Fe}}^{{\text{sed}}}=
       \left[
       F_{\op{Fe}}^{\op{sed pcm}} w^{\mathrm{C}}_{{{\text{sink}}}} \op{POC}
       - F_{\op{Fe}}^{\op{sed min}}
       \right]_0

For backwards compatibility, the variable sediment flux can be expressed in
terms of POP if :varlink:`DARWIN_IRON_SED_SOURCE_POP` is defined:

.. math::

   F_{\op{Fe}}^{{\text{sed}}}=
       F_{\op{Fe}}^{\op{sed pcm}} w^{\mathrm{P}}_{{{\text{sink}}}}
       R^{{\mathrm{C}}:{\mathrm{P}}}_{{\text{sed}}}  \op{POP}^{\op{up}}

where :math:`\op{POP}^{\op{up}}` is POP in the second-lowest wet grid cell
of the water column.


Hydrothermal vents
''''''''''''''''''

The third term represents iron input from hydrothermal vents.  To enable it,
define :varlink:`DARWIN_ALLOW_HYDROTHERMAL_VENTS`.  This iron source is only
active below :varlink:`depthFeVent`.  The flux is proportional to the
Helium-3 flux :math:`F_{^3\text{He}}^{{\text{vents}}}` given in
:varlink:`ventHe3file` in units of mmol :sup:`3`\ He m\ :sup:`-2` s\ :sup:`-1`,

.. math::

   F_{\op{Fe}}^{\text{vents}} = \alpha_{\op{Fe}}^{\op{vents}}
       R^{\op{Fe:^3He}}_{\op{vents}} F_{^3\text{He}}^{{\text{vents}}}
   \;.

Here, :math:`\alpha_{\op{Fe}}^{\op{vents}}` (:varlink:`solFeVent`) is the
solubility of iron from vents and :math:`R^{\op{Fe:^3He}}_{\op{vents}}`
(:varlink:`R_FeHe3_vent`) is the iron to Helium-3 ratio of the vents.


Scavenging
''''''''''

The fourth term represents losses due to particle scavenging.
The scavenging rate for free iron is

.. math::

   r_{{\text{scav}}}= \begin{cases}
       \op{scav}
       & \text{for fixed-rate scavenging,} \\
       \tau_{{\text{scav}}}I_{{\text{scav}}}\op{POM}^{e_{{\text{scav}}}}
       & \text{for particle-based scavenging.}
       \end{cases}

To select particle-based scavenging following Parekh et al. (2005)
:cite:`parekh:2005`, define :varlink:`DARWIN_PART_SCAV`.  POM is the
concentration of particulate organic matter in units of mg/L.  It is
parameterized in terms of POC, PSi and PIC,

.. math::

   \op{POM} = w^{\text{scav}}_{\text{POC}} \op{POC}
            + w^{\text{scav}}_{\text{PSi}} \op{PSi}
            + w^{\text{scav}}_{\text{PIC}} \op{PIC}
            + \op{rPOM}
   \;.

By default, only POC contributes, see
:numref:`tab_phys_pkgs_darwin_iron_params`.

.. admonition:: deprecated formulation

   The old (and deprecated) formulation of scavenging in terms of POP can be
   recovered by defining :varlink:`DARWIN_PART_SCAV_POP`, in which case
   :math:`\op{POM}` is replaced by
   :math:`\op{POP}\!/R^{\op{POP}:\op{POC}}_{{\text{scav}}}`.  Parameter names
   and defaults are different in this case, see
   :numref:`tab_phys_pkgs_darwin_scav_pop`.  The new formulation with default
   parameters closely approximates the old formulation with its default
   parameters when POC:POP is 120:1.

The concentration of free iron, Fe', is determined following Parekh et al.
(2004) :cite:`parekh:2004` and Dutkiewicz et al. (2005)
:cite:`dutkiewicz:2005`.  Free dissolved iron is assumed to be in equilibrium
with dissolved iron bound to ligands, FeL,

.. math:: \op{Fe}' + L' \rightleftharpoons \op{FeL}

At equilibrium,

.. math:: \frac{[\op{FeL}]}{[\op{Fe}'][L']} = {\beta_{{\text{stab}}}}\;,

Using
:math:`\op{FeL}+\op{Fe}'={\op{FeT}}` and :math:`\op{FeL}+L'={L_{{\mathrm{T}}}}`,
the solution is obtained as

.. math::

     L' &= \frac{ {\beta_{{\text{stab}}}}({L_{{\mathrm{T}}}}- {\op{FeT}}) - 1
                +\sqrt{(1 - {\beta_{{\text{stab}}}}({L_{{\mathrm{T}}}}- {\op{FeT}}))^2 + 4 {\beta_{{\text{stab}}}}{L_{{\mathrm{T}}}}}}
             {2 {\beta_{{\text{stab}}}}}

     \op{FeL} &= {L_{{\mathrm{T}}}}- L'

     \op{Fe}' &= \op{FeT} - \op{FeL}\;.

If :varlink:`DARWIN_MINFE` is defined, Fe' will be
constrained to be no more than Fe':sub:`max`, and FeT adjusted accordingly,
assuming that excess free iron is scavenged away. This is done before
and after each biogeochemical subtimestep.

.. csv-table:: Iron parameters set in DARWIN_PARAMS
   :delim: &
   :widths: auto
   :header: Parameter, Symbol, Default, Units, Description
   :name: tab_phys_pkgs_darwin_iron_params

   :varlink:`alpfe`         & :math:`\alpha_{\op{Fe}}`             & 0.04        &                        & solubility of Fe dust
   :varlink:`depthfesed`    & :math:`d_{\op{sed}}`                 & -1.0        & m                      & depth above which to add sediment source
   :varlink:`fesedflux`     & fesedflux                            & 1E-3 / day  & mmol Fe /m\ :sup:`2`/s & fixed iron flux from sediment
   :varlink:`fesedflux_pcm` & :math:`F_{\op{Fe}}^{\op{sed pcm}}`   & 0.68E-3     & mmol Fe / mmol C       & iron input per POC sinking into bottom for :varlink:`DARWIN_IRON_SED_SOURCE_VARIABLE`
   :varlink:`fesedflux_min` & :math:`F_{\op{Fe}}^{\op{sed min}}`   & 0.5E-3 / day& mmol Fe /s             & minimum iron input rate subtracted from fesedflux_pcm*wc_sink*POC
   :varlink:`R_CP_fesed`    & :math:`R^{\op{C:P}}_{\op{sed}}`      & 106         & mmol C / mmol P        & POC:POP conversion for :varlink:`DARWIN_IRON_SED_SOURCE_VARIABLE`
   :varlink:`depthFeVent`   & :math:`d_{\op{vents}}`               & 750         & m                      & depth below which iron from hydrothermal vents is added
   :varlink:`solFeVent`     & :math:`\alpha_{\op{Fe}}^{\op{vents}}` & 0.002      &                        & solubility of iron from hydrothermal vents
   :varlink:`R_FeHe3_vent`  & :math:`R^{\op{Fe:^3He}}_{\op{vents}}` & 4.5E8      & mol Fe / mol :sup:`3`\ He & Fe:\ :sup:`3`\ He ratio for hydrothermal vents
   :varlink:`scav`          & scav                                 & 0.4/year    & 1/s                    & fixed iron scavenging rate
   :varlink:`scav_tau`      & :math:`\tau_{\op{scav}}`             & 0.2         &                        & factor for converting Th scavenging rates to iron ones
   :varlink:`scav_inter`    & :math:`I_{\op{scav}}`                & 0.079 / day & L\ :sup:`e` mg\ :sup:`-e` s\ :sup:`-1` & intercept of scavenging power law (e=e\ :sub:`scav`)
   :varlink:`scav_exp`      & :math:`e_{\op{scav}}`                & 0.58        &                        & exponent of scavenging power law
   :varlink:`scav_POC_wgt`  & :math:`w^{\op{scav}}_{\op{POC}}`     & 0.12728     & g/mmol |nbsp| C        & weight POC contributes to POM
   :varlink:`scav_PSi_wgt`  & :math:`w^{\op{scav}}_{\op{PSi}}`     & 0.0         & g/mmol |nbsp| Si       & weight PSi contributes to POM
   :varlink:`scav_PIC_wgt`  & :math:`w^{\op{scav}}_{\op{PIC}}`     & 0.0         & g/mmol |nbsp| C        & weight PIC contributes to POM
   :varlink:`scav_rPOM`     & :math:`\op{rPOM}`                    & 0.0         & g/m\ :sup:`3`          & concentration of non-labile POM for scavenging
   :varlink:`ligand_tot`    & :math:`L_{\op{T}}`                   & 1E-3        & mmol/m\ :sup:`3`       & total ligand concentration
   :varlink:`ligand_stab`   & :math:`\beta_{\op{stab}}`            & 0.2E6       & m\ :sup:`3`/mmol       & ligand stability rate ratio
   :varlink:`freefemax`     & :math:`\op{Fe}'_{\op{max}}`          & 0.4E-3      & mmol/m\ :sup:`3`       & max concentration of free iron


.. csv-table:: Iron parameters for :varlink:`DARWIN_PART_SCAV_POP`
   :delim: &
   :widths: auto
   :header: Parameter, Symbol, Default, Units, Description
   :name: tab_phys_pkgs_darwin_scav_pop

   :varlink:`scav_rat`      & :math:`\tau_{\op{scav}}`             & 0.005 / day & 1/s                       & rate factor
   :varlink:`scav_inter`    & :math:`I_{\op{scav}}`                & 0.079       & L\ :sup:`e` mg\ :sup:`-e` & intercept of scavenging power law (e=e\ :sub:`scav`)
   :varlink:`scav_exp`      & :math:`e_{\op{scav}}`                & 0.58        &                           & exponent of scavenging power law
   :varlink:`scav_R_POPPOC` & :math:`R^{\op{POP:POC}}_{\op{scav}}` & 1.1321E-4   & mmol |nbsp| P / g         & POP\:POC ratio
