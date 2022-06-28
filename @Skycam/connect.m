% The connect function is used to initiate the connection with the DSLR
% camera, as well as to check and connect the Arduino temperature sensor.
% When connectong, the camera will start the continuous capture.

function F = connect(F,Port)

% Gphoto will save the images to the current directory, so we change it to
% the desired image path:
wd = pwd; % Save the current directory (to return later)
% Check if the image path director exists, if not, create it
if ~exist(F.ImagePath, 'dir')
    mkdir(F.ImagePath);
end
cd(F.ImagePath);
addpath(wd);

% Try to connect the temperature sensor and log its temperatures
F.connectSensor
if F.found
    disp("Temperature data logger detected!")
    disp("Initial temperature: " + F.Temperature)
else
    disp("No temperature data logger detected. Temperature will not be monitored")
end

% Initiate the gphoto process, gphoto automatically detects the port if
% none is given
if ~exist('Port','var') || isempty(Port)
    F.gp = gphoto;
else
    F.gp = gphoto(string(Port));
end

pause(5)
% Check successful connection
if string(F.gp.status) == "IDLE" || string(F.gp.status) == "BUSY"
    fprintf("\nCamera connected successfully!\n\n")
else
    error("Could not find camera! Check connection")
end

% Set the exposure time to the closest available value
data = importdata("exptimes.txt"); % Import the exposure times table
[val,idx] = min(abs(data-F.ExpTime)); % Check what is the closest value
F.gp.set('bulb', 0) % Bulb has to be off to change exposure time
F.gp.set('shutterspeed', idx-1) % Set the shutter speed (exposure time) index is different than the table

% Set the delay between each capture
if ~exist('delay','var') || isempty(delay)
    delay = F.Delay;
end

% plot starts liveview. I have no idea why, but without plotting, the
% images wouldn't save (and everything gets stuck)
F.gp.plot

pause(2)

% Set the period (delay) and start continuous capture
period(F.gp, string(delay));
continuous(F.gp, 'on');

% Get the class' directory
classdir = erase(which('Skycam'), "/@Skycam/Skycam.m");
proc = "bash " + classdir + "/bin/checkfiles.sh"; % Formulate command
% Start the process and get process id
pid = process(convertStringsToChars(proc));
F.filecheck = pid;

cd(wd); % return to the previous directory
