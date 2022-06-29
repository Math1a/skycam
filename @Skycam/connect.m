% The connect function is used to initiate the connection with the
% camers, as well as to check and connect the Arduino temperature sensor.
% When connectong, the camera will start the continuous capture.

function F = connect(F,Port)
%% Temperature
% Try to connect the temperature sensor and log its temperatures
F.connectSensor
if F.Found
    disp("Temperature data logger detected!")
    disp("Initial temperature: " + F.Temperature)
else
    disp("No temperature data logger detected. Temperature will not be monitored")
end

% If statement for different camera types, the two different cameras have
% different connection and disconnection processes.
if F.CameraType == "ASTRO"
    %% ASTRO
    % Create the camera object (no port specified)
    C = inst.QHYccd;
    
    if C. connect
        disp("Connected successfully!")
    else
        error("Unsuccessful connection! Please check camera connection and try again.")
    end
    pause(5)
    
    % In case you don't want the image on screen:
    C.classCommand('Display= []');
    % Turn off the cooling fan
    C.coolingOff
    
    F.CameraRes = C; % Save the camera object in the class
    
    % INCOMPLETE: Astronomical cameras still don't capture images! need to
    % figure out a way of taking images wthout blocking Matlab with a loop
    % Maybe C.takeExposureSeq? Or use UnitCS?
    
    % Infinite loop that will take pictures at night, every minute
    while true % Maybe add a way to interrupt loop?
        tic() % Start measuring time
        disp("Taking an image...   " + datestr(now))
        C.takeExposure(F.ExpTime) % Take one image with an exposure time of ExpTime
        wait = toc(); % Stop measuring time
        pause (F.Delay - wait) % Wait until the next capture (if needed)
        
        % Get stats about the temperature to avoid overheating
        disp("Temperature: " + C.Temperature)
        if C.Temperature >= 35
            C.disconnect
            error("Temperature too high!")
        end
    end
    
elseif F.CameraType == "DSLR"
    %% DSLR
    % Gphoto will save the images to the current directory, so we change it to
    % the desired image path:
    wd = pwd; % Save the current directory (to return later)
    % Check if the image path director exists, if not, create it
    if ~exist(F.ImagePath, 'dir')
        mkdir(F.ImagePath);
    end
    cd(F.ImagePath);
    addpath(wd);
    
    % Initiate the gphoto process, gphoto automatically detects the port if
    % none is given
    if ~exist('Port','var') || isempty(Port)
        F.CameraRes = gphoto;
    else
        F.CameraRes = gphoto(string(Port));
    end
    
    pause(5)
    % Check successful connection
    if string(F.CameraRes.status) == "IDLE" || string(F.CameraRes.status) == "BUSY"
        fprintf("\nCamera connected successfully!\n\n")
    else
        error("Could not find camera! Check connection")
    end
    
    % Get the class' directory
    classdir = erase(which('Skycam'), "/@Skycam/Skycam.m");
    % Set the exposure time to the closest available value
    data = importdata(classdir + "/bin/exptimes.txt"); % Import the exposure times table
    [val,idx] = min(abs(data-F.ExpTime)); % Check what is the closest value
    F.CameraRes.set('bulb', 0) % Bulb has to be off to change exposure time
    F.CameraRes.set('shutterspeed', idx-1) % Set the shutter speed (exposure time) index is different than the table
    
    % Set the delay between each capture
    if ~exist('delay','var') || isempty(delay)
        delay = F.Delay;
    end
    
    % plot starts liveview. I have no idea why, but without plotting, the
    % images wouldn't save (and everything gets stuck)
    F.CameraRes.plot
    
    pause(2)
    
    % Set the period (delay) and start continuous capture
    period(F.CameraRes, string(delay));
    continuous(F.CameraRes, 'on');
    
    % Formulate command using class' directory
    proc = "bash " + classdir + "/bin/checkfiles.sh";
    % Start the process and get process id
    pid = process(convertStringsToChars(proc));
    F.FileCheck = pid;
    
    cd(wd); % return to the previous directory
    
else
    error("Invalid camera type!")
end

end
