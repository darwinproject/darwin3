.. include:: ../defs.hrst

Model equations
^^^^^^^^^^^^^^^

The basic model equations are (omitting transport terms handled by the
ptracers package):

.. math::

   \partial_t\op{DIC}   &= -\sum_j U^{\op{DIC}}_j \cdot (1 + R^{\text{PIC:POC}}_j)
                           + r_{\op{DOC}} \op{DOC}+ [r_{\op{POC}} \op{POC}]
                           + \kappa^{{\text{diss}}}_{\mathrm{C}}\op{PIC}\\
   \partial_t\op{PO}_4  &= -\sum_j U^{\op{PO4}}_j + r_{\op{DOP}} \op{DOP}+ [r_{\op{POP}} \op{POP}] \\
   \partial_t\op{NH}_4  &= -\sum_j U^{\op{NH4}}_j + r_{\op{DON}} \op{DON}+ [r_{\op{PON}} \op{PON}] - P_{\op{NO2}}
                                      - D_{\op{NH4}} \\
   \partial_t\op{NO}_2  &= -\sum_j U^{\op{NO2}}_j + P_{\op{NO2}} - P_{\op{NO3}} \\
   \partial_t\op{NO}_3  &= -\sum_j U^{\op{NO3}}_j + P_{\op{NO3}} - D_{\op{NO3}} \\
   \partial_t\op{SiO}_2 &= -\sum_j U^{\op{SiO2}}_j + r_{\op{POSi}} \op{POSi}\\
   \partial_t\op{FeT}   &= -\sum_j U^{\op{Fe}}_j + r_{\op{DOFe}} \op{DOFe}+ [r_{\op{POFe}} \op{POFe}] + S_{\op{Fe}} \\[-1ex]
   \partial_t c_j       &= U^{\op{DIC}}_j - M_j - R^{\mathrm{C}}_j - G_j + g_j^{\mathrm{C}}\\
   \partial_t p_j       &= U^{\op{PO4}}_j - M_j Q^{\mathrm{P}}_j - G_j Q^{\mathrm{P}}_j + g_j^{\mathrm{P}}\\
   \partial_t n_j       &= U^{{\op{N}}}_j \;\;\; - M_j Q^{\mathrm{N}}_j - G_j Q^{\mathrm{N}}_j + g_j^{\mathrm{N}}\\
   \partial_t\op{si}_j  &= U^{\op{SiO2}}_j - M_j Q^{\op{Si}}_j - G_j Q^{\op{Si}}_j \\
   \partial_t\op{fe}_j  &= U^{\op{Fe}}_j \;\; - M_j Q^{\op{Fe}}_j - G_j Q^{\op{Fe}}_j + g_j^{\op{Fe}} \\
   \partial_t\op{Chl}_j &= S^{\op{Chl}}_j \; - M_j \cdot \op{Chl\text{:}C}_j - G_j \cdot \op{Chl\text{:}C}_j \\
   \partial_t\op{DOC}   &= \sum_j M_j^{\op{DOM}} \;\;\;\;\;    + g^{\op{DOC}}  - r_{\op{DOC}} \op{DOC}\\
   \partial_t\op{DOP}   &= \sum_j M_j^{\op{DOM}} Q_j^{{\mathrm{P}}}  + g^{\op{DOP}}  - r_{\op{DOP}} \op{DOP}\\
   \partial_t\op{DON}   &= \sum_j M_j^{\op{DOM}} Q_j^{{\mathrm{N}}}  + g^{\op{DON}}  - r_{\op{DON}} \op{DON}\\
   \partial_t\op{DOFe}  &= \sum_j M_j^{\op{DOM}} Q_j^{\op{Fe}} + g^{\op{DOFe}} - r_{\op{DOFe}} \op{DOFe}\\
   \partial_t\op{PIC}   &= \sum_j M_j     R_j^{\text{PIC:POC}} + g^{\op{PIC}} - \kappa^{{\text{diss}}}_{\mathrm{C}}\op{PIC}\\
   \partial_t\op{POC}   &= \sum_j M_j^{\op{POM}} \;\;\;\;\;    + g^{\op{POC}}  - r_{\op{POC}} \op{POC}\\
   \partial_t\op{POP}   &= \sum_j M_j^{\op{POM}} Q_j^{{\mathrm{P}}}  + g^{\op{POP}}  - r_{\op{POP}} \op{POP}\\
   \partial_t\op{PON}   &= \sum_j M_j^{\op{POM}} Q_j^{{\mathrm{N}}}  + g^{\op{PON}}  - r_{\op{PON}} \op{PON}\\
   \partial_t\op{POSi}  &= \sum_j M_j Q_j^{\op{Si}} \;\;\;\;\; + g^{\op{POSi}} - r_{\op{POSi}} \op{POSi}\\
   \partial_t\op{POFe}  &= \sum_j M_j^{\op{POM}} Q_j^{\op{Fe}} + g^{\op{POFe}} - r_{\op{POFe}} \op{POFe}

