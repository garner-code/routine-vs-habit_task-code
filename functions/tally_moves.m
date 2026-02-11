function [go] = tally_moves(moves_record, moves_goal, count_trials, n_correct_required)
% TALLY_GOES - count up how many trials over which participants scored >
% 90% over the past n_correct_required trials
% INPUTS
% moves_record = the number of moves made on each trial so far
% moves_goal = number of moves they are aiming for
% count_trials = trial number we are currently on

% get last 20 trials
tback = n_correct_required - 1;
record = moves_record(count_trials - tback: count_trials);
acc = sum(record <= moves_goal)/length(record);

if acc >= .9 % if they've got the target within 4 on the last 10 trials
    go = false;
else
    go = true;
end

