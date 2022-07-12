% Skycam is a tool for using DSLR cameras or astronomical cameras in order
% to survey the night sky.
% Skycam will take pictures with a given exposure time and delay until
% requested to stop. It can handle continuous captures of hundreds of images
% for hours at a time.
% Currently the class structure supports only DSLR cameras, is uses gphoto
% (and matlab-gphoto) to capture images
% To use the class: First create a Skycam object, then use the connect
% function - it's that simple.
% Optionally you can connect an Arduino with a temperature sensor, that
% prints to the serial port its raw temperature values. The function
% connectSensor will detect it and display it and display it under the
% class.
% Don't forget to disconnect using the disconnect function! Incorrect
% shutdown can cause the camera to get stuck.
% If the camera does get stuck, restart it (physically).

classdef Skycam < obs.LAST_Handle
    
    properties
        ExpTime = 8         % Exposure time, in seconds
        Delay = 12          % Delay between each capture, only for DSLR
        CameraType = "DSLR" % The type of camera used (DSLR/ASTRO)
        % The directory where the images will be saved (and the bash script will run)
        % Only for DSLR!
        ImagePath = "/home/ocs/skycam/"
    end
    
    properties(GetAccess = public, SetAccess = private)
        Temperature     % Debug: the reading of the Arduino temperature sensor
        CameraTemp      % The temperature of the camera, only for astronimical cameras that support it
        CameraRes       % The gphoto serial resource
    end
    
    properties(Hidden)
        TemperatureLogger   % The temperature logger serial resource
        DataDir             % The directory where th gphoto process will run
        FileCheck           % DSLR: The bash script procces that checks for new files OR ASTRO: The timer object that calls TakeExposure
        ExpTimesData        % DSLR: The possible exposure times data table
        InitialTemp         % Debug: The initial temperature is recorded to avoid overheating
        Found = 0           % Whether or not an arduino temperature sensor is connected
    end
    
    methods
        % constructor and destructor
        
        % What happens when the class is deleted or cleared
        function delete(F)
            F.disconnect
        end
    end
    
    methods
        % getters and setters
        
        % Get the temperature whenever it is requested
        function d = get.Temperature(F)
            if exist('F.TemperatureLogger','var') || ~isempty('F.TemperatureLogger')
                F.TemperatureLogger.flush % Clear the serial port
                d = F.TemperatureLogger.readline; % Read the last line from the serial port
            end
        end
        
        function temp = get.CameraTemp(F)
            if F.CameraType == "ASTRO"
                % Get stats about the temperature to avoid overheating
                temp = F.CameraRes.Temperature;
                if temp >= 35
                    warning("Camera is overheating!")
                    F.disconnect
                end
            end
        end
        
        % Set the camera types, only two values are allowed: "DSLR" and "ASTRO"
        function set.CameraType(F, CameraType)
            if ~isempty(F.FileCheck) % Check if the camera is already running
                error("Cannot change mode while camera is running!" + ...
                    newline + "Use disconnect or create a new Skycam object")
            end
            
            % A switch case for many possible inputs, but only two are
            % possible (DSLR and ASTRO)
            switch lower(CameraType)
                case 'dslr'
                    F.CameraType = "DSLR";
                case 'nikon'
                    F.CameraType = "DSLR";
                case 'canon'
                    F.CameraType = "DSLR";
                case 'astro'
                    F.CameraType = "ASTRO";
                case 'astronomical'
                    F.CameraType = "ASTRO";
                case 'qhy'
                    F.CameraType = "ASTRO";
                case 'qhyccd'
                    F.CameraType = "ASTRO";
                case 'qhy367'
                    F.CameraType = "ASTRO";
                case 'qhy367c'
                    F.CameraType = "ASTRO";
                otherwise
                    error("Possible camera types are DSLR or ASTRO!")
            end
        end
        
        function set.ExpTime(F, ExpTime)
            if ~isempty(F.FileCheck) % Check if the camera is already running
                error("Cannot change exposure time while camera is running!" + ...
                    newline + "Use disconnect and then change the exposure time")
            elseif ExpTime < 0
                error("Exposure time cannot be less than 0!")
            elseif ExpTime > F.Delay
                error("Exposure time cannot be greater than the delay")
            elseif F.CameraType == "DSLR"
                % Old way of comparing (with text list)
                % Get the class' directory
                %classdir = erase(which('Skycam'), "/@Skycam/Skycam.m");
                % Set the exposure time to the closest available value
                %data = importdata(classdir + "/bin/exptimes.txt"); % Import the exposure times table
                
                % New way, more reliable as it asks the camera every time,
                % but it is slower and also can't check while the camera is
                % connected
                [result, raw] = system("gphoto2 --get-config=shutterspeed");
                
                if result ~= 0
                    error("Error communicating with camera! Check if busy")
                end
                out = splitlines(raw);
                choices = string.empty;
                for s = 1:length(out)
                    str = string(out{s});
                    if contains(str,"Choice:")
                        str = erase(str, "Choice: ");
                        str = erase(str, "s");
                        choices(end+1) = str;
                    end
                end
                data = [];
                for s = 1:length(choices)
                    num = erase(choices(s), strcat(string(s-1) + ' '));
                    data(end+1) = num;
                end
                % Check what is the closest value
                [val,idx] = min(abs(data-ExpTime));
                % Set the class' value as an indicator
                F.ExpTime = data(idx);
            elseif F.CameraType == "ASTRO"
                F.ExpTime = ExpTime;
            else
                error("Invalid camera type!")
            end
        end
        
        function set.Delay(F, Delay)
            if Delay < F.ExpTime
                error("Delay cannot be smaller than exposure time")
            end
            F.Delay = Delay;
        end
    end
end
