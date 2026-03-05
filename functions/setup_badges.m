function [badge_textures, badgeRects] = setup_badges(window, screenXpixels, ...
    screenYpixels, mm, pix_per_mm, badge_names)

% make badge textures
badge_textures = make_badge_textures(window, badge_names);
% define badge rects. I want 4 rects equally spaced across the 
% top quarter of the screen
badge_base_pix = mm*pix_per_mm;
badge_base_rect = [0 0 badge_base_pix badge_base_pix];
badge_rect_y = screenYpixels*.25;
badge_rects_x = [screenXpixels*.2, screenXpixels*.4,...
                  screenXpixels*.6, screenXpixels*.8];
for count_badges = 1:length(badge_rects_x)
    badgeRects(:, count_badges) = CenterRectOnPointd(badge_base_rect, ...
        badge_rects_x(count_badges), badge_rect_y);
end

end