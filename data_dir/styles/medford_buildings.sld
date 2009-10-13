<?xml version="1.0" encoding="ISO-8859-1"?>
<StyledLayerDescriptor version="1.0.0" xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer>
    <Name>medford:buildings</Name>
    <UserStyle>
      <Title>Medford, OR - Buildings</Title>
      <Abstract></Abstract>

      <FeatureTypeStyle>

<!--70K-35K--> 
        <Rule>
          <Name>Buildings 70K-35K</Name>
          <Title>Buildings 70K-35K</Title>

          <MinScaleDenominator> 35000 </MinScaleDenominator>
          <MaxScaleDenominator> 70000 </MaxScaleDenominator> 
          
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#333333</CssParameter>
              <CssParameter name="fill-opacity">.5</CssParameter>   
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#333333</CssParameter>
              <CssParameter name="stroke-width">.5</CssParameter>
            </Stroke>
          </PolygonSymbolizer>  
        </Rule>

<!--< 35K--> 
        <Rule>
          <Name>Buildings &lt; 35K </Name>
          <Title>Buildings &lt; 35K</Title>
          
          <MaxScaleDenominator> 35000 </MaxScaleDenominator>   
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#333333</CssParameter>
              <CssParameter name="fill-opacity">.5</CssParameter>   
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#333333</CssParameter>
              <CssParameter name="stroke-width">.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>