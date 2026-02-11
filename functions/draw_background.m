function [] = draw_background(w, rect, xCenter, yCenter, col)
    % DRAW_BACKGROUND Draw the square background using the colour designated
    % for that trial. 
    % w = the window being drawn to
    % rect = the rectangle coordinates (base, unaligned to centre)
    % col = the colour of the rectangle (rgb)
    centeredRect = CenterRectOnPointd(rect, xCenter, yCenter);
    Screen('FillRect', w, col, centeredRect);   
end