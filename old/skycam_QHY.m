% This script is using the QHY367 astronomical camera in order to survey
% the night sky.
% The camera will activate (TODO: maybe implement a power switch?) when the
% sun in 5 degrees below the horizon, and it will take a picture every
% minute, until the sun will be higher than 5 degrees again (the following
% morning)

% Get the sun's position
sun = celestial.SolarSys.get_sun;
%sunalt = rad2deg(sun.Alt);
sunalt = -10;

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
% Turn off the cooling fan
c.coolingOff

% Infinite loop that will take pictures at night, every minute
while sunalt < -5 % Maybe add a way to interrupt loop?
    tic()
    disp("Taking an image...   " + datestr(now))
    c.takeExposure(10) % TODO: exposure time?
    wait = toc();
    pause (60 - wait)
    
    disp("Temperature: " + c.Temperature)
    if c.Temperature >= 35
        c.disconnect
        error("Temperature too high!")
    end
    
    sun = celestial.SolarSys.get_sun;
    %sunalt = rad2deg(sun.Alt);
    sunalt = sunalt + 1;
end
