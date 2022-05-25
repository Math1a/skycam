function F = disconnect(F)

clear('F.TemperatureLogger')
F.gp.stop
pause(2)
F.gp.delete
clear('F.gp')

end