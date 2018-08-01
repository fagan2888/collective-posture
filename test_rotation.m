

figure, hold on
subplot(1,2,1), hold on

other_x = vectorise(linspace(0,10,100));
other_y = 13*other_x + randn(100,1)*.1;

plot(other_x,other_y,'ko')

% define rotation matrix
R = @(theta) [cos(theta) -sin(theta); sin(theta) cos(theta)];

theta = atan2(other_y(end),other_x(end));

% coordinate transform -- rotate axes
temp = R(-theta)*[other_x other_y]';
other_x = temp(1,:);
other_y = temp(2,:);

plot(other_x,other_y,'ro')

axis equal