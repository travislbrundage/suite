.. _intro.installation.war.uninstall:

Uninstallation
==============

This section describes how to uninstall OpenGeo Suite for Application Servers.

.. note:: These instructions assume Tomcat, but the steps required for each application server will be similar to the ones presented here.

Undeploying applications via the Tomcat Management Console
----------------------------------------------------------

#. Open the Tomcat Management Console.

#. Click :guilabel:`Undeploy` next to each OpenGeo Suite web application.

#. The Tomcat Management Console will remove the deployed application and associated WAR file for each web application.

   .. note:: Undeploying will not delete your data directory if you have set it up to be external to the application.

Undeploying application manually
--------------------------------

#. Stop Tomcat.

#. Locate the :file:`webapps` directory and delete the following files:

   * :file:`opengeo-docs.war`
   * :file:`dashboard.war`
   * :file:`geoserver.war`
   * :file:`geoexplorer.war`
   * :file:`geowebcache.war`

   .. todo:: Might be others.
   
#. Delete the associated directories:

   * :file:`opengeo-docs`
   * :file:`dashboard`
   * :file:`geoserver`
   * :file:`geoexplorer`
   * :file:`geowebcache`

   .. todo:: Might be others.

#. Restart the application server (if desired).

   .. note:: Undeploying will not delete your data directory if you have set it up to be external to the application.
