rm(list=ls())
library(sf)
library(dplyr)
library(readr)
#source("./R/Soil_lib.r")
library(GetSoilPars)
library(purrr)
library(devtools)




geoLaenge <- 11.5
geoBreite <- 48.1


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





Point <- getPointCoordinates (geoLaenge, geoBreite, crs = "EPSG:25832")

Map <- getSoilMap(Point)#, BUEK2000_Kartenblaetter)

SPolygon <- getSoilPolygon (Point, Map)

SoilTexture <- getSoilTexture (SPolygon, short = TRUE, fill_NA = TRUE)


SoilTexture2 <- getPointTextureData (geoLaenge, geoBreite, short = TRUE, fill_NA = TRUE)
