.. _cartography.ysld.tutorial.raster:

Styling a raster layer
======================

Raster layers are composed of a grid of values in one or more bands. A grayscale image will have a single band, with each grid element containing the intensity at that pixel. An RGB image will have 3 bands, corresponding to red, green, and blue values. A raster can have any number of bands. 

This raster layer has a single band. With the default :ref:`raster symbolizer <cartography.ysld.reference.symbolizers.raster>`, it is drawn as a grayscale image.

Viewing the existing style
--------------------------

#. In the layers tab of the Composer, click on the style option for the ``16_bit_dem_large`` layer to go to the style edit page. A simple default style is already associated with this layer::

      name: raster
      feature-styles:
      - name: name
        rules:
        - symbolizers:
          - raster:
              opacity: 1

   .. figure:: img/raster_dem_gray.png

      Default raster display

Adding contrast
---------------

#. If we want the land to show up better in the display, we can use the ``contrast-enhancement`` attribute::

          contrast-enhancement:
            mode: histogram
            gamma: 4

   This adjusts the contrast so each brightness level contains an equal amount of content, and darkens the resulting image by a factor of ``4``.

#. The style now is::

      name: raster
      feature-styles:
      - name: name
        rules:
        - symbolizers:
          - raster:
              opacity: 1
              contrast-enhancement:
                mode: histogram
                gamma: 4

   .. figure:: img/raster_dem_contrast.png

      Added contrast

Creating a color map
--------------------

The ``color-map`` attribute can be used to convert any single band of data into a colored image based on the band values.

#. Add a color map with the following intervals:

   .. list-table::
      :class: non-responsive
      :widths: 40 60 
      :header-rows: 1

      * - Color
        - Values
      * - ``0043c8``
        - Less than ``8080``
      * - ``00c819``
        - Between ``8080`` and ``100000``

::

          color-map:
            type: intervals
            entries:
            - (0043c8, 1, 8080, blue)
            - (00c819, 1, 100000, green)

#. Since ``contrast-enhancement`` cannot be used with ``color-map``, remove it from the style.

#. The layer now looks like this:

   .. figure:: img/raster_dem_interval.png

      Interval color map

#. The color map can also be used with ``type: ramp`` to create a gradient of colors between entries. Use this to create a basic colored elevation map with the following values:

   .. list-table::
      :class: non-responsive
      :widths: 40 60 
      :header-rows: 1

      * - Color
        - Value
      * - ``0043c8`` (blue)
        - ``8080``
      * - ``00c819`` (green)
        - ``10000``
      * - ``bbc800`` (yellow)
        - ``15000``
      * - ``c81c00`` (red)
        - ``30000``
      * - ``ffffff`` (white)
        - ``50000``

   ::

          color-map:
            type: ramp
            entries:
            - (0043c8, 1, 8080, blue)
            - (00c819, 1, 10000, green)
            - (bbc800, 1, 15000, yellow)
            - (c81c00, 1, 30000, red)
            - (ffffff, 1, 50000, white)


   .. figure:: img/raster_dem_rgb.png

      Color ramp

#. The full style for this is::

    name: raster
    feature-styles:
    - name: name
      rules:
      - symbolizers:
        - raster:
            opacity: 1
            color-map:
              type: ramp
              entries:
              - (0043c8, 1, 8080, blue)
              - (00c819, 1, 10000, green)
              - (bbc800, 1, 15000, yellow)
              - (c81c00, 1, 30000, red)
              - (ffffff, 1, 50000, white)


Simplifying the style
---------------------

Because our final purpose for this layer is to display it along with other layers, a simpler, less colorful style would be easier to read.

#. Create a ``color-map`` with intervals denoting ocean, and three elevations:

   .. list-table::
      :class: non-responsive
      :widths: 40 60 
      :header-rows: 1

      * - Color
        - Value
      * - ``0043c8`` (ocean)
        - Less than ``8080``
      * - ``4b4422`` (low elevation)
        - Between ``8080`` and ``10000``
      * - ``857b54`` (mid elevation)
        - Between ``10000`` and ``15000``
      * - ``d9d1a8`` (red)
        - Between ``15000`` and ``30000``

::

          color-map:
            type: intervals
            entries:
            - (0043c8, 1, 8080, ocean)
            - (4b4422, 1, 10000, low)
            - (857b54, 1, 20000, mid)
            - (d9d1a8, 1, 60000, high)

Final style
-----------

The final style looks like::

  name: raster
  feature-styles:
  - name: name
    rules:
    - symbolizers:
      - raster:
          opacity: 1
          color-map:
            type: intervals
            entries:
            - (0043c8, 1, 8080, ocean)
            - (4b4422, 1, 10000, low)
            - (857b54, 1, 20000, mid)
            - (d9d1a8, 1, 60000, high)

.. figure:: img/raster_dem_brownscale.png

   Simplified color map

.. note:: :download:`Download the final raster style <files/ysldtut_raster.ysld>`

We have now styled all of our layers. Continue on to :ref:`cartography.ysld.tutorial.map` for the final step in the process.
