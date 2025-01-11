rm(list=ls())
library(sf)
library(dplyr)
library(readr)
#source("./R/Soil_lib.r")
library(GetSoilPars)
library(purrr)
library(devtools)




geoLaenge <- 10.626512
geoBreite <- 52.734129


BUEK2000_Kartenblaetter <- read_rds("C:/Users/h_kage/Documents/R_Statistik/BUEK_2000/data/Bodenuebersichtskarte_1_20000/Kartenblaetter_Box")
BUEK2000_path <- "C:/Users/h_kage/Documents/R_Statistik/BUEK_2000/data/Bodenuebersichtskarte_1_20000/Kartenblaetter_RDS/"
BUEK2000_code <- read_rds("C:/Users/h_kage/Documents/R_Statistik/BUEK_2000/data/Bodenuebersichtskarte_1_20000/Bodenübersichtskarte_1_200000_code")

usethis::use_data(BUEK2000_Kartenblaetter)
usethis::use_data(BUEK2000_code)


fn_Kartenblaetter <- list.files(path = "C:/Users/h_kage/Documents/R_Statistik/BUEK_2000/data/Bodenuebersichtskarte_1_20000/Kartenblaetter_RDS")

sourcedir <- "C:/Users/h_kage/Documents/R_Statistik/BUEK_2000/data/Bodenuebersichtskarte_1_20000/Kartenblaetter_RDS/"

list_kb <- list()
for (i in 1:length(fn_Kartenblaetter)) {
#  i <- 1
  fn <- paste0(sourcedir, fn_Kartenblaetter[i])
  Kartenblatt <- read_rds(fn)
  list_kb[[fn_Kartenblaetter[i]]] <- Kartenblatt
}
fn_Kartenblaetter <- paste0("kb_", fn_Kartenblaetter)
names(list_kb) <- fn_Kartenblaetter



#  Kartenblatt <- read_rds(fn)# %>% save(., file = paste0("C:/Users/h_kage/Documents/R_Statistik/GetSoilPars/data/kb",fn_Kartenblaetter[i],".rda"))

walk2(list_kb, fn_Kartenblaetter, function(obj, name) {
  assign(name, obj)
  do.call("use_data", list(as.name(name), overwrite = TRUE))
})







NDSborder <- st_read("C:/Users/h_kage/Documents/Qgis/NitratNiedersachsen/GrenzeNiedersachsenUTM32.shp")

NDSborder <- st_transform(NDSborder, crs = "EPSG:25832")
NDSborder

crs = "EPSG:25832"
sites <- read.csv("C:/Users/h_kage/Documents/R_Statistik/ShinyHumeWheat/data/Standorte_Liste_Hoehe_key.csv")
sites <- sites %>% select(Standort, Bundesland, Latitude, Longitude) %>% st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)  %>%
  st_set_crs(value = "+proj=longlat +datum=WGS84") %>%
  st_transform(crs = crs)

nds_sites <- st_filter(sites, NDSborder)



usethis::use_data(NDSborder, overwrite = TRUE)

MyPoint <- st_sfc(st_point(c(geoLaenge, geoBreite)), crs = 25832)



Point <- getPointCoordinates (geoLaenge, geoBreite, crs = "EPSG:25832")

Map <- getSoilMap(Point)#, BUEK2000_Kartenblaetter)

SPolygon <- getSoilPolygon (Point, Map)

SoilTexture <- getSoilTexture (SPolygon, short = TRUE, fill_NA = TRUE)



+
  <- getPointTextureData (geoLaenge, geoBreite, short = TRUE, fill_NA = TRUE)


Point <- nds_sites[nds_sites$Standort == "Isenhagen","geometry"]

#Point <- Point$geometry

class(Point)

Point

Point <- st_sfc(st_point(c(geoLaenge, geoBreite)), crs = 25832)


test <- getLBEGSoilData (Lon =  geoLaenge, Lat = geoBreite)
test
