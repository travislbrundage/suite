/* (c) 2014 Boundless, http://boundlessgeo.com
 * This code is licensed under the GPL 2.0 license.
 */
package com.boundlessgeo.geoserver.api.controllers;

// TODO: Clean up imports
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
import static org.geoserver.catalog.Predicates.equal;

import org.opengis.feature.simple.SimpleFeature;
import org.opengis.feature.simple.SimpleFeatureType;
import org.opengis.filter.Filter;
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
    
    private static boolean WELLFORMED = true;
    
    @Autowired
    public FootprintsController(GeoServer geoServer) {
        super(geoServer);
    }
    
    // Issue GET request in /footprints/<workspace>?bbox=x1,x2,y1,y2
    @RequestMapping(value="/{wsName}", method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseStatus(HttpStatus.OK)
    public @ResponseBody
    void getLayersInBbox(@PathVariable String wsName, @RequestParam("bbox") String bbox,
            HttpServletResponse response) throws IOException{
        Catalog cat = geoServer.getCatalog();
        
        final Envelope bboxEnv = getBboxFromString(bbox);
        final Iterator<LayerInfo> layers = findAllLayersInWorkspace(wsName, cat);
        final SimpleFeatureBuilder featureBuilder = makeBuilder(wsName);
        
        final Iterator<SimpleFeature> featuresFromLayers = 
                transform(layers, new Function<LayerInfo, SimpleFeature>() {
                @Override
                public SimpleFeature apply(LayerInfo layer) {
                    featureBuilder.add(JTS.toGeometry(layer.getResource().getLatLonBoundingBox()));
                    featureBuilder.add(layer.getName());
                    featureBuilder.add(layer.getTitle());
                    // Only use the bbox if the parameter is well formed
                    if (WELLFORMED == true) {
                        // TODO: Use the bbox specified in the get request
                    }
                    return featureBuilder.buildFeature(null);
                }
        });
        
        FeatureCollection featureCollection = 
                new DefaultFeatureCollection(null, featureBuilder.getFeatureType()) {
                @Override
                public SimpleFeatureIterator features() {
                    return new DelegateSimpleFeatureIterator(featuresFromLayers);
            }
        };
        
        FeatureJSON json = new FeatureJSON();
        json.writeFeatureCollection(featureCollection, response.getWriter());
    }
    
    private Envelope getBboxFromString(String bbox) {
        int[] env = new int[4];
        String[] integers = bbox.split(",");
        
        if (integers.length == 4) {
            for (int i = 0; i < integers.length; i++) {
                try {
                    env[i] = Integer.parseInt(integers[i]);
                } catch (NumberFormatException e) {
                    WELLFORMED = false;
                    return null;
                }
            }
        } else {
            WELLFORMED = false;
            return null;
        }
        
        return new Envelope(env[0],env[1],env[2],env[3]);
    }
    
    private Iterator<LayerInfo> findAllLayersInWorkspace(String wsName, Catalog cat) {
        return cat.list(LayerInfo.class, Predicates.equal("resource.namespace.prefix", wsName));
    }
    
    private SimpleFeatureBuilder makeBuilder(String wsName) {
        SimpleFeatureTypeBuilder typebuilder = new SimpleFeatureTypeBuilder();
        // TODO: Set the correct values here
        typebuilder.setName(wsName);
        typebuilder.setNamespaceURI( "http://" + wsName );
        typebuilder.setSRS( "EPSG:4326" );
        typebuilder.add( "geometry", Geometry.class );
        typebuilder.add( "name", String.class );
        typebuilder.add( "title", String.class );
        typebuilder.add( "bbox", String.class );
        
        SimpleFeatureType type = typebuilder.buildFeatureType();
        return new SimpleFeatureBuilder(type);
    }
}

