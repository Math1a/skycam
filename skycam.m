% This script is using the Nikon D850 DSLR camera in order to survey the
% night sky.
% The camera will activate when the sun in 5 degrees below the horizon, and
% it will take a picture every minute, until the sun will be higher than 5
% degrees again (the following morning). These calculations are done with
% AstroPack.
% This script uses a Matlab interface for gphoto2 by E. Farhi. This
% interface creates a window that updates with a preview image every
% second.
% The images will we saved in their raw format (.nef), as:
% "SkyImage_yyyy:mm:dd-HH:MM:SS" in /home/ocs/skycam/ (subject to change).

% Setup
% Set the working directory, this is where images will be saved
projectdir = "/home/ocs/skycam/";
dateformat = 'yyyy:mm:dd-HH:MM:SS';
cd(projectdir);
addpath('/home/ocs/matlab/skycam/')
addpath('/home/ocs/')

sun = celestial.SolarSys.get_sun;
%sunalt = rad2deg(sun.Alt);
sunalt = -10;

% Initiate connection with camera
p = gphoto;
pause(5)
if string(p.status) == "IDLE" || string(p.status) == "BUSY"
    fprintf("\nCamera connected successfully!\n\n")
else
    error("Could not find camera! Check connection")
end

plot(p);

pause(5)

while sunalt < -5 % Maybe add a way to break?
    % This part of the loop will only activate at night (when the sun is 5
    % deg. below the horizon)
    if sunalt < -5
        tic % Start measiring time
        if ~isempty(dir('capt0000.nef'))
            movefile('capt0000.nef', projectdir + "OldImage_" + ...
                datestr(now, dateformat) + ".nef");
        end
        filenum = length(dir('capt*'));
        p.capture; % Capture an image
        % Wait untill the camera is idle again, and the new image is saved
        while length(dir('capt*')) <= filenum || isempty(p.lastImageFile); end
        waittime = toc; % Get the time it took to capture the image
        
        % Rename newly captured image to match date and time
        % Unknown errors can occur, in that case, try again
        try
            filename = projectdir + "SkyImage_" +  datestr(now - (waittime/86400), dateformat) + ".nef";
            movefile(string(p.lastImageFile), filename)
        catch err
            pause(3)
            movefile(string(p.lastImageFile), filename)
        end
        disp("New image " + filename + " saved successfully!")
    end
    if waittime < 60
        pause(60 - waittime)
    end
    
    % Get an update on the sun's position
    %sun = celestial.SolarSys.get_sun;
    %sunalt = rad2deg(sun.Alt);
    sunalt = sunalt + 1;
end

p.stop
p.delete