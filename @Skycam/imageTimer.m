% Only works for DSLR!
% This function is used for debugging, it is used to determine how much
% time it takes from the moment of capture to when the image saves on the
% disk.
% There is no end condition to the loop, so to end the logging you should
% press Ctrl + C.

function F = imageTimer(F)

wd = pwd; % Save the current directory (to return later)
% Set the working directory, this is where images will be saved
cd(F.DataDir);
addpath(wd);

% Wait untill a new file is created (meaning the script is on)
filenum = length(dir('*.nef'));
while length(dir('*.nef')) <= filenum; end

while true
    tic % Start measuring time
    
    filenum = length(dir('*.nef'));
    % Wait untill the camera is idle again, and the new image is saved
    while length(dir('*.nef')) <= filenum; end
    
    waittime = toc; % Get the time it took to capture the image
    fprintf("\nNew image detected at: " + datestr(now) + "\nElapsed time: " + string(waittime) +" seconds\n")
end

cd(wd) % Return to the previus directory, cannot be reached
