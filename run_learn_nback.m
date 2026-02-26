%% Habit vs Routine 2026
% This script runs the stage where participants learn to perfom an N-back
% task.
% K. Garner
% NOTES:
%
% Dimensions calibrated for 530 mm x 300 mm ASUS VG248 monitor (with viewing distance
% of 570 mm) and refresh rate of 100 Hz
%
% If running on a different monitor, remember to set the monitor
% dimensions, eye to monitor distances, and refresh rate (~lines 169-178)!!!!
%
% Task is an auditory n back task. Listen to the stream of audio and press
% a key whenever the letter matches the same one as N ago.
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
sub.stage = 3; % 1 = learn nback
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
% first, generate the stream of letters, following the method in
% Fig 1 of https://doi.org/10.1080/09658211003702171
% set params
out_file = set_sub_audio_file_path(sub.num, exp_code, sub_dir, stage, []);
n = 2; % we're doing a 2-back task
dur_isi = 3000; % we want 3000 ms between the start of each item
tgt_rate = .33; % 33% of the stream will be targets
min_time = 2; % the sequence will go for 2 minutes
[stream, is_target, onsets, onsets_in_sec] = generate_nback_stream(out_file,...
    n, dur_isi, tgt_rate, min_time);

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
task_log_fname = write_nback_logs(sub.num, sub_dir, stage, exp_code, task, []);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% now set up vis and stuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AssertOpenGL
KbCheck;
KbName('UnifyKeyNames');
%ListenChar(2);% suppress keyboard echo to MATLAB/Octave window
GetSecs;
%Screen('Preference', 'SkipSyncTests', 0);
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

% size of fixation
dot_size_pix = 10*pix_per_mm;
dot_colour = [127, 0, 255]; % KG chose purple, but can be anything

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% now set up keys 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resp.hit = KbName('z');
device_index = [];
all_keys = [];
key_list = zeros(1, 256);
key_list(resp.hit) = 1;
KbQueueCreate(device_index, key_list); % create the keyboard queue

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% timing 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ifi = Screen('GetFlipInterval', window);
waitframes = 1;
time.wait_after_instruct = .5;
time.wait_before_start = 2;
time.memory_task = (min_time*60) + (dur_isi/1000);
num_frames_memory = round(time.memory_task / ifi);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% set up sound
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% note, setting up in anticipation of having two sources of sound in the
% main task
InitializePsychSound(1); % in case PC doesn't have .dll file
%devices = PsychPortAudio('GetDevices');
sound_device_id = 1;
master = PsychPortAudio('Open', sound_device_id, 1+8, 2, 48000, 2); 
memory = PsychPortAudio('OpenSlave', master, 1, 2);

% memory track
memory_mp3 = out_file;
[y, freq] = audioread(memory_mp3);
PsychPortAudio('FillBuffer', memory, y');

% Playback once at start
PsychPortAudio('Start', master, 0, 0, 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% lets tell them what to do
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run_n_back_instructions(window, screenYpixels);
KbWait;
WaitSecs(time.wait_after_instruct);

% now draw a fixation point, flip it 
Screen('DrawDots', window, [xCenter, yCenter], dot_size_pix, dot_colour, [], 2);
Screen('Flip', window);
KbQueueStart(device_index);
WaitSecs(time.wait_before_start);

Screen('DrawDots', window, [xCenter, yCenter], dot_size_pix, dot_colour, [], 2);
Screen('DrawingFinished', window);
vbl = Screen('Flip', window);
PsychPortAudio('Start', memory, 1, 0, 0);
time.everything_starts = vbl;

for frame = 1:num_frames_memory

    Screen('DrawDots', window, [xCenter, yCenter], dot_size_pix, dot_colour, [], 2);

    vbl = Screen('Flip', window, vbl + (waitframes-0.5)*ifi);

end

% now collect the key press events
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

% now save the responses to the log matrix
save(task_log_fname, 'resp', 'time', '-append');

% now score the person's responses
scores = score_nback_responses(resp.press_time_in_rt, ...
                      task.onsets_in_sec,...
                      task.is_target, ...
                      dur_isi);

KbQueueRelease(device_index);
PsychPortAudio('Close');
Screen('CloseAll');

% now save the scores to the log matrix
save(task_log_fname, 'scores', '-append');

acc = sum(scores.hit_count)/sum(task.is_target);
fa = sum(scores.fa_count)/sum(task.is_target);

sprintf('Accuracy score: %.2f%%', acc)
sprintf('False alarm score: %.2f%%', fa)

