%%%% this script creates the matrix of target location/condition
%%%% assignments across participants
clear all

nsubs = 80;
% cols:
sub = 1;
ca_cols = 2:5;
cb_cols = 6:9;
colour_assign = 10;

sub_infos = zeros(nsubs, colour_assign); 

% assign subject numbers
sub_infos(:,sub) = 1:nsubs;
sub_infos(:,colour_assign) = repmat([1,2], 1, nsubs/2);
iplus = 1; % to allocate the next subject with same locations as sub isub

for isub = 1:2:(nsubs-1)

    [~, ca_idxs, cb_idxs] = assign_target_locations(isub);

    % context a & b locations
    sub_infos(isub, ca_cols) = ca_idxs;
    sub_infos(isub, cb_cols) = cb_idxs;
    sub_infos(isub+iplus, ca_cols) = ca_idxs;
    sub_infos(isub+iplus, cb_cols) = cb_idxs;
end

save('sub_infos', 'sub_infos')