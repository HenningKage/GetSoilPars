
## Setup
library("httr")
library("stringr")
library("plyr")
library("XML")
library("xml2")

soap_template <-
  '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">
  <soap-env:Body>
  <ns0:GibBodenErweitert xmlns:ns0="http://nibis.lbeg.de/BodenDienst">
  <ns0:x>${x}</ns0:x>
  <ns0:y>${y}</ns0:y>
  <ns0:EPSG>${epsg}</ns0:EPSG>
  <ns0:quelle>${boden_quelle}</ns0:quelle>
  </ns0:GibBodenErweitert>
  </soap-env:Body>
  </soap-env:Envelope>'

#x = 32546634
#y = 5804181
x = 32547634
y = 5805181

# Verfügbare EPSG sind 31465, 31466, 31467, 31468 (Gauss-Krueger für die Meridianstreifen 1, 2, 3, 4), 4326 (WGS84) und 4647 (UTM mit vorgestelltem Streifen)

epsg = 4647

# Quellen können sein 'Buek50' or 'Bodenschaetzung' or 'BK50' or 'AlleQuellenVersucheVonGrossenZuKleinemMassstab' or 'NichtDefiniert'
# boden_quelle = 'Bodenschaetzung'
boden_quelle = 'AlleQuellenVersucheVonGrossenZuKleinemMassstab'

# reformat the template
soap_request = str_interp(soap_template)


# send request to server
r <- POST(

  "https://nibis.lbeg.de/SoapBodenDienst/Boden.asmx",
  body = soap_request,
  add_headers(SOAPAction = "http://nibis.lbeg.de/BodenDienst/GibBodenErweitert"
              ,"Content-Type" = "text/xml")

)

# Changed package for import, because XML could not handle the "<![CDATA[ ]]>" tag
xml_import <- read_xml(r)

# Navigate the Node-Tree
xml_subset <- xml_child(xml_child(xml_child(xml_child(xml_child(xml_import))), 3), 6)

# Back to package XML for the convenient function xmlToDataFrame
xml_subset <- XML::xmlParse(xml_subset)
df <- xmlToDataFrame(xml_subset)


