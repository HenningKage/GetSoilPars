


# Libraries ---------------------------------------------------------------
library(httr)
library(readr)
library(plyr)
library(dplyr)
library(XML)
library(xml2)
library(stringr)


#' Title getLBEGSoilData
#'
#' @param Lon the longitude of the point
#' @param Lat the latitude of the point
#' @returns a data frame with the soil texture data for the soil profile based on data of Reichsbodenschätzung
#' @export
#'
#' @examples
getLBEGSoilData <- function(Lon, Lat) {

  Point <- getPointCoordinates(Lon, Lat, crs = "EPSG:25832")


  ###### template for soap request ######
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



  Point <- st_filter(st_sf(Point, crs=25832), NDSborder)

  if (nrow(Point)>0) {
    Point <- Point %>%
      st_cast("POINT")

    Point <-  st_coordinates(Point)
    x <- Point[1]
    y <- Point[2]

    epsg <-  25832

    # Quellen können sein 'Buek50' or 'Bodenschaetzung' or 'BK50' or 'AlleQuellenVersucheVonGrossenZuKleinemMassstab' or 'NichtDefiniert'
    # boden_quelle = 'Bodenschaetzung'
    boden_quelle = 'AlleQuellenVersucheVonGrossenZuKleinemMassstab'

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
    df$geoLaenge <- Lon
    df$geoBreite <- Lat
    df$BOART <- df$Hnbod
    df$Hnbod <- NULL
    df$LE_TXT <- ""
    df$UTIEF <- df$Utief
    df$Utief <- NULL
    df$OTIEF <- df$Otief
    df$Otief <- NULL
    df$HUMUS <- df$Humus
    df$Humus <- NULL
    df$LD <- df$Ld
    df$Ld <- NULL
    return(df)
  } else {
    return(NULL)
  }
}

DataDir <- tools::R_user_dir("GetSoilPars", which="data")
if (!dir.exists(DataDir)) {
  dir.create(DataDir, recursive=TRUE)
}




## functions #################

#' Title getPointCoordinates
#'
#' @param geoLaenge the longitude of the point
#' @param geoBreite the latitude of the point
#' @param crs the coordinate reference system of the point
#'
#' @returns an sf object with the point coordinates in the given crs
#' @export
#'

getPointCoordinates <- function(geoLaenge, geoBreite, crs = "EPSG:25832") {

 df <-  data.frame("geoLaenge" = geoLaenge, "geoBreite" = geoBreite) %>%
    st_as_sf(coords = c("geoLaenge", "geoBreite")) %>%
    st_set_crs(value = "+proj=longlat +datum=WGS84") %>%
    st_transform(crs = crs) %>%
    mutate("geoLaenge" = geoLaenge, "geoBreite" = geoBreite)
 return(df)
}


#' Title getSoilMap
#'
#' @param point_coordinates the coordinates of the point as an sf object
#'
#' @returns the selected map sheet of the BUEK2000 data as sf multipolygon object
#' @export
#'
getSoilMap <- function(point_coordinates) {

  ## Select map sheet and import
  Kartenblatt <- point_coordinates %>%
    st_join(BUEK2000_Kartenblaetter, join = st_covered_by) %>%
    pull(Kartenblatt) %>%
    first()

  File_string <- paste0(paste0("kb_",Kartenblatt))
  Kartenblatt_spatial <- get(File_string)
#  Kartenblatt_spatial <- read_rds(File_string) %>%
#    dplyr::select(TKLE_NR)

  return(Kartenblatt_spatial)

}


#' Title getSoilPolygon
#'
#' @param point_coordinates the point coordinates as an sf object
#' @param Kartenblatt_spatial the selected map sheet of the BUEK2000 data
#'
#' @returns a data frame with the soil polygon data including texture data for the soil profiles
#' of the "Leitboden", i.e. the most important soil profile and additional "Begleitböden"
#' @export
#'
getSoilPolygon <- function(point_coordinates, Kartenblatt_spatial) {

  ## Extract point values
  Boden_All <- point_coordinates %>%
    st_join(Kartenblatt_spatial, join = st_nearest_feature) %>%
    left_join(BUEK2000_code, multiple = "all", by = "TKLE_NR")

  Boden_All

}


