function [task_log_fname] = write_nback_logs(sub, sub_dir, stage, exp_code, task, block)

task.sub = sub;
task.stage = stage;
task.exp_code = exp_code;

if stage == 3
    ses_str = 'learn-nback';
else
    ses_str = 'main-task';
end

if isempty(block)

    if sub < 10
        task_log_fname   = sprintf('sub-0%d_ses-%s_task-n-back-log.mat', sub, ses_str);
    else
        task_log_fname   = sprintf('sub-%d_ses-%s_task-n-back-log.mat', sub, ses_str);
    end

    % define trial log file
    task_log_fname = [sprintf('exp_%s', exp_code), '/', sub_dir, sprintf('/ses-%s', ses_str), '/beh/' task_log_fname];

else

    if sub < 10
        task_log_fname   = sprintf('sub-0%d_ses-%s_b-%s_task-n-back-log.mat', sub, ses_str, block);
    else
        task_log_fname   = sprintf('sub-%d_ses-%s_b-%s_task-n-back-log.mat', sub, ses_str, block);
    end


    task.block = block;

    % define trial log file
    task_log_fname = [sprintf('exp_%s', exp_code), '/', sub_dir, sprintf('/ses-%s', ses_str), '/beh/' task_log_fname];

end

save(task_log_fname, 'task');

end