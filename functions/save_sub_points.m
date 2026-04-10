function [] = save_sub_points(sub, sub_dir, exp_code, task, tpoints)

sub = sub.num;
task.exp_code = exp_code;
ses_str = 'main-task';

if sub < 10
    task_log_fname   = sprintf('sub-0%d_ses-%s_task-multi-sess-points-log.mat', sub, ses_str);
else
    task_log_fname   = sprintf('sub-%d_ses-%s_task-multi-sess-points-log.mat', sub, ses_str);
end

% define trial log file
task_log_fname = [sprintf('exp_%s', exp_code), '/', sub_dir, sprintf('/ses-%s', ses_str), '/beh/' task_log_fname];

save(task_log_fname, 'tpoints');

end