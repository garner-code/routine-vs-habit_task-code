function [] = post_tgt_response_poll(window, trialStart, ...
    xPos, yPos, r, door_probs, fid, fform, sub,...
    sess, trial_n, cond, tgt_flag)
% still capture data while the target is on
[x,y,~] = GetMouse(window); % has the mouse been clicked
timer = GetSecs - trialStart;

door_check = doorSample(xPos, yPos, x, y); % returns distance of
% mouse coordinates from all door centres
didx = find(door_check < r); % which door has been selected
curr_door_prob = door_probs(didx); % for data collection, this will tell us whether
% this is a target, whether its a random error, or whether its a
% 'different context' error
if isempty(didx)
    didx = 0;
    curr_door_prob = 0;
end
tmp_flag = 10;
% collect the data from this sample
fprintf(fid, fform, sub, sess, trial_n, cond, timer, tmp_flag,...
    didx, curr_door_prob, tgt_flag, 1, x, y); 