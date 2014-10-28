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
import org.geoserver.catalog.WorkspaceInfo;
import org.geoserver.catalog.util.CloseableIterator;
import org.geoserver.config.GeoServer;
import org.geotools.geojson.GeoJSON;

import com.boundlessgeo.geoserver.bundle.BundleExporter;
import com.boundlessgeo.geoserver.bundle.BundleImporter;
import com.boundlessgeo.geoserver.bundle.ExportOpts;
import com.boundlessgeo.geoserver.bundle.ImportOpts;
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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Iterator;
import java.util.List;

@Controller
// Should it just be /footprints? workspaces is based on their selection?
@RequestMapping("/api/footprints/workspaces")
public class FootprintsController extends ApiController {
    
    @Autowired
    public FootprintsController(GeoServer geoServer) {
        super(geoServer);
    }
    
    @RequestMapping(method = RequestMethod.GET)
    public @ResponseBody
    JSONObj testGet() {
        Catalog cat = geoServer.getCatalog();
        WorkspaceInfo ws = cat.getFactory().createWorkspace();
        String wsName = "whatsinaname";
        ws.setName(wsName);
        NamespaceInfo ns = cat.getFactory().createNamespace();
        ns.setPrefix(wsName);
        ns.setURI("http://" + wsName);
        return IO.workspace(new JSONObj(), ws, ns, true);
    }
    
    // Issue GET request in /footprints/<workspace>/?bbox=x1,x2,y1,y2
    /*@RequestMapping(method = RequestMethod.GET)
    public @ResponseBody
    GeoJSON exportLayers(@RequestParam(value="bbox", defaultValue="0,0,0,0") Envelope bbox) {
        // Which Envelope do I use? Default value?
        // what do
        Catalog cat = geoServer.getCatalog();
        WorkspaceInfo ws = cat.getDefaultWorkspace();
        List<LayerInfo> list = cat.getLayers();
        LayerInfo layer;
    }
    */
}

