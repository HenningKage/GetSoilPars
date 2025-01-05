rm(list=ls())
library(sf)
library(dplyr)
library(readr)
#source("./R/Soil_lib.r")
library(GetSoilPars)




geoLaenge <- 11.5
geoBreite <- 48.1


BUEK2000_Kartenblaetter <- read_rds("C:/Users/h_kage/Documents/R_Statistik/BUEK_2000/data/Bodenuebersichtskarte_1_20000/Kartenblaetter_Box")
BUEK2000_path <- "C:/Users/h_kage/Documents/R_Statistik/BUEK_2000/data/Bodenuebersichtskarte_1_20000/Kartenblaetter_RDS/"
BUEK2000_code <- read_rds("C:/Users/h_kage/Documents/R_Statistik/BUEK_2000/data/Bodenuebersichtskarte_1_20000/Bodenübersichtskarte_1_200000_code")

usethis::use_data(BUEK2000_Kartenblaetter)
usethis::use_data(BUEK2000_code)



Point <- getPointCoordinates (geoLaenge, geoBreite, crs = "EPSG:25832")

Map <- getSoilMap(Point, BUEK2000_Kartenblaetter, BUEK2000_path)

SPolygon <- getSoilPolygon (Point, Map, BUEK2000_code)

SoilTexture <- getSoilTexture (SPolygon, short = TRUE, fill_NA = TRUE)


SoilTexture2 <- getPointTextureData (geoLaenge, geoBreite, BUEK2000_Kartenblaetter, BUEK2000_code, BUEK2000_path, short = TRUE, fill_NA = TRUE)
