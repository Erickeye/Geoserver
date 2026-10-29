<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor version="1.0.0"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer>
    <Name>youbike-bikes</Name>
    <UserStyle>
      <Title>YouBike 依可借車輛上色</Title>
      <FeatureTypeStyle>
      <Rule>
        <Name>inactive-far</Name><Title>停用</Title>
        <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>active</ogc:PropertyName><ogc:Literal>0</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
        <MinScaleDenominator>200000</MinScaleDenominator>
        <PointSymbolizer><Graphic><Mark><WellKnownName>circle</WellKnownName><Fill><CssParameter name="fill">#9E9E9E</CssParameter></Fill></Mark><Size>4</Size></Graphic></PointSymbolizer>
      </Rule>
      <Rule>
        <Name>inactive-near</Name><Title>停用</Title>
        <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>active</ogc:PropertyName><ogc:Literal>0</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
        <MaxScaleDenominator>200000</MaxScaleDenominator>
        <PointSymbolizer><Graphic><Mark><WellKnownName>circle</WellKnownName><Fill><CssParameter name="fill">#9E9E9E</CssParameter></Fill><Stroke><CssParameter name="stroke">#FFFFFF</CssParameter><CssParameter name="stroke-width">1</CssParameter></Stroke></Mark><Size>11</Size></Graphic></PointSymbolizer>
      </Rule>
      <Rule>
        <Name>empty-far</Name><Title>無車可借</Title>
        <ogc:Filter><ogc:And><ogc:PropertyIsEqualTo><ogc:PropertyName>active</ogc:PropertyName><ogc:Literal>1</ogc:Literal></ogc:PropertyIsEqualTo><ogc:PropertyIsEqualTo><ogc:PropertyName>bikes</ogc:PropertyName><ogc:Literal>0</ogc:Literal></ogc:PropertyIsEqualTo></ogc:And></ogc:Filter>
        <MinScaleDenominator>200000</MinScaleDenominator>
        <PointSymbolizer><Graphic><Mark><WellKnownName>circle</WellKnownName><Fill><CssParameter name="fill">#D32F2F</CssParameter></Fill></Mark><Size>4</Size></Graphic></PointSymbolizer>
      </Rule>
      <Rule>
        <Name>empty-near</Name><Title>無車可借</Title>
        <ogc:Filter><ogc:And><ogc:PropertyIsEqualTo><ogc:PropertyName>active</ogc:PropertyName><ogc:Literal>1</ogc:Literal></ogc:PropertyIsEqualTo><ogc:PropertyIsEqualTo><ogc:PropertyName>bikes</ogc:PropertyName><ogc:Literal>0</ogc:Literal></ogc:PropertyIsEqualTo></ogc:And></ogc:Filter>
        <MaxScaleDenominator>200000</MaxScaleDenominator>
        <PointSymbolizer><Graphic><Mark><WellKnownName>circle</WellKnownName><Fill><CssParameter name="fill">#D32F2F</CssParameter></Fill><Stroke><CssParameter name="stroke">#FFFFFF</CssParameter><CssParameter name="stroke-width">1</CssParameter></Stroke></Mark><Size>11</Size></Graphic></PointSymbolizer>
      </Rule>
      <Rule>
        <Name>low-far</Name><Title>1-4 輛</Title>
        <ogc:Filter><ogc:And><ogc:PropertyIsEqualTo><ogc:PropertyName>active</ogc:PropertyName><ogc:Literal>1</ogc:Literal></ogc:PropertyIsEqualTo><ogc:PropertyIsBetween><ogc:PropertyName>bikes</ogc:PropertyName><ogc:LowerBoundary><ogc:Literal>1</ogc:Literal></ogc:LowerBoundary><ogc:UpperBoundary><ogc:Literal>4</ogc:Literal></ogc:UpperBoundary></ogc:PropertyIsBetween></ogc:And></ogc:Filter>
        <MinScaleDenominator>200000</MinScaleDenominator>
        <PointSymbolizer><Graphic><Mark><WellKnownName>circle</WellKnownName><Fill><CssParameter name="fill">#F57C00</CssParameter></Fill></Mark><Size>4</Size></Graphic></PointSymbolizer>
      </Rule>
      <Rule>
        <Name>low-near</Name><Title>1-4 輛</Title>
        <ogc:Filter><ogc:And><ogc:PropertyIsEqualTo><ogc:PropertyName>active</ogc:PropertyName><ogc:Literal>1</ogc:Literal></ogc:PropertyIsEqualTo><ogc:PropertyIsBetween><ogc:PropertyName>bikes</ogc:PropertyName><ogc:LowerBoundary><ogc:Literal>1</ogc:Literal></ogc:LowerBoundary><ogc:UpperBoundary><ogc:Literal>4</ogc:Literal></ogc:UpperBoundary></ogc:PropertyIsBetween></ogc:And></ogc:Filter>
        <MaxScaleDenominator>200000</MaxScaleDenominator>
        <PointSymbolizer><Graphic><Mark><WellKnownName>circle</WellKnownName><Fill><CssParameter name="fill">#F57C00</CssParameter></Fill><Stroke><CssParameter name="stroke">#FFFFFF</CssParameter><CssParameter name="stroke-width">1</CssParameter></Stroke></Mark><Size>11</Size></Graphic></PointSymbolizer>
      </Rule>
      <Rule>
        <Name>ok-far</Name><Title>5 輛以上</Title>
        <ogc:Filter><ogc:And><ogc:PropertyIsEqualTo><ogc:PropertyName>active</ogc:PropertyName><ogc:Literal>1</ogc:Literal></ogc:PropertyIsEqualTo><ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyName>bikes</ogc:PropertyName><ogc:Literal>5</ogc:Literal></ogc:PropertyIsGreaterThanOrEqualTo></ogc:And></ogc:Filter>
        <MinScaleDenominator>200000</MinScaleDenominator>
        <PointSymbolizer><Graphic><Mark><WellKnownName>circle</WellKnownName><Fill><CssParameter name="fill">#2E7D32</CssParameter></Fill></Mark><Size>4</Size></Graphic></PointSymbolizer>
      </Rule>
      <Rule>
        <Name>ok-near</Name><Title>5 輛以上</Title>
        <ogc:Filter><ogc:And><ogc:PropertyIsEqualTo><ogc:PropertyName>active</ogc:PropertyName><ogc:Literal>1</ogc:Literal></ogc:PropertyIsEqualTo><ogc:PropertyIsGreaterThanOrEqualTo><ogc:PropertyName>bikes</ogc:PropertyName><ogc:Literal>5</ogc:Literal></ogc:PropertyIsGreaterThanOrEqualTo></ogc:And></ogc:Filter>
        <MaxScaleDenominator>200000</MaxScaleDenominator>
        <PointSymbolizer><Graphic><Mark><WellKnownName>circle</WellKnownName><Fill><CssParameter name="fill">#2E7D32</CssParameter></Fill><Stroke><CssParameter name="stroke">#FFFFFF</CssParameter><CssParameter name="stroke-width">1</CssParameter></Stroke></Mark><Size>11</Size></Graphic></PointSymbolizer>
      </Rule>
      <Rule>
        <Name>label</Name><Title>可借車輛數</Title>
        <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>active</ogc:PropertyName><ogc:Literal>1</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
        <MaxScaleDenominator>20000</MaxScaleDenominator>
        <TextSymbolizer>
          <Label><ogc:PropertyName>bikes</ogc:PropertyName></Label>
          <Font><CssParameter name="font-family">Arial</CssParameter><CssParameter name="font-size">9</CssParameter><CssParameter name="font-weight">bold</CssParameter></Font>
          <LabelPlacement><PointPlacement><AnchorPoint><AnchorPointX>0.5</AnchorPointX><AnchorPointY>0.5</AnchorPointY></AnchorPoint></PointPlacement></LabelPlacement>
          <Fill><CssParameter name="fill">#FFFFFF</CssParameter></Fill>
        </TextSymbolizer>
      </Rule>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
