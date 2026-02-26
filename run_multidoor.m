%% Habit vs Routine 2026
% This script runs the main experimenta stage of the experiment, where participants 
% either find targets under state uncertainty, or they do this while also
% performing an N back task
% K. Garner
% NOTES:
%
% Dimensions calibrated for 530 mm x 300 mm ASUS VG248 monitor (with viewing distance
% of 570 mm) and refresh rate of 100 Hz
%
% If running on a different monitor, remember to set the monitor
% dimensions, eye to monitor distances, and refresh rate (lines 169-178)!!!!
%
% In this stage, participants perform their two tasks with no
% coloured border to tell them where they are. The change in state is not
% predictable but occurs at a rate of 10%. The participant will perform 4
% blocks of the task, each containing 160 trials and lasting ~10-15 minutes.
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
sub.stage = 4; % 4 = the real deal
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
config.info.task_order = 11:14;
config.info.p = .1; % probility of switching state
house = [];

load('probs_cert_world_v2.mat'); % this specifies that there are 4 doors with p=0.25 each 
door_probs   = probs_cert_world;
clear probs_cert_world 

n_practice_trials = 0;
ntrials = 40; % how many trials per context per block?
nblocks = 4; % 2 x single task, 2 x multi-task
[trial_sets, c_ps] = generate_trial_structure_maintask(ntrials, nblocks, ...
    sub_config, door_probs, config); 
door_ps = [c_ps(1,:); c_ps(2,:); repmat(1/length(c_ps(1,:)), 1, length(c_ps(1,:)))];
ndoors = length(c_ps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% define colour settings for worlds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first put the colours in order of the counterbalancing

hole = [20, 20, 20];
col   = [160 160 160]; % set up the colours of the doors
doors_closed_cols = repmat([96, 96, 96]', 1, ndoors); 
door_open_col = hole;

context_cols =  [col; ... % no colours this time
                 col;
                 [0, 0, 0]]; % finish with practice context cols, just in case

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% other considerations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
button_idx = 1; % which mouse button do you wish to poll? 1 = left mouse button
feedback_on = 1; 

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% timing 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ifi = Screen('GetFlipInterval', window);
waitframes = 1;
time.ifi = Screen('GetFlipInterval', window);
time.frames_per_sec = round(1/time.ifi);
time.context_cue_on = round(1000/time.ifi); % made arbitrarily long so it won't turn off
time.tgt_on = .35; % 350 msec - adjust this to adjust how long the target is on for
time.wait_after_instruct = .5;
time.wait_before_start = 2;

% draw srch tgt for the first trial
srch_tgts = [1 2 3 4]; % all categories of image are game
[srch_tex, srch_fname] = make_search_texture(srch_tgts, window);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% setting up master for future memeory sounds and sound for feedback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
InitializePsychSound(1); % in case PC doesn't have .dll file
%devices = PsychPortAudio('GetDevices');
sound_device_id = 1;
nchannels = 2;
req_lat = 2;
frq = 48000;
master = PsychPortAudio('Open', sound_device_id, 1+8, req_lat, frq, nchannels);
%PsychPortAudio('Start', master, 0, 0, 0);   

% coin sound
win_sounds_dir = 'win';
win_sounds = dir(fullfile(win_sounds_dir, '*.mp3'));
win_sounds = win_sounds(~[win_sounds.isdir]);

% now read in mp3 files
coin_handles = cell(1, numel(length(win_sounds)));
for imp3 = 1:length(win_sounds)
    mp3fname = fullfile(win_sounds(imp3).folder, win_sounds(imp3).name);
    [y, freq] = audioread(mp3fname);

    coin_handles{imp3} =  PsychPortAudio('OpenSlave', master, 1, nchannels); % get handle
    PsychPortAudio('FillBuffer', coin_handles{imp3}, y'); % fill buffer with sound
end

% Playback once at start
PsychPortAudio('Start', master, 0, 0, 0);
PsychPortAudio('Start', coin_handles{1}, 1, 0, 1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% now we're ready to run through the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SetMouse(xCenter, yCenter, window);

% things to use/collect during the experiment
block_types = sub_config(config.info.task_order);
moves_record = [];
moves_goal = 4;
tpoints = 0; % not collecting in this phase, but presetting
points_structure = []; % as above
badge_rects = [];
badge_tex = [];
mt_blocks_done = 0;
st_blocks_done = 0;

% run_instructions

for count_blocks = 1:length(trial_sets)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % step 1: is this a multiasking block? if so, set up the N back task
    current_block_type = block_types(count_blocks);
    if current_block_type == 2

        mt_blocks_done = mt_blocks_done + 1;

        out_file = set_sub_audio_file_path(sub.num, exp_code, sub_dir, stage, ...
            mt_blocks_done);
        n = 2; % we're doing a 2-back task
        dur_isi = 3000; % we want 3000 ms between the start of each item
        tgt_rate = .33; % 33% of the stream will be targets
        min_time = 30; % the sequence will go for 30 minutes to be
        % suuuuuuper safe
        [stream, is_target, onsets, onsets_in_sec] = generate_nback_stream(out_file,...
            n, dur_isi, tgt_rate, min_time);

        memory = PsychPortAudio('OpenSlave', master, 1, nchannels); % will use this on a block by block basis
        % memory track
        memory_mp3 = out_file;
        [y, freq] = audioread(memory_mp3);
        PsychPortAudio('FillBuffer', memory, y');

        % Playback once at start
        PsychPortAudio('Start', master, 0, 0, 0);

        % save the task parameters
        task.out_file = out_file;
        task.n = n;
        task.dur_isi = dur_isi;
        task.tgt_tate = tgt_rate;
        task.min_time = min_time;
        task.stream = stream;
        task.is_target = is_target;
        task.onsets = onsets;
        task.onsets_in_sec = onsets_in_sec;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% now set up keys
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        resp.hit = KbName('z');
        device_index = [];
        all_keys = [];
        key_list = zeros(1, 256);
        key_list(resp.hit) = 1;
        KbQueueCreate(device_index, key_list); % create the keyboard queue
    else
        task.out_file = [];
        st_blocks_done = st_blocks_done + 1;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % step 2: set up the trial and behaviour logs for this block

    trials = trial_sets{count_blocks};

    if current_block_type == 1
        blck_str = sprintf('st%d', st_blocks_done);
        blks_done = st_blocks_done;
    elseif current_block_type == 2
        blck_str = sprintf('mt%d', mt_blocks_done);
        blks_done = mt_blocks_done;
    end

    write_trials_and_params_file_4main_task(sub.num, stage, exp_code, ...
        blck_str, blks_done, current_block_type, trials, ...
        door_probs, sub_config, door_ps, sub_dir, task);
    [beh_form, beh_fid] = initiate_sub_beh_file(sub.num, sub.stage, sub_dir, ...
        exp_code, house, blck_str); % this is the behaviour and the events log
    % probabilities of target location and number of doors

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % step 3: set up the reward trials for this block

    % if feedback is on, set up half of the stay trials to be reward trials
    max_reward_trials = ntrials - (ntrials*config.info.p); %  
    reward_trials = find(~diff(trials(:,2)))+1;
    n_reward_trials = min(max_reward_trials, round(length(reward_trials)/2));
    reward_trials = datasample(reward_trials, n_reward_trials, 'Replace', false);
    reward_trials = sort(reward_trials, 'ascend');

    % insert run block instructions here
    Screen('TextSize', window, 40);          % Set your text size
    Screen('TextFont', window, 'Arial');     % Optional
    DrawFormattedText(window, 'Hello world!', 'center', 'center', [255 255 255]);
    Screen('Flip', window);
    KbWait;
    WaitSecs(1); 

    % Draw a regular display with blocks and start working memory task
    % draw doors and start
    edge_col = context_cols(1,:);
    draw_edge(window, edgeRect, xCenter, yCenter, edge_col, 0, time.context_cue_on);
    draw_background(window, backRect, xCenter, yCenter, col);
    draw_doors(window, doorRects, doors_closed_cols);
    Screen('Flip', window);

    if current_block_type == 2
        KbQueueStart(device_index);
        WaitSecs(time.wait_before_start);

        % Screen here
        draw_edge(window, edgeRect, xCenter, yCenter, edge_col, 0, time.context_cue_on);
        draw_background(window, backRect, xCenter, yCenter, col);
        draw_doors(window, doorRects, doors_closed_cols);
        vbl = Screen('Flip', window);
        PsychPortAudio('Start', memory, 1, 0, 0);
        time.everything_starts = vbl;
    end

    for count_trials = 1:length(trials(:,1))

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
        
        if ismember(count_trials, reward_trials)
            feedback_on = 1;
        else
            feedback_on = 0;
        end
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

    end


    % now wrap up the block
    % first, the behavioural log needs to be closed no matter the block
    % type
    fclose(beh_fid);

    % now wrap up audio stuff 
    if current_block_type == 2
        % now collect the key press events
        task.offset_time = GetSecs - time.everything_starts;
        resp.press_time_in_getsecs = [];
        resp.press_time_in_rt = [];
        while true
            [key_press_event, nremaining] = KbEventGet(device_index);
            if isempty(key_press_event), break; end
            if key_press_event.Pressed == 1 && key_press_event.Keycode == resp.hit
                resp.press_time_in_getsecs = [resp.press_time_in_getsecs, key_press_event.Time];
                resp.press_time_in_rt = [resp.press_time_in_rt, key_press_event.Time - time.everything_starts];
            end
            if nremaining <= 0, break; end
        end

        % now amend the task details ready for scoring
        nback_used_idx = task.onsets_in_sec < task.offset_time;
        task.stream = task.stream(nback_used_idx);
        task.is_target = task.is_target(nback_used_idx);
        task.onsets = task.onsets(nback_used_idx);
        task.onsets_in_sec = task.onsets_in_sec(nback_used_idx);

        % now score the person's responses
        scores = score_nback_responses(resp.press_time_in_rt, ...
            task.onsets_in_sec,...
            task.is_target, ...
            dur_isi);

        % now save the scores to the log matrix
        task_log_fname = write_nback_logs(sub.num, sub_dir, stage, exp_code, task, blck_str);
        save(task_log_fname, 'resp', 'time', 'scores', '-append');
        % free the keyboard queue and close the audio slave
        KbQueueRelease(device_index);
        PsychPortAudio('Stop', memory, 0, 1);   % stop, don't wait until end of track, + wait for stop
        % Close this slave to free resources before opening another one
        PsychPortAudio('Close', memory);
    end

end


% end the experiment
% insert end message
sca;
Priority(0);
PsychPortAudio('Stop', master);
PsychPortAudio('Close');
Screen('CloseAll');