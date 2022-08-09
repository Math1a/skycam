# Skycam

Skycam is a tool for using DSLR cameras or astronomical cameras in order to survey the night sky

### Dependencies:

System dependencies: 
- [gphoto2 (libgphoto2)](http://www.gphoto.org/)

For debugging purposes: 
- [gtkam](http://www.gphoto.org/proj/gtkam/) - A GUI for DSLR cameras that uses gphoto2.
- [Geqqie](https://www.geeqie.org/) - A lightweight image viewer that handles raw (NEF) files, recommended for image viewing.
- [Digitemp_DS9097](https://manpages.ubuntu.com/manpages/bionic/man1/digitemp.1.html) - The USB temperature sensor used for the logging.

Matlab dependencies:
- [matlab-gphoto](https://gitlab.com/astrophotography/matlab-gphoto/)
- [matlab process](https://github.com/farhi/matlab-process)

Astronomical cameras: 
- [LAST_QHYccd](https://github.com/EastEriq/LAST_QHYccd)
- [AstroPack](https://github.com/EranOfek/AstroPack/tree/dev1)

#### Auto installation:

Clone this repository to the desired location, then run "install.sh" to install the dependencies.
```bash
sudo bash install.sh
```
---

# Camera Matlab use:

Using a DSLR camera or an astronomical camera is pretty similar, they both use the same class, properties and methods.

**Skycam is written as a class in Matlab, first, we will need to create a Skycam object (in this case, P):**
```matlab
P = Skycam
```
*Next, we can assign the properties that we would like to change:*

**The camera type, this is crucial in order for the camera to work properly (default DSLR):**
```matlab
P.CameraType = 'DSLR' / 'ASTRO'
```
- Note that while only two values are possible, many inputs will be valid.
For example; 'Nikon', 'Canon' and 'dslr' are valid inputs that will result in the CameraType to be 'DSLR'.
- This is the same for astronomical cameras; 'QHY', 'QHY367', 'QHYCCD' 'astro' and some more inputs are valid and will result in the CameraType being 'ASTRO'.

Exposure time, in seconds (default 8):
```matlab
P.ExpTime = x
```

*For DSLR cameras* we can also set the F - Number (Deafult 1.4):
```matlab
P.F_Number = x
```

Time delay between each capture, in seconds from the start of the previous capture (default 12):
```matlab
P.Delay = x
```

Image path (default '/home/ocs/skycam/'), only relevant while the camera type is DSLR:
```matlab
P.ImagePath = 'x'
```
**Initiate the connection with the camera, make sure it is connected via USB and turned on:**
```matlab
P.connect
```

**To start capturing images, use the 'start' function**
```matlab
P.start
```

- Note that properties cannot be changed while the camera is started and capturing images.

For DSLR cameras:
- A bash script will run, organizing all the images in the image path directory.
- A plot window will open with a live view of the camera, and the camera will continue capturing until it will be disconnected.
- If you don't want the plot window, you can change the figure in 'matlab-gphoto' submodule, inside the gphoto.plot function file to: "(,'visible','off')"
- If astropack is present, the images will be saved with (AstroPack's) 'ImagePath''s standard, else, it will be saved just in 'P.ImagePath'.

For Astronimical cameras:
- A timer object is created that will call the private property "takeExposure" every {Delay} seconds.
- Currently the display is turned off for technical reasons, but it can be turned on for liveview (with ClassCommand).

**Stopping the image capture:**
```matlab
P.stop
```

- Stopping the image capture is preferable if you intend to use the same camera later and not turn it off in the meantime.
- If you turn off the camera, you should first disconnect it.
- Reconnecting the same camera with 'connect' instantly after 'disconnect' may cause some errors in DSLR cameras.

**Correctly shutting down is crucial!** Otherwise, it can leave the timer/bash script running in the background and cause errors.

*Do not clear or delete the class before disconnecting.*

**Disconnection:**
```matlab
P.disconnect
```
Disconnection will take a few seconds, it will close the liveview window and clear the class' objects.

<details open><summary> Properties </summary>

| Property name | Summary | Default value | Visible?
| --- | --- | --- | --- |
| ExpTime | The exposure time of the camera, note that this will be rounded to the closest available value, as not all values are possible. | 8 | Yes |
| F_Number | *DSLR - Only:* The F - Number of the camera, note that this will be rounded to the closest available value, as not all values are possible. | [Empty] | Yes |
| Delay | Time delay in seconds between the start of each capture. | 12 | Yes |
| CameraType | The type of camera used. Can only be 'DSLR' or 'ASTRO', multiple inputs are accepted, but they will return only one of these two values. | 'DSLR' | Yes |
| ImagePath | The parent directory where the images will be saved. | '/home/ocs/skycam/' | Yes |
| Temperature | *Debug property:* Shows the temperature of the sensor, if connected. | ~ | Only if 'Found' |
| CameraTemp | *ASTRO - Only:* The internal temperature of the camera. | Readonly | Only in ASTRO mode |
| CameraRes | The camera serial resource, is used for both astronomical as DSLR cameras, but it will store different resources. | Readonly | Yes |
| SensorType | *Debug property:* the type of temperature logger that you want to connect (Arduino / Digitemp). | 'Digitemp' | If assigned a value |
| TemperatureLogger | The temperature logger serial resource, if found. Serial resource for arduino and bash script process for Digitemp. | Readonly | No |
| DataDir | *AstroPack - Only:* The child directory where the images will be saved, a subdirectory of ImagePath. | Readonly | No |
| FileCheck | *In DSLR mode:* The file organizing script process. <br /> *In ASTRO mode:* The timer object that calls TakeExposure. | Readonly | No |
| ExpTimesData | *DSLR - Only:* The data table of the possible exposure times that is read from the camera's settings. | Readonly | No | 
| FNumData | *DSLR - Only:* The data table of the possible F - Numbers that is read from the camera's settings. | Readonly | No | 
| InitialTemp | *Debug property:* the initial temperature of the sensor (if found). Used for comparison and to avoid overheating. | Readonly | No |
| Found | *Debug property:* indicates if a temperature logger was found. | 0 (false) | No |
| Connected | The connection status of the camera: 0 for not connected, 1 for connected, and 2 for started. | 0 | No |

</details>

<details><summary> Debug methods </summary>

| Method name | Summary | Properties | Optional inputs |
| --- | --- | --- | --- |
| connectSensor | Used to connect the Arduino or Digitemp_DS9097 temperature sensors with serialport (Arduino) or bash (Digitemp), automatically detects port unless provided. This method is no longer automatically called due to performance reasons. <br /> *For Digitemp sensors:* The sensor will write a log file with the temperatures every 2 seconds. It will be located under the 'ImagePath' folder. | Found, SesnorType, InitialTemp, TemperatureLogger, ImagePath | Port, Baud - The serial port and baud rate of the Arduino |
| stopLogging | *Digitemp - Only:* Used to disconnect and kill the Digitemp temperature sensor process and stop writing to the log file. | Found, SensorType, TemperatureLogger | |
| imageTimer | Detects when a new file has been saved on disk. Blocks Matlab, and can only be interrupted with Ctrl + C. | DataDir | |
| ~~logTemperature~~ | Uses Digitemp_DS9097 USB temperature sensor to log temperatures (instead of arduino) every 2 seconds (can be changed). Creates a file in the ImagePath directory where it saves a timetable with the temperature data. **Cut into 'connectSensor'** - Is still in 'old' folder. | SensorType, ImagePath, TemperatureLogger | |

</details>

---

<details>
<summary> Gphoto Matlab usage </summary>
<br>
	

Initiate the connection:
```matlab
p = gphoto % + (port (leave empty for auto-detect))
```
Start LiveView:
```matlab
p.plot
```
Take an image:
```matlab
p.capture
% OR
p.image
```
Open the settings menu:
```matlab
p.set
% OR
set(p)
```
Get camera's status:
```matlab
p.status
```

For more information about gphoto, see [man gphoto](https://manpages.ubuntu.com/manpages/impish/man1/gphoto2.1.html), and [matlab-gphoto](https://gitlab.com/astrophotography/matlab-gphoto/)
	
</details>

<details>
	
<summary> How does the camera handle different exposure times? (DSLR) </summary>
<br>


```matlab
p.set('bulb', 0)
p.set('shutterspeed', /*Shutter Speed Choice Number*/)
```
Possible choices:
```
Label: Shutter Speed
Readonly: 0
Type: RADIO
Current: 0.0166s
Choice: 0 0.0005s
Choice: 1 0.0006s
Choice: 2 0.0008s
Choice: 3 0.0010s
Choice: 4 0.0012s
Choice: 5 0.0015s
Choice: 6 0.0020s
Choice: 7 0.0025s
Choice: 8 0.0031s
Choice: 9 0.0040s
Choice: 10 0.0050s
Choice: 11 0.0062s
Choice: 12 0.0080s
Choice: 13 0.0100s
Choice: 14 0.0125s
Choice: 15 0.0166s
Choice: 16 0.0200s
Choice: 17 0.0250s
Choice: 18 0.0333s
Choice: 19 0.0400s
Choice: 20 0.0500s
Choice: 21 0.0666s
Choice: 22 0.0769s
Choice: 23 0.1000s
Choice: 24 0.1250s
Choice: 25 0.1666s
Choice: 26 0.2000s
Choice: 27 0.2500s
Choice: 28 0.3333s
Choice: 29 0.4000s
Choice: 30 0.5000s
Choice: 31 0.6250s
Choice: 32 0.7692s
Choice: 33 1.0000s
Choice: 34 1.3000s
Choice: 35 1.6000s
Choice: 36 2.0000s
Choice: 37 2.5000s
Choice: 38 3.0000s
Choice: 39 4.0000s
Choice: 40 5.0000s
Choice: 41 6.0000s
Choice: 42 8.0000s
Choice: 43 10.0000s
Choice: 44 13.0000s
Choice: 45 15.0000s
Choice: 46 20.0000s
Choice: 47 25.0000s
Choice: 48 30.0000s
Choice: 49 Bulb
Choice: 50 Time
END
```
Choice 53 ('Bulb') can be used for an indefinite exposure time

</details>

<details>
<summary> Get the sun's altitude (Currently unimplemented) </summary>
<br>

The sun's altitude can be used to determine when to take images (only at night), it is not currently being used in the Skycam class, but it might be useful.

We use AstroPack's "celestial" in order to determine where the sun is (in order to determine whether it is time to start taking images).
Basic sun altitude reading:
```matlab
% Get sun parameters
sun = celestial.SolarSys.get_sun;
% Extract altitude
sunalt = sun.Alt
% If we want to convert to degrees:
sunalt = rad2deg(sun.Alt);
```
</details>

---
