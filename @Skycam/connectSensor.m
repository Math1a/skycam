function F = connectSensor(F,Port,Baud)
%This script is to connect the Arduino data logger (if it exists)
%Optional parameters:
%'Port' - The port where the Arduino is connected, auto detect by deafult.
%Example input: "/dev/ttyUSB0"
%'Baud' - The baud rate (bits per second) of the communication, deafult is
%9600.

F.found = 0;

if ~exist('Baud','var') || isempty(Baud)
    Baud = 9600;
end

if ~exist('Port','var') || isempty(Port)
    ports = serialportlist("available")'; % Check Avalible ports
    for i = 1:length(ports)
        try
            F.TemperatureLogger = serialport(ports(i),Baud); % Set the port and the baud rate
            F.TemperatureLogger.flush
            resp = F.TemperatureLogger.readline;
            if resp.contains(".")
                F.found = 1;
            else
                clear S
            end
        catch
            continue
        end
    end
else
    F.TemperatureLogger = serialport(Port,Baud); % Set the port and the baud rate
    F.found = 1;
end

F.TemperatureLogger.flush
F.InitialTemp = F.TemperatureLogger.readline;