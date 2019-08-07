.. include:: ../defs.hrst

Bacteria
^^^^^^^^

To enable bacteria, specify which groups are particle-associated or free-living
bacteria by setting :varlink:`bactType` to 1 or 2, resp., and set
:varlink:`isAerobic` to 1 for aerobic and :varlink:`isDenit` to 1 for
denitrifying bacteria.  NH\ :sub:`4` and NO\ :sub:`2` oxidizers will be
included in the future.

Bacteria traits are set from the following parameters by scaling with
each plankton elemental ratios,

.. math::

   \begin{aligned}
     {k^{\op{POM}}}&= 1 \op{mmol} {\mathrm{N}}\\
     {k^{\op{DOM}}}&= 1 \op{mmol} {\mathrm{N}}\\
     {k^{\op{DIN}}}&= 0.01 \op{mmol} {\mathrm{N}}\\
     {P^{{\mathrm{C}}{\op{m}}}_{\op{DIN}}}&= 20/{{\text{day}}}\\
     {P^{{\mathrm{C}}\,{\mathrm{O}}2{\op{m}}}}&= 290.820/(\op{mmol} {\mathrm{O}}_2\, {{\text{day}}}) \\
     {\alpha^{\op{hydrol}}}&= 2.0\end{aligned}

In addition, :varlink:`PCmax` should be set to 5/day to recover
previous settings.

The yields of aerobic bacteria are:

.. math::

   \begin{aligned}
     {Y_j}&= 0.2 &
     {Y^{{\mathrm{O}}_2}_j}&= \frac{{Y_j}}{467} \frac{4}{1-{Y_j}} 106 &&\end{aligned}

Those of dentrifying ones:

.. math::

   \begin{aligned}
     {Y_j}&= 0.16 &
     {Y^{\op{NO}_3}_j}&= \frac{{Y_j}}{467} \frac{5}{1-{Y_j}} 106 &&\end{aligned}

The parameterized remineralization rates :math:`r_{\op{DOC}}`, ...
should be set to zero if remineralization is to be by bacteria only.

