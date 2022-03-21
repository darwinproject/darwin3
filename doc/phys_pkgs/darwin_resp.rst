.. include:: ../defs.hrst

.. _Respiration:

Respiration
^^^^^^^^^^^

Carbon is respired with a temperature-dependent rate.
Respiration stops at :math:`{c}_j^{\min}`:

.. math::

   R^{\mathrm{C}}_j = r^{{{\text{resp}}}}_j f^{{{\text{remin}}}}(T) ({c}_j - {c}_j^{\min})
   \,.

For elements with fixed stochiometry, any excess is returned to the inorganic
pool, e.g.,

.. math::

   R^{\mathrm{P}}_j = R^{\mathrm{P}:\mathrm{C}}_j R^{\mathrm{C}}_j
   \qquad\text{(without P quota)}
   \,.

For nitrogen, return fluxes to NH\ :sub:`4` and NO\ :sub:`2` are limited to not
exceed uptake.  If carbon respiration exceeds uptake, excess nitrogen goes to
NO\ :sub:`3`,

.. math::

   R^{\mathrm{N,NH4}}_j &= U^{\op{NH4}}_j
   \,,

   R^{\op{N,NO2}}_j &= U^{\op{NO2}}_j
   \,,

   R^{\op{N,NO3}}_j &= R^{{\mathrm{N}}:{\mathrm{C}}}_j R^{\mathrm{C}}_j
                       - U^{\op{NH4}}_j - U^{\op{NO2}}_j

   \text{(if } R^{\mathrm{C}}_j &> U^{\op{DIC}}_j
   \text{ without N quota).}

For non-phototrophs, all nitrogen goes to NO\ :sub:`3`.


Parameters
''''''''''

.. csv-table:: Mortality and respiration parameters
   :delim: &
   :widths: 20,22,11,11,13,23
   :class: longtable
   :header: Trait, Param, Symbol, Default, Units, Description

   :varlink:`respRate`        & :varlink:`a <a_respRate_c>`,\ :varlink:`b_respRate_c` [#]_ & :math:`r^{\op{resp}}_j`       & 0                & s\ :sup:`-1`            & respiration rate
   :varlink:`qcarbon`         & :varlink:`a <a_qcarbon>`,\ :varlink:`b_qcarbon`         & :math:`Q^{\mathrm{c}}_j`      & 1.8E-11          & mmol C cell\ :sup:`--1` & cellular carbon content
   :varlink:`Xmin`            & :varlink:`a_Xmin`                & :math:`c^{\min}_j`            & 0                & mmol C m\ :sup:`-3`     & minimum abundance for mortality, respiration and exudation

.. [#] the units of :varlink:`a_respRate_c` are mmol C cell\ :sup:`--1`, see discussion below.


The respiration rate follows a different scaling law from other traits: it
scales in terms of cellular carbon content,

.. math::

    r^{\op{resp}}_j = \frac{\op{a\_respRate\_c(g)}}{Q^{\mathrm{c}}_j}
    \left( 12\cdot10^9 \cdot Q^{\mathrm{c}}_j \right)^{\op{b\_respRate\_c(g)}}

where

.. math::

   Q^{\mathrm{c}}_j = \op{a\_qcarbon(g)} \cdot V_j^{\op{b\_qcarbon(g)}}
   \;.

.. So

    .. math::

        r^{\op{resp}}_j = 12\cdot10^9 \cdot \op{a\_respRate\_c}
        \left( 12\cdot10^9 \cdot Q^{\mathrm{c}}_j \right)^{\op{b\_respRate\_c}-1}

    .. math::

       r^{\op{resp}}_j = 12\cdot10^9 \op{a\_respRate\_c}\cdot(12\cdot10^9 \cdot \op{a\_qcarbon})^{\op{b\_respRate\_c}-1}
                   \cdot V^{(\op{b\_respRate\_c}-1)\cdot\op{b\_qcarbon}}

The units of a_respRate_c are mmol C cell\ :sup:`--1` s\ :sup:`--1`.  It
now defaults to zero.  In the quota model, the default was 3.21·10\
:sup:`--11`/86400.
