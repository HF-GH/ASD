
clc;clear;close all;

load('loc_summ_data4PSE');

%-------------------------------------------------------------------------%
% The data is organized as structure with two fileds, one for each 
% experimental condition (primary and response invariant). 
% Each of them includes two additional fileds, one for each group (asd and control). 
% Each group includes separate feilds for each participant, which contain the summarized information 
% needed for  calculating the psychometric curves. Each participant has two
% fields - left_priros and right_priors. Each of them contains a matrix
% with three columns: (1) stimulus intensity (stimulus location in degrees),
% (2) the number of rightward choices (for the specific intensity),
% (3) the number of trials that included this intensity choices.
% The code uses psignifit4 functions to calculate and plot the psychometric
% curves (the psignifit4 toolbox needs to be downloaded and included int he
% matlab path).
%-------------------------------------------------------------------------%

for cond = 1:2
    for group = 1:2
        if cond == 1 && group == 1
            curr_data = loc_summ_data4PSE.primary.asd;
            data_used = 'loc_summ_data4PSE.primary.asd'
            exp_cond = 'primary';
            group_name = 'asd';
        elseif cond == 1 && group == 2
            curr_data = loc_summ_data4PSE.primary.cont;
            data_used = 'loc_summ_data4PSE.primary.cont'
            exp_cond = 'primary';
            group_name = 'cont';
        elseif cond == 2 && group == 1
            curr_data = loc_summ_data4PSE.resp_inv.asd;
            data_used = 'loc_summ_data4PSE.resp_inv.asd'
            exp_cond = 'respInv';
            group_name = 'asd';
        elseif cond == 2 && group == 2
            curr_data = loc_summ_data4PSE.resp_inv.cont;
            data_used = 'loc_summ_data4PSE.resp_inv.cont'
            exp_cond = 'respInv';
            group_name = 'cont';
        end
  
        
        
        for sub = 1:length(curr_data)
                sub_num = num2str(sub)
                sub_data_right = curr_data(sub).sub_filed.summ_data4PSE.right_priors;
                sub_data_left = curr_data(sub).sub_filed.summ_data4PSE.left_priors;
                if ~isempty(sub_data_right)
                    current_fig = figure;

                    % ploting psychometric curve - right priors
                    pfit_input = sub_data_right;
                    % setting psignifit4 parameters for the psychometric curve (see 'github.com/wichmann-lab/psignifit/wiki/'):
                    % choose a cumulative Gauss as the sigmoid:  
                    options.sigmoidName = 'norm';
                    % assume upper and the lower asymptote are equal:
                    options.expType = 'equalAsymptote';
                    % get the fit results:
                    result = psignifit(pfit_input,options);

                   % setting psignifit4 parameters for the plot: 
                    plotOptions = struct;
                    plotOptions.plotThresh     = false;
                    plotOptions.plotAsymptote  = false;
                    plotOptions.xLabel         = 'Location [deg]';     
                    plotOptions.yLabel         = 'Rightward Choice Ratio';
                    plotOptions.labelSize      = 12;                  
                    plotOptions.fontSize       = 10;
                    plotOptions.lineColor = [0,0,1];
                    plotOptions.dataColor = [0,0,1];

                    [hline_r,hdata_r] = plotPsych(result,plotOptions);
                    grid on;
                    hold on;

                    % ploting psychometric curve - left priors
                    pfit_input = sub_data_left;

                    % get the fit results:
                    result = psignifit(pfit_input,options);

                    % setting psignifit4 parameters for the plot: 
                    plotOptions.lineColor = [1,0,0];
                    plotOptions.dataColor = [1,0,0];
                    [hline_l,hdata_l] = plotPsych(result,plotOptions);

                    title([exp_cond,' ',group_name,' ', sub_num]);
                    legend([hline_r,hline_l],'Right Priors','Left Priors');
                    hold off

                    % save plot:
                    saveas(current_fig,[exp_cond,'_',group_name,'_', sub_num],'fig');
                end
        end
    end
        
        
end