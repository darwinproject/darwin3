.. include:: ../defs.hrst

.. _Temperature:

Temperature dependence
^^^^^^^^^^^^^^^^^^^^^^

Temperature functions are selected by the cpp options
:varlink:`DARWIN_TEMP_VERSION` and :varlink:`DARWIN_TEMP_RANGE`. 
The cpp option :varlink:`DARWIN_NOTEMP` turns off all temperature dependence.
The temperature dependence of mortality and grazing can be turned off for
individual plankton types by setting the traits :varlink:`tempMort`,
:varlink:`tempMort2` and :varlink:`tempGraz` to 0.

Note that the temperature functions in all versions except 1 can be greater than 1.0.


DARWIN_TEMP_VERSION 1
'''''''''''''''''''''

.. math::

   \begin{gathered}
     f^{\text{phy}}_j(T) = \left[ c_j \left[ e_{1 j}^{T/1^\circ{\rm C}}
         {\mathrm{e}}^{-e_{2 j} {|T - T^{\text{opt}}_j|}^{p_j}} - n \right]_{\ge 10^{-10}}
       \right]^{\le 1}
   \\
     f^{\text{up}}_j(T) =
     f^{\text{graz}}_z(T) =
     f^{\text{remin}}(T) =
     f^{\text{mort}}(T) =
     f^{\text{mort2}}(T) =
     1
   \end{gathered}

where the exponential is only present with :varlink:`DARWIN_TEMP_RANGE`.


DARWIN_TEMP_VERSION 2
'''''''''''''''''''''

.. math::

   \begin{gathered}
     f^{\text{phy}}_j(T) = c^{\text{Arr}} \left[
         {\mathrm{e}}^{A^{\text{Arr}}_{\text{e}}
              \bigl( (T+273.15)^{-1} - {T^{\text{Arr}}_{\text{ref}}}^{-1} \bigr)}
         {\mathrm{e}}^{-e_{2 j} {|T - T^{\text{opt}}_j|}^{p_j}} \right]_{\ge 10^{-10}}
   \\
     f^{\text{up}}_j(T) =
     f^{\text{graz}}_z(T) =
     f^{\text{remin}}(T) =
     f^{\text{mort}}(T) =
     f^{\text{mort2}}(T) =
     f_{\text{Arr}}(T)
   \\
     f_{\text{Arr}}(T) = c^{\text{Arr}} \left[
         {\mathrm{e}}^{A^{\text{Arr}}_{\text{e}}
              \bigl( (T+273.15)^{-1} - {T^{\text{Arr}}_{\text{ref}}}^{-1} \bigr)}
       \right]_{\ge 10^{-10}}\end{gathered}

where the second exponential in :math:`f^{{{\text{phy}}}}` again is only
present with :varlink:`DARWIN_TEMP_RANGE`.


DARWIN_TEMP_VERSION 3
'''''''''''''''''''''

.. math::

   f^{\text{phy}}_j(T) =
   f^{\text{up}}_j(T) =
   f^{\text{het}}_j(T) =
   f^{\text{graz}}_z(T) =
   f^{\text{mort}}(T) =
   f^{\text{mort2}}(T) =
   f^{\text{remin}}(T) =
   \\
   = \left[ {\mathrm{e}}^{A_{\text{e}} (T - T_{\text{ref}})} \right]_{\ge 10^{-10}}

where :math:`A_{{\mathrm{e}}}=0.05/{}^\circ{\rm C}` [#Ae]_ and
:math:`T_{\text{ref}}=20\,^\circ{\rm C}`.


DARWIN_TEMP_VERSION 4
'''''''''''''''''''''

Temperature functions are exponential, with an optional restriction on their range,

.. math::

     f^{\text{phy}}_j(T) &=
       \mathrm{e}^{A^{\text{phy}}_{\text{e} j} (T - T_{\text{ref}})}
       \mathrm{e}^{-e_{2 j} {|T - T^{\text{opt}}_j|}^{p_j}}

     f^{\text{het}}_j(T) &=
       \mathrm{e}^{A^{\text{het}}_{\text{e} j} (T - T_{\text{ref}})}
       \mathrm{e}^{-e^{\text{het}}_{2 j} {|T - T^{\text{opt het}}_j|}^{p^{\text{het}}_j}}

     f^{\text{graz}}_j(T) &=
       \text{e}^{A^{\text{zoo}}_{\text{e} j} (T - T_{\text{ref}})}
       \mathrm{e}^{-e^{\text{graz}}_{2 j} {|T - T^{\text{opt graz}}_j|}^{p^{\text{graz}}_j}}

     f^{\text{mort}}(T) &=
       \mathrm{e}^{A^{\text{mort}}_{\text{e}} (T - T_{\text{ref}})}

     f^{\text{mort2}}(T) &=
       \mathrm{e}^{A^{\text{mort2}}_{\text{e}} (T - T_{\text{ref}})}

     f^{\text{remin}}(T) &=
       \mathrm{e}^{A^{\text{remin}}_{\text{e}} (T - T_{\text{ref}})}

     f^{{{\text{up}}}}_j(T) &=
       \mathrm{e}^{A^{\text{uptake}}_{\text{e}} (T - T_{\text{ref}})}

where :math:`T_{\text{ref}}=20\,^\circ{\rm C}` and the exponentials with :math:`e^{*}_{2j}`
are only present if :varlink:`DARWIN_TEMP_RANGE` is defined.
The main exponential temperature dependence corresponds to the use of
a Q\ :sub:`10` temperature coefficient,

.. math::

   \mathrm{e}^{A_{\text{e}}(T-T_{\text{ref}})} = Q_{10}^{(T-T_{\text{ref}})/10\,^\circ\mathrm{C}}

where

