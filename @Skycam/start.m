function F = start(F,delay)

if ~exist('delay','var') || isempty(delay)
    delay = F.Delay;
end

projectdir = F.ImagePath;

F.gp.preview

period(F.gp, string(delay));
continuous(F.gp, 'on');

loop = 0;
trylater = [];
period(F.gp, string(delay));
continuous(F.gp, 'on');

while true % Maybe add a way to break?
    disp("Taking new image at " + datestr(now))
    tic % Start measuring time
    lastImageFile = strcat("capt" + sprintf('%04d',loop) + ".nef");
    
    if ~isempty(dir(lastImageFile))
        movefile(lastImageFile, projectdir + "OldImage_" + ...
            datestr(now, F.dateformat) + ".nef");
    end
    filenum = length(dir('capt*'));
    % Wait untill the camera is idle again, and the new image is saved
    while length(dir('capt*')) <= filenum; end
    
    % Rename newly captured image to match date and time
    % Unknown errors can occur, in that case, try again
    waittime = toc; % Get the time it took to capture the image
    if ~isempty(trylater)
        try
            movefile(trylater(1),trylater(2))
        catch
            warning(trylater(1) + " could not be renamed to " + trylater(2))
        end
        trylater = [];
    end
    try
        filename = projectdir + "SkyImage_" +  datestr(now - (waittime/86400), dateformat) + ".nef";
        movefile(string(lastImageFile), filename)
    catch err
        trylater = [string(lastImageFile), filename];
    end
    disp("New image " + filename + " saved successfully!")
    disp("Elapsed time: " + string(waittime) +" seconds")
    
    if F.found && str2double(F.InitialTemp) + 5 < str2double(F.Temperature)
        F.gp.stop
        F.gp.delete
        error("Temperature too high!!! Let the camera cool down!")
    end
    
    loop = loop + 1;
end

end