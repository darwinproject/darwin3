.. include:: ../defs.hrst

.. _GeiderGrowth:

Geider growth
^^^^^^^^^^^^^

.. math::

   U^{\op{DIC}}_j = P^{\mathrm{C}}_j {c}_j
         \underbrace{{}-\op{synthcost}\cdot U^{\mathrm{N}}_j}_{
                         \text{only with both N and Chl quotas}}

.. math::

   P^{\mathrm{C}}_j = P^{{\mathrm{C}}{\op{m}}}_j \left(
       1 - \exp\left\{ -\frac{\gamma^{\op{\mathit{Q}Fe}}_j
                        \langle\alpha I\rangle_j
                        \op{Chl\text{:}C}_j }{ P^{{\mathrm{C}}{\op{m}}}_j }
               \right\}
     \right) \gamma^{{{\text{inhib}}}}_j
     \cdot\op{ ngrow}
     \qquad\text{if } I>I_{\min}

.. math:: \langle\alpha I\rangle_j = \sum_{l=1}^{\op{nlam}} \alpha^{\op{Chl}}_{j,l} I_l

.. math:: P^{{\mathrm{C}}{\op{m}}}_j = P_{{\mathrm{C}},j}^{\max} \gamma^{\op{nut}}_j f^{{{\text{phy}}}}_j(T) \gamma_{\op{pCO2}}

(currently ngrow and :math:`\gamma_{\op{pCO2}}` are both set to 1 in the code).

Without dynamic Chl quota, we set [1]_

.. math:: \op{Chl\text{:}C}_j = \op{Chl\text{:}C}_j^{\op{acclim}}

.. math::

   \op{Chl\text{:}C}_j^{\op{acclim}} = \left[
         \frac{\op{Chl\text{:}C}^{\max}{_j}}
              {1 + \op{Chl\text{:}C}^{\max}_j\langle\alpha I\rangle_j/(2P^{{\mathrm{C}}{\op{m}}}_j)}
       \right]_{\op{Chl\text{:}C}^{\min}_j}^{\op{Chl\text{:}C}^{\max}_j}

If :math:`P^{{\mathrm{C}}{\op{m}}}_j=0`, we set
:math:`\op{Chl\text{:}C}_j^{\op{acclim}}=\op{Chl\text{:}C}^{\min}_j`.

Photo inhibition:

.. math::

   \gamma^{{{\text{inhib}}}}_j = \begin{cases}
       c^{\op{inhib}}_j \cdot \op{EkoverE} & \text{if } \op{EkoverE} \le 1 \\
       1                               & \text{otherwise}
     \end{cases}

where

.. math::

   \op{EkoverE} = \frac{P^{{\mathrm{C}}{\op{m}}}_j/(\op{Chl\text{:}C}_j\cdot\overline{\alpha}_j)}
                  {\langle\alpha I\rangle_j/\overline{\alpha}_j}

and

.. math::

   \overline{\alpha}_j = \sum_l \Delta\lambda_l \alpha^{\op{Chl}}_{j,l} \Big/
                           \sum_l \Delta\lambda_l
     \;.


.. [1]
   Notation: :math:`[A]_a^b\equiv\max(a,\min(b,A))`
