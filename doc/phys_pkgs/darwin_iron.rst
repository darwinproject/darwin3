.. include:: ../defs.hrst

.. _Iron:

Iron chemistry
^^^^^^^^^^^^^^

The tracer representing inorganic iron in darwin is total dissolved inorganic
iron, FeT.  Its source terms are

.. math::

   S_{\op{Fe}} = \delta_{k,1} \frac{\alpha_{\op{Fe}}}{\Delta r_{\mathrm{F}}h_{\mathrm{C}}} F_{\op{Fe}}
             + \delta_{\op{bottom}} \delta_{|r|\le\op{depthfesed}}
               \frac{1}{\Delta r_{\mathrm{F}}h_{\mathrm{C}}} F_{\op{Fe}}^{{\text{sed}}}- r_{{\text{scav}}}\op{Fe}'

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


Scavenging
''''''''''

The third term represents losses due to particle scavenging.
The scavenging rate for free iron is

.. math::

   r_{{\text{scav}}}= \begin{cases}
       r_{{\text{scav}}}I_{{\text{scav}}}\op{POC}^{e_{{\text{scav}}}}
       & \text{for POM-based scavenging,} \\
       \op{scav}
       & \text{for constant scavenging.}
       \end{cases}

To select POM-based scavenging, #define :varlink:`DARWIN_PART_SCAV`.
If :varlink:`DARWIN_PART_SCAV_POP` is defined, :math:`\op{POC}` is
replaced by :math:`\op{POP}\!/R^{\op{POP}:\op{POC}}_{{\text{scav}}}`.

The concentration of free iron is determined following
Parekh et al. (2004) :cite:`parekh:2004` and
Dutkiewicz et al. (2005) :cite:`dutkiewicz:2005`.  Free dissolved iron,
Fe', is assumed to be in equilibrium with dissolved iron bound
to ligands, FeL,

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

   :varlink:`alpfe`         & :math:`\alpha_{\op{Fe}}`             & 0.04        &                        & solubility of Fe dust
   :varlink:`depthfesed`    & depthfesed                           & -1.0        & m                      & depth above which to add sediment source
   :varlink:`fesedflux`     & fesedflux                            & 1D-3 / day  & mmol Fe /m\ :sup:`2`/s & fixed iron flux from sediment
   :varlink:`fesedflux_pcm` & :math:`F_{\op{Fe}}^{\op{sed pcm}}`   & 0.68D-3     & mmol Fe / mmol C       & iron input per POC sinking into bottom for :varlink:`DARWIN_IRON_SED_SOURCE_VARIABLE`
   :varlink:`fesedflux_min` & :math:`F_{\op{Fe}}^{\op{sed min}}`   & 0.5D-3 / day& mmol Fe /s             & minimum iron input rate subtracted from fesedflux_pcm*wc_sink*POC
   :varlink:`R_CP_fesed`    & :math:`R^{\op{C:P}}_{\op{sed}}`      & 106         & mmol C / mmol P        & POC:POP conversion for :varlink:`DARWIN_IRON_SED_SOURCE_VARIABLE`
   :varlink:`scav`          & scav                                 & 0.4/year    & 1/s                    & fixed iron scavenging rate
   :varlink:`scav_rat`      & :math:`r_{\op{scav}}`                & 0.005 / day & 1/s                    & rate of POM-based iron scavenging
   :varlink:`scav_inter`    & :math:`I_{\op{scav}}`                & 0.079       &                        & intercept of scavenging power law
   :varlink:`scav_exp`      & :math:`e_{\op{scav}}`                & 0.58        &                        & exponent of scavenging power law
   :varlink:`scav_R_POPPOC` & :math:`R^{\op{POP:POC}}_{\op{scav}}` & 1.1321D-4   & mmol P / mmol C        & POP\:POC ratio for :varlink:`DARWIN_PART_SCAV_POP`
   :varlink:`ligand_tot`    & :math:`L_{\op{T}}`                   & 1D-3        & mmol/m\ :sup:`3`       & total ligand concentration
   :varlink:`ligand_stab`   & :math:`\beta_{\op{stab}}`            & .2D6        & m\ :sup:`3`/mmol       & ligand stability rate ratio
   :varlink:`freefemax`     & :math:`\op{Fe}'_{\op{max}}`          & 0.4D-3      & mmol/m\ :sup:`3`       & max concentration of free iron