The following abbreviated source terms are described in sections below:

- :math:`U`: uptake, see :ref:`Uptake`, :ref:`Growth`, :ref:`Light` and :ref:`Spectral`
- :math:`M`: mortality, see :ref:`Mortality`
- :math:`P`: nitrification, see :ref:`Remineralization`
- :math:`D`: denitrification, see :ref:`Denitrification`
- :math:`R`: respiration, see :ref:`Mortality`
- :math:`G`: grazing losses, see :ref:`Grazing`
- :math:`g`: grazing gains, see :ref:`Grazing`
- :math:`S`: synthesis/other sources, see :ref:`Synthesis` and :ref:`Iron`
- [...]: with :varlink:`DARWIN_ALLOW_CDOM`, all particulate remineralization terms
  (in square brackets) except Si are absent, see :ref:`CDOM`.

For alkalinity, oxygen and CDOM also see the sections below: :ref:`CarbonChemistry` and :ref:`CDOM`.


.. csv-table:: General parameters
   :delim: &
   :widths: auto
   :class: longtable
   :header: Trait, Param, Symbol, Default, Units, Description

                       & :varlink:`Kdoc`       & :math:`r_{\op{DOC}}`       & 1/(100 days) & 1/s                            & DOC remineralization rate
                       & :varlink:`Kdop`       & :math:`r_{\op{DOP}}`       & 1/(100 days) & 1/s                            & DON remineralization rate
                       & :varlink:`Kdon`       & :math:`r_{\op{DON}}`       & 1/(100 days) & 1/s                            & DOP remineralization rate
                       & :varlink:`KdoFe`      & :math:`r_{\op{DOFe}}`      & 1/(100 days) & 1/s                            & DOFe remineralization rate
                       & :varlink:`KPOC`       & :math:`r_{\op{POC}}`       & 1/(50 days)  & 1/s                            & POC remineralization rate
                       & :varlink:`KPOP`       & :math:`r_{\op{POP}}`       & 1/(50 days)  & 1/s                            & POP remineralization rate
                       & :varlink:`KPON`       & :math:`r_{\op{PON}}`       & 1/(50 days)  & 1/s                            & PON remineralization rate
                       & :varlink:`KPOFe`      & :math:`r_{\op{POFe}}`      & 1/(50 days)  & 1/s                            & POFe remineralization rate
                       & :varlink:`KPOSi`      & :math:`r_{\op{POSi}}`      & 1/(300 days) & 1/s                            & POSi remineralization rate
                       & :varlink:`Kdissc`     & :math:`\kappa^{\op{diss}}` & 1/(300 days) & 1/s                            & dissolution rate for PIC
   :varlink:`R_PICPOC` & :varlink:`a_R_PICPOC` & :math:`R^{\op{PICPOC}}_j`  & 0.8          & mmol PIC (mmol POC)\ :sup:`-1` & inorganic-organic carbon ratio

