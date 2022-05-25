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
exptime = 8; % Exposure time, in seconds
delay = 10; % The delay between each image, in seconds

% Debug: Check if the temperature logger is connected (Arduino)
connectSensor
if found
    disp("Temperature data logger detected!")
    initialTemp = string(resp);
    disp("Initial temperature: " + initialTemp)
else
    disp("No temperature data logger detected. Temperature will not be monitored")
end

% Set the working directory, this is where images will be saved
projectdir = "/home/ocs/skycam/";
dateformat = 'yyyy:mm:dd-HH:MM:SS';
cd(projectdir);
addpath('/home/ocs/matlab/skycam/')
addpath('/home/ocs/')

% Get the sun's position
%sun = celestial.SolarSys.get_sun;
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

% Change exposure time, there is a list of possible values, the script will
% automatically choose the closest one to the one selected in the beginning
data = importdata("exptimes.txt");
[val,idx] = min(abs(data-exptime));
disp("Setting exposure time to closest available value:")
p.set('bulb', 0)
p.set('shutterspeed', idx-1)

p.preview

loop = 0;
trylater = [];
period(p, string(delay));
continuous(p, 'on');
while sunalt < -5 % Maybe add a way to break?
    % This part of the loop will only activate at night (when the sun is 5
    % deg. below the horizon)
    if sunalt < -5
        disp("Taking new image at " + datestr(now))
        tic % Start measuring time
        lastImageFile = strcat("capt" + sprintf('%04d',loop) + ".nef");
        % Incomplete: Move old images out of the way, so they won't
        % interfere with the new ones
        if ~isempty(dir(lastImageFile))
            movefile(lastImageFile, projectdir + "OldImage_" + ...
                datestr(now, dateformat) + ".nef");
        end
        filenum = length(dir('capt*'));
        % Wait untill the camera is idle again, and the new image is saved
        while length(dir('capt*')) <= filenum; end
        
        % Rename newly captured image to match date and time
        % Unknown errors can occur, in that case, try again
        waittime = toc; % Get the time it took to capture the image
        if ~isempty(trylater)
            try
                movefile(trylater(1),trylater(2))
            catch
                warning(trylater(1) + " could not be renamed to " + trylater(2))
            end
            trylater = [];
        end
        try
            filename = projectdir + "SkyImage_" +  datestr(now - (waittime/86400), dateformat) + ".nef";
            movefile(string(lastImageFile), filename)
        catch err
            trylater = [string(lastImageFile), filename];
        end
        disp("New image " + filename + " saved successfully!")
        disp("Elapsed time: " + string(waittime) +" seconds")
        if found
            S.flush
            resp = S.readline;
            disp("Temperature: " + string(resp))
        end
        loop = loop + 1;
    end
    if waittime < delay
        pause(delay - waittime)
    end
    
    if found && str2double(initialTemp) + 5 < str2double(resp)
        p.stop
        p.delete
        error("Temperature too high!!! Let the camera cool down!")
    end
    
    % Get an update on the sun's position
    %sun = celestial.SolarSys.get_sun;
    %sunalt = rad2deg(sun.Alt);
    %sunalt = sunalt + 1;
end

p.stop
p.delete