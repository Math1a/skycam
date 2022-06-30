function takeExposure(F,expTime)
% like startExposure+collectExposure, but the latter is called by a timer, 
%  which collects the image behind the scenes when expTime is past.
% The resulting image goes in QC.LastImage
    if exist('expTime','var')
        F.CameraRes.ExpTime=expTime;
    end

    % last image: empty it when starting, or really keep the last
    % one available till a new is there?
    % QC.LastImage=[];

    F.CameraRes.SequenceLength=1;
    F.CameraRes.startExposure(F.CameraRes.ExpTime)
    deltat=F.CameraRes.TimeStartDelta*86400; % TimeStartDelta set inside startExposure

    collector=timer('Name',sprintf('ImageCollector-%d',F.CameraRes.CameraNum),...
        'ExecutionMode','SingleShot','BusyMode','Queue',...
        'StartDelay',max(round(F.CameraRes.ExpTime-deltat,3),0),...
        'TimerFcn',@(~,~)collectExposure(F.CameraRes),...
        'StopFcn',@(mTimer,~)delete(mTimer));

    start(collector)

end
