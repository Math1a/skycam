function F = connect(F,Port)

F.connectSensor
if F.found
    disp("Temperature data logger detected!")
    disp("Initial temperature: " + F.Temperature)
else
    disp("No temperature data logger detected. Temperature will not be monitored")
end

if ~exist('Port','var') || isempty(Port)
    F.gp = gphoto;
else
    F.gp = gphoto(string(Port));
end

pause(5)
if string(F.gp.status) == "IDLE" || string(F.gp.status) == "BUSY"
    fprintf("\nCamera connected successfully!\n\n")
else
    error("Could not find camera! Check connection")
end

data = importdata("exptimes.txt");
[val,idx] = min(abs(data-F.ExpTime));
F.gp.set('bulb', 0)
F.gp.set('shutterspeed', idx-1)

end