Generic particle-associated
'''''''''''''''''''''''''''

The growth rate is limited by the presence of particulate organic matter
and the energy source (O\ :sub:`2` for aerobic, NO\ :sub:`3` for denitrifying),

.. math:: \partial_t{c}_j = \mu_j {c}_j

.. math:: \mu_j = \min(\mu^{\op{POP}}_j, \mu^{\op{PON}}_j, \mu^{\op{POC}}_j, \mu^{{\mathrm{O}}}_j)

.. math:: \mu^{\op{PON}}_j = Y_j {P^{\op{max}}_{{\mathrm{C}},j}} \frac{\op{PON}}{\op{PON}+ {k^{\op{PON}}}_j} f^{\op{remin}}(T)

.. math:: \mu^{\op{POC}}_j = Y_j {P^{\op{max}}_{{\mathrm{C}},j}} \frac{\op{POC}}{\op{POC}+ {k^{\op{POC}}}_j} f^{\op{remin}}(T)

.. math:: \mu^{\op{POP}}_j = Y_j {P^{\op{max}}_{{\mathrm{C}},j}} \frac{\op{POP}}{\op{POP}+ {k^{\op{POP}}}_j} f^{\op{remin}}(T)

.. math::

   \mu^{{\mathrm{O}}}_j = \begin{cases}
       {Y^{{\mathrm{O}}_2}_j}{P^{{\mathrm{C}}\,{\mathrm{O}}2{\op{m}}}}{\mathrm{O}}_2  & \text{if aerobic} \\
       {Y^{\op{NO}_3}_j}{P^{{\mathrm{C}}{\op{m}}}_{\op{DIN}}}\dfrac{\op{NO}_3}{\op{NO}_3 + {k^{\op{DIN}}}} f^{\op{remin}}(T)
                               & \text{if denitrifying }
     \end{cases}

Consumption of organic matter:

.. math:: U^{\op{POC}}_j = \frac{{\alpha^{\op{hydrol}}}}{Y_j} \mu_j {c}_j

.. math:: U^{\op{POX}}_j = U^{\op{POC}}_j R^{X{\mathrm{C}}}_j  \qquad X={\mathrm{N}},{\mathrm{P}},\op{Fe}

Oxygen/nitrate is only used for the part of POC that is metabolized:

.. math::

   U^{{\mathrm{O}}2}_j = \frac{1}{{Y^{{\mathrm{O}}_2}_j}} \mu_j {c}_j
     \qquad\text{(aerobic)}

.. math::

   U^{\op{NO3}}_j = \frac{1}{{Y^{\op{NO}_3}_j}} \mu_j {c}_j
     \qquad\text{(denitrifying)}

This is the part of POM that is hydrolized into DOM:

.. math:: H^{\op{POC}}_j = \frac{{\alpha^{\op{hydrol}}}- 1}{Y_j} \mu_j {c}_j

.. math:: H^{\op{POX}}_j = H^{\op{POC}}_j R^{X{\mathrm{C}}}_j  \qquad X={\mathrm{N}},{\mathrm{P}},\op{Fe}

These are the bacteria products for remineralization of POM:

.. math:: R^{\op{POC}}_j = \left( \frac{1}{Y_j} - 1 \right) \mu_j {c}_j

.. math:: R^{\op{POX}}_j = R^{\op{POC}}_j R^{X{\mathrm{C}}}_j  \qquad X={\mathrm{N}},{\mathrm{P}},\op{Fe}

Generic free-living
'''''''''''''''''''

The growth rate is limited by the presence of dissolved organic matter
and the energy source (O\ :sub:`2` for aerobic, NO\ :sub:`3` for denitrifying),

.. math:: \partial_t{c}_j = \mu_j {c}_j

.. math:: \mu_j = \min(\mu^{\op{DOP}}_j, \mu^{\op{DON}}_j, \mu^{\op{DOC}}_j, \mu^{{\mathrm{O}}}_j)

.. math:: \mu^{\op{DON}}_j = Y_j {P^{\op{max}}_{{\mathrm{C}},j}} \frac{\op{DON}}{\op{DON}+ {k^{\op{DON}}}_j} f^{\op{remin}}(T)

.. math:: \mu^{\op{DOC}}_j = Y_j {P^{\op{max}}_{{\mathrm{C}},j}} \frac{\op{DOC}}{\op{DOC}+ {k^{\op{DOC}}}_j} f^{\op{remin}}(T)

.. math:: \mu^{\op{DOP}}_j = Y_j {P^{\op{max}}_{{\mathrm{C}},j}} \frac{\op{DOP}}{\op{DOP}+ {k^{\op{DOP}}}_j} f^{\op{remin}}(T)

:math:`\mu^{{\mathrm{O}}}_j` is the same as for particle-associated
bacteria.

Consumption of organic matter:

.. math:: U^{\op{DOC}}_j = \frac{1}{Y_j} \mu_j {c}_j

.. math:: U^{\op{DOX}}_j = U^{\op{DOC}}_j R^{X{\mathrm{C}}}_j  \qquad X={\mathrm{N}},{\mathrm{P}},\op{Fe}

Oxygen/nitrate is only used for the part of DOC that is metabolized:

.. math::

   U^{{\mathrm{O}}2}_j = \frac{1}{{Y^{{\mathrm{O}}_2}_j}} \mu_j {c}_j
     \qquad\text{or } 1

.. math::

   U^{\op{NO3}}_j = \frac{1}{{Y^{\op{NO}_3}_j}} \mu_j {c}_j
     \qquad\text{or } 1

These are the bacteria products for remineralization of DOM:

.. math:: R^{\op{DOC}}_j = \left( \frac{1}{Y_j} - 1 \right) \mu_j {c}_j

.. math:: R^{\op{DOX}}_j = R^{\op{DOC}}_j R^{X{\mathrm{C}}}_j  \qquad X={\mathrm{N}},{\mathrm{P}},\op{Fe}

