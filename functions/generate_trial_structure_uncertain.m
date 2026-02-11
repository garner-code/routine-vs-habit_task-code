function [trial_struct, c_ps] = generate_trial_structure_uncertain(ntrials, ...
    nblocks, sub_config, door_probs, config)
%%%%%
% GENERATE_TRIAL_STRUCTURE_UNCERTAIN
% generate the trial structure for the learning uncertainty stage.
% we are generating ntrials per state, and switching state nblock times
%
% inputs - ntrials = number of trials in each condition 
% sub_config [1, n] = subject counterbalancing info loaded from
% 'sub_infos.mat'
% door_probs [1, ndoors] = set of target probabilities to be distributed
% among the doors
%
% 
% RETURNS:
% [trial_struct] = 5 x ntrials matrix
% col 1 = trial number
% col 2 = context - 1 or 2
% col 3 = target door for that trial
% col 4 = a priori p(tgt door)
% col 5 = target for that trial

% ca_ps = 1,ndoor vector of which p goes with which door for context a
% cb_ps = as above, but for context b

ndoors = length(door_probs);
ntargets = 100; % total number of targets to choose from (now defunct)
% get ca and cb locations
ca_cols = config.info.ca_cols;
cb_cols = config.info.cb_cols;
ca_idxs = sub_config(ca_cols);
cb_idxs = sub_config(cb_cols);

% now I make a cell containing matrices for each block of trials
trial_cell = cell(1, nblocks);
trial_cell(:) = {zeros(ntrials, 5)};     % fill each cell with an n-by-m zeros matrix
ab_changes = repmat([1,2],1,nblocks/2);

for i_ab = 1:length(ab_changes)
    
    if (ab_changes(i_ab)) < 2
        these_idxs = ca_idxs;
    else
        these_idxs = cb_idxs;
    end

    trial_cell{i_ab}(:,2) = ab_changes(i_ab);

    ps = zeros(1, ndoors);
    ps(these_idxs) = door_probs(door_probs > 0);
    these_locs = get_locs_given_probs_v2(ntrials, ps);

    trial_cell{i_ab}(:,3) = these_locs;
    trial_cell{i_ab}(:,4) = max(ps);
    trial_cell{i_ab}(:,5) = NaN;
end
    % complete trial structure
    trial_struct = vertcat(trial_cell{:});
    trial_struct(:,1) = 1:length(trial_struct(:,1));

    % get vectors of ps for each context
    ca_ps = zeros(1, ndoors);
    cb_ps = ca_ps;
    ca_ps(ca_idxs) = door_probs(door_probs > 0);
    cb_ps(cb_idxs) = door_probs(door_probs > 0);
    c_ps = [ca_ps; cb_ps];
    
end 