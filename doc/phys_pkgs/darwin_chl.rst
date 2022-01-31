.. include:: ../defs.hrst

.. _Synthesis:

Chlorophyll synthesis
^^^^^^^^^^^^^^^^^^^^^

With N quota:
'''''''''''''

.. math:: S^{\op{Chl}}_j = \rho^{\op{Chl}}_j U^{\mathrm{N}}_j

where

.. math::

   \rho^{\op{Chl}}_j = \begin{cases}
       \op{Chl\text{:}n}^{\max}_j
         \dfrac{P^{\mathrm{C}}_j}
              {\langle\alpha I\rangle_j \cdot \op{Chl\text{:}C}_j}
       & \text{if } \langle\alpha I\rangle_j \cdot \op{Chl\text{:}C}_j > 0, \\
       \op{Chl\text{:}n}^{\max}_j
       & \text{else.}
     \end{cases}


Without N quota:
''''''''''''''''

– with :varlink:`DARWIN_GEIDER_RHO_SYNTH`:

.. math::

   S^{\op{Chl}}_j = \rho^{\op{Chl}}_j \cdot P^{\mathrm{C}}_j {c}_j
              + \tau^{\op{acclim}}_j (\op{Chl\text{:}C}_j^{\op{acclim}} - \op{Chl\text{:}C}_j) {c}_j

where

.. math::

   \rho^{\op{Chl}}_j = \begin{cases}
       \op{Chl\text{:}C}^{\max}_j \dfrac{P^{\mathrm{C}}_j}
       {\langle\alpha I\rangle_j \op{Chl\text{:}C}^{{{\text{acclim}}}}_j}
       & \text{if } \langle\alpha I\rangle_j > 0
         \text{ and } \op{Chl\text{:}C}^{{{\text{acclim}}}}_j > 0, \\
       0 & \text{else.}
     \end{cases}

– else

.. math::

   S^{\op{Chl}}_j = \op{Chl\text{:}C}_j^{\op{acclim}} \cdot P^{\mathrm{C}}_j {c}_j
                + \tau^{\op{acclim}}_j (\op{Chl\text{:}C}_j^{\op{acclim}} - \op{Chl\text{:}C}_j) {c}_j

The acclimated chlorophyll-c ratio, :math:`\op{Chl\text{:}C}_j^{\op{acclim}}`,
is defined in :eq:`chl2cacclim`.


Without Chl quota,
''''''''''''''''''

current chl, i.e., :math:`{c}_j\cdot\op{Chl\text{:}C}_j`, is
stored for the next time step.


.. csv-table:: Chlorophyll synthesis parameters
   :delim: &
   :widths: 13,20,14,14,15,24
   :class: longtable
   :header: Trait, Param, Symbol, Default, Units, Description

                            & :varlink:`chl2nmax`        & Chl:n\ :math:`^{\op{max}}_j` & 3.00   & mg Chl / mmol N & max Chl:N ratio for Chl synthesis following Moore 2002
   :varlink:`acclimtimescl` & :varlink:`a_acclimtimescl` & :math:`\tau^{\op{acclim}}` & 1/20days & 1/s             & rate of chlorophyll acclimation
