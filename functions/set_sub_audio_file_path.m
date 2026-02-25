function [wavfname] = set_sub_audio_file_path(sub, exp_code, sub_dir, stage, block)
% set the file path where we should save the wav file from the nback task

if stage == 3
    ses_str = 'learn-nback';
else
    ses_str = 'main-task';
end

if isempty(block)
    if sub < 10
        wavfname   = sprintf('sub-0%d_ses-%s_task-n-back-stream.wav', sub, ses_str);
    else
        wavfname   = sprintf('sub-%d_ses-%s_task-n-back-stream.wav.tsv', sub, ses_str);
    end

else

    if sub < 10
        wavfname   = sprintf('sub-0%d_ses-%s_b-%d_task-n-back-stream.wav', sub, ses_str, block);
    else
        wavfname   = sprintf('sub-%d_ses-%s_b--%d_task-n-back-stream.wav.tsv', sub, ses_str, block);
    end
end


% define wav file
wavfname = [sprintf('exp_%s', exp_code), '/', sub_dir, sprintf('/ses-%s', ses_str), '/beh/' wavfname];
end