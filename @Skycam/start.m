% This function is used to start the continuous capture of images by the
% camera, regardless of its type

function F = start(F)

if F.Connected == 0
    error("No camera connected! Use 'connect' function first!")
elseif F.Connected == 2
    error("Image capture already running!")
end

%% ASTRO
if F.CameraType == "ASTRO"
    
    % The timer will call a specific function every x seconds, in this case
    % it will capture an image every desired interval
    t = timer; % Create a timer object
    t. period = F.Delay; % Set the period of the timer
    t.TasksToExecute = 7200; % Maximun number of exposures
    t.ExecutionMode = 'fixedRate'; % Set execution mode
    t.TimerFcn = @(~,~)takeExposure(F); % The command that will execute
    start(t) % Start the timer
    
    F.FileCheck = t;
    % Don't ever forget to delete the timer!
    
elseif F.CameraType == "DSLR"
    %% DSLR
    
    wd = pwd; % Save the current directory (to return later)
    
    % Get the class' directory
    classdir = erase(which('Skycam'), "/@Skycam/Skycam.m");
    % Check if 'AstroPack' is present (LAST)
    if exist('ImagePath', 'class')
        % Create the data direcotry
        cd(F.DataDir)
        % Formulate command using class' directory
        proc = "bash " + classdir + "/bin/LASTcheckfiles.sh";
    else
        cd(F.ImagePath);
        % Formulate command using class' directory
        proc = "bash " + classdir + "/bin/checkfiles.sh";
    end
    
    addpath(wd);
    
    % Old way of getting exposure times: with text file
    % Set the exposure time to the closest available value
    %data = importdata(classdir + "/bin/exptimes.txt"); % Import the exposure times table
    
    [val,idx] = min(abs(F.ExpTimesData-F.ExpTime)); % Check what is the closest value
    F.CameraRes.set('bulb', 0) % Bulb has to be off to change exposure time
    F.CameraRes.set('shutterspeed', idx-1) % Set the shutter speed (exposure time) index is different than the table
    
    [val,idx] = min(abs(F.ExpTimesData-F.F_Number)); % Check what is the closest value
    F.CameraRes.set('f-number', idx-1) % Set the shutter speed (exposure time) index is different than the table
    
    %F.CameraRes.set('f_number', 0) % Set the f number to the lowest the camera is capable of
    %F.CameraRes.set('iso') % Set the ISO number
    F.CameraRes.set('autoiso', 0) % Set autoiso to on
    % Consider changing to a more general approach
    F.CameraRes.set('imagequality', 7) % Set image quality to RAW
    
    % plot starts liveview. I have no idea why, but without plotting, the
    % images wouldn't save (and everything gets stuck)
    F.CameraRes.plot
    
    pause(2)
    
    % Set the period (delay) and start continuous capture
    period(F.CameraRes, string(F.Delay));
    continuous(F.CameraRes, 'on');
    
    % Start the process and get process id
    pid = process(convertStringsToChars(proc));
    F.FileCheck = pid;
    
    cd(wd); % return to the previous directory
    
    if string(F.CameraRes.status) == "ERROR"
        F.disconnect
        error("Camera error! Please turn the camera off and on again!")
    end
else
    error("Invalid camera type!")
end

F.Connected = 2; % Notify the class that the camera is capturing

end
