<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor version="1.0.0"
  xmlns="http://www.opengis.net/sld"
  xmlns:ogc="http://www.opengis.net/ogc"
  xmlns:xlink="http://www.w3.org/1999/xlink">
  <NamedLayer>
    <Name>town-county</Name>
    <UserStyle>
      <Title>Towns by county</Title>
      <FeatureTypeStyle>
        <Rule>
          <Name>臺北市-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>臺北市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#E15759</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#E15759</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>臺北市-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>臺北市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#E15759</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>新北市-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>新北市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#4E79A7</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#4E79A7</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>新北市-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>新北市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#4E79A7</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>基隆市-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>基隆市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#F28E2B</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#F28E2B</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>基隆市-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>基隆市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#F28E2B</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>桃園市-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>桃園市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#59A14F</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#59A14F</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>桃園市-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>桃園市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#59A14F</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>新竹市-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>新竹市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#B07AA1</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#B07AA1</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>新竹市-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>新竹市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#B07AA1</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>新竹縣-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>新竹縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#EDC948</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#EDC948</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>新竹縣-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>新竹縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#EDC948</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>苗栗縣-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>苗栗縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#76B7B2</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#76B7B2</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>苗栗縣-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>苗栗縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#76B7B2</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>臺中市-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>臺中市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#FF9DA7</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FF9DA7</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>臺中市-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>臺中市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#FF9DA7</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>彰化縣-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>彰化縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#9C755F</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#9C755F</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>彰化縣-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>彰化縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#9C755F</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>南投縣-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>南投縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#BAB0AC</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#BAB0AC</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>南投縣-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>南投縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#BAB0AC</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>雲林縣-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>雲林縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#E15759</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#E15759</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>雲林縣-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>雲林縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#E15759</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>嘉義市-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>嘉義市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#F28E2B</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#F28E2B</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>嘉義市-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>嘉義市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#F28E2B</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>嘉義縣-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>嘉義縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#4E79A7</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#4E79A7</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>嘉義縣-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>嘉義縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#4E79A7</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>臺南市-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>臺南市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#59A14F</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#59A14F</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>臺南市-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>臺南市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#59A14F</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>高雄市-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>高雄市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#B07AA1</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#B07AA1</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>高雄市-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>高雄市</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#B07AA1</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>屏東縣-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>屏東縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#EDC948</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#EDC948</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>屏東縣-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>屏東縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#EDC948</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>宜蘭縣-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>宜蘭縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#76B7B2</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#76B7B2</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>宜蘭縣-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>宜蘭縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#76B7B2</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>花蓮縣-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>花蓮縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#FF9DA7</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FF9DA7</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>花蓮縣-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>花蓮縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#FF9DA7</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>臺東縣-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>臺東縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#9C755F</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#9C755F</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>臺東縣-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>臺東縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#9C755F</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>澎湖縣-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>澎湖縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#59A14F</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#59A14F</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>澎湖縣-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>澎湖縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#59A14F</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>金門縣-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>金門縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#E15759</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#E15759</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>金門縣-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>金門縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#E15759</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>連江縣-far</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>連江縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MinScaleDenominator>1500000</MinScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#4E79A7</CssParameter>
              <CssParameter name="fill-opacity">0.8</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#4E79A7</CssParameter>
              <CssParameter name="stroke-width">0.3</CssParameter>
            </Stroke>
          </PolygonSymbolizer>
        </Rule>
        <Rule>
          <Name>連江縣-near</Name>
          <ogc:Filter><ogc:PropertyIsEqualTo>
            <ogc:PropertyName>COUNTYNAME</ogc:PropertyName><ogc:Literal>連江縣</ogc:Literal>
          </ogc:PropertyIsEqualTo></ogc:Filter>
          <MaxScaleDenominator>1500000</MaxScaleDenominator>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#4E79A7</CssParameter>
              <CssParameter name="fill-opacity">0.7</CssParameter>
            </Fill>
            <Stroke>
              <CssParameter name="stroke">#FFFFFF</CssParameter>
              <CssParameter name="stroke-width">0.6</CssParameter>
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
