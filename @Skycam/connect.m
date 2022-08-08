% The connect function is used to initiate the connection with the
% camers, as well as to check and connect the Arduino temperature sensor.

function F = connect(F,Port)
%% Setup
% Try to connect the temperature sensor and log its temperatures
% F.connectSensor
% if F.Found
%     disp("Temperature data logger detected!")
%     disp("Initial temperature: " + F.Temperature)
% else
%     disp("No temperature data logger detected. Temperature will not be monitored")
% end

% Gphoto will save the images to the current directory, so we change it to
% the desired image path:
wd = pwd; % Save the current directory (to return later)
% Check if the image path directory exists, if not, create it
if ~exist(F.ImagePath, 'dir')
    mkdir(F.ImagePath);
end

addpath(wd);

if F.Connected ~= 0
    error("Camera is already connected!")
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
    
elseif F.CameraType == "DSLR"
    %% DSLR
    % Check if 'AstroPack' is present (LAST)
    if exist('ImagePath', 'class')
        % Create the data direcotry
        F.DataDir = strcat(F.ImagePath,datestr(now, '/yyyy/mm/dd'),'/raw');
        mkdir(F.DataDir)
        cd(F.DataDir)
    else
        cd(F.ImagePath);
    end
    
    % New way of getting the exposure times, ask the camera, only works
    % when not connected
    [result1, exp] = system("gphoto2 --get-config=shutterspeed");
    [result2, fnum] = system("gphoto2 --get-config=f-number");
    
    if result1 ~= 0 && result2 ~= 0
        cd(wd) % return to the previous directory
        error("Error communicating with camera! Check if busy")
    end
    
    F.ExpTimesData = parsedata(exp);
    F.FNumData = parsedata(fnum);
    
    % Initiate the gphoto process, gphoto automatically detects the port if
    % none is given
    if ~exist('Port','var') || isempty(Port)
        F.CameraRes = gphoto;
    else
        F.CameraRes = gphoto(string(Port));
    end
    
    pause(5)
    loops = 0;
    while string(F.CameraRes.status) == "BUSY"
        % Wait until camera is connected and ready
        pause(0.1)
        loops = loops + 1;
        % Timeout condition
        if loops > 6000
            break
        end
    end
    
    
    % Check successful connection
    if string(F.CameraRes.status) == "IDLE"
        fprintf("\nCamera connected successfully!\n\n")
    else
        cd(wd) % return to the previous directory
        F.disconnect
        error("Error connecting to the camera, check connection or try restarting")
    end
    
    cd(wd); % return to the previous directory
else
    error("Invalid camera type!")
end

F.Connected = 1; % Notify the class that a camera is connected

end

function dat = parsedata(raw)
out = splitlines(raw);
choices = string.empty;
for s = 1:length(out)
    str = string(out{s});
    if contains(str,"Choice:")
        str = erase(str, "Choice: ");
        str = erase(str, "s");
        str = erase(str, "f/");
        choices(end+1) = str;
    end
end
dat = [];
for s = 1:length(choices)
    num = erase(choices(s), strcat(string(s-1) + ' '));
    dat(end+1) = num;
end
end
