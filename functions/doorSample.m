function doorDist = doorSample(xPos, yPos, x, y)

% this function takes the coordinates x and y, and checks the distance from
% the centre of each door

doorDist = sqrt((xPos - x).^ 2 + (yPos - y).^ 2);

end