% The disconnect function is used to disconnect and clear all the serial
% ports, to ensure a smooth run next time.

function F = disconnect(F)

% If statement for different camera types, the two different cameras have
% different connection and disconnection processes.
if F.CameraType == "ASTRO"
    F.CameraRes.disconnect; % Disconnect the camera
    pause(3) % Give the camera some time to shut down and save the last images
    F.CameraRes.delete; % Delete the camera object
    F.CameraRes = [];
    
elseif F.CameraType == "DSLR"
    
    F.CameraRes.stop; % Stop the gphoto process
    pause(3) % Give gphoto some time to shut down and save the last images
    
    % Delete and clear the gphoto process, I am not sure if this is required,
    % but it seems to cause less bugs this way
    F.CameraRes.delete;
    
    % Try to close the plot window, if it stays open, gphoto might get stuck
    % next time
    try
        close Figure 1
    catch err
        % Closing all plot windows might be a little too destructive, 0n the
        % other hand not closing the liveview window will almost certainly
        % cause a bug if it stays open next time
        %close all
    end
else
    error("Invalid camera type!")
end

if ~isempty(F.SensorType) && F.SensorType == "Digitemp"
    F.stopLogging
else % Arduino
    clear('F.TemperatureLogger'); % Free the Arduino serial port
end

if ~isempty(F.FileCheck) % Check if the property exists
    F.FileCheck.stop; % Stop The organizer function
    F.FileCheck.delete;
    F.FileCheck = [];
end

F.Connected = 0; % Notify the class that there is no camera connected

end
