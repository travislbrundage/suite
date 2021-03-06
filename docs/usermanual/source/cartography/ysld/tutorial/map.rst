.. _cartography.ysld.tutorial.map:

Composing a map
===============

Now that we have a set of styled layers, we can bring them together as a map.

In the Composer, create a new map with the four layers styled in the following order (top is drawn last)

* ``ne_10m_admin_0_populated_places`` (point layer)
* ``ne_10m_admin_0_roads`` (line layer)
* ``ne_10m_admin_0_countries`` (polygon layer)
* ``16_bit_dem_large`` (raster layer)

.. todo:: Link to info or show here.

This will produce a map that looks like the following at various zoom levels:

.. figure:: img/map_zoom_1.png

   Map at world scale

.. figure:: img/map_zoom_2.png

   Map at region scale

.. figure:: img/map_zoom_3.png

   Map at city scale

For more information, please see the :ref:`cartography.ysld.reference`.
