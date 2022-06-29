%This script is to connect the Arduino data logger (if it exists)
%Optional parameters:
%'Port' - The port where the Arduino is connected, auto detect by deafult.
%Example input: "/dev/ttyUSB0"
%'Baud' - The baud rate (bits per second) of the communication, deafult is
%9600.
%
clear S
found = 0;

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
            if resp.contains(".")
                found = 1;
            else
                clear S
            end
        catch
            continue
        end
    end
else
    S = serialport(Port,Baud); % Set the port and the baud rate
    found = 1;
end

if found
    S.flush
    resp = S.readline;
end