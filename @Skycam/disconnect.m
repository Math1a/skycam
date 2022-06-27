% The disconnect function is used to disconnect and clear all the serial
% ports, to ensure a smooth run next time.

function F = disconnect(F)

clear('F.TemperatureLogger'); % Free the Arduino serial port
F.gp.stop; % Stop the gphoto process
pause(3) % Give gphoto some time to shut down and save the last images
F.filecheck.stop; % Stop The organizer function

% Delete and clear the gphoto process, I am not sure if this is required, 
% but it seems to cause less bugs this way
F.gp.delete; 
clear('F.gp');

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