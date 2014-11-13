.. _intro.installation.war.install:

Installing
==========

OpenGeo Suite is compatible with a number of application servers, among them Jetty, Tomcat, JBoss, and WebSphere. The most popular application server, and the most recommended is `Tomcat <http://tomcat.apache.org/>`_. Tomcat is available for all operating systems.

The following sections will assume that Tomcat is used, although most of the instructions and recommended strategies will also apply to other application servers with minimal alteration. 

System requirements
-------------------

OpenGeo Suite requires the use of Java 7 as a minimum. Either **Oracle JRE 7** or **OpenJDK 7** is supported.

.. for reference http://docs.geoserver.org/latest/en/user/installation/java.html

Other system requirements are the same as for other operating systems:

* :ref:`Windows <intro.installation.windows.install>`
* :ref:`OS X <intro.installation.mac.install>`
* :ref:`Ubuntu <intro.installation.ubuntu.install>`
* :ref:`Red Hat / CentOS <intro.installation.redhat.install>`

Deploying with Tomcat
---------------------

This section will show how to deploy the web applications to Tomcat.

Increasing the maximum application size
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Tomcat Management Console has an upper limit on the size of WAR files that can be deployed. This will need to be changed in order to deploy many of the OpenGeo Suite web applications.
   
#. Open the :file:`$CATALINA_BASE/webapps/manager/WEB-INF/web.xml` file in a text editor.

#. Edit the ``*multipart-config`` parameters as follows:
   
   .. code-block:: xml
      
       <multipart-config>
         <!-- 260 MB max -->
         <max-file-size>262144000</max-file-size>
         <max-request-size>262144000</max-request-size>
         <file-size-threshold>0</file-size-threshold>
       </multipart-config>

#. Save and close this file.

Increasing available memory
~~~~~~~~~~~~~~~~~~~~~~~~~~~

OpenGeo Suite requires more memory to be allocated on the application server. Increase both the heap space (used for data) and the PermGen space (used to load web applications).

Linux / OS X:

#. Create a :file:`$CATALINA_BASE/bin/setenv.sh` file if it doesn't already exist.

#. Add the following line:

   .. code-block:: sh

      export CATALINA_OPTS = "-Xmx1024m -XX:MaxPermSize=128m"

#. Save and close the file.

#. Restart Tomcat.

Windows:

#. Create a :file:`$CATALINA_BASE/bin/setenv.bat` file if it doesn't already exist.

#. Add the following line:

   .. code-block:: sh

      set CATALINA_OPTS = "-Xmx1024m -XX:MaxPermSize=128m"

#. Save and close the file. 

#. As an alternative you can configure these settings in the Tomcat Properties available in the from the task bar:
     
   * :guilabel:`Java Options`: Append :kbd:`-XX:MaxPermSize=128m`
   * :guilabel:`Maximum memory pool`: :kbd:`1024 MB`
     
   .. figure:: img/tomcat-windows.png
        
      Tomcat memory options

#. Restart Tomcat.

Deploying applications
~~~~~~~~~~~~~~~~~~~~~~

There are two ways to deploy applcations:

* Manually
* Through the `Tomcat Management Console <http://tomcat.apache.org/tomcat-7.0-doc/manager-howto.html>`_.

For deploying manually, web applications can often deployed by copying the individual WAR files to the :file:`webapps` directory. You may have to restart the container service afterwards.

For deploying using Tomcat Management Console:

#. Open the Management Console (often available at ``http://localhost:8080/manager/html``).

#. Locate the :guilabel:`Deploy` heading and click the :guilabel:`Browse` button.

   .. figure:: img/deploy-browse.png
        
      Deploying a web application

#. Select the web application file to deploy.

#. Click :guilabel:`Deploy`. The WAR file will be uploaded and unpacked into the :file:`webapps` folder.

#. Repeat this process as needed for every web application to be deployed.
   
Externalizing the GeoServer data directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

GeoServer includes a built-in data directory used to manage configuration information. To facilitate updating and prevent data loss, it is highly recommended to move the data directory to an location external to the application itself.

#. Stop Tomcat (or just GeoServer).

#. Move the :file:`geoserver/data` directory to an external location. Here are some suggested locations:
   
   * **Linux**: :file:`/var/lib/opengeo/geoserver`
   * **Windows**: :file:`C:\\ProgramData\\Boundless\\OpenGeo\\geoserver`
   * **OS X**: :file:`/Users/opengeo/geoserver_data`

#. Open :file:`geoserver/WEB-INF/web.xml` in a text editor.

#. Change the ``GEOSERVER_DATA_DIRECTORY`` parameter to point to the new directory location.

   .. note:: For similar reasons, it is recommended to do the same thing with the GeoWebCache cache location. This new location can be set in the :file:`geowebcache/WEB_INF/web.xml` file.

#. Restart Tomcat (or just GeoServer).

