
clc;clear;

load('loc_data');

%-------------------------------------------------------------------------%
% The data is organized as structure with two fileds, one for each 
% experimental condition (primary and response invariant). 
% Each of them includes two additional fileds, one for each group (asd and control). 
% Each group includes separate feilds for each participant, which contain a table 
% with several columns: (1) loc_deg (stimulus location in degrees),(2) prior_type 
% (priors' type, such that right priors are coded as "1" and left priors 
% as "-1"), (3)stim_num (stimulus number within a specific trial: the test stimulus
% is coded as "0", the preceeding prior as "1", the one before that as "2", etc.), 
% (4) test_stim (test stim are coded as "1" and priors are coded as "0"), 
% (5) ans (participant's response; "right" is coded as "1" and "left" is
% coded as "-1", (6) corr (was the response correct or not; 
% correct responses are coded as "1" and incorrect as "0"),(7)rt (response time in seconds). 
% The response invariant condition table includes an additionl column (8) prior_color 
% (priors were either green or purple, coded as "1" and "2", counterbalanced between participants.
% Test circles were always white, and their color is coded as "0").
% The PSE calculation is done using the psignifit4 toolbox 
% (which needs to be downloaded and included in the matlab path).
%-------------------------------------------------------------------------%

for cond = 1:2
    for group = 1:2
        if cond == 1 && group == 1
            curr_data = data.primary.asd;
            data_used = 'data.primary.asd'
        elseif cond == 1 && group == 2
            curr_data = data.primary.cont;
            data_used = 'data.primary.cont'
        elseif cond == 2 && group == 1
            curr_data = data.resp_inv.asd;
            data_used = 'data.resp_inv.asd'
        elseif cond == 2 && group == 2
            curr_data = data.resp_inv.cont;
            data_used = 'data.resp_inv.cont'
        end
        
        
        for sub = 1:length(curr_data)
            sub
            sub_data = curr_data(sub).sub_filed;
            % calculate mean response time:
            if ~isempty(sub_data)
                sub_res.rt_mean = mean(sub_data.rt);

                % calculate correct answers ratio:
                % for all stim:
                sub_res.corr_score_all = mean(sub_data.corr);
                % for prior stim only:
                prior_ind = find(sub_data.test_stim == 0);
                sub_res.corr_score_priors = mean(sub_data.corr(prior_ind));
                % for test stim only:
                test_ind = find(sub_data.test_stim == 1);
                sub_res.corr_score_tests = mean(sub_data.corr(test_ind));

                % PSE calculation:

                % create a mat with the needed info. From left to right - 
                % priors' type, stimulus location, participant's response, 
                % is it a test stimulus, stimulus number within a trial):
                data_mat = [sub_data.prior_type sub_data.loc_deg sub_data.ans...
                    sub_data.test_stim sub_data.stim_num];

                % use only test stimuli:
                left_resp_ind = find(data_mat(:,3) == -1);
                data_mat(left_resp_ind,3) = 0;
                test_ind = find(data_mat(:,4) == 1);
                data_4PSE_test = data_mat(test_ind,:);

                %divide according to prior's type (right/left):
                right_ind = find(data_4PSE_test(:,1) == 1);
                left_ind = find(data_4PSE_test(:,1) == -1);
                data_4PSE_right = data_4PSE_test(right_ind,:);
                data_4PSE_left = data_4PSE_test(left_ind,:);

                % sort trials according to stim location:
                data_4PSE_right = sortrows(data_4PSE_right,2);
                data_4PSE_left = sortrows(data_4PSE_left,2);

                % find unique location values:
                right_locs = unique(data_4PSE_right(:,2));
                left_locs = unique(data_4PSE_left(:,2));
                
                
                % create the input for the psignifit toolbox:
                % (1)intensity (=location) (2) number of rightward responses for this intensity
                % (3)number of trials with this intensity 

                % right:
                num_trials_right = zeros(size(right_locs));
                num_rightward_right = zeros(size(right_locs));
                for loc = 1:length(right_locs)
                    loc_index_right = find(data_4PSE_right(:,2) == right_locs(loc));
                    num_trials_right(loc) = length(loc_index_right);
                    num_rightward_right(loc) = sum(data_4PSE_right(loc_index_right,3));
                end
                pfit_input_right = [right_locs num_rightward_right num_trials_right];
                
                % left:
                num_trials_left = zeros(size(left_locs));
                num_rightward_left = zeros(size(left_locs));
                for loc = 1:length(left_locs)
                    loc_index_left = find(data_4PSE_left(:,2) == left_locs(loc));
                    num_trials_left(loc) = length(loc_index_left);
                    num_rightward_left(loc) = sum(data_4PSE_left(loc_index_left,3));
                end
                pfit_input_left = [left_locs num_rightward_left num_trials_left];

                % make sure that the psignifit-master is installed and is in your
                % matlab path:

                % clculate psychometric curve - right priors:
                pfit_input = pfit_input_right;
                options.sigmoidName = 'norm';
                options.expType = 'equalAsymptote';
                result = psignifit(pfit_input_right,options);
                result_orig = getStandardParameters(result);

                % retrive right PSE:
                sub_res.pfit_data.miu_right = result_orig(1);
                sub_res.pfit_data.sig_right = result_orig(2);

                % calculate Goodness-of-fit - pseudo-r-squared calculation - right:
                % calculate the deviance: 
                [devianceResiduals, deviance_right, samples_deviance, samples_devianceResiduals]...
                    = getDeviance(result,'');
                
                % calculate the null deviance (based on the getDeviance function from psignifit):
                pPred_right = result.psiHandle(result.data(:,1));
                % change predicted to the null predicted: The mean of y values.
                pPred_right(1:end) = mean(result.data(:,2) ./ result.data(:,3));
                pMeasured_right = result.data(:,2) ./ result.data(:,3);
                loglikelihoodPred_right = result.data(:,2) .* log(pPred_right)...
                    + (result.data(:,3) - result.data(:,2)) .* log((1 - pPred_right));
                loglikelihoodMeasured_right = result.data(:,2) .* log(pMeasured_right)...
                    + (result.data(:,3) - result.data(:,2)) .* log((1 - pMeasured_right));
                loglikelihoodMeasured_right(pMeasured_right == 1) = 0;
                loglikelihoodMeasured_right(pMeasured_right == 0) = 0;
                devianceResiduals_right = -2*sign(pMeasured_right - pPred_right).*(loglikelihoodMeasured_right - loglikelihoodPred_right);
                deviance_null_right = sum(abs(devianceResiduals_right));
                sub_res.pseudo_r_right =(deviance_null_right - deviance_right)/deviance_null_right;

                % calculate psychometric curve - left priors:
                pfit_input = pfit_input_left;
                options.sigmoidName = 'norm';
                options.expType = 'equalAsymptote';
                result = psignifit(pfit_input_left,options);
                result_orig = getStandardParameters(result);

                % retrive left PSE:
                sub_res.pfit_data.miu_left = result_orig(1);
                sub_res.pfit_data.sig_left = result_orig(2);

                % calculate Goodness-of-fit - pseudo-r-squared calculation - left
                [devianceResiduals, deviance_left, samples_deviance, samples_devianceResiduals] = getDeviance(result,'');
                % calculate the null deviance (based on the getDeviance function from psignifit):
                pPred_left = result.psiHandle(result.data(:,1));
                % change predicted to the null predicted: The mean of y values.
                pPred_left(1:end) = mean(result.data(:,2) ./ result.data(:,3));
                pMeasured_left = result.data(:,2) ./ result.data(:,3);
                loglikelihoodPred_left = result.data(:,2) .* log(pPred_left)...
                    + (result.data(:,3) - result.data(:,2)) .* log((1 - pPred_left));
                loglikelihoodMeasured_left = result.data(:,2) .* log(pMeasured_left)...
                    + (result.data(:,3) - result.data(:,2)) .* log((1 - pMeasured_left));
                loglikelihoodMeasured_left(pMeasured_left == 1) = 0;
                loglikelihoodMeasured_left(pMeasured_left == 0) = 0;
                devianceResiduals_left = -2*sign(pMeasured_left - pPred_left).*(loglikelihoodMeasured_left - loglikelihoodPred_left);
                deviance_null_left = sum(abs(devianceResiduals_left));
                sub_res.pseudo_r_left =(deviance_null_left - deviance_left)/deviance_null_left;

                % calculate delta PSE:
                sub_res.delta_PSE = sub_res.pfit_data.miu_left - sub_res.pfit_data.miu_right;

                % Fit Perceptual decision model:

                % normalize locations: 
                norm_loc = data_mat(:,2)/rms(data_mat(:,2)); 
                % calculate prior inforamtion - stim and choices
                sub_choices = data_mat(:,3);
                test_ind = find(data_mat(:,4) == 1);
                first_prior_ind = [1; test_ind(1:end - 1) + 1];
                priors_in_trial = data_mat(first_prior_ind,5);
                % initialize vectors:
                prior_stim = zeros(size(test_ind));
                prior_choices = zeros(size(test_ind));
                % calculate mean prior stim and choices
                count_stim = 0;
                for stim_ind = 1:length(priors_in_trial)
                    curr_prior_num = priors_in_trial(stim_ind);
                    relevant_ind =(count_stim + 1):(count_stim + curr_prior_num);
                    prior_stim(stim_ind) = mean(norm_loc(relevant_ind));
                    prior_choices(stim_ind)= mean(sub_choices(relevant_ind));
                    count_stim = count_stim + curr_prior_num + 1;
                end

                test_norm_loc = norm_loc(test_ind);
                test_sub_choices = sub_choices(test_ind);
                sub_mat4model = [test_norm_loc prior_choices prior_stim];
                [sub_res.decision_model_coeff, dev, stats] = ...
                    glmfit(sub_mat4model,test_sub_choices,'binomial','link','logit');
            else
                sub_res = [];
            end
            
             %5-back model (choices and stimuli):
              curr_s = norm_loc(6:end);
              curr_c = sub_choices(6:end);
              p1_s = norm_loc(5:end - 1);
              p1_c = sub_choices(5:end - 1);
              p2_s = norm_loc(4:end - 2);
              p2_c = sub_choices(4:end - 2);
              p3_s = norm_loc(3:end - 3);
              p3_c = sub_choices(3:end - 3);
              p4_s = norm_loc(2:end - 4);
              p4_c = sub_choices(2:end - 4);
              p5_s = norm_loc(1:end - 5);
              p5_c = sub_choices(1:end - 5);
                
              five_back_mat = [curr_s p1_c p2_c p3_c p4_c p5_c p1_s p2_s p3_s p4_s p5_s];
              [sub_res.decision_model_5_back_coeff, dev_5_back, stats_5_back] = ...
                  glmfit(five_back_mat,curr_c,'binomial','link','logit');
              
              %5-back choices model:
           
                five_back_choices_mat = [curr_s p1_c p2_c p3_c p4_c p5_c];
                [sub_res.decision_model_5_choices_coeff, dev_5_choices, stats_5_choices] = ...
                    glmfit(five_back_choices_mat,curr_c,'binomial','link','logit');

            if cond == 1 && group == 1
                results.primary.asd(sub).sub_filed = sub_res;
            elseif cond == 1 && group == 2
                results.primary.cont(sub).sub_filed = sub_res;
            elseif cond == 2 && group == 1
                results.resp_inv.asd(sub).sub_filed = sub_res;
            elseif cond == 2 && group == 2
                 results.resp_inv.cont(sub).sub_filed = sub_res;
            end
        end
    end
end

save('loc_res','results');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%











