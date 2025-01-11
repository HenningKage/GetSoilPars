library(devtools)


# Create a package

#create_package("GetSoilPars")

library(devtools)

## make it a git repository

use_git()

## put a source file

use_r("strsplit1")

## install for test purposes

load_all()

## check the package




## Add a licence model

use_mit_license()

## Add documentation

document()

#?
