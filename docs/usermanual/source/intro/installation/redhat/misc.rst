.. _intro.installation.redhat.misc:

Working with OpenGeo Suite for Red Hat Linux
============================================

This document contains information about various tasks specific to OpenGeo Suite for Red Hat-based Linux distributions. 

Starting and stopping OpenGeo services
--------------------------------------

OpenGeo Suite is comprised of two main services:

#. The `Tomcat <http://tomcat.apache.org/>`_ web server that contains all the OpenGeo web applications such as GeoServer, GeoWebCache, and GeoExplorer. 

#. The `PostgreSQL <http://www.postgresql.org/>`_ database server with the PostGIS spatial extensions. 

On Red Hat based distributions the :command:`service` command is used to control the services. 

Controlling the Tomcat service
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To start/stop/restart the Tomcat service:

  .. code-block:: bash
 
     service tomcat start|stop|restart

.. note:: Depending on the distribution and version the service name may be one of "tomcat", "tomcat5", or "tomcat6". Use the :command:`service` command to determine which one is installed:

  .. code-block:: bash

     service --status-all | grep tomcat

Controlling the PostgreSQL service
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Before PostgreSQL service can be started it must first be initialized:

  .. code-block:: bash

     service postgresql-9.3 initdb

To start/stop/restart the PostgreSQL service:

  .. code-block:: bash
 
     service postgresql-9.3 start|stop|restart

Service port configuration
--------------------------

The Tomcat and PostgreSQL services run on ports **8080** and **5432** respectively. These ports can often conflict with existing services on the systemk, in which case the ports must be changed. 

Changing the Tomcat port
^^^^^^^^^^^^^^^^^^^^^^^^

To change the Tomcat port:

#. Edit the file :file:`/etc/tomcat/server.xml`. 

   .. note:: Depending on the distribution and version replace "tomcat" with "tomcat5" or "tomact6" accordingly. Use the :command:`service` command to determine which one is installed:

      .. code-block:: bash

         service --status-all | grep tomcat

#. Search for "8080" (around line 75) and change the ``port`` attribute to the desired value.

#. Restart tomcat. 

   .. code-block:: bash

        service tomcat restart

Changing the PostgreSQL port
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To change the PostgreSQL port:

#. Edit the file :file:`/var/lib/pgsql/9.3/data/postgresql.conf`.

#. Search or the ``port`` property (around line 63), uncomment and change it to the desired value.

#. Restart PostgreSQL.

   .. code-block:: bash

       service postgresql-9.3 restart

Working with Tomcat
-------------------

Changing the Tomcat Java
^^^^^^^^^^^^^^^^^^^^^^^^

If you wish to use the Oracle Java 7 JRE (rather than the OpenJDK 7 installed by default):

#. Download and install Oracle Java 7 JRE.

#. Edit the /etc/default/tomcat7
   
   Update the JAVA_HOME environment variable.

Use Suite Packages with custom Tomcat
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Suite packages can be used to manage the contents :file:`/usr/share/opengeo` components while making use of your own Tomcat Application Server. This is an alternative to deploying suite using web archives into the :file:`webapps` directory.

#. Install suite packages

#. Stop your Tomcat service

#. Navigate to :file:`/etc/tomcat7/Catalina/localhost/`

#. Create the :file:`geoserver.xml` with the following content:
   
   .. code-block:: xml
   
      <Context displayName="geoserver"
               docBase="/usr/share/opengeo/geoserver"
               path="/geoserver"/>

#. Create the :file:`geowebcache.xml` with the following content:
   
   .. code-block:: xml
   
      <Context displayName="geowebcache"
               docBase="/usr/share/opengeo/geowebcache"
               path="/geowebcache"/>

#. Create the :file:`dashboard.xml` with the following content:
   
   .. code-block:: xml
   
      <Context displayName="dashboard"
               docBase="/usr/share/opengeo/dashboard"
               path="/dashboard"/>

#. Create the :file:`geoexplorer.xml` with the following content:
   
   .. code-block:: xml
   
      <Context displayName="geoexplorer"
               docBase="/usr/share/opengeo/geoexplorer"
               path="/geoexplorer"/>

#. Create the :file:`docs.xml` with the following content:
   
   .. code-block:: xml
   
      <Context displayName="docs"
               docBase="/usr/share/opengeo/docs"
               path="/docs"/>

#. Create the :file:`recipes.xml` with the following content:
   
   .. code-block:: xml
   
      <Context displayName="docs"
               docBase="/usr/share/opengeo/recipes"
               path="/recipes"/>
               
#. Restart Tomcat

GeoServer Data Directory
------------------------

The **GeoServer Data Directory** is the location on the file system where GeoServer stores all of its configuration, and (optionally) file-based data. By default, this directory is located at: :file:`/var/lib/opengeo/geoserver`. 

To point GeoServer to an alternate location:

#. Edit the file :file:`/usr/share/opengeo/geoserver/WEB-INF/web.xml`.

#. Search for ``GEOSERVER_DATA_DIR`` and change its value accordingly.

#. Restart Tomcat.

.. _intro.installation.redhat.misc.pgconfig:

PostgreSQL Configuration
------------------------

PostgreSQL configuration is controlled within the ``postgresql.conf`` file. This
file is located at :file:`/var/lib/pgsql/9.3/data/postgresql.conf`. 

You will want to ensure you can connect to the database, and that you have a user to 
work with. Please see the section on :ref:`dataadmin.pgGettingStarted.firstconnect`.
