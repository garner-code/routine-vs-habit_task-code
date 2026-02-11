function [doorRects, squareXpos, squareYpos] = define_door_rects_v2(backRect, xCenter, yCenter, doorPix)
% function to draw 12 doors on the background square provided in backRect
% will work if backRect is placed in the centre by draw_background.m
% v2 makes a new rect within which to set the doors, rather than using the
% background rect as a basis for drawing
n_doors = 4;
% get coordinates of background Rect
scale = .9;
doorBaseRect = backRect * scale;
centeredDoorBaseRect = CenterRectOnPointd(doorBaseRect, xCenter, yCenter);
xPix = (centeredDoorBaseRect(3) - centeredDoorBaseRect(1)); % get the number of x pixels in the space for the doors
yPix = (centeredDoorBaseRect(4) - centeredDoorBaseRect(2));

squareXpos = centeredDoorBaseRect(1) + [xPix*0.125, xPix*0.375, xPix*0.625, xPix*.875];
squareYpos = centeredDoorBaseRect(2) + [yPix*0.125, yPix*0.375, yPix*0.625, yPix*.875];
doorCoords = combvec(squareYpos, squareXpos); 
doorCoords = [doorCoords(2,:); doorCoords(1,:)];
doorBase = [0 0 doorPix, doorPix];

% make rectangle coordinates
doorRects = nan(4,n_doors^2);

for countDoors = 1:n_doors^2
    doorRects(:, countDoors) = CenterRectOnPointd(doorBase, doorCoords(1, countDoors), doorCoords(2, countDoors));
end

end