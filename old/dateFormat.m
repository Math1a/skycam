IP = ImagePath;
IP.ProjName = 'LAST.dslr1.in';
IP.Time = datestr(now,'yyyy-mm-ddThh:MM:SS.FFF');
IP.Filter        = 'clear';
IP.FieldID    = '';
IP.Counter  = %d
IP.CCDID   = '';
IP.CropID   = '';
IP.Type      = 'sci';
IP.Level     = 'raw';
IP.BasePath = '/home/ocs';
IP.DataDir = 'skycam';
IP.FileType = 'nef';

%IP.genFile
IP.genFull
%IP.genPath