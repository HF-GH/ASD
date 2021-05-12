# ASD - location discrimination task



*******************************************************************************************************************************


*******************************************************************************************************************************
For plotting psychometric curves for each participant (and experimental condition):

1. download and install the psignifit4 toolbox (from: https://github.com/wichmann-lab/psignifit)
	and make sure it is included in the Matlab path
2. download code: "plot_psych_curves_loc_task.m"
3. download data: "loc_summ_data4PSE"
4. make sure both files are in the same directory
5. run the code 

*******************************************************************************************************************************
For analyzing psychometric curves and perceptual decision models results:

1. download and install the psignifit4 toolbox (from: https://github.com/wichmann-lab/psignifit)
	and make sure it is included in the Matlab path
2. download code: "analyze_loc_task_updated"
3. download data file: "loc_data"
4. make sure all files are in the same directory
5. run the code
6. optional - if you do not wish to run the code, you can skip steps 1-5 and simply download the results file: "loc_res"
	(for information regarding the results file, please see 'additional information for analyzing the data' section below).

*******************************************************************************************************************************
Additional information for plotting psychometric curves: 

The data is organized as structure with two fields, one for each experimental condition (primary and response invariant). 
Each of them includes two additional fields, one for each group (asd and control). 
Each group includes separate fields for each participant, 
which contain the summarized information needed for calculating the psychometric curves. 
Each participant has two fields - left_priors and right_priors. 
Each of them contains a matrix with three columns: 
1. stimulus intensity (stimulus location in degrees)
2. the number of rightward choices (for the specific intensity)
3. the number of trials that included this intensity choices.

The code uses psignifit4 functions to calculate and plot the psychometric curves (the psignifit4 toolbox needs to be downloaded and included in the Matlab path).

*******************************************************************************************************************************
Additional information for analyzing the data: 


The data is organized as structure with two fields, one for each experimental condition (primary and response invariant). 
Each of them includes two additional fields, one for each group (asd and control). 

Each group includes separate fields for each participant, which contain a table with several columns: 
1. loc_deg (stimulus location in degrees)
2. prior_type (priors' type, such that right priors are coded as "1" and left priors as "-1")
3. stim_num (stimulus number within a specific trial: 
	the test stimulus is coded as "0", the preceding prior as "1", the one before that as "2", etc.)
4. test_stim (test stim are coded as "1" and priors are coded as "0")
5. ans (participant's response; "right" is coded as "1" and "left" is % coded as "-1"
6. corr (was the response correct or not; correct responses are coded as "1" and incorrect as "0")
7. rt (response time in seconds). 
The response invariant condition table includes an additional column:
8. prior_color (priors were either green or purple, coded as "1" and "2", counterbalanced between participants. 
	Test circles were always white, and their color is coded as "0").

The PSE calculation is done using the psignifit4 toolbox (which needs to be downloaded and included in the Matlab path).

Perceptual decision model coefficients (model output) can be found under the 'decision_model_coeff' field 
in the results file, such that: 
1. general bias
2. current stimulus
3. prev. choices
4. prev. stim.

Similarly, 5-back model perceptual decision model coefficients an be found under the 'decision_model_5_back_coeff' 
field in the results file,	such that: 
1. general bias
2. current stimulus

3-8. 1-5 (the number of steps back) prev. choices, respectively

9-12. 1-5 prev. stim, respectively. 

The coefficients of the additional 5-back model perceptual decision model that includes only prev. choices (and not prev. stimuli) 
can be found under the 'decision_model_5_choices_coeff' field in the results file, such that: 
1. general bias
2. current stimulus

3-8. 1-5 (the number of steps back) prev. choices respectively.
*******************************************************************************************************************************

