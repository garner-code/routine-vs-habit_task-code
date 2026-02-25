function [stream, is_target, onsets, onsets_in_sec] = generate_nback_stream(out_file, n, dur_isi, tgt_rate, min_time)
% generate an auditory file of spoken letters for nback task
% using the methods from https://doi.org/10.1080/09658211003702171
% eight letters (b, c, g, h, k, p, q, t)
% inter-stimulus-interval = 3000 ms
% 33 % of stimuli = targets 
% 67 % of stimuli = non-targets
% inputs
% out_file      : what to name the output file?
% n             : how many back?
% dur_isi       : how long before the beginning of each letter? (ms)
% tgt_rate      : how many items in the streams should be one of the
% targets (proportion)
% min           : how many minutes should the sequence last?

%% first, work out how many items we need to get for stream
stim = {'b', 'c', 'g', 'h', 'k', 'l', 'q', 's'};
K = length(stim);
n_items = floor((min_time*60*1000)/dur_isi);

%% create an index for the stream
stream = generate_balanced_nback_vector(n_items, n, tgt_rate, K);
% compute target positions
is_target = false(1, n_items);
for t = (n+1):n_items
    is_target(t) = stream(t) == stream(t-n);
end

%% create a cell of the files required according to the values in stream
file_tmplt = 'n_back/alphabet/alphabet-spoken-letter-%s.wav';
stream_stim = cell(1, n_items);
for i = 1:n_items
    stream_stim{i} = sprintf(file_tmplt, stim{stream(i)});
end

%% now make an auditory file that plays each stimulus with an 
% isi of 2500 ms
tgt_chans = 2;
tgt_freq = 48000;
[onsets, ~, fs0] = make_fixedSOA_playlist(stream_stim, out_file, dur_isi, tgt_freq, tgt_chans);

%% put the onsets in samples back into time (seconds)
onsets_in_sec = onsets / tgt_freq;

end