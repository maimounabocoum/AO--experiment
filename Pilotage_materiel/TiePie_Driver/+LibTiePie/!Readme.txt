============================================================================================
MatlabLibTiePie : TiePie engineering's instrument library for Matlab 7.7 = 2008b and higher.
============================================================================================

MatlabLibTiePie is a Matlab package for using LibTiePie supported devices with Matlab 7.7 = 2008b and up.
LibTiePie is a library for controlling TiePie engineering's test and measurement equipment.
The following device types are supported:
- oscilloscopes
- function generators / arbitrary waveform generators (AWG)
- I2C hosts.

For examples and more information, see api.tiepie.com and www.tiepie.com/LibTiePie .


Setup:

The parent directory of the +LibTiePie directory must be in the Matlab path (or must be the current directory).
Therefore, create a directory structure such as 'C:\TiePie\+LibTiepie'.
To temporarily add 'C:\TiePie' to the Matlab path, execute 'addpath C:\TiePie'.
To permanently add 'C:\TiePie' to the Matlab path, use file->set path->add folder->save->close, or in Matlab 2012b+'s ribbon menu Environment->Set Path.

libtiepie.dll (or .so) and libtiepie.h must also be in the Matlab path. You can copy them to the 'C:\TiePie' directory already added to the Matlab path.


Use:

It is recommended to import the enumerated constants for LibTiePie to be able to use them for example as MM.STREAM instead of LibTiePie.Enum.MM.STREAM.
You can do this by executing 'import LibTiePie.Enum.*'.

Now you can open the library as follows:

>> LibTiePie = LibTiePie.Library

Search for devices:

>> LibTiePie.DeviceList.update()

Open the first oscilloscope:

>> scp = LibTiePie.DeviceList.getItemByIndex(0).openOscilloscope()

or function generator:

>> gen = LibTiePie.DeviceList.getItemByIndex(0).openGenerator()

Matlab will show which properties and methods can be used on each object.