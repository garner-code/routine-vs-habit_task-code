function [onsets, SOA_samp, fs0] = make_fixedSOA_playlist(files, outFile, SOA_ms, targetFs, targetChannels)
%MAKE_FIXEDSOA_PLAYLIST Create one audio file with fixed onsets
%   files          : 1xN cell array of audio file paths (wav, flac, mp3, etc.)
%   outFile        : output WAV path (e.g., 'playlist.wav')
%   SOA_ms         : stimulus onset asynchrony in milliseconds (e.g., 2500)
%   targetFs       : (optional) output sample rate (e.g., 44100). If empty, uses first file's Fs.
%   targetChannels : (optional) 1 for mono, 2 for stereo. If empty, preserves first file's channels.
%
% Example:
%   files = {'A.wav','B.wav','C.wav'};
%   [onsets, SOA_samp] = make_fixedSOA_playlist(files, 'out.wav', 2500, 48000, 2);
% Returns:
%   onsets         : the onset of each stimulus (in samples)
%   SOA_samp       : how many samples in each SOA duration (should match
%   diff(onsets)
%   fs0            : frequency of output track (samples per sec)

    if nargin < 3 || isempty(SOA_ms), SOA_ms = 2500; end
    if ~iscell(files) || isempty(files)
        error('files must be a non-empty cell array of file paths.');
    end

    % --- Probe first file to set defaults if not provided
    [y0, fs0] = audioread(files{1});
    if nargin < 4 || isempty(targetFs), targetFs = fs0; end
    if nargin < 5 || isempty(targetChannels), targetChannels = size(y0,2); end
    if ~ismember(targetChannels, [1 2])
        error('targetChannels must be 1 (mono) or 2 (stereo).');
    end

    % --- Convert SOA to samples
    SOA_samp = round((SOA_ms/1000) * targetFs);

    % % --- Utility: normalize channel count
    % toChannels = @(x, C) ...
    %     (C==1) * mean(x,2) + ...                             % to mono
    %     (C==2) * (size(x,2)==2) .* x + ...                   % already stereo
    %     (C==2) * (size(x,2)==1) .* [x, x];                   % mono -> stereo (duplicate)

    % --- First pass: read, resample, convert channels, and store lengths
    N = numel(files);
    clips = cell(1,N);
    clipLens = zeros(1,N); % in samples, at targetFs
    for i = 1:N
        [y, fs] = audioread(files{i});
        % Resample if needed
        if fs ~= targetFs
            y = resample(y, targetFs, fs);
        end
        % Channel conversion
 %       y = toChannels(y, targetChannels);
        clips{i} = y;
        clipLens(i) = size(y,1);
    end

    % --- Onset schedule: 0, SOA, 2*SOA, ...
    onsets = (0:(N-1)) * SOA_samp;  % samples

    % --- Determine output length: last onset + duration of last clip
    outLen = onsets(end) + clipLens(end);

    % --- Pre-allocate output with small headroom (float)
    Y = zeros(outLen, targetChannels, 'double');

    % --- Mix each clip at its onset
    for i = 1:N
        s0 = onsets(i) + 1;
        s1 = s0 + clipLens(i) - 1;
        Y(s0:s1, :) = Y(s0:s1, :) + clips{i};
    end

    % --- Prevent clipping:
    peak = max(abs(Y), [], 'all');
    if peak > 1
        Y = Y / peak * 0.99; % normalize with a bit of headroom
        fprintf('Warning: mix was clipped; normalized to 0.99 full scale.\n');
    end

    % --- Write output (16‑bit is common, but you can go 24‑bit/32‑bit if you prefer)
    audiowrite(outFile, Y, targetFs, 'BitsPerSample', 24);
    fprintf('Wrote %s (Fs=%d Hz, channels=%d, length=%.2f s)\n', ...
        outFile, targetFs, targetChannels, size(Y,1)/targetFs);
end