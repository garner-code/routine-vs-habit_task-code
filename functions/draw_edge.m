function [] = draw_edge(w, rect, xCenter, yCenter, col, trialStart, context_on)
    % DRAW_EDGE Draw the square edging used to denote context for that
    % trial
    % w = the window being drawn to
    % rect = the rectangle coordinates (base, unaligned to centre)
    % col = the colour of the rectangle (rgb) when context cue is on
    % trialStart = when did the trial start?
    % context_on = how long should the cue be on for?
    trialStart = trialStart; % legacy issues
    context_on = context_on; % legacy issues
    this_col = col;
    centeredRect = CenterRectOnPointd(rect, xCenter, yCenter);
    Screen('FrameRect', w, this_col, centeredRect, 20);   
end