.. math::

   Q_{10} = \mathrm{e}^{A_{\text{e}}\cdot 10\,^\circ\mathrm{C}}
   \quad \text{or} \quad
   A_{\text{e}} = \tfrac{1}{10\,^\circ\mathrm{C}} \ln Q_{10}

The default value corresponds to :math:`Q_{10}\approx1.55`.

Note that while the temperature dependences of versions 2, 3 and 4 are similar,
versions 3 and 4 yield rates about 70% higher than version 2 with the default
TempCoeffArr.  The magnitude of version 1 functions is similar to version 2
ones.  :ref:`fig_phys_pkg_darwin_tempfunc` shows the phytoplankton temperature
functions with default parameters for the four versions.

.. figure:: figs/phytotempfunc.*
    :name: fig_phys_pkg_darwin_tempfunc

    Default phytoplankton temperature functions for all DARWIN_TEMP_VERSION.

The parameters of all temperature functions are summarized in
:numref:`tab_phys_pkg_darwin_tempparams`.


.. table:: Temperature function parameters
   :name: tab_phys_pkg_darwin_tempparams

   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | **Trait**                   | **Parameter**                 | **Default Value**                                                    |
   +=============================+===============================+======================================================================+
   | **for version 1:**          |                               |                                                                      |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | :varlink:`phytoTempCoeff`   | :varlink:`a_phytoTempCoeff`   | :math:`c_j=1/3`                                                      |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | :varlink:`phytoTempExp1`    | :varlink:`a_phytoTempExp1`    | :math:`e_{1j}=1.04` [#Exp1]_                                         |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   |                             | :varlink:`tempnorm`           | :math:`n=0.3`                                                        |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | **for version 2:**          |                               |                                                                      |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   |                             | :varlink:`TempCoeffArr`       | :math:`c^{\text{Arr}}=0.5882`                                        |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   |                             | :varlink:`TempAeArr`          | :math:`A^{\text{Arr}}_{{\text{e}}}=-4000\,{\rm K}` [#AeArr]_         |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   |                             | :varlink:`TempRefArr`         | :math:`T^{\text{Arr}}_{\text{ref}}=293.15\,{\rm K}`                  |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | **for version 4:**          |                               |                                                                      |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | :varlink:`phytoTempAe`      | :varlink:`a_phytoTempAe`      | :math:`A^{\text{phy}}_{\text{e}j}=0.0438/{}^\circ\mathrm{C}` [#Ae4]_ |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | :varlink:`hetTempAe`        | :varlink:`a_hetTempAe`        | :math:`A^{\text{het}}_{\text{e}j}=0.0438/{}^\circ\mathrm{C}`         |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | :varlink:`grazTempAe`       | :varlink:`a_grazTempAe`       | :math:`A^{\text{graz}}_{\text{e}j}=0.0438/{}^\circ\mathrm{C}`        |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   |                             | :varlink:`reminTempAe`        | :math:`A^{\text{remin}}_{\text{e}}=0.0438/{}^\circ\mathrm{C}`        |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   |                             | :varlink:`mortTempAe`         | :math:`A^{\text{mort}}_{\text{e}}=0.0438/{}^\circ\mathrm{C}`         |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   |                             | :varlink:`mort2TempAe`        | :math:`A^{\text{mort2}}_{\text{e}}=0.0438/{}^\circ\mathrm{C}`        |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   |                             | :varlink:`uptakeTempAe`       | :math:`A^{\text{uptake}}_{\text{e}}=0.0/{}^\circ\mathrm{C}`          |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | **for TEMP_RANGE:**         |                               |                                                                      |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | :varlink:`phytoTempExp2`    | :varlink:`a_phytoTempExp2`    | :math:`e_{2j}=0.001`                                                 |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | :varlink:`phytoTempOptimum` | :varlink:`a_phytoTempOptimum` | :math:`T^{\text{opt}}_j=2.0\,^\circ{\rm C}`                          |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | :varlink:`phytoDecayPower`  | :varlink:`a_phytoDecayPower`  | :math:`p_{j}=4.0`                                                    |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | :varlink:`hetTempExp2`      | :varlink:`a_hetTempExp2`      | :math:`e^{\text{het}}_{2j}=0.001`                                    |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | :varlink:`hetTempOptimum`   | :varlink:`a_hetTempOptimum`   | :math:`T^{\text{opt het}}_j=2.0\,^\circ{\rm C}`                      |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | :varlink:`hetDecayPower`    | :varlink:`a_hetDecayPower`    | :math:`p^{\text{het}}_{j}=4.0`                                       |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | :varlink:`grazTempExp2`     | :varlink:`a_grazTempExp2`     | :math:`e^{\text{graz}}_{2j}=0.001`                                   |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | :varlink:`grazTempOptimum`  | :varlink:`a_grazTempOptimum`  | :math:`T^{\text{opt graz}}_j=2.0\,^\circ{\rm C}`                     |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+
   | :varlink:`grazDecayPower`   | :varlink:`a_grazDecayPower`   | :math:`p^{\text{graz}}_{j}=4.0`                                      |
   +-----------------------------+-------------------------------+----------------------------------------------------------------------+

With random trait generation, :math:`T^{\text{opt}}_j` is drawn from
a range [:varlink:`tempmax`--:varlink:`temprange`, :varlink:`tempmax`].

.. [#Ae]     Corresponds to an activation energy of 35.725 kJ mol\ :sup:`--1` at 20°C.
.. [#Exp1]   Corresponds to an activation energy of 28.023 kJ mol\ :sup:`--1` at 20°C.
.. [#AeArr]  Corresponds to an activation energy of 33.257 kJ mol\ :sup:`--1` at 20°C.
.. [#Ae4]    Corresponds to an activation energy of 31.314 kJ mol\ :sup:`--1` at 20°C.

