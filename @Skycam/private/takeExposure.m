% Take exposure with astronomical cameras, called by the timer
function takeExposure(F)
    if ~isempty(F.FileCheck) && F.CameraType == "ASTRO"
        F.CameraRes.takeExposure(F.ExpTime);
    end
end