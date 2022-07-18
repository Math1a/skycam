% This function is used to log the temperatures using digitemp_DS9097
% temperature sensor

function F = logTemperature(F)

if ~isempty(F.SensorType) && F.SensorType == "Digitemp"
    
    % Construct the filename
    filename = strcat(F.ImagePath, "TempLog_", datestr(now, 'yyyy-mm-dd_hh:MM:ss'), ".tsv");
    % Set the delay
    delay = 2;
    command = strcat("digitemp_DS9097 -q -t 0 -c .digitemprc -d ",...
        string(delay)," -n 3600 -o 2 -l ", filename);
    
    pid = process(convertStringsToChars(command)); % Run the command
    pid.silent; % Set in silent mode
    F.TemperatureLogger = pid; % save the process id
else
    error("'logTemperature' can only be used for Digitemp temperature sensors!")
end

end
