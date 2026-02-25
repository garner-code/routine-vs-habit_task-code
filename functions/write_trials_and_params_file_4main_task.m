function [trlg_fid] = write_trials_and_params_file_4main_task(sub, stage, ...
    exp_code, blk_str, blks_done, current_block_type, trials,  ...
    door_probs, sub_loc_config, door_ps, sub_dir, task)

% write a record of the trials and various params for this subject
ses_str = 'main-task';

if sub < 10
    trlfname   = sprintf('sub-0%d_ses-%s_b-%s_task-mforage_trls.tsv', sub, ses_str, blk_str);
else
    trlfname   = sprintf('sub-%d_ses-%s_b-%s_task-mforage_trls.tsv', sub, ses_str, blk_str);
end

% define trial log file 
trlg_fid = fopen([sprintf('exp_%s', exp_code), '/', sub_dir, sprintf('/ses-%s', ses_str), '/beh/' trlfname], 'w');
fprintf(trlg_fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'sub','sess','bty', 'bn','t','cond','loc','prob','tgt');
fprintf(trlg_fid, '%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n', [repmat(sub, 1, length(trials(:,1)))', repmat(stage, 1, length(trials(:,1)))', ...
                                                   repmat(current_block_type, 1, length(trials(:,1)))', ...
                                                   repmat(blks_done, 1, length(trials(:,1)))',...
                                                   trials]');
fclose(trlg_fid);

% save the subject parameters for this session 
if sub < 10
    sess_params_mat_name = [sprintf('exp_%s', exp_code), '/', sub_dir, sprintf('/ses-%s', ses_str), '/beh/', ...
        sprintf('sub-%0d-ses-%s_b-%s_task-mforage_sess-params', sub, ses_str, blk_str)];
else
    sess_params_mat_name = [sprintf('exp_%s', exp_code), '/', sub_dir, sprintf('/ses-%s', ses_str), ...
        '/beh/', sprintf('sub-%d-ses-%s_b-%s_task-mforage_sess-params', sub, ses_str, blk_str)];
end

save(sess_params_mat_name, 'sub', 'trials', 'door_probs', ...
                               'sub_loc_config', 'door_ps', 'task');

end