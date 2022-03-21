.. include:: ../defs.hrst

Model equations
^^^^^^^^^^^^^^^

The basic model equations are (omitting transport terms handled by the ptracers
package, sinking and swimming terms discussed in
:numref:`para_phys_pkg_darwin_sink`, terms correcting conservation with the
linear free surface formulation discussed in
:numref:`para_phys_pkg_darwin_cons`) and surface fluxes related to
:ref:`CarbonChemistry`:

.. math::

   \partial_t\op{DIC}   &= \sum_j \bigl( (-U^{\op{DIC}}_j + R^{\mathrm{C}}_j)
                                         \cdot (1 + R^{\text{PIC:POC}}_j)
                                         + R^{\op{DIC}}_j
                                  \bigr)
                           + R_{\op{DOC}} + [R_{\op{POC}}]
                           + \kappa^{{\text{diss}}}_{\mathrm{C}}\op{PIC} \\
   \partial_t\op{PO}_4  &= \sum_j \bigl( -U^{\op{PO4}}_j + R^{\mathrm{P}}_j + R^{\op{PO4}}_j \bigr)
                           + R_{\op{DOP}} + [R_{\op{POP}}] \\
   \partial_t\op{NH}_4  &= \sum_j \bigl( -U^{\op{NH4}}_j + R^{\mathrm{N,NH4}}_j + R^{\op{NH4}}_j \bigr)
                           + R_{\op{DON}} + [R_{\op{PON}}] - P_{\op{NO2}} - D_{\op{NH4}} \\
   \partial_t\op{NO}_2  &= \sum_j \bigl( -U^{\op{NO2}}_j + R^{\mathrm{N,NO2}}_j + R^{\op{NO2}}_j \bigr)
                           + P_{\op{NO2}} - P_{\op{NO3}} \\
   \partial_t\op{NO}_3  &= \sum_j \bigl( -U^{\op{NO3}}_j + R^{\mathrm{N,NO3}}_j + R^{\op{NO3}}_j \bigr)
                           + P_{\op{NO3}} - D_{\op{NO3}} \\
   \partial_t\op{FeT}   &= \sum_j \bigl( -U^{\op{Fe}}_j + R^{\mathrm{Fe}}_j + R^{\op{FeT}}_j \bigr)
                           + R_{\op{DOFe}} + [R_{\op{POFe}}] + S_{\op{Fe}} \\
   \partial_t\op{SiO}_2 &= \sum_j \bigl( -U^{\op{SiO2}}_j + R^{\mathrm{Si}}_j \bigr)
                           + R_{\op{POSi}} \\
   \partial_t c_j       &= U^{\op{DIC}}_j - M_j - R^{\mathrm{C}}_j - G_j + g_j^{\mathrm{C}} \\
   \partial_t p_j       &= U^{\op{PO4}}_j - M_j Q^{\mathrm{P}}_j - G_j Q^{\mathrm{P}}_j + g_j^{\mathrm{P}}         \qquad\text{(with P quota)} \\
   \partial_t n_j       &= U^{{\op{N}}}_j \;\;\; - M_j Q^{\mathrm{N}}_j - G_j Q^{\mathrm{N}}_j + g_j^{\mathrm{N}}  \qquad\text{(with N quota)} \\
   \partial_t\op{fe}_j  &= U^{\op{Fe}}_j \;\; - M_j Q^{\op{Fe}}_j - G_j Q^{\op{Fe}}_j + g_j^{\op{Fe}}              \qquad\text{(with Fe quota)} \\
   \partial_t\op{si}_j  &= U^{\op{SiO2}}_j - M_j Q^{\op{Si}}_j - G_j Q^{\op{Si}}_j                                 \qquad\text{(with Si quota)} \\
   \partial_t\op{Chl}_j &= S^{\op{Chl}}_j \; - M_j \cdot \op{Chl\text{:}C}_j - G_j \cdot \op{Chl\text{:}C}_j       \qquad\text{(with Chl quota)} \\
   \partial_t\op{DOC}   &= \sum_j M_j^{\op{DOM}} \;\;\;\;\;         + g^{\op{DOC}}  + \sum_j \left( H^{\op{POC}}_j - U^{\op{DOC}}_j \right) - R_{\op{DOC}} - S_{\op{CDOM}} R^{{\mathrm{C}}:{\mathrm{P}}}_{\op{CDOM}} \\
   \partial_t\op{DOP}   &= \sum_j M_j^{\op{DOM}} Q_j^{{\mathrm{P}}} + g^{\op{DOP}}  + \sum_j \left( H^{\op{POP}}_j - U^{\op{DOP}}_j \right) - R_{\op{DOP}} - S_{\op{CDOM}} \\
   \partial_t\op{DON}   &= \sum_j M_j^{\op{DOM}} Q_j^{{\mathrm{N}}} + g^{\op{DON}}  + \sum_j \left( H^{\op{PON}}_j - U^{\op{DON}}_j \right) - R_{\op{DON}} - S_{\op{CDOM}} R^{{\mathrm{N}}:{\mathrm{P}}}_{\op{CDOM}} \\
   \partial_t\op{DOFe}  &= \sum_j M_j^{\op{DOM}} Q_j^{\op{Fe}}      + g^{\op{DOFe}} + \sum_j \left( H^{\op{POFe}}_j- U^{\op{DOFe}}_j\right) - R_{\op{DOFe}}- S_{\op{CDOM}} R^{{\mathrm{Fe}}:{\mathrm{P}}}_{\op{CDOM}} \\
   \partial_t\op{PIC}   &= \sum_j M_j     R_j^{\text{PIC:POC}}      + g^{\op{PIC}} - \kappa^{{\text{diss}}}_{\mathrm{C}}\op{PIC} \\
   \partial_t\op{POC}   &= \sum_j M_j^{\op{POM}} \;\;\;\;\;         + g^{\op{POC}}  - \sum_j U^{\op{POC}}_j  - R_{\op{POC}} \\
   \partial_t\op{POP}   &= \sum_j M_j^{\op{POM}} Q_j^{{\mathrm{P}}} + g^{\op{POP}}  - \sum_j U^{\op{POP}}_j  - R_{\op{POP}} \\
   \partial_t\op{PON}   &= \sum_j M_j^{\op{POM}} Q_j^{{\mathrm{N}}} + g^{\op{PON}}  - \sum_j U^{\op{PON}}_j  - R_{\op{PON}} \\
   \partial_t\op{POFe}  &= \sum_j M_j^{\op{POM}} Q_j^{\op{Fe}}      + g^{\op{POFe}} - \sum_j U^{\op{POFe}}_j - R_{\op{POFe}} \\
   \partial_t\op{POSi}  &= \sum_j M_j Q_j^{\op{Si}} \;\;\;\;\;      + g^{\op{POSi}}                          - R_{\op{POSi}} \\
   \partial_t\op{ALK}   &= -\biggl( P_{\op{NO3}} - \sum_j U^{\op{NO3}}_j \biggr)
       - 2\biggl( \sum_j U^{\op{DIC}}_j R^{{\text{PIC:POC}}}_j - \kappa^{{\text{diss}}}_{\mathrm{C}}\op{PIC}\biggr)
       + D_{\op{NO3}} \\
   \partial_t{\mathrm{O}}_2 &= R_{\mathrm{O}_2:\mathrm{P}} \biggl(
                                   \sum_j U^{\op{PO4}}_j
                                   - R_{\op{DOP}} - [R_{\op{POP}}]
                               \biggr)
   \\
   \partial_t\op{CDOM}  &= S_{\op{CDOM}} \qquad\text{(with CDOM tracer)} \\


The following abbreviated source terms are described in sections below:

- :math:`U`: uptake, see :ref:`Uptake` and :ref:`Bacteria`,
  also :ref:`Growth`, :ref:`CarbonStore`, :ref:`Light` and :ref:`Spectral`
- :math:`M`: :ref:`Mortality`
- :math:`R^{\mathrm{C}}`: :ref:`Respiration`
- :math:`H`, :math:`R_j`: bacterial hydrolysis and remineralization, see :ref:`Bacteria`
- :math:`R`, :math:`P`: parameterized :ref:`Remineralization`
- :math:`D`: denitrification, see :ref:`Denitrification`
- :math:`g`, :math:`G`: grazing gains and losses, see :ref:`Grazing`
- :math:`S^{\op{Chl}}`: synthesis, see :ref:`Synthesis`
- :math:`S_{\op{Fe}}`: iron sources, see :ref:`Iron`
- :math:`S_{\op{CDOM}}`: see :ref:`CDOM`.

With :varlink:`DARWIN_ALLOW_CDOM`, all particulate remineralization terms
(in square brackets [...]) except Si are absent.
Without :varlink:`DARWIN_ALLOW_CDOM`, :math:`f_{\op{CDOM}}=0` and there is no CDOM tracer.


.. csv-table:: General parameters
   :delim: &
   :widths: 15,17,14,11,18,25
   :class: longtable
   :header: Trait, Param, Symbol, Default, Units, Description

                       & :varlink:`Kdissc`     & :math:`\kappa^{\op{diss}}_{\mathrm{C}}` & 1/(300 days) & 1/s                       & dissolution rate for PIC
   :varlink:`R_PICPOC` & :varlink:`a_R_PICPOC` & :math:`R^{\op{PIC:POC}}_j`              & 0.8          & mmol PIC / mmol POC       & inorganic-organic carbon ratio
                       & :varlink:`R_OP`       & :math:`R_{\mathrm{O}_2:\mathrm{P}}`      & 170          & mmol O\ :sub:`2` / mmol P & O\ :sub:`2`:P ratio for respiration and consumption

