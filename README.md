# XCO2 diurnal cycles - Summer Project 2022

This repo contains the code developed by Calla Marchetti during her summer 2022 
internship. It can train a random forest model to predict both the diurnal cycle
and drawdown of XCO2 given 3x daily input of XCO2 and several meteorological
variables. TCCON data comprises the training and testing set.

## Setup

* Make sure that the Python environment used by Matlab can import the `sklearn` package
* Download the public TCCON GGG2020 data from tccondata.org for the following sites. Name
  the files as follows:
    - East Trout Lake: `east_trout_lake.nc`
    - Lamont: `lamont.nc`
    - Lauder (all three): `lauder01.nc`, `lauder02.nc`, `lauder03.nc`. 
        * Note that the Lauder data is read from `Lauder.mat`, update that file if new Lauder
          data available.
    - Park Falls: `park_falls.nc`
    - Sodankyla: `sodankyla.nc`

## Usage

The main driver script is `XCO2_Diurnal_Cycles.m`. Run that script to train and test the models,
and see it for examples of usage for the rest of the code in this repo.
