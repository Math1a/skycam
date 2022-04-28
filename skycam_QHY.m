% This script is using the QHY367 astronomical camera in order to survey
% the night sky.
% The camera will activate (TODO: maybe implement a power switch?) when the
% sun in 5 degrees below the horizon, and it will take a picture every
% minute, until the sun will be higher than 5 degrees again (the following
% morning)

% Get the sun's position
sun = celestial.SolarSys.get_sun;
sunalt = rad2deg(sun.Alt);

c = inst.QHYccd; % Maybe specify a port?
% Initate connection
if c. connect
    disp("Connected successfully!")
else
    error("Unsuccessful connection! Please check camera connection and try again.")
end
pause(5)

% In case you don't want the image on screen:
% c.classCommand('Display= []');

% Infinite loop that will take pictures at night, every minute
while true % Maybe add a way to interrupt loop?
    if sunalt < -5
        disp("Taking an image...   " + datestr(now))
        c.takeExposure(10) % TODO: exposure time?
    end
    pause (60)
    
    sun = celestial.SolarSys.get_sun;
    sunalt = rad2deg(sun.Alt);
end
