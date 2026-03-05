function draw_badges(window, unlocked, badge_rects, badge_tex)
% unlocked is a vector of 0s and 1s which indicate which
% badges should be unlocked (or not)

alphas = zeros(1, length(badge_tex));
if sum(unlocked) % if any are unlocked
    alphas(find(unlocked)) = 1;
end
Screen('DrawTextures', window, badge_tex, [], badge_rects, [], ...
    [], alphas);
Screen('FrameRect', window, [255, 255, 255], badge_rects, 10);

end