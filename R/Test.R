rm(list=ls())
library(sf)
library(dplyr)

#source("./R/Soil_lib.r")


geoLaenge <- 11.5
geoBreite <- 48.1


Point <- getPointCoordinates (geoLaenge, geoBreite, crs = "EPSG:25832")

Map <- getSoilMap(Point, BUEK2000_Kartenblaetter, BUEK2000_path)

SPolygon <- getSoilPolygon (Point, Map, BUEK2000_code)

SoilTexture <- getSoilTexture (SPolygon, short = TRUE, fill_NA = TRUE)
