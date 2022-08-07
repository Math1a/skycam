% This function is used to stop the continuous capture of images by the
% camera, regardless of its type. Without deleting the objects

function F = stop(F)
    
if F.CameraType == "DSLR"
    % Stop continuous capture
    continuous(F.CameraRes, 'off');
    pause(F.ExpTime)
    
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
elseif F.CameraType == "ASTRO"
    
else
    error("Invalid camera type!")
end

pause(F.Delay) % Let the last images save
if ~isempty(F.FileCheck) % Check if the property exists
    F.FileCheck.stop; % Stop The organizer/timer function
    F.FileCheck.delete;
    F.FileCheck = [];
end

F.Connected = 1; % Notify the class that the camera is no longer capturing

end
