%% Habit vs Routine 2026
% This script runs the learning stage of the experiment, where participants learn which doors lead to targets in each context.
% K. Garner
% NOTES:
%
% Dimensions calibrated for 530 mm x 300 mm ASUS VG248 monitor (with viewing distance
% of 570 mm) and refresh rate of 100 Hz
%
% If running on a different monitor, remember to set the monitor
% dimensions, eye to monitor distances, and refresh rate (lines 169-178)!!!!
%
% Task is a visual search/foraging task. Participants seek the target which
% is randomly placed behind 1 of 16 doors. There are two contexts to learn
% with 4 doors in each context being allocated p=.25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear all the things
sca
clear all
clear mex

addpath(genpath('functions')) % add the functions folder to the path

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% session settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub.num = input('sub number? ');
sub.stage = 1; % 1 = learn doors
exp_code = 'hvr_data';
sub_dir = make_sub_folders(sub.num, sub.stage, exp_code);

% set randomisation seed based on sub/sess number
stage = sub.stage;
r_num = [num2str(sub.num) num2str(sub.stage)];
r_num = str2double(r_num);
rand('state',r_num);
randstate = rand('state');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% generate trial structure for participants and setup log files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('sub_infos.mat'); % matrix of counterbalancing info
% see generate_sub_info_mat for details
sub_config = sub_infos(sub.num, :); 
config.info.ca_cols = 2:5;
config.info.cb_cols = 6:9;
config.info.colour_assign = 10;

% now find out if its the first house or second house to be learned
sub.house = input('house number? 1 or 2 or 9 '); % 1 for the first house, 2 for house 2, 9 to go through both
house = sub.house;

[beh_form, beh_fid] = initiate_sub_beh_file(sub.num, sub.stage, sub_dir, exp_code, house, []); % this is the behaviour and the events log
% probabilities of target location and number of doors
load('probs_cert_world_v2.mat'); % this specifies that there are 4 doors with p=0.25 each 
door_probs   = probs_cert_world;
clear probs_cert_world 

% trial number settings etc
if stage == 1 && house < 9% if its initial learning
    n_practice_trials = 5;
    n_correct_required = 40; % how many do you have to get correct to break out?
    ntrials = 200; % KG: MFORAGE - max per context
    [trials, ca_ps] = generate_trial_structure_learn(ntrials, sub_config, door_probs, house, config);    
elseif stage == 1 && house == 9

    n_practice_trials = 0;
    ntrials = 80; % KG: MFORAGE - max per context
    [trials, ca_ps] = generate_trial_structure_learn(ntrials, sub_config, door_probs, house, config); 
end

if house == 1
    door_ps = [ca_ps; zeros(1, length(ca_ps)); repmat(1/length(ca_ps), 1, length(ca_ps))];
elseif house == 2
    door_ps = [zeros(1, length(ca_ps)); ca_ps; repmat(1/length(ca_ps), 1, length(ca_ps))];
else
    door_ps = [ca_ps(1,:); ca_ps(2,:); repmat(1/length(ca_ps(1,:)), 1, length(ca_ps(1,:)))];
end

ndoors = length(ca_ps);

% add the 5 practice trials to the start of the matrix
if house == 1
    practice = [ repmat(999, n_practice_trials, 1), ...
        repmat(3, n_practice_trials, 1), ...
        datasample(1:16, n_practice_trials)', ...
        repmat(999, n_practice_trials, 1), ...
        datasample(1:100, n_practice_trials)'];
    trials   = [practice; trials];
end

write_trials_and_params_file(sub.num, stage, exp_code, trials, ...
    door_probs, sub_config, door_ps, sub_dir, house);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% define colour settings for worlds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first put the colours in order of the counterbalancing
green = [27, 158, 119]; 
purple = [117, 112, 179];
colour_options = {green, purple};

hole = [20, 20, 20];
col   = [160 160 160]; % set up the colours of the doors
doors_closed_cols = repmat([96, 96, 96]', 1, ndoors); 
door_open_col = hole;

context_cols =  [colour_options{sub_config(config.info.colour_assign)}; ... % colour-task assignment is counterbalanced
                 colour_options{3-sub_config(config.info.colour_assign)};
                 [0, 0, 0]]; % finish with practice context cols

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% other considerations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

breaks = 20; % how many trials inbetween breaks?
count_blocks = 0;
button_idx = 1; % which mouse button do you wish to poll? 1 = left mouse button
feedback_on = 1; % we want feedback on every trial in this phase

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% SET UP PSYCHTOOLBOX THINGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up screens and mex
KbCheck;
KbName('UnifyKeyNames');
GetSecs;
AssertOpenGL
Screen('Preference', 'SkipSyncTests', 1);
PsychDebugWindowConfiguration;
monitorXdim = 530; % in mm % KG: MFORAGE: GET FOR UNSW MATTHEWS MONITORS
monitorYdim = 300; % in mm
screens = Screen('Screens');
screenNumber = max(screens);
% screenNumber = 0;
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
back_grey = 200;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, back_grey);
ifi = Screen('GetFlipInterval', window);
waitframes = 1;
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% compute pixels for background rect
pix_per_mm = screenYpixels/monitorYdim;
display_scale = .65; % VARIABLE TO SCALE the display size
display_scale_edge = .75; % scale the context indicator
base_pix   = 180*pix_per_mm*display_scale; 
backRect   = [0 0 base_pix base_pix];
edge_pix   = 180*pix_per_mm*display_scale_edge;
edgeRect   = [0 0 edge_pix edge_pix];

% and door pixels for door rects (which are defined in draw_doors.m
nDoors     = 16;
doorPix    = 26.4*pix_per_mm*display_scale; % KG: MFORAGE: May want to change now not eyetracking
[doorRects, xPos, yPos]  = define_door_rects_v2(backRect, xCenter, yCenter, doorPix);
% define arrays for later comparison
xPos = repmat(xPos, 4, 1);
yPos = repmat(yPos', 1, 4);
r = doorPix/2; % radius is the distance from center to the edge of the door

% timing % KG: MFORAGE: timing is largely governed by participant's button
% presses, not much needs to be defined here
time.ifi = Screen('GetFlipInterval', window);
time.frames_per_sec = round(1/time.ifi);
time.context_cue_on = round(1000/time.ifi); % made arbitrarily long so it won't turn off
time.tgt_on = .35; % 350 msec - adjust this to adjust how long the target is on for

% draw srch tgt for the first trial
srch_tgts = [1 2 3 4]; % all categories of image are game
[srch_tex, srch_fname] = make_search_texture(srch_tgts, window);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% setting up sound for feedback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
InitializePsychSound; % in case PC doesn't have .dll file
% coin sound
win_sounds = dir('win');
% remove hidden files
hidden_index = [];
for ihid = 1:length(win_sounds)
    if length(win_sounds(ihid).name) < 5
        hidden_index = [hidden_index, ihid];
    end
end
win_sounds(hidden_index) = [];
% now read in mp3 files
coin_handles = cell(1, numel(length(win_sounds)));
for imp3 = 1:length(win_sounds)
    mp3fname = fullfile(win_sounds(imp3).folder, win_sounds(imp3).name);
    [y, freq] = audioread(mp3fname);
    coin_handles{imp3} = PsychPortAudio('Open', [], [], 0, freq, size(y, 2)); % get handle
    PsychPortAudio('FillBuffer', coin_handles{imp3}, y'); % fill buffer with sound
end

% Playback once at start
PsychPortAudio('Start', coin_handles{1}, 1, 0, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% now we're ready to run through the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SetMouse(xCenter, yCenter, window);

% things to collect during the experiment
moves_record = [];
moves_goal = 4;
tpoints = 0; % not collecting in this phase, but presetting
points_structure = []; % as above
badge_rects = [];
badge_tex = [];

for count_trials = 1:length(trials(:,1))

    if count_trials == 1
        run_instructions(window, screenYpixels, stage, house);
        KbWait;
        WaitSecs(1);
    end

    %%%%%%% trial start settings
    idxs = 0; % refresh 'door selected' idx
    % assign tgt loc and onset time
    tgt_loc = trials(count_trials, 3);
    tgt_flag = tgt_loc; %%%% where is the target
    door_select_count = 0; % track how many they got it in
    % set context colours according to condition
    edge_col = context_cols(trials(count_trials, 2), :); % select colour for context

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% run trial
    tgt_found = 0;
   
    % draw doors and start
    draw_edge(window, edgeRect, xCenter, yCenter, edge_col, 0, time.context_cue_on); 
    draw_background(window, backRect, xCenter, yCenter, col);
    draw_doors(window, doorRects, doors_closed_cols);
    trial_start = Screen('Flip', window); % use this time to determine the time of target onset
      
    while ~any(tgt_found)

        door_on_flag = 0; % poll until a door has been selected
        while ~any(door_on_flag) 

            % poll what the mouse is doing, until a door is opened
            [didx, door_on_flag, x, y] = query_door_select(door_on_flag, doors_closed_cols, window, ...
                                                                edgeRect, backRect,  xCenter, ...
                                                                yCenter, edge_col, col, doorRects, ...
                                                                beh_fid, beh_form, ...
                                                                sub.num, sub.stage,...
                                                                count_trials, trials(count_trials,2), ...
                                                                tgt_flag, ...
                                                                xPos, yPos, ...
                                                                r, door_ps(trials(count_trials,2), :), trial_start, ...
                                                                button_idx, time.context_cue_on);

        end

        door_select_count = door_select_count + 1;

        while any(door_on_flag)
            % insert a function here that opens the door (if there is no
            % target), or that breaks and moves to the draw_target_v2
            % function, if the target is at the location of the selected
            % door

            % didx & tgt_flag info are getting here
            [tgt_found, didx, door_on_flag] = query_open_door(trial_start, sub.num, sub.stage, ...
                count_trials, trials(count_trials,2), ...
                door_ps(trials(count_trials,2), :), ...
                tgt_flag, window, ...
                backRect, edgeRect, xCenter, yCenter, edge_col, col, ...
                doorRects, doors_closed_cols, ...
                door_open_col,...
                didx, beh_fid, beh_form, x, y, button_idx, time.context_cue_on);

        end
    end % end of target search period for trial

    [points, tgt_on] = draw_target_v2(window, edgeRect, backRect, edge_col, col, ...,
                        doorRects, doors_closed_cols, didx, ...
                        srch_tex, xCenter, yCenter, time.context_cue_on, ...
                        trial_start, door_select_count, feedback_on, ...
                        coin_handles);
    % now draw target texture for next trial while target is being
    % displayed, but still poll the mouse
    nxt_tgt_drawn = 0;
    while (GetSecs - tgt_on) < time.tgt_on % leave the target on for time.tgt_on
        % while you have time, draw the target texture for the next trial
        if ~nxt_tgt_drawn
            Screen('Close', srch_tex);
            [srch_tex, srch_fname] = make_search_texture(srch_tgts, window);
            nxt_tgt_drawn = 1;
        end
        % but poll the mouse
        WaitSecs(.015); % to mirror sample rate during the trials
        post_tgt_response_poll(window, trial_start, ...
            xPos, yPos, r, door_ps(trials(count_trials,2), :),...
            beh_fid, beh_form, sub.num,...
            sub.stage, count_trials, trials(count_trials,2), ...
            tgt_flag)
    end

    if stage == 1 && house == 1 && count_trials == n_practice_trials % if needed, explain the task

        end_practice(window, screenYpixels);
        KbWait;
        WaitSecs(1);
    end

    if any(mod(count_trials-n_practice_trials, breaks))
    else
        if count_trials == n_practice_trials
        else
            take_a_break(window, count_trials-n_practice_trials, ntrials*2, ...
                breaks, backRect, xCenter, yCenter, screenYpixels, tpoints, stage);
            KbWait;
        end
        WaitSecs(1);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% if in stage 1, tally up how many doors they got it in and see
%%%%%%%%%%%% if you can switch them to the next phase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if stage == 1 && house < 9
    moves_record = [moves_record, door_select_count];

    if count_trials > n_practice_trials + n_correct_required
        go = tally_moves(moves_record, moves_goal, count_trials, n_correct_required); % returns a true if we should proceed as normal
        if ~go
            break
        end
    end
elseif stage == 1 && house == 9
    moves_record = [moves_record, door_select_count];
end % end stage 1 response tally

end

sca;
Priority(0);
PsychPortAudio('Close');
Screen('CloseAll');

if stage == 1 && house < 9 &&  ~go
    sprintf('achievement unlocked! proceed to next level')
elseif stage == 1 && house < 9 && count_trials == length(trials(:,1))
    sprintf('accuracy criterion wasn`t reached this time, check next stage :(')
elseif stage == 1 && house == 9
    acc_house_1 = mean(moves_record(trials(:,2) == 1) <= moves_goal);
    acc_house_2 = mean(moves_record(trials(:,2) == 2) <= moves_goal);
    sprintf('house 1 acc: %.2f, house 2 acc: %.2f', acc_house_1, acc_house_2)
end