function F = disconnect(F)

clear('F.TemperatureLogger');
F.filecheck.stop;
F.gp.stop;
pause(2)
F.gp.delete;
clear('F.gp');

try
    close Figure 1
catch err
    close all
end