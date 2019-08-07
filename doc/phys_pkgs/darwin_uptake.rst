.. include:: ../defs.hrst

.. _Uptake:

Nutrient uptake and limitation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. math::

   \gamma^{\op{nut}}_j = \min(\gamma^{\mathrm{P}}_j, \gamma^{\mathrm{N}}_j, \gamma^{\op{Si}}_j,
                              \gamma^{\op{Fe}}_j)

Without P quota:
''''''''''''''''

Monod limitation

.. math:: \gamma^{\mathrm{P}}_j = \frac{\mathrm{PO}_4}{\mathrm{PO}_4 + k^{\op{PO4}}_j}

.. math:: U^{\mathrm{P}}_j = R^{{\mathrm{P}}:{\mathrm{C}}}_j P^{\mathrm{C}}_j {c}_j

With P quota:
'''''''''''''

normalized Droop limitation

.. math::

   \gamma^{\mathrm{P}}_j = \left[ \frac{1 - Q^{{\mathrm{P}}\min}_j/Q^{{\mathrm{P}}}_j}
                               {1 - Q^{{\mathrm{P}}\min}_j/Q^{{\mathrm{P}}\max}_j}
                   \right]_0^1

.. math::

   U^{\mathrm{P}}_j = V^{{\mathrm{P}}\max}_j \frac{\mathrm{PO}_4}{\mathrm{PO}_4 + k^{\op{PO4}}_j}
              {{\text{reg}}}^{Q{\mathrm{P}}}_j \cdot f^{{\text{up}}}_j(T) \cdot {c}_j

where

.. math::

     {{\text{reg}}}^{Q{\mathrm{P}}}_j = \left( \left[ \frac{Q^{{\mathrm{P}}\max}_j - Q^{{\mathrm{P}}}_j}
                                {Q^{{\mathrm{P}}\max}_j - Q^{{\mathrm{P}}\min}_j}
                    \right]_0^1 \right)^{h_{\op{U}}}

and the exponent, :math:`h_{\op{U}}`, is the Hill number for
uptake (:varlink:`hillnumUptake`, default 1).

Si:
'''

Diatoms (trait :varlink:`hasSi` = 1) have linear limitation when using a Si quota,

.. math::

   \gamma^{\op{Si}}_j = \left[ \frac{Q^{\op{Si}}_j - Q^{\op{Si}\min}_j}
                              {Q^{\op{Si}\max}_j - Q^{\op{Si}\min}_j}
                      \right]_0^1

Otherwise Si is analogous to P.

