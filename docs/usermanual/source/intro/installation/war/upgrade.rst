.. _intro.installation.war.upgrade:

Upgrading to OpenGeo Suite Enterprise
=====================================

This section describes how to upgrade OpenGeo Suite to OpenGeo Suite Enterprise.

.. note:: OpenGeo Suite Enterprise can only be obtained through `Boundless <http://boundlessgeo.com>`_. Please `contact us <http://boundlessgeo.com/about/contact-us/sales/>`_ for information on how to purchase OpenGeo Suite Enterprise.

.. todo:: Details needed.

#. Download the additional files as part of the Enterprise bundle for application servers.

#. Ensure GeoServer is configured with an external data directory. See the section on :ref:`intro.installation.war.install` for how to do this.

   .. warning:: Failure to use an external data directory may cause you to lose all of your data and settings.

#. Undeploy the following web applications:

   .. todo:: Details needed.

#. Remove the following files and directories:
   
   .. todo:: Details needed.

#. Unpack the following content:

   .. todo:: Details needed.

#. Restart Tomcat.

To verify that the upgrade was successful:

#. Navigate to the Dashboard, and verify that there is an entry for :guilabel:`Composer`.

#. Click the link to open the Composer. The application should load successfully.
