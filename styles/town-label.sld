<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor version="1.0.0"
  xmlns="http://www.opengis.net/sld"
  xmlns:ogc="http://www.opengis.net/ogc"
  xmlns:xlink="http://www.w3.org/1999/xlink">
  <NamedLayer>
    <Name>town-label</Name>
    <UserStyle>
      <Title>Town with labels</Title>
      <FeatureTypeStyle>
        <Rule>
          <Name>fill</Name>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#4A90D9</CssParameter>
              <CssParameter name="fill-opacity">0.6</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.5</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>label</Name>
          <MaxScaleDenominator>500000</MaxScaleDenominator>
          <TextSymbolizer>
            <Label><ogc:PropertyName>TOWNNAME</ogc:PropertyName></Label>
            <Font>
              <CssParameter name="font-family">Microsoft JhengHei</CssParameter>
              <CssParameter name="font-size">12</CssParameter>
            </Font>
            <LabelPlacement><PointPlacement><AnchorPoint>
              <AnchorPointX>0.5</AnchorPointX><AnchorPointY>0.5</AnchorPointY>
            </AnchorPoint></PointPlacement></LabelPlacement>
            <Halo><Radius>1.5</Radius><Fill><CssParameter name="fill">#FFFFFF</CssParameter></Fill></Halo>
            <Fill><CssParameter name="fill">#222222</CssParameter></Fill>
            <VendorOption name="maxDisplacement">20</VendorOption>
            <VendorOption name="goodnessOfFit">0.3</VendorOption>
          </TextSymbolizer>
        </Rule>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
