#  XCO2 diurnal cycles - Summer Project 2023 update

The current version aims to derive diurnal cycles from simulated OCO-2/3
observations taken from TCCON data. The three subfolders are:

1. `model` - this has the main model code
2. `misc` - this has the plotting code and utilities functions that aren't 
  part of the current model, but are still useful, and
3. `defunct` - this has code that is probably bad, but might be salvagable,
  as well as script versions of functions for debugging.

## Quickstart

- Set up a python environment in matlab, with sklearn and xgb modules. 
- Download TCCON data from tccondata.org, rename files/ set file names in code.
- Get the OCO-2/3 crossing data from Josh, or from the OCO-2 cluster
