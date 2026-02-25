function [trial_struct] = create_switch_conditions(trial_struct, ntrials, p)
    % CREATE SWITCH CONDITIONS
    % uses this solution to generate state switches
    % https://au.mathworks.com/matlabcentral/answers/108252-how-to-split-a-number-into-10-different-numbers

    % ntrials = number of trials in 1 context
    % p = switch probability

    % get e.g. 30 numbers that add up to 100
    % this is the 30 durations of A
    % do the same for B, inter-splice them
    % reallocate the trial matrix according to this vector
    nsegments = ntrials*p; % need ntrials split into this many segments of varying length
    ca_runs = diff([0, sort(randperm(ntrials-1, nsegments-1)), ntrials]); % n trials spent in context a each time you enter context a
    cb_runs = diff([0, sort(randperm(ntrials-1, nsegments-1)), ntrials]); % same for b

    context_order = [];
    for icontext = 1:length(ca_runs)
        context_order = [context_order, ones(1,ca_runs(icontext)), ones(1,cb_runs(icontext))*2];
    end

    tmp_trial_struct = zeros(size(trial_struct));
    tmp_trial_struct(:,1) = 1:ntrials*2;
    tmp_trial_struct(:,2) = context_order;
    tmp_trial_struct(tmp_trial_struct(:,2) == 1, 3:5) = trial_struct(trial_struct(:,2) == 1, 3:5);
    tmp_trial_struct(tmp_trial_struct(:,2) == 2, 3:5) = trial_struct(trial_struct(:,2) == 2, 3:5);
    trial_struct = tmp_trial_struct;

end