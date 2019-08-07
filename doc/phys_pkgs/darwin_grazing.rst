.. include:: ../defs.hrst

.. _Grazing:

Grazing
^^^^^^^

Grazing loss of plankton :math:`j`:

.. math:: G_j = \sum_{z\in\op{pred}} G_{j,z}

where

.. math::

   G_{j,z} = g^{\max}_z
          \frac{({p}_{j,z} {c}_j)^s}{A_z}
          \frac{p_z^h}{p_z^h + {k^{{{\text{graz}}}}_z}^h}
          (1 - {\mathrm{e}}^{-i_{{{\text{graz}}}} p_z})
          f^{{{\text{graz}}}}_z(T)
          {c}_z

with

.. math:: A_z = \biggl[ \sum_j ({p}_{j,z} {c}_j)^s \biggr]_{\ge\op{phygrazmin}}

.. math:: p_z = \biggl[ \sum_j {p}_{j,z} {c}_j - \op{phygrazmin} \biggr]_{\ge 0}

:math:`s` is 1 for non-switching and 2 for switching grazers
(#define :varlink:`DARWIN_GRAZING_SWITCH`). The exponent :math:`h` defaults to
1.

**Note:** For non-switching grazers (:math:`s=1`), Ben has an additional
factor

.. math:: \frac{S^{[j]}_z}{S^{{{\text{phy}}}}_z + S^{{\text{zoo}}}_z}

in :math:`G_{j,z}` where

.. math::

     S^{{{\text{phy}}}}_z &= \sum_{j\in{{\text{phy}}}} {p}_{j,z} {c}_j

     S^{{\text{zoo}}}_z &= \sum_{j\in{{\text{zoo}}}} {p}_{j,z} {c}_j

and :math:`S^{[j]}_z` is the sum for the class plankton :math:`j`
belongs to. **This is not implemented yet!**

Gains from grazing:

.. math::

       g^{{\mathrm{C}}}_z &= \sum_j G_{j,z} a_{j,z} {{\text{reg}}}^{Q{\mathrm{C}}}_z

       g^{{\mathrm{P}}}_z &= \sum_j G_{j,z} a_{j,z} {{\text{reg}}}^{Q{\mathrm{P}}}_z Q^{\mathrm{P}}_j
       \qquad\text{if }\op{DARWIN\_ALLOW\_PQUOTA}

       &\dots

       g^{\op{DOC}} &= \sum_{j,z} G_{j,z} (1 - a_{j,z} {{\text{reg}}}^{Q{\mathrm{C}}}_z) (1 - f^{\text{exp graz}}_{j,z})

       g^{\op{DOP}} &= \sum_{j,z} \begin{cases}
         G_{j,z} (1 - a_{j,z} {{\text{reg}}}^{Q{\mathrm{P}}}_z) (1 - f^{\text{exp graz}}_{j,z}) Q^{\mathrm{P}}_j
         &\text{if }\op{DARWIN\_ALLOW\_PQUOTA}

         G_{j,z} (R^{{\mathrm{P}}:{\mathrm{C}}}_j - a_{j,z} R^{{\mathrm{P}}:{\mathrm{C}}}_z) (1 - f^{\text{exp graz}}_{j,z})
         &\text{else}
       \end{cases}

       &\dots

       g^{\op{POC}} &= \sum_{j,z} G_{j,z} (1 - a_{j,z} {{\text{reg}}}^{Q{\mathrm{C}}}_z) f^{\text{exp graz}}_{j,z}

       g^{\op{POP}} &= \sum_{j,z} \begin{cases}
         G_{j,z} (1 - a_{j,z} {{\text{reg}}}^{Q{\mathrm{P}}}_z) f^{\text{exp graz}}_{j,z} Q^{\mathrm{P}}_j
         &\text{if }\op{DARWIN\_ALLOW\_PQUOTA}

         G_{j,z} (R^{{\mathrm{P}}:{\mathrm{C}}}_j - a_{j,z} R^{{\mathrm{P}}:{\mathrm{C}}}_z) f^{\text{exp graz}}_{j,z}
         &\text{else}
         \end{cases}

       &\dots

       g^{\op{POSi}} &= \sum_{j,z} G_{j,z} Q^{\op{Si}}_j

       g^{\op{PIC}} &= \sum_{j,z} G_{j,z} R^{{\text{PIC:POC}}}_z

where

.. math::

       {{\text{reg}}}^{Q{\mathrm{P}}}_z &= \left( \left[ \frac{Q^{{\mathrm{P}}\max}_z - Q^{{\mathrm{P}}}_z}
                                   {Q^{{\mathrm{P}}\max}_z - Q^{{\mathrm{P}}\min}_z}
                       \right]_0^1 \right)^{h_{\op{G}}}

       &\dots

       {{\text{reg}}}^{Q{\mathrm{C}}}_z &= \left( \min\left\{
             \frac{Q^{{\mathrm{P}}}_z - Q^{{\mathrm{P}}\min}_z}{Q^{{\mathrm{P}}\max}_z - Q^{{\mathrm{P}}\min}_z},
             \frac{Q^{{\mathrm{N}}}_z - Q^{{\mathrm{N}}\min}_z}{Q^{{\mathrm{N}}\max}_z - Q^{{\mathrm{N}}\min}_z},
             \frac{Q^{\op{Fe}}_z - Q^{\op{Fe}\min}_z}{Q^{\op{Fe}\max}_z - Q^{\op{Fe}\min}_z}
             \right\}_0^1 \right)^{h_{\op{G}}}

       & \qquad\text{(only quota elements)}

and :math:`h_{\op{G}}` is the Hill number for grazing (:varlink:`hillnumGraz`,
default 1).

