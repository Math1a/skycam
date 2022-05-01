# skycam

---

### Dependencies:

System dependencies: [gphoto2 (libgphoto2)](http://www.gphoto.org/)

For debugging porpouses: [gtkam](http://www.gphoto.org/proj/gtkam/)

Matlab dependencies: [matlab-gphoto](https://gitlab.com/astrophotography/matlab-gphoto/), [matlab process](https://github.com/farhi/matlab-process)

#### Auto installation:

Place the installation file in the desired install directory and run it, it will create a "skycam" directory, and place the matlab dependencies there.

---

<details open>
<summary> Basic Matlab usage: </summary>
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
	
</details>

<details>
	
<summary> For long exposure times:</summary>
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

[Man gphoto](https://manpages.ubuntu.com/manpages/impish/man1/gphoto2.1.html)
