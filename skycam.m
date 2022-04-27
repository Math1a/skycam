%

% Set the working directory, this is where images will be saved
projectdir = "/home/ocs/skycam/";
dateformat = 'yyyy:mm:dd-HH:MM:SS';
waittime = 20;
cd(projectdir);

% Initiate connection with camera
p = gphoto;
pause(5)
if string(p.status) == "IDLE" || string(p.status) == "BUSY"
    fprintf("\nCamera connected successfully!\n\n") 
else
    error("Could not find camera! Check connection")
end

plot(p);

pause(5)

p.capture; % Capture an image
pause(waittime) % Give image time to save
% ! TODO: Implement a loop that checks when the camera is avalible again!
% Check newly captured image
filelist = dir('capt*');
[~,idx] = sort([filelist.datenum]);
newimg = filelist.name;

% Rename newly captured image to match date and time
movefile(projectdir + string(newimg), projectdir + "SkyImage_" + ... 
    datestr(now - waittime, dateformat) + ".nef");

p.stop
p.delete