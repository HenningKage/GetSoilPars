library(readr)


DataDir <- tools::R_user_dir("GetSoilPars", which="data")
if (!dir.exists(DataDir)) {
  dir.create(DataDir, recursive=TRUE)
}


## soil data #################

BUEK2000_Kartenblaetter <- read_rds("C:/Users/h_kage/Documents/R_Statistik/BUEK_2000/data/Bodenuebersichtskarte_1_20000/Kartenblaetter_Box")

 #                "C:\Users\h_kage\Documents\R_Statistik\BUEK_2000\data\Bodenuebersichtskarte_1_20000\Kartenblaetter_RDS"
BUEK2000_path <- "C:/Users/h_kage/Documents/R_Statistik/BUEK_2000/data/Bodenuebersichtskarte_1_20000/Kartenblaetter_RDS/"
BUEK2000_code <- read_rds("C:/Users/h_kage/Documents/R_Statistik/BUEK_2000/data/Bodenuebersichtskarte_1_20000/Bodenübersichtskarte_1_200000_code")


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
#' @examples
getPointCoordinates <- function(geoLaenge, geoBreite, crs = "EPSG:25832") {

  data.frame("geoLaenge" = geoLaenge, "geoBreite" = geoBreite) %>%
    st_as_sf(coords = c("geoLaenge", "geoBreite")) %>%
    st_set_crs(value = "+proj=longlat +datum=WGS84") %>%
    st_transform(crs = crs) %>%
    mutate("geoLaenge" = geoLaenge, "geoBreite" = geoBreite)

}


#' Title
#'
#' @param point_coordinates the coordinates of the point as an sf object
#' @param BUEK2000_Kartenblaetter the map sheets of the BUEK2000 data
#' @param BUEK2000_path the path to the BUEK2000 data
#'
#' @returns the selected map sheet of the BUEK2000 data as sf multipolygon object
#' @export
#'
#' @examples
getSoilMap <- function(point_coordinates, BUEK2000_Kartenblaetter, BUEK2000_path) {

  ## Select map sheet and import
  Kartenblatt <- point_coordinates %>%
    st_join(BUEK2000_Kartenblaetter, join = st_covered_by) %>%
    pull(Kartenblatt) %>%
    first()

  File_string <- paste0(BUEK2000_path, Kartenblatt)
  # File_string <- "C:/Users/h_kage/Documents/R_Statistik/BUEK_2000/data/Bodenübersichtskarte_1_20000/Kartenblaetter_RDS/7926"

  Kartenblatt_spatial <- read_rds(File_string) %>%
    dplyr::select(TKLE_NR)

  Kartenblatt_spatial

}


#' Title getSoilPolygon
#'
#' @param point_coordinates the point coordinates as an sf object
#' @param Kartenblatt_spatial the selected map sheet of the BUEK2000 data
#' @param BUEK2000_code the BUEK2000 code data
#'
#' @returns a data frame with the soil polygon data including texture data for the soil profiles
#' of the "Leitboden", i.e. the most important soil profile and additional "Begleitböden"
#' @export
#'
#' @examples
getSoilPolygon <- function(point_coordinates, Kartenblatt_spatial, BUEK2000_code) {

  ## Extract point values
  Boden_All <- point_coordinates %>%
    st_join(Kartenblatt_spatial, join = st_nearest_feature) %>%
    left_join(BUEK2000_code, multiple = "all", by = "TKLE_NR")

  Boden_All

}


#' Title
#'
#' @param soil_polygon
#' @param short
#' @param fill_NA
#'
#' @returns a data frame with the soil texture data for the soil profile of the "Leitboden",
#' @export
#'
#' @examples
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
