%This script is to connect the Arduino data logger (if it exists)
%Optional parameters:
%'Port' - The port where the Arduino is connected, auto detect by deafult.
%Example input: "/dev/ttyUSB0"
%'Baud' - The baud rate (bits per second) of the communication, deafult is
%9600.

function F = connectSensor(F,Port,Baud)

F.Found = 0;

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
                F.SensorType = "Arduino";
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
else  
    %% Digitemp
    
    if ~exist('Port','var') || isempty(Port)
        ports = serialportlist("available")'; % Check Avalible ports
        for i = 1:length(ports)
            try
                [~, resp] = system(strcat("digitemp_DS9097 -i -s ", ports(i)));
                if string(resp).contains("Wrote .digitemprc")
                    F.Found = 1;
                    F.SensorType = "Digitemp";
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
    end
end

end