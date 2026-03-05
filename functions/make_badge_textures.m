function [badge_textures] = make_badge_textures(window, badge_names)

badge_files = dir('Badges/');

for ibadge = 1:length(badge_names)

    badge_fname = fullfile(badge_files(1).folder, ...
        sprintf('%s.png', badge_names{ibadge}));
    badge = imread(badge_fname);
    badge_textures(ibadge) = Screen('MakeTexture', window, badge);
end
end