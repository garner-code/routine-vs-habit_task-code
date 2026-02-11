function [trial_locs] = get_locs_given_probs_v2(n, probs)

% function takes the number of trials per condition and selects the 
% target location over n trials, given that vector of target probailities
nlocs = 16;

trial_locs = datasample(1:nlocs, n, 'Replace', true, 'Weights', probs);

end