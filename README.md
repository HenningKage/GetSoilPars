
<!-- README.md is generated from README.Rmd. Please edit that file -->

# GetSoilPars

<!-- badges: start -->
<!-- badges: end -->

The goal of GetSoilPars is to retrieve soil texture parameters by
geographic coordinates fromthe BUEK2000 soil map.

## Installation

You can install the development version of GetSoilPars from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("HenningKage/GetSoilPars")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(GetSoilPars)
library(dplyr)
#> 
#> Attache Paket: 'dplyr'
#> Die folgenden Objekte sind maskiert von 'package:stats':
#> 
#>     filter, lag
#> Die folgenden Objekte sind maskiert von 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(sf)
#> Warning: Paket 'sf' wurde unter R Version 4.4.2 erstellt
#> Linking to GEOS 3.12.2, GDAL 3.9.3, PROJ 9.4.1; sf_use_s2() is TRUE
## basic example code


geoLaenge <- 11.5
geoBreite <- 48.1


# transfer geographic coordinates to a point object
Point <- getPointCoordinates (geoLaenge, geoBreite, crs = "EPSG:25832")

# get a local part of the soil map
Map <- getSoilMap(Point)#, BUEK2000_Kartenblaetter)

# retrieve the soil polygon for the location
SPolygon <- getSoilPolygon (Point, Map)

# retrieve the soil texture data for the soil profile of the "Leitboden"
SoilTexture <- getSoilTexture (SPolygon, short = TRUE, fill_NA = TRUE)
str(SoilTexture)
#> 'data.frame':    3 obs. of  9 variables:
#>  $ geoLaenge: num  11.5 11.5 11.5
#>  $ geoBreite: num  48.1 48.1 48.1
#>  $ HOR_NR   : num  1 2 3
#>  $ OTIEF    : int  0 20 35
#>  $ UTIEF    : int  20 35 200
#>  $ BOART    : chr  "Ls2" "Lt3" "Su3"
#>  $ LE_TXT   : chr  "Überwiegend Parabraunerden und verbreitet Braunerde-Parabraunerden aus carbonatreichem, würmzeitlichem Schotter"| __truncated__ "Überwiegend Parabraunerden und verbreitet Braunerde-Parabraunerden aus carbonatreichem, würmzeitlichem Schotter"| __truncated__ "Überwiegend Parabraunerden und verbreitet Braunerde-Parabraunerden aus carbonatreichem, würmzeitlichem Schotter"| __truncated__
#>  $ HUMUS    : chr  "h4" "h2" "h0"
#>  $ LD       : chr  "Ld2" "Ld3" "Ld3"
```

``` r
# same as above but in one step
SoilTexture2 <- getPointTextureData (geoLaenge, geoBreite, short = TRUE, fill_NA = TRUE)
#SoilTexture2
```
