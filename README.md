# XCO2 diurnal cycles from machine learning

This repo contains experimental code designed to test the ability of a machine learning model trained on [TCCON](https://tccondata.org/)
data to reproduce diurnal cycles of XCO2 from more temporally sparse observations, such as those from satellites.
A manuscript describing and evaluating this approach is forthcoming.

*This code is provided as-is; any support provided by the maintainers to those who wish to use this code will
be done on an "as-available" basis, constrained by our other responsibilities.*

## Setup instructions

*First: need to set up a python environment in matlab*  
Download python, install xgboost and sklearn via conda install or mamba install. Make sure the python version is compatible with the matlab version. Then type `pyenv(Version="[path to python]")`

[Link to python versions compatible with Matlab releases](https://www.mathworks.com/support/requirements/python-compatibility.html)  
[Link to pyenv documentation](https://www.mathworks.com/help/matlab/ref/pyenv.html)

**Commands used to prepare data. Don’t need to run these everytime, just to initialize or if data changes**  
\*All output data from these scripts are expected to be saved into the same directory\*

*self_crossing_litefile*
- Change addpath command at the beginning of the file to all directories where self crossing matchup files are
- For each path that we want to read files from, call dir on that path
- Then loop over the filenames from each list of files and add the files from each directory to a big list of filenames. 
  - In my case we start from index 4 on the for loops because dir returns `.`, `..`, and a `.toml` file as the first three filenames
- Change savepath to the directory where all the processed data is stored

*making_self_litefile_struct*
- Change the load path to the path you saved Crossing_Struct to
- Change save path to the directory where all the processed data is stored  

*making_litefile_struct*
- Change addpath command at the beginning of the file to all directories where the oco-2/3 crossing matchup files are
- For each path that we want to read files from, call dir on that path
- Then loop over the filenames from each list of files and add the files from each directory to a big list of filenames. 
  - In my case we start from index 4 on the for loops because dir returns `.`, `..`, and a `.toml` file as the first three filenames
- Change savepath to the directory where all the processed data is stored

*faster_lite_script*
- Change the load path to the path you saved Crossing_Struct to
- Add savepath to the directory where all the processed data is stored

*make_big_lite_struct*
- Change the load path to the path you saved Crossing_Struct to
- Add savepath to the directory where all the processed data is stored

*av_numsoundings_anderror*
- If there are more sites than the 6 used for development (PF, ETL, Lamont, Lauder, Iza, Nic), add their Latitude, Longitude, and site name into the arrays.
- In make_big_lite_struct, `Big_Lite_Struct` is saved in 10 pieces, which is why the for loop is `1:10`. If it is saved in more or less pieces, change the for loop indexes. 
- Load `Big_Lite_Struct` from the directory you saved it to
- Change savepath to the directory where all the processed data is stored

*GEOS_process*
-  In the function process_GEOS
   - If there are more sites than the 6 used for development (PF, ETL, Lamont, Lauder, Iza, Nic), add their Latitude, Longitude, and site name into the arrays.
    - Change path to where the GEOS files are
    - This code assumes the GEOS files are named by and organized into folders by year, then subfolders by month, and subsubfolders by day, and the for loops are looping over those folders. If your files are organized differently, change the for loops and the automatic naming of the files
    - Change savepath to where processed data is saved

## Training and application
**Commands that you run to train the model**

*detrended_process*
- Change addpath to the directory all the data above is saved to
- Change path where public netcdf TCCON data is downloaded to
- Change data_setup_for_model to be `data_setup_for_model(‘make_daily_arrays’,1,’delta_temp’,1,’make_prob_dists’,1)` for the first time running it, or if data has changed. Afterwards these variables will be saved and it can be run empty
- In data_setup_for_model
  - Change savepath to the processed data folder from above
  - Under make_prob_dists:
    - If there are more sites than the 6 used for development (PF, ETL, Lamont, Lauder, Iza, Nic), add their Latitude, Longitude, and site name into the arrays.
    - Under make_daily_arrays:  
      - Change path where public netcdf TCCON data is downloaded to
    - Under delta_temp:
      - If there are more sites than the 6 used for development, write a line `[delta_reg_[site],delta_abs_[site]] = add_delta_temp_eff('[TCCON site .nc]', Daily_Struct_[site].days);` and `Delta_Temp_Struct.[site].reg = delta_reg_[site]; Delta_Temp_Struct.[site].abs = delta_abs_[site];` 
  - Set `method = 0` for the pessimistic simulation where systematic errors don’t cancel between same satellite instruments at different times and `method = 1` for the optimistic simulations where systematic errors completely cancel 
  - Set `bigloop = 1` to have ETL as the testsite, 2 for PF, 3 for Lauder, and 4 for Lamont. If you add additional sites that you want to be test sites, append the name to the skippednames cell array.
  - Set `skipbool= 1` if you want to leave a site out as a test site, and `skipbool = 0` if you want to do a 70/30 train/test split (not recommended)
  - Change `init_sites` depending on which sites you want included. `init_sites('all')` for the 6 TCCON sites used in development (PF, ETL, Lamont, Lauder, Izana, Nicosia), otherwise type the names, such as `init_sites(‘PF’,’ETL’,’Lamont’)` 
   - If you want to add more sites, in init_sites you will add the lines `load Daily_Struct_[site].mat` and `Daily_Structs_All.[site] = Daily_Struct_[site];`
- If you want to filter by the growing season, uncomment `Grow_Season = load(Grow_Season.mat)` and comment out `Grow_Season = badmonths_struct`. If you want no filtering, comment out `Grow_Season = load(Grow_Season.mat)` and uncomment `Grow_Season = badmonths_struct`
- Change the subsample_observations_flex inputs depending on which simulation you’re running. 
  - For the OCO-2/3 sim (i.e. a simulation using OCO-2/3 crossing times from the structures provided by Josh): `subsample_observations_flex(Daily_Structs,’type’,’oco2-3’,’num_obs’,2)`
  - For the Self Crossing sim (i.e. a simulation using OCO-3 self crossing times from structures provided by Josh): `subsample_observations_flex(Daily_Structs,’type’,’self’,’num_obs’,2),`
  - If you want to sample at fixed times of your choosing (i.e. if you want to simulate three observations, with the first point 3 hours before solar noon, and the subsequent two points spaced 2 hours apart): `subsample_observations_flex(Daily_Structs,’type’,’create’,’num_obs’,3,’start_time’,-3,’spacing’,2)`
  - If you want to sample from probability distributions centered at fixed times (i.e. rather than sampling from fixed times, the start time is sampled from a probability distribution centered at 3 hours before solar noon, with a standard deviation of 0.5, and the point spacing is sampled from a PD centered at 2 hours, with a standard deviation of 1): `subsample_observations_flex(Daily_Structs,’type’,’prob_dist’,’num_obs’,3,’start_time’-3,’spacing’,2,’stdev_st’,0.5,’stdev_sp’,1)`
  - For any of the simulations, if you want to change the minimum number of TCCON points to average together for a subsampled points add `‘min_num_points’,[min num points]` as arguments to any of the simulations
- Change the add_error inputs depending on the simulation.
  - For the OCO-2/3 sim: `add_error(Subsampled_Struct.(skip),Daily_Structs.(skip),'type','oco2-3','location',skip,'method',method)`.
  - For the self crossing sim, `add_error(Subsampled_Struct.(skip),Daily_Structs.(skip),'type','self,'location',skip,'method',method)`.
  - And to create your own error distributions (i.e you want the uncertainty distribution to have a standard deviation of 0.04 ppm) , `add_error(Subsampled_Struct.(skip),Daily_Structs.(skip),'type','oco2-3','location',skip,’error’,0.04)`
- Inside the  add_GEOS_all function:
  - Change load filepaths to the processed data folder where the GEOS files in process_GEOS are saved to

**Using the Model’s outputs and applying it to other data** 
xgb_model_detrends outputs these variables:
- `PC_preds`
  - The models outputs, as a struct.
  - The most important variables are the `inbagpred`, `oob_train`, and `oobPred` for each PC, which are used to reconstruct the diurnal cycles
  - Each day of TCCON data that was decomposed to quarter hour averages has a predicted set of PCs, which are the weights that can be applied to our set of EOFs to create our model’s predicted diurnal cycle
  - The model’s predicted diurnal cycle is 27 points at quarter hour intervals of XCO2 values relative to the predicted value of XCO2 at solar noon
- `Idrem`
  - This is an array of indexes from the test site that are not present in the validation site preds, because there was a NaN value present at that index in the feature set. These indexes need to also be removed from the quarter hour averaged values from that site so that the reconstructed diurnal cycles can be compared to the actual quarter hour averaged values from TCCON
- `MODEL`
  - This is our trained XGBoost model. Can be applied to other data
- `Importance`
  - Feature importance. Used in RFE (recursive feature elimination), but not for general model run
- `Rem`
  - Same as `Idrem`, but the array of indexes from the train sites that were not used because there was a NaN present in the features set. This is applied to the combo set of quarter hour averages in order to compare the inbag and out of bag predicted cycles to the actual TCCON data.
- `Idx`
  - The in bag/oob data is separated by a random 70/30 split. `Idx` is the indexes used for the 70%, which can be used to separate the train data to compare the inbag predicted diurnal cycles to the corresponding TCCON data, and the out of bag predicted diurnal cycles to the corresponding TCCON data

**To apply model to other data**: to apply model to other data, such as data from the OCO satellites, you use the outputted `MODEL`. You will create a new feature set with all the same variables present in the training features set in the same order. Then,  `predicted_PCs = double(MDL.predict(new_feature_set));`. `predicted_PCs` will be an array of size [num_EOFs]x[num days inputted], and it can be used to create model predicted diurnal cycles by applying it to the EOFs following:

```
for number = 1:size(predicted_PCs,1)  
    Predicted_Cycles(number,:) = zeros(1,size(predicted_PCs,2));
    
    for i = 1:num_eofs
        Predicted_Cycles(number,:) = Predicted_Cycles(number,:)+EOFs_Combo(i,:).*(predicted_PCs(number,i));
    end
end
```
