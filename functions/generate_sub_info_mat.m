%%%% this script creates the matrix of target location/condition
%%%% assignments across participants
clear all

% add block order for counterbalancing withinmain task
blocks = [1, 2, 1, 2];
all_blocks = perms(blocks);
expand_all_blocks = 4; % how many times to replicate the rows of all_blocks to 
% get the total number of subs
nsubs = size(all_blocks,1)*expand_all_blocks;
% cols:
sub = 1;
ca_cols = 2:5;
cb_cols = 6:9;
colour_assign = 10;
exp_block_order = 11:14;

sub_infos = zeros(nsubs, max(exp_block_order)); 

% assign subject numbers
sub_infos(:,sub) = 1:nsubs;
sub_infos(:,colour_assign) = datasample([1,2], nsubs, 'Replace', true);


for isub = 1:nsubs

    [~, ca_idxs, cb_idxs] = assign_target_locations(isub);

    % context a & b locations
    sub_infos(isub, ca_cols) = ca_idxs;
    sub_infos(isub, cb_cols) = cb_idxs;

end

% now add the counterbalancing of the exp blocks
sub_infos(:, exp_block_order) = repmat(all_blocks, expand_all_blocks, 1);

save('sub_infos', 'sub_infos')