Without N quota:
''''''''''''''''

diazotroph:
"""""""""""

No limitation, no consumption:

.. math:: \gamma^{\mathrm{N}}_j = 1

.. math:: U^{\op{NH4}}_j = U^{\op{NO2}}_j = U^{\op{NO3}}_j = 0

not diazotroph:
"""""""""""""""

Modified Monod limitation:

.. math:: \gamma^{\mathrm{N}}_j = \left[ \gamma^{\op{NH4}}_j + \gamma^{\op{NO2}}_j + \gamma^{\op{NO3}}_j \right]_0^1

.. math:: \gamma^{\op{NH4}}_j = \op{useNH4}_j \frac{\op{NH}_4}{\op{NH}_4 + k^{\op{NH4}}_j}

NO\ :sub:`2` and NO\ :sub:`3` limitations can be combined
(trait :varlink:`combNO` = 1),

.. math::

   \gamma^{\op{NO2}}_j = \op{useNO2}_j
     \dfrac{\op{NO}_2}{\op{NO}_2 + \op{NO}_3 + k^{\op{NO3}}_j}
     \op{e}^{-\sigma_1 \op{NH}_4}

.. math::

   \gamma^{\op{NO3}}_j = \op{useNO3}_j
     \dfrac{\op{NO}_3}{\op{NO}_2 + \op{NO}_3 + k^{\op{NO3}}_j}
     \op{e}^{-\sigma_1 \op{NH}_4}

or not (combNO = 0),

.. math::

   \gamma^{\op{NO2}}_j = \op{useNO2}_j
     \dfrac{\op{NO}_2}{\op{NO}_2 + k^{\op{NO2}}_j}
     \op{e}^{-\sigma_1 \op{NH}_4}

.. math::

   \gamma^{\op{NO3}}_j = \op{useNO3}_j
     \dfrac{\op{NO}_3}{\op{NO}_3 + k^{\op{NO3}}_j}
     \op{e}^{-\sigma_1 \op{NH}_4}

Uptake is then

.. math::
   :label: eq_uptakeN

     U^{\op{NH4}}_j &= \frac{\gamma^{\op{NH4}}_j}
                    {\gamma^{\op{NH4}}_j + \gamma^{\op{NO2}}_j + \gamma^{\op{NO3}}_j}
                    R^{{\mathrm{N}}:{\mathrm{C}}}_j P^{\mathrm{C}}_j {c}_j

     U^{\op{NO2}}_j &= \frac{\gamma^{\op{NO2}}_j}
                    {\gamma^{\op{NH4}}_j + \gamma^{\op{NO2}}_j + \gamma^{\op{NO3}}_j}
                    R^{{\mathrm{N}}:{\mathrm{C}}}_j P^{\mathrm{C}}_j {c}_j

     U^{\op{NO3}}_j &= \frac{\gamma^{\op{NO3}}_j}
                     {\gamma^{\op{NH4}}_j + \gamma^{\op{NO2}}_j + \gamma^{\op{NO3}}_j}
                     R^{{\mathrm{N}}:{\mathrm{C}}}_j P^{\mathrm{C}}_j {c}_j

With N quota:
'''''''''''''

linear limitation

.. math::

   \gamma^{\mathrm{N}}_j = \left[ \frac{Q^{{\mathrm{N}}}_j - Q^{{\mathrm{N}}\min}_j}
                           {Q^{{\mathrm{N}}\max}_j - Q^{{\mathrm{N}}\min}_j}
                   \right]_0^1

.. math::

     U^{\op{NH4}}_j &= V^{\op{NH4}\max}_j
                    \frac{\op{NH}_4}{\op{NH}_4 + k^{\op{NH4}}_j}
                    {{\text{reg}}}^{Q{\mathrm{N}}}_j \cdot
                    f^{{\text{up}}}_j(T) \cdot {c}_j

     U^{\op{NO2}}_j &= V^{\op{NO2}\max}_j \cdot
                    {\mathrm{e}}^{-\sigma_1 \op{NH}_4} \cdot
                    \frac{\op{NO}_2}{\op{NO}_2 + k^{\op{NO2}}_j}
                    {{\text{reg}}}^{Q{\mathrm{N}}}_j \cdot
                    f^{{\text{up}}}_j(T) \cdot {c}_j

     U^{\op{NO3}}_j &= V^{\op{NO3}\max}_j \cdot
                     {\mathrm{e}}^{-\sigma_1 \op{NH}_4} \cdot
                     \frac{\op{NO}_3}{\op{NO}_3 + k^{\op{NO3}}_j}
                     {{\text{reg}}}^{Q{\mathrm{N}}}_j \cdot
                     f^{{\text{up}}}_j(T) \cdot {c}_j
                     \cdot \gamma^{\op{\mathit{Q}Fe}}_j

where

.. math::

   {{\text{reg}}}^{Q{\mathrm{N}}}_j = \left( \left[ \frac{Q^{{\mathrm{N}}\max}_j - Q^{{\mathrm{N}}}_j}
                                {Q^{{\mathrm{N}}\max}_j - Q^{{\mathrm{N}}\min}_j}
                    \right]_0^1 \right)^{h_{\op{U}}}

diazotroph:
"""""""""""

consume what is available, fix what is missing (up to
:math:`V^{{\mathrm{N}}\max}_j`),

.. math::

   U^{{\mathrm{N}}}_j = \max\biggl( U^{\op{NH4}}_j + U^{\op{NO2}}_j + U^{\op{NO3}}_j,\;
                    V^{{\mathrm{N}}\max}_j
                    {{\text{reg}}}^{Q{\mathrm{N}}}_j \cdot
                    f^{{\text{up}}}_j(T) \cdot {c}_j
                \biggr) \\

Rate of nitrogen fixation is

.. math:: U^{{\mathrm{N}}}_j - U^{\op{NH4}}_j - U^{\op{NO2}}_j - U^{\op{NO3}}_j


not diazotroph:
"""""""""""""""

.. math:: U^{{\mathrm{N}}}_j = U^{\op{NH4}}_j + U^{\op{NO2}}_j + U^{\op{NO3}}_j


Without Fe quota:
'''''''''''''''''

.. math:: \gamma^{\op{Fe}}_j = \frac{\op{FeT}}{\op{FeT}+ k^{\op{Fe}}_j}

.. math:: \gamma^{\op{\mathit{Q}Fe}}_j = 1

.. math:: U^{\op{Fe}}_j = R^{\op{Fe}:{\mathrm{C}}}_j P^{\mathrm{C}}_j {c}_j


With Fe quota,
''''''''''''''

a low iron quota does not directly limit growth,

.. math:: \gamma^{\op{Fe}}_j = 1

It rather reduced the light available for photosynthesis (see
:ref:`GeiderGrowth` above),

.. math::

   \gamma^{\op{\mathit{Q}Fe}}_j = \left[ \frac{1 - Q^{\op{Fe}\min}_j/Q^{\op{Fe}}_j}
                                   {1 - Q^{\op{Fe}\min}_j/Q^{\op{Fe}\max}_j}
                       \right]_0^1

Iron uptake depends on the available dissolved iron,

.. math::

   U^{\op{Fe}}_j = V^{\op{Fe}\max}_j \frac{\op{FeT}}{\op{FeT}+ k^{\op{Fe}}_j}
              {{\text{reg}}}^{Q\op{Fe}}_j \cdot
              f^{{\text{up}}}_j(T) \cdot {c}_j

where

.. math::

   {{\text{reg}}}^{Q\op{Fe}}_j = \left( \left[ \frac{Q^{\op{Fe}\max}_j - Q^{\op{Fe}}_j}
                                 {Q^{\op{Fe}\max}_j - Q^{\op{Fe}\min}_j}
                    \right]_0^1 \right)^{h_{\op{U}}}

