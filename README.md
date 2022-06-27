# Skycam

Skycam is a tool for using DSLR cameras or astronomical cameras in order to survey the night sky

### Dependencies:

System dependencies: [gphoto2 (libgphoto2)](http://www.gphoto.org/)

For debugging purposes: [gtkam](http://www.gphoto.org/proj/gtkam/)

Matlab dependencies: [matlab-gphoto](https://gitlab.com/astrophotography/matlab-gphoto/), [matlab process](https://github.com/farhi/matlab-process)

#### Auto installation:

Clone this repository to the desired location, then run "install.sh" to install the dependencies.
```bash
sudo bash install.sh
```
---

# DSLR Camera Matlab use:

Skycam is written as a class in Matlab, first, we will need to create a skycam object (in this case, P):
```matlab
P = Skycam
```
**Next, we can assign the properties that we would like to change:**

Exposure time, in seconds (default 8):
```matlab
P.ExpTime = x
```

Time delay between each capture, in seconds from the start of the previous capture (default 12):
```matlab
P.Delay = x
```

Image path (default '/home/ocs/skycam/'):
```matlab
P.ImagePath = 'x'
```
All that's left now is to initiate the connection with the camera, make sure it is connected via USB and turned on:
```matlab
P.connect
```
- Note that properties cannot be changed while the camera is connected and capturing images.
- A bash script will run, organizing all the images in the image path directory.
- This method will also search if an Arduino temperature sensor is connected.
- A plot window will open with a live view of the camera, and the camera will continue capturing until it will be disconnected:
```matlab
P.disconnect
```

<details><summary> Properties </summary>

| Property name | Summary | Default value | Visible?
| --- | --- | --- | --- |
| Delay | Time delay in seconds between the start of each capture | 12 | Yes |
| ExpTime | The exposure time of the camera, note that this might be rounded to the closest available value, as not all values are possible | 8 | Yes |
| ImagePath | The path where the images will be saved | '/home/ocs/skycam/' | Yes |
| Temperature | Debug property, shows the temperature of the sensor, if connected | ~ | Only if found |
| gp | The gphoto serial resource | Readonly | No |
| TemperatureLogger | The temperature logger serial resource, if found | Readonly | No |
| filecheck | The file organizing script process | Readonly | No |
| InitialTemp | Debug property, the initial temperature of the sensor (if found). Used for comparison and to avoid overheating | Readonly | No |
| found | Debug property, indicates if a temperature logger was found | 0 (false) | No |

</details>

<details><summary> Debug methods </summary>

| Method name | Summary | Properties | 
| --- | --- | --- |
| connectSensor | Used to connect the Arduino temperature sensor with serialport, automatically detects port unless provided. This method is called by the 'connect' method automatically and detects if there is a sensor connected | Port, Baud - The serial port and baud rate of the Arduino |
| imageTimer | Detects when a new file has been saved on disk. Blocks matlab, and can only be interruped with Ctrl + C | |

</details>

---

<details>
<summary> Gphoto Matlab usage </summary>
<br>
	

Initiate the connection:
```matlab
p = gphoto % + (port (leave empty for auto detect))
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
	
<summary> How does the camera handle different exposure times? </summary>
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
Current: 0.5000s
Choice: 0 0.0001s
Choice: 1 0.0002s
Choice: 2 0.0003s
Choice: 3 0.0004s
Choice: 4 0.0005s
Choice: 5 0.0006s
Choice: 6 0.0008s
Choice: 7 0.0010s
Choice: 8 0.0012s
Choice: 9 0.0015s
Choice: 10 0.0020s
Choice: 11 0.0025s
Choice: 12 0.0031s
Choice: 13 0.0040s
Choice: 14 0.0050s
Choice: 15 0.0062s
Choice: 16 0.0080s
Choice: 17 0.0100s
Choice: 18 0.0125s
Choice: 19 0.0166s
Choice: 20 0.0200s
Choice: 21 0.0250s
Choice: 22 0.0333s
Choice: 23 0.0400s
Choice: 24 0.0500s
Choice: 25 0.0666s
Choice: 26 0.0769s
Choice: 27 0.1000s
Choice: 28 0.1250s
Choice: 29 0.1666s
Choice: 30 0.2000s
Choice: 31 0.2500s
Choice: 32 0.3333s
Choice: 33 0.4000s
Choice: 34 0.5000s
Choice: 35 0.6250s
Choice: 36 0.7692s
Choice: 37 1.0000s
Choice: 38 1.3000s
Choice: 39 1.6000s
Choice: 40 2.0000s
Choice: 41 2.5000s
Choice: 42 3.0000s
Choice: 43 4.0000s
Choice: 44 5.0000s
Choice: 45 6.0000s
Choice: 46 8.0000s
Choice: 47 10.0000s
Choice: 48 13.0000s
Choice: 49 15.0000s
Choice: 50 20.0000s
Choice: 51 25.0000s
Choice: 52 30.0000s
Choice: 53 Bulb
Choice: 54 Time
```
Choice 53 ('Bulb') can be used for an indefinete exposure time

</details>

<details>
<summary> Get the sun's altitude </summary>
<br>

We use AstroPack's "celestial" in order to detremine where the sun is (in order to determine whether it is time to start taking images).
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
