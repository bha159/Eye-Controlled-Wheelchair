# Eye-Controlled-Wheelchair
This project contains MATLAB code for moving a bluetooth controlled bot by detecting the motion of eye pupil with Bluetooth

## Getting Started
Functions used in this project are used with MATLAB 2016a,so the project will work fine with 2016a and newer versions. 

### Prerequisites
MATLAB 2016a(or later versions)

Bot having a bluetooth module(Like HC-05) and two dc motors [Arduino code for bot](https://gist.github.com/ratcoder/89c020a11d56afc3a7b371548ea7fee0).

### Installing
Simply download the zip file of the project and extract it in MATLAB directory. For using camera download "IP Webcam" from [playstore](https://play.google.com/store/apps/details?id=com.pas.webcam&hl=en).

## Running the tests
Before running firstly pair bot's Bluetooth module with device's Bluetooth. For running the project use eyebot function in MATLAB with IP address recived from IP webcam application.
```
eyebot("http://XX.XX.XX.XX:8080");
```

## Authors

* **Bharat Kumar** - *Initial work* - [ratcoder](https://github.com/ratcoder)

