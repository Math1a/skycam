%Used to disconnect and kill the Digitemp temperature sensor process and
%stop writing to the log file.

function F = stopLogging(F)

if F.Found == 1 && F.SensorType == "Digitemp"
    F.TemperatureLogger.kill
    F.Found = 0;
end

end
