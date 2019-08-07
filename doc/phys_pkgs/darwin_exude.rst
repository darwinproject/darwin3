.. include:: ../defs.hrst

Exudation
^^^^^^^^^

If :varlink:`DARWIN_ALLOW_EXUDE` is defined, an additional per-element loss
term is introduced, e.g.,

.. math:: \partial_tp_j = \dots - E^{\mathrm{P}}_j

with

.. math:: E^{\mathrm{P}}_j = \kappa^{\op{exc}}_{{\mathrm{P}}\,j} ({c}_j - {c}_j^{\min}) Q^{\mathrm{P}}_j

and fed into organic matter pools, e.g.,

.. math:: \partial_t\op{DOP}= \dots + \sum_j (1 - f^{\exp}_j) E^{\mathrm{P}}_j

and

.. math:: \partial_t\op{POP}= \dots + \sum_j f^{\exp}_j E^{\mathrm{P}}_j

(Maybe should NOT use :math:`{c}_j^{\min}` in this case, or have a
separate one for each quota?)

