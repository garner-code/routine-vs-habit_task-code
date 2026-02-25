function [trial_sets, cps] = generate_trial_structure_maintask(ntrials, ...
    nblocks, sub_config, door_probs, config)
%%%%%
% GENERATE_TRIAL_STRUCTURE_MAINTASK
% generate the trial structure for the main experimental task
% we are generating ntrials per block, and switching state 
% with a probability of config.info.p
% 
%  inputs - ntrials = number of trials in each state per block 
%  sub_config [1, n] = subject counterbalancing info loaded from
% 'sub_infos.mat'
%  door_probs [1, ndoors] = set of target probabilities to be distributed
%  among the doors
%
%
% RETURNS:
% {trial_struct} = a cell of 1, nblocks, contraining one ntrials x 5 matrix
% per matrix:
% col 1 = trial number
% col 2 = context - 1 or 2
% col 3 = target door for that trial
% col 4 = a priori p(tgt door)
% col 5 = target for that trial
% c_ps =
% ca_ps = 1,ndoor vector of which p goes with which door for context a
% cb_ps = as above, but for context b
tn_col = 1;
cntx_col = 2;
tgtdoor_col = 3;
prior_col = 4;
tgtid_col = 5;

ndoors = length(door_probs);
%ntargets = 100; % total number of targets to choose from (now defunct)
% get ca and cb locations
ca_cols = config.info.ca_cols;
cb_cols = config.info.cb_cols;
ca_idxs = sub_config(ca_cols);
cb_idxs = sub_config(cb_cols);
p_switch = config.info.p;
total_trials_per_block = ntrials*2; % WARNING: hard coded, assuming 2 states

% setup: get target locations for each context
ca_ps = zeros(1, ndoors);
cb_ps = ca_ps;
ca_ps(ca_idxs) = door_probs(door_probs > 0);
cb_ps(cb_idxs) = door_probs(door_probs > 0);

cps = [ca_ps; cb_ps];

% setup the trial structure
trial_sets = cell(1, nblocks);
trial_sets(:) = {zeros(total_trials_per_block, 5)};     % fill each cell with an n-by-m zeros matrix

% now make trials
for iblock = 1:nblocks

    these_trials = trial_sets{iblock}; % make life easier for now

    % first, assign the trial numbers for that block
    these_trials(:,tn_col) = 1:size(these_trials,1);

    % first, make a matrix as if there were only going to be one switch
    these_trials(1:ntrials,cntx_col) = datasample(1:2,1); % randomise which context comes first
    these_trials((ntrials+1):total_trials_per_block,cntx_col) = 3-these_trials(1,cntx_col);

    % select targets with p(prior)
    ca_locs = get_locs_given_probs_v2(ntrials, ca_ps);
    cb_locs = get_locs_given_probs_v2(ntrials, cb_ps);

    % allocate a target door to each trial
    these_trials(these_trials(:,cntx_col) == 1, tgtdoor_col) = ca_locs;
    these_trials(these_trials(:,cntx_col) == 2, tgtdoor_col) = cb_locs;
    these_trials(these_trials(:,cntx_col) == 1, prior_col) = max(ca_ps); % assumes uniform priors for ca doors
    these_trials(these_trials(:,cntx_col) == 2, prior_col) = max(cb_ps); % assumes uniform priors for cb doors
    these_trials(:, tgtid_col) = NaN;

    % now create switching conditions
    these_trials = create_switch_conditions(these_trials, ntrials, p_switch);

    trial_sets{iblock} = these_trials;

end

end