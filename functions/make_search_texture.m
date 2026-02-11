function [tex, im_fname] = make_search_texture(srch_tgts, window)

% first, select a target image category
this_srch_categ = srch_tgts(randperm(length(srch_tgts), 1));
% Get all files and folders in the current directory
all_tgt_files = dir('tgts');
% Filter out hidden files (those starting with a dot)
all_tgt_files = all_tgt_files(arrayfun(@(x) x.name(1) ~= '.',...
    all_tgt_files));
tgt_cat_dir = all_tgt_files(this_srch_categ); % get the category for this
% trial
% get list of images from that directory
these_ims = dir(fullfile(tgt_cat_dir.folder, ...
    tgt_cat_dir.name));
% again, remove hidden files
these_ims = these_ims(arrayfun(@(x) x.name(1) ~= '.', ...
    these_ims));
% randomly select one
im_idx = randperm(length(these_ims), 1);
im_fname = fullfile(these_ims(im_idx).folder, ...
    these_ims(im_idx).name);
im = imread(im_fname);
tex = Screen('MakeTexture', window, im);

end