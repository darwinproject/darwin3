.. include:: ../defs.hrst

Model equations
^^^^^^^^^^^^^^^

The basic model equations are (omitting transport terms handled by the ptracers
package, :ref:`para_phys_pkg_darwin_sink`, :ref:`AirSea` and terms correcting
conservation with the linear free surface formulation discussed in
:numref:`para_phys_pkg_darwin_cons`):

.. math::

   \partial_t\op{DIC}   &= \sum_j \bigl( (-U^{\mathrm{DIC}}_j + R^{\mathrm{C}}_j)
                                         \cdot (1 + R^{\text{PIC:POC}}_j)
                                         + R^{\mathrm{DIC}}_j
                                  \bigr)
                           + R_{\mathrm{DOC}} + [R_{\mathrm{POC}}]
                           + D_{\mathrm{PIC}} \\
   \partial_t\op{PO}_4  &= \sum_j \bigl( -U^{\mathrm{PO4}}_j + R^{\mathrm{P}}_j + R^{\mathrm{PO4}}_j \bigr)
                           + R_{\mathrm{DOP}} + [R_{\mathrm{POP}}] \\
   \partial_t\op{NH}_4  &= \sum_j \bigl( -U^{\mathrm{NH4}}_j + R^{\mathrm{N,NH4}}_j + R^{\mathrm{NH4}}_j \bigr)
                           + R_{\mathrm{DON}} + [R_{\mathrm{PON}}] - P_{\mathrm{NO2}} - D_{\mathrm{NH4}} \\
   \partial_t\op{NO}_2  &= \sum_j \bigl( -U^{\mathrm{NO2}}_j + R^{\mathrm{N,NO2}}_j + R^{\mathrm{NO2}}_j \bigr)
                           + P_{\mathrm{NO2}} - P_{\mathrm{NO3}} \\
   \partial_t\op{NO}_3  &= \sum_j \bigl( -U^{\mathrm{NO3}}_j + R^{\mathrm{N,NO3}}_j + R^{\mathrm{NO3}}_j \bigr)
                           + P_{\mathrm{NO3}} - D_{\mathrm{NO3}} \\
   \partial_t\op{FeT}   &= \sum_j \bigl( -U^{\mathrm{Fe}}_j + R^{\mathrm{Fe}}_j + R^{\mathrm{FeT}}_j \bigr)
                           + R_{\mathrm{DOFe}} + [R_{\mathrm{POFe}}] + S_{\mathrm{Fe}} \\
   \partial_t\op{SiO}_2 &= \sum_j \bigl( -U^{\mathrm{SiO2}}_j + R^{\mathrm{Si}}_j \bigr)
                           + R_{\mathrm{POSi}} \\
   \partial_t c_j       &= U^{\mathrm{DIC}}_j - M_j - R^{\mathrm{C}}_j - G_j + g_j^{\mathrm{C}} \\
   \partial_t p_j       &= U^{\mathrm{PO4}}_j - M_j Q^{\mathrm{P}}_j - G_j Q^{\mathrm{P}}_j + g_j^{\mathrm{P}}          \qquad\text{(with P quota)} \\
   \partial_t n_j       &= U^{{\mathrm{N}}}_j \;\;\; - M_j Q^{\mathrm{N}}_j - G_j Q^{\mathrm{N}}_j + g_j^{\mathrm{N}}   \qquad\text{(with N quota)} \\
   \partial_t\op{fe}_j  &= U^{\mathrm{Fe}}_j \;\; - M_j Q^{\mathrm{Fe}}_j - G_j Q^{\mathrm{Fe}}_j + g_j^{\mathrm{Fe}}   \qquad\text{(with Fe quota)} \\
   \partial_t\op{si}_j  &= U^{\mathrm{SiO2}}_j - M_j Q^{\mathrm{Si}}_j - G_j Q^{\mathrm{Si}}_j                          \qquad\text{(with Si quota)} \\
   \partial_t\op{Chl}_j &= S^{\mathrm{Chl}}_j \; - M_j Q^{\mathrm{Chl}}_j - G_j Q^{\mathrm{Chl}}_j                      \qquad\text{(with Chl quota)} \\
   \partial_t\op{DOC}   &= \sum_j M_j^{\mathrm{DOM}} \;\;\;\;\;         + g^{\mathrm{DOC}}  + \sum_j \left( H^{\mathrm{POC}}_j - U^{\mathrm{DOC}}_j \right) - R_{\mathrm{DOC}} - S_{\mathrm{CDOM}} R^{{\mathrm{C}}:{\mathrm{P}}}_{\mathrm{CDOM}} \\
   \partial_t\op{DOP}   &= \sum_j M_j^{\mathrm{DOM}} Q_j^{{\mathrm{P}}} + g^{\mathrm{DOP}}  + \sum_j \left( H^{\mathrm{POP}}_j - U^{\mathrm{DOP}}_j \right) - R_{\mathrm{DOP}} - S_{\mathrm{CDOM}} \\
   \partial_t\op{DON}   &= \sum_j M_j^{\mathrm{DOM}} Q_j^{{\mathrm{N}}} + g^{\mathrm{DON}}  + \sum_j \left( H^{\mathrm{PON}}_j - U^{\mathrm{DON}}_j \right) - R_{\mathrm{DON}} - S_{\mathrm{CDOM}} R^{{\mathrm{N}}:{\mathrm{P}}}_{\mathrm{CDOM}} \\
   \partial_t\op{DOFe}  &= \sum_j M_j^{\mathrm{DOM}} Q_j^{\mathrm{Fe}}      + g^{\mathrm{DOFe}} + \sum_j \left( H^{\mathrm{POFe}}_j- U^{\mathrm{DOFe}}_j\right) - R_{\mathrm{DOFe}}- S_{\mathrm{CDOM}} R^{{\mathrm{Fe}}:{\mathrm{P}}}_{\mathrm{CDOM}} \\
   \partial_t\op{PIC}   &= \sum_j M_j     R_j^{\text{PIC:POC}}      + g^{\mathrm{PIC}} - D_{\mathrm{PIC}} \\
   \partial_t\op{POC}   &= \sum_j M_j^{\mathrm{POM}} \;\;\;\;\;         + g^{\mathrm{POC}}  - \sum_j U^{\mathrm{POC}}_j  - R_{\mathrm{POC}} \\
   \partial_t\op{POP}   &= \sum_j M_j^{\mathrm{POM}} Q_j^{{\mathrm{P}}} + g^{\mathrm{POP}}  - \sum_j U^{\mathrm{POP}}_j  - R_{\mathrm{POP}} \\
   \partial_t\op{PON}   &= \sum_j M_j^{\mathrm{POM}} Q_j^{{\mathrm{N}}} + g^{\mathrm{PON}}  - \sum_j U^{\mathrm{PON}}_j  - R_{\mathrm{PON}} \\
   \partial_t\op{POFe}  &= \sum_j M_j^{\mathrm{POM}} Q_j^{\mathrm{Fe}}      + g^{\mathrm{POFe}} - \sum_j U^{\mathrm{POFe}}_j - R_{\mathrm{POFe}} \\
   \partial_t\op{POSi}  &= \sum_j M_j Q_j^{\mathrm{Si}} \;\;\;\;\;      + g^{\mathrm{POSi}}                          - R_{\mathrm{POSi}} \\
   \partial_t\op{ALK}   &= -\biggl( P_{\mathrm{NO3}} - \sum_j U^{\mathrm{NO3}}_j \biggr)
       - 2\biggl( \sum_j U^{\mathrm{DIC}}_j R^{{\text{PIC:POC}}}_j - D_{\mathrm{PIC}} \biggr)
       + D_{\mathrm{NO3}} \\
   \partial_t{\mathrm{O}}_2 &= R_{\mathrm{O}_2:\mathrm{P}} \biggl(
                                   \sum_j U^{\mathrm{PO4}}_j
                                   - R_{\mathrm{DOP}} - [R_{\mathrm{POP}}]
                               \biggr)
   \\
   \partial_t\op{CDOM}  &= S_{\mathrm{CDOM}} \qquad\text{(with CDOM tracer)} \\


The quotas are defined as :math:`Q^{\mathrm{P}}_j=p_j/c_j`, etc.  The following
abbreviated source terms are described in sections below:

- :math:`U`: uptake, see :ref:`Uptake` and :ref:`Bacteria`,
  also :ref:`Growth`, :ref:`CarbonStore`, :ref:`Light` and :ref:`Spectral`
- :math:`M`: :ref:`Mortality`
- :math:`R^{\mathrm{C}}`: :ref:`Respiration`
- :math:`H`, :math:`R_j`: bacterial hydrolysis and remineralization, see :ref:`Bacteria`
- :math:`R`, :math:`P`: parameterized :ref:`Remineralization`
- :math:`D_{\mathrm{NO3}}`: denitrification, see :ref:`Denitrification`
- :math:`D_{\mathrm{PIC}}`: dissolution of PIC, see :ref:`CarbonChemistry`
- :math:`g`, :math:`G`: grazing gains and losses, see :ref:`Grazing`
- :math:`S^{\mathrm{Chl}}`: synthesis, see :ref:`Synthesis`
- :math:`S_{\mathrm{Fe}}`: iron sources, see :ref:`Iron`
- :math:`S_{\mathrm{CDOM}}`: see :ref:`CDOM`.

With :varlink:`DARWIN_ALLOW_CDOM`, all particulate remineralization terms
(in square brackets [...]) except Si are absent.
Without :varlink:`DARWIN_ALLOW_CDOM`, :math:`f_{\mathrm{CDOM}}=0` and there is no CDOM tracer.
The Alk and O\ :sub:`2` tracers are only present with :varlink:`DARWIN_ALLOW_CARBON`.


.. csv-table:: General parameters
   :delim: &
   :widths: 15,17,14,11,18,25
   :class: longtable
   :header: Trait, Param, Symbol, Default, Units, Description

   :varlink:`R_PICPOC` & :varlink:`a_R_PICPOC` & :math:`R^{\text{PIC:POC}}_j`              & 0.8          & mmol PIC / mmol POC       & inorganic-organic carbon ratio
                       & :varlink:`R_OP`       & :math:`R_{\mathrm{O}_2:\mathrm{P}}`       & 170          & mmol O\ :sub:`2` / mmol P & O\ :sub:`2`:P ratio for respiration and consumption

For CDOM elemental ratios, see :ref:`CDOM`.
