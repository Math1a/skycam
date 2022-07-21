%This script is to connect the Arduino data logger (if it exists)
%Optional parameters:
%'Port' - The port where the Arduino is connected, auto detect by deafult.
%Example input: "/dev/ttyUSB0"
%'Baud' - The baud rate (bits per second) of the communication, deafult is
%9600.

function F = connectSensor(F,Port,Baud)

F.Found = 0;

if F.SensorType == "Arduino"
    %% Arduino
    
    if ~exist('Baud','var') || isempty(Baud)
        Baud = 9600;
    end
    
    if ~exist('Port','var') || isempty(Port)
        ports = serialportlist("available")'; % Check Avalible ports
        for i = 1:length(ports)
            try
                S = serialport(ports(i),Baud); % Set the port and the baud rate
                S.flush
                resp = S.readline;
                if string(resp).contains(".")
                    F.Found = 1;
                    F.TemperatureLogger = S;
                    break
                else
                    clear S
                end
            catch
                continue
            end
        end
    end
    
    if F.Found
        F.TemperatureLogger.flush
        F.InitialTemp = F.TemperatureLogger.readline;
    end
    
elseif F.SensorType == "Digitemp"
    %% DigiTemp
    
    if ~exist('Port','var') || isempty(Port)
        ports = serialportlist("available")'; % Check Avalible ports
        for i = 1:length(ports)
            try
                [~, resp] = system(strcat("digitemp_DS9097 -i -s ", ports(i)));
                if string(resp).contains("Wrote .digitemprc")
                    F.Found = 1;
                    break
                end
            catch
                continue
            end
        end
    end
    
    if F.Found
        [~, resp] = system("digitemp_DS9097 -q -t 0 -c .digitemprc");
        index = strfind(resp, "C:");
        F.InitialTemp = resp(index + 3: index + 7);
        
        % Construct the filename
        filename = strcat(F.ImagePath, "TempLog_", datestr(now, 'yyyy-mm-dd_hh:MM:ss'), ".tsv");
        % Set the delay
        delay = 2;
        command = strcat("digitemp_DS9097 -q -t 0 -c .digitemprc -d ",...
            string(delay)," -n 0 -o 2 -l ", filename);
        
        pid = process(convertStringsToChars(command)); % Run the command
        pid.silent; % Set in silent mode
        F.TemperatureLogger = pid; % save the process id
    end
else
    error("Invalid sensor type! Possible types are: 'Arduino' or 'Digitemp'")
end

end