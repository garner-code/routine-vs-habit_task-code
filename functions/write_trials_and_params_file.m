function [trlg_fid] = write_trials_and_params_file(sub, stage, exp_code, trials, ...
    door_probs, sub_loc_config, door_ps, sub_dir, house)

% write a record of the trials and various params for this subject
if stage == 1
    ses_str = 'learn-doors';
elseif stage == 2
    ses_str = 'learn-uncertainty';
elseif stage == 3
    ses_str = 'learn-nback';
elseif stage == 4
    ses_str = 'main-task';
end

if stage == 1
    if sub < 10
        trlfname   = sprintf('sub-0%d_ses-%s_house-%d_task-mforage_trls.tsv', sub, ses_str, house);
    else
        trlfname   = sprintf('sub-%d_ses-%s_house-%d_task-mforage_trls.tsv', sub, ses_str, house);
    end
else
    if sub < 10
        trlfname   = sprintf('sub-0%d_ses-%s_task-mforage_trls.tsv', sub, ses_str);
    else
        trlfname   = sprintf('sub-%d_ses-%s_task-mforage_trls.tsv', sub, ses_str);
    end
end

% define trial log file 
trlg_fid = fopen([sprintf('exp_%s', exp_code), '/', sub_dir, sprintf('/ses-%s', ses_str), '/beh/' trlfname], 'w');
fprintf(trlg_fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'sub','sess','t','cond','loc','prob','tgt');
fprintf(trlg_fid, '%d\t%d\t%d\t%d\t%d\t%d\t%d\n', [repmat(sub, 1, length(trials(:,1)))', repmat(stage, 1, length(trials(:,1)))', trials]');
fclose(trlg_fid);

% save the subject parameters for this session 
if stage == 1
    if sub < 10
        sess_params_mat_name = [sprintf('exp_%s', exp_code), '/', sub_dir, sprintf('/ses-%s', ses_str), '/beh/', ...
            sprintf('sub-%0d-ses-%s_house-%d_task-mforage_sess-params', sub, ses_str, house)];
    else
        sess_params_mat_name = [sprintf('exp_%s', exp_code), '/', sub_dir, sprintf('/ses-%s', ses_str), ...
            '/beh/', sprintf('sub-%d-ses-%s_house-%d_task-mforage_sess-params', sub, ses_str, house)];
    end
else
    if sub < 10
        sess_params_mat_name = [sprintf('exp_%s', exp_code), '/', sub_dir, sprintf('/ses-%s', ses_str), '/beh/', ...
            sprintf('sub-%0d-ses-%s_task-mforage_sess-params', sub, ses_str)];
    else
        sess_params_mat_name = [sprintf('exp_%s', exp_code), '/', sub_dir, sprintf('/ses-%s', ses_str), ...
            '/beh/', sprintf('sub-%d-ses-%s_task-mforage_sess-params', sub, ses_str)];
    end
end

save(sess_params_mat_name, 'sub', 'trials', 'door_probs', ...
                               'sub_loc_config', 'door_ps');

end