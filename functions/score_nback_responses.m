function scores = score_nback_responses(press_time_in_rt, onsets_in_sec, is_target, dur_isi)
% SCORE_RESPONSES  Score hits, misses, and false alarms for a series of stimuli.
%
%   scores = score_responses(press_time_in_rt, onsets_in_sec, is_target)
%
% Inputs
%   press_time_in_rt : [1 x P] or [P x 1] vector of response times (sec).
%   onsets_in_sec    : [1 x N] or [N x 1] vector of stimulus onset times (sec).
%   is_target        : [1 x (N-1)] logical/double; 1 if stimulus i is target,
%                      0 otherwise. (Only the first N-1 stimuli are scorable
%                      because each scoring window ends at the next onset.)
%
% Definitions
%   Window i: from onsets(i) (inclusive) to onsets(i+1) (exclusive).
%   - If is_target(i)==1 and at least one response occurs in Window i => HIT (one per target window).
%   - If is_target(i)==1 and no response in Window i                 => MISS.
%   - Any response occurring in a non-target window                   => FALSE ALARM.
%
% Output (struct)
%   scores.hit_idx        : indices (i) of target windows with ≥1 response.
%   scores.miss_idx       : indices (i) of target windows with no response.
%   scores.fa_press_idx   : indices of responses that fell into non-target windows.
%   scores.hit_count      : number of hits.
%   scores.miss_count     : number of misses.
%   scores.fa_count       : number of false alarms.
%   scores.hit_rt_first   : RT (sec) for the first response in each HIT window.
%   scores.mapping        : for each response, the window index it was assigned to
%                           (0 means unassigned: before first onset or after last scorable window).

    % add the final duration after the last stim onset
    onsets_in_sec = [onsets_in_sec, onsets_in_sec(end)+(dur_isi/1000)];
    % Ensure column vectors
    press_time_in_rt = press_time_in_rt(:);
    onsets_in_sec    = onsets_in_sec(:);
    is_target        = is_target(:) ~= 0;

    N = numel(onsets_in_sec);
    if numel(is_target) ~= N-1
        error('is_target must have length numel(onsets_in_sec)-1 (one per scorable window).');
    end

    % Preallocate: responses grouped by window
    nWin = N - 1;
    resp_by_window = cell(nWin,1);

    % Map each press to its window i such that onsets(i) <= t < onsets(i+1)
    % (presses before first onset or with no "next" onset are ignored)
    P = numel(press_time_in_rt);
    resp_window_idx = zeros(P,1); % 0 = unassigned (ignored)

    for p = 1:P
        t = press_time_in_rt(p);
        % Find latest onset <= t
        i = find(onsets_in_sec <= t, 1, 'last');
        if isempty(i) || i >= N
            continue; % before first onset or at/after last onset -> ignore
        end
        if t < onsets_in_sec(i+1)
            resp_by_window{i} = [resp_by_window{i} ; p];
            resp_window_idx(p) = i;
        end
    end

    % Hits and misses (per target window)
    has_resp = cellfun(@(c) ~isempty(c), resp_by_window);
    hit_idx  = find(is_target & has_resp);
    miss_idx = find(is_target & ~has_resp);

    % False alarms: all responses that fell into non-target windows
    fa_press_idx = cell2mat(resp_by_window(~is_target));

    % (Optional) RTs for hits: first response in each hit window
    hit_rt_first = arrayfun(@(i) ...
        press_time_in_rt(resp_by_window{i}(1)) - onsets_in_sec(i), hit_idx);

    % Package results
    scores = struct();
    scores.hit_idx       = hit_idx;
    scores.miss_idx      = miss_idx;
    scores.fa_press_idx  = fa_press_idx;
    scores.hit_count     = numel(hit_idx);
    scores.miss_count    = numel(miss_idx);
    scores.fa_count      = numel(fa_press_idx);
    scores.hit_rt_first  = hit_rt_first(:);
    scores.mapping       = resp_window_idx; % response -> window (0 if ignored)
end