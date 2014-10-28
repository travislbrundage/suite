/* (c) 2014 Boundless, http://boundlessgeo.com
 * This code is licensed under the GPL 2.0 license.
 */
package com.boundlessgeo.geoserver.api.controllers;

import com.boundlessgeo.geoserver.api.exceptions.BadRequestException;
import com.boundlessgeo.geoserver.json.JSONArr;
import com.boundlessgeo.geoserver.json.JSONObj;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.io.FileUtils;
import org.geoserver.catalog.CascadeDeleteVisitor;
import org.geoserver.catalog.Catalog;
import org.geoserver.catalog.LayerInfo;
import org.geoserver.catalog.NamespaceInfo;
import org.geoserver.catalog.Predicates;
import org.geoserver.catalog.StoreInfo;
import org.geoserver.catalog.WorkspaceInfo;
import org.geoserver.catalog.util.CloseableIterator;
import org.geoserver.config.GeoServer;
import org.geoserver.wfs.json.GeoJSONBuilder;
import org.geotools.geojson.GeoJSON;
import org.geotools.geojson.feature.FeatureJSON;
import org.geotools.geometry.jts.JTS;

import com.boundlessgeo.geoserver.bundle.BundleExporter;
import com.boundlessgeo.geoserver.bundle.BundleImporter;
import com.boundlessgeo.geoserver.bundle.ExportOpts;
import com.boundlessgeo.geoserver.bundle.ImportOpts;
import com.vividsolutions.jts.geom.Envelope;
import com.vividsolutions.jts.geom.Polygon;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;

import static com.google.common.collect.Iterators.transform;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.feature.simple.SimpleFeatureType;
import org.opengis.geometry.Geometry;

import com.google.common.base.Function;

import org.geotools.data.simple.SimpleFeatureIterator;
import org.geotools.feature.DefaultFeatureCollection;
import org.geotools.feature.FeatureCollection;
import org.geotools.feature.FeatureIterator;
import org.geotools.feature.collection.DelegateFeatureIterator;
import org.geotools.feature.collection.DelegateSimpleFeatureIterator;
import org.geotools.feature.collection.SimpleFeatureIteratorImpl;
import org.geotools.feature.simple.SimpleFeatureTypeBuilder;
import org.geotools.feature.simple.SimpleFeatureBuilder;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Iterator;
import java.util.List;

@Controller
@RequestMapping("/api/footprints")
public class FootprintsController extends ApiController {
    
    @Autowired
    public FootprintsController(GeoServer geoServer) {
        super(geoServer);
    }
    
    // Issue GET request in /footprints/<workspace>?bbox=x1,x2,y1,y2
    @RequestMapping(value="/{wsName}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseStatus(HttpStatus.OK)
    public @ResponseBody
    FeatureJSON exportLayer(@PathVariable String wsName, HttpServletResponse response,
            @RequestParam("bbox") String bbox) throws IOException{
        Envelope bboxEnv = getBboxFromString(bbox);

        Catalog cat = geoServer.getCatalog();
        final Iterator<LayerInfo> layers = 
                cat.list(LayerInfo.class, Predicates.equal("resource.store.workspace.name", wsName));
        
        SimpleFeatureTypeBuilder typebuilder = new SimpleFeatureTypeBuilder();
        // TODO: set the proper values
        typebuilder.setName(wsName);
        typebuilder.setNamespaceURI( "http://" + wsName );
        typebuilder.setSRS( "EPSG:4326" );
        
        typebuilder.add( "geometry", Geometry.class );
        typebuilder.add( "name", String.class );
        typebuilder.add( "title", String.class );
        
        SimpleFeatureType type = typebuilder.buildFeatureType();
        final SimpleFeatureBuilder featurebuilder = new SimpleFeatureBuilder(type);
        
        final Iterator<SimpleFeature> featuresFromLayers = 
                transform(layers, new Function<LayerInfo, SimpleFeature>() {
            @Override
            public SimpleFeature apply(LayerInfo layer) {
                featurebuilder.add(JTS.toGeometry(layer.getResource().getLatLonBoundingBox()));
                featurebuilder.add(layer.getName());
                featurebuilder.add(layer.getTitle());
                return featurebuilder.buildFeature(null);
            }
        });
        
        
        FeatureCollection featureCollection = new DefaultFeatureCollection(null, null) {
            // TODO: Did I do this right?
            @Override
            public SimpleFeatureIterator features() {
                return new DelegateSimpleFeatureIterator(featuresFromLayers);
            }
        };
        
        FeatureJSON json = new FeatureJSON();
        json.writeFeatureCollection(featureCollection, response.getWriter());
        return json;
    }
    
    private Envelope getBboxFromString(String bbox) {
        Integer x1=0,y1=0,x2=0,y2=0;
        String[] integers = bbox.split(",");
        
        if (integers.length == 4) {
            x1 = Integer.parseInt(integers[0]);
            y1 = Integer.parseInt(integers[1]);
            x2 = Integer.parseInt(integers[2]);
            y2 = Integer.parseInt(integers[3]);
        } else {
            System.out.println("Malformed bbox request");
        }
        
        return new Envelope(x1,y1,x2,y2);
    }
    
    private CloseableIterator<LayerInfo> findAllLayersInWorkspace(String wsName, Catalog cat) {
        return cat.list(LayerInfo.class, Predicates.equal("resource.store.workspace.name", wsName));
    }
    
    private SimpleFeatureBuilder makeBuilder(String wsName) {
        SimpleFeatureTypeBuilder typebuilder = new SimpleFeatureTypeBuilder();
        // TODO: set the proper values
        typebuilder.setName(wsName);
        typebuilder.setNamespaceURI( "http://" + wsName );
        typebuilder.setSRS( "EPSG:4326" );
        
        typebuilder.add( "geometry", Geometry.class );
        typebuilder.add( "name", String.class );
        typebuilder.add( "title", String.class );
        
        SimpleFeatureType type = typebuilder.buildFeatureType();
        return new SimpleFeatureBuilder(type);
    }
}

