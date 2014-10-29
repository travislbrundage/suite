
 package com.boundlessgeo.geoserver.api.controllers;  import static org.junit.Assert.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.ArrayList;

import org.geoserver.config.GeoServer;

import org.json.simple.JSONArray;

import org.junit.Before;
import org.junit.Test;

import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import com.boundlessgeo.geoserver.api.converters.JSONMessageConverter;
import com.boundlessgeo.geoserver.json.JSONArr;
import com.boundlessgeo.geoserver.json.JSONObj;
import com.boundlessgeo.geoserver.json.JSONWrapper;

public class FootprintsControllerTest {

    @Mock
    GeoServer geoServer;
    
    @InjectMocks
    FootprintsController ctrl;
    
    MockMvc mvc;
    
    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);

        mvc = MockMvcBuilders.standaloneSetup(ctrl).setMessageConverters(new JSONMessageConverter()).build();
    }
    
    @Test
    public void testGetLayersInBbox() throws Exception {
        String fooLayer1 = "foo_one", fooLayer2 = "foo_two", fooLayer3 = "foo_three",
                barLayer1 = "bar_one", barLayer2 = "bar_two";
        MockGeoServer.get().catalog()
            .workspace("foo", "http://scratch.org", true)
                .layer(fooLayer1).featureType().defaults().workspace()
                .layer(fooLayer2).featureType().defaults().workspace()
                .layer(fooLayer3).featureType().defaults().geoServer().catalog()
            .workspace("bar", "http://bar.org", false)
                .layer(barLayer1).featureType().defaults().workspace()
                .layer(barLayer2).featureType().defaults()
            .geoServer().build(geoServer);
        
        // TODO: Needs to use the bbox parameter somehow
        // Test workspace foo
        String bbox = "?bbox=1,2,3,4,";
        String wsName = "foo";
        MvcResult result = mvc.perform(get("/api/footprints/" + wsName + bbox))
                .andExpect(status().isOk())
                .andReturn();
        
        JSONObj obj = JSONWrapper.read(result.getResponse().getContentAsString()).toObject();
        
        ArrayList<String> names = new ArrayList<String>();
        names.add(fooLayer1);
        names.add(fooLayer2);
        names.add(fooLayer3);
        testJSON(obj, names);
        names.clear();
        
        // Test workspace bar
        bbox = "?bbox=4,3,2,1";
        wsName = "bar";
        result = mvc.perform(get("/api/footprints/" + wsName + bbox))
                .andExpect(status().isOk())
                .andReturn();
        
        obj = JSONWrapper.read(result.getResponse().getContentAsString()).toObject();
        
        names.add(barLayer1);
        names.add(barLayer2);
        testJSON(obj, names);
        names.clear();
    }
    
    /**
     * Runs JUnit assertions to check that the JSON was generated correctly for
     * the mocked up layers in the workspace specified by the GET request.
     * @param obj - The JSONObj generated based on the response to the GET request
     * @param names - The names of the mocked up layers
     */
    public void testJSON(JSONObj obj, ArrayList<String> names) {
        JSONArr features = obj.array("features");
        assertEquals(names.size(), features.size());
        for(int i = 0; i < names.size(); i++) {
            JSONObj feature = features.object(i);
            assertEquals("Feature", feature.get("type"));
            assertNotNull(feature.get("id"));
            JSONObj properties = feature.object("properties");
            assertEquals(names.get(i), properties.get("name"));
            JSONObj geometry = properties.object("geometry");
            assertEquals("Polygon", geometry.get("type"));
            JSONArray coordinates = (JSONArray)geometry.get("coordinates");
            JSONArray subcoordinates = (JSONArray)coordinates.get(0);
            assertEquals(5, subcoordinates.size());
            assertEquals("[-180,-90]", subcoordinates.get(0).toString());
            assertEquals("[180,-90]", subcoordinates.get(1).toString());
            assertEquals("[180,90]", subcoordinates.get(2).toString());
            assertEquals("[-180,90]", subcoordinates.get(3).toString());
            assertEquals("[-180,-90]", subcoordinates.get(4).toString());
        }
    }
}

