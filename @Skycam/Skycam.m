classdef Skycam < handle % obs.LAST_Handle
    
    properties
        ExpTime = 8 % Exposure time, in seconds
        Delay = 12 % Delay between each capture
    end
    
    properties(GetAccess = public, SetAccess = private)
        Temperature
        LastImage
        ImagePath = "/home/ocs/skycam/"
    end
    
    properties(Hidden)
        gp % The gphoto serial resource
        TemperatureLogger % The temperature logger serial resource
        InitialTemp
        found = 0
        dateformat = 'yyyy:mm:dd-HH:MM:SS'
    end
    
    methods
        % constructor and destructor
        function delete(F)
            clear(F.TemperatureLogger)
            F.gp.stop
            wait(1)
            F.gp.delete
        end
    end
    
    methods
        % getters and setters
        function d = get.LastImage(F)
            if exist('F.gp','var') || ~isempty('F.gp')
                d = F.gp.lastImageFile;
            end
        end
        
        function d = get.Temperature(F)
            if exist('F.TemperatureLogger','var') || ~isempty('F.TemperatureLogger')
                F.TemperatureLogger.flush
                d = F.TemperatureLogger.readline;
            end
        end
        
        function set.ExpTime(F, ExpTime)
            if ExpTime < 0
                error("Exposure time cannot be less than 0!")
            else
                % Import the exposure times switch
                data = importdata("exptimes.txt");
                % Check what is the closest one
                [val,idx] = min(abs(data-ExpTime));
                % Change the camera settings to match the closest one
                F.gp.set('bulb', 0)
                F.gp.set('shutterspeed', idx-1)
               
                % Set the class' value, this is merely an indicator
                F.ExpTime = ExpTime;
            end
        end
        
    end
end