#' Title getSoilTexture
#'
#' @param soil_polygon the soil polygon data including texture data for the soil profiles
#' @param short if TRUE, the data frame is reduced to the basic information
#' @param fill_NA if TRUE, the texture is set to the value of the upper horizon if texture is NA
#'
#' @returns a data frame with the soil texture data for the soil profile of the "Leitboden",
#' @export
#'
getSoilTexture <- function(soil_polygon, short = TRUE, fill_NA = TRUE) {

  Boden_All <- soil_polygon %>%
    `st_geometry<-`(NULL)

  ## Set texture to the value óf the upper horizon if texture is na
  if(fill_NA) {

    Boden_All <- Boden_All %>%
      mutate(BOART = ifelse(is.na(BOART), lag(BOART), BOART))

  }

  ## Reduce data to the basic information if short == TRUE
  if(short) {

    Boden_All <-  Boden_All %>%
      filter(STATUS == "Leitboden") %>%
      dplyr::select(geoLaenge, geoBreite, HOR_NR, OTIEF, UTIEF, BOART, LE_TXT,HUMUS,LD) %>%
      mutate(OTIEF = as.integer(OTIEF*10),
             UTIEF = as.integer(UTIEF*10))

  }

  Boden_All

}



#' Title getPointTextureData
#'
#' @param geoLaenge geographic longitude
#' @param geoBreite geographic latitude
#' @param BUEK2000_Kartenblaetter a link to the BUEK2000 map sheets
#' @param BUEK2000_code a link to the BUEK2000 code data
#' @param BUEK2000_path a link to the BUEK2000 data
#' @param short option for short format of data frame return
#' @param fill_NA option to fill NA values in the texture data
#'
#' @returns a data frame with the soil texture data for the soil profile of the "Leitboden",
#' @export
#'
getPointTextureData <- function(geoLaenge, geoBreite, short = TRUE, fill_NA = TRUE) {

  Point <- getPointCoordinates (geoLaenge, geoBreite, crs = "EPSG:25832")

  Map <- getSoilMap(Point)

  SPolygon <- getSoilPolygon (Point, Map)

  SoilTexture <- getSoilTexture (SPolygon, short = short, fill_NA = fill_NA)

  return(SoilTexture)

}


myRenderMapview = function (expr, env = parent.frame(), quoted = FALSE)
{
  if (!quoted)
    expr = substitute(mapview:::mapview2leaflet(expr))
  htmlwidgets::shinyRenderWidget(expr, leafletOutput, env,
                                 quoted = TRUE)
}


# getSoilTexture <- function(geoLaenge, geoBreite, BUEK2000_shape, BUEK2000_code, short = TRUE, fill_NA = TRUE) {
#
#   ## Transform numerical Long/Lat-input into sf coordinates with the right crs
#   point_coordinates <- data.frame("geoLaenge" = geoLaenge, "geoBreite" = geoBreite) %>%
#     st_as_sf(coords = c("geoLaenge", "geoBreite")) %>%
#     st_set_crs(value = "+proj=longlat +datum=WGS84") %>%
#     st_transform(crs = st_crs(BUEK2000_shape)) %>%
#     mutate("geoLaenge" = geoLaenge, "geoBreite" = geoBreite)
#
#   ## Extract point values
#   Boden_All <- point_coordinates %>%
#     st_join(BUEK2000_shape, join = st_nearest_feature) %>%
#     left_join(BUEK2000_code, multiple = "all", by = "TKLE_NR") %>%
#     dplyr::select(-Symbol, -Shape_Area, -Shape_Leng) %>%
#     `st_geometry<-`(NULL)
#
#   ## Set texture to the value óf the upper horizon if texture is na
#   if(fill_NA) {
#
#     Boden_All <- Boden_All %>%
#       mutate(BOART = ifelse(is.na(BOART), lag(BOART), BOART))
#
#   }
#
#   ## Reduce data to the basic information if short == TRUE
#   if(short) {
#
#     Boden_All <-  Boden_All %>%
#       filter(STATUS == "Leitboden") %>%
#       dplyr::select(geoLaenge, geoBreite, HOR_NR, OTIEF, UTIEF, BOART) %>%
#       mutate(OTIEF = as.integer(OTIEF*10),
#              UTIEF = as.integer(UTIEF*10))
#
#   }
#
#   Boden_All
#
# }
