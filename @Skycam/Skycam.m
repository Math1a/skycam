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

classdef Skycam < handle % obs.LAST_Handle
    
    properties
        ExpTime = 8         % Exposure time, in seconds
        Delay = 12          % Delay between each capture
        CameraType = "DSLR" % The typer of camera used (DSLR/ASTRO)
        % The directory where the images will be saved (and the bash script will run)
        % Only for DSLR!
        ImagePath = "/home/ocs/skycam/"
    end
    
    properties(GetAccess = public, SetAccess = private)
        Temperature                     % Debug: the reading of the Arduino temperature sensor
        CameraRes           % The gphoto serial resource
    end
    
    properties(Hidden)
        TemperatureLogger   % The temperature logger serial resource
        FileCheck           % The bash script procces that checks for new files
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
        
        % Set the camera types, only two values are allowed: "DSLR" and "ASTRO"
        function set.CameraType(F, CameraType)
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
        
        % Currently unused as the exposure time cannot be changed during
        % captures
        function set.ExpTime(F, ExpTime)
            if ExpTime < 0
                error("Exposure time cannot be less than 0!")
            elseif F.CameraType == "DSLR"
                % Import the exposure times table
                data = importdata("exptimes.txt");
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
        
    end
end
