# Sitelen Mute: a static, minimalist javascript photo gallery

*Sitelen Mute* is a static photo gallery generator with no frills that has a
stylish, minimalist look. It shows your photos, and nothing else.

You can see example galleries at the following address:

https://alexschroeder.ch/gallery

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Features](#features)
- [Usage](#usage)
- [Pre-built packages](#pre-built-packages)
- [Docker](#docker)
- [Usage notes](#usage-notes)
- [Tuning thumbnail generation](#tuning-thumbnail-generation)
- [Portraits and face detection](#portraits-and-face-detection)
- [Image captioning](#image-captioning)
- [Color management](#color-management)
- [Technical details](#technical-details)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [Authors](#authors)
- [License](#license)
- [Extending Sitelen Mute](#extending-sitelen-mute)
- [Troubleshooting](#troubleshooting)
    - [not built to support threads](#not-built-to-support-threads)
    - [convert: width or height exceeds limit](#convert-width-or-height-exceeds-limit)
- [Issues](#issues)
- [Todo](#todo)

<!-- markdown-toc end -->

## Features

There is no server-side processing, only static generation. The resulting
gallery can be uploaded anywhere without additional requirements and works with
any modern browser.

- Automatically orients pictures without quality loss.
- Multi-camera friendly: automatically sorts pictures by time: just throw your
  (and your friends) photos and movies in a directory. The resulting gallery
  shows the pictures in seamless shooting order.
- Adapts to the current screen size and proportions, switching from
  horizontal/vertical layout and scaling thumbnails automatically.
- Supports face detection for improved thumbnail centering.
- Loads fast! Especially over slow connections.
- Includes original (raw) pictures in a zip file for downloading.
- Panoramas can be seen full-size by default.

The name is [Toki Pona](https://tokipona.org/) for "many pictures",
i.e. a gallery.

## Usage

Generate all the static files with `./sitelen-mute`:

```
./sitelen-mute photo-dir my-gallery
```

Upload `my-gallery` somewhere.

For a real world example including face detection and meta data for
social media, with the images stored in the `Quito` directory and the
gallery ending up in `2020-quito`:

```
sitelen-mute -f --title "Quito 2020" \
  --description "On our way to the Galápagos we stopped for a few days in Quito, Ecuador." \
  --url https://alexschroeder.ch/gallery/2020-quito/ \
  Quito \
  2020-quito
```

## Pre-built packages

Pre-built packages for *Sitelen Mute* are not yet available anywhere.

Pre-built packages for `facedetect` should be available from your distribution.

Want to be the maintainer for one of the many systems out there? Let
me know.

## Docker

You can look at the status of the
[latest builds on Docker Hub](https://hub.docker.com/r/kensanata/sitelen-mute/builds/).

```
# Set the initial environment variables
SOURCE_DIRECTORY="$HOME/mypictures/album1"
DESTINATION_DIRECTORY="/var/tmp/my_web_sitelen_mute_photo_album"

# Check the SOURCE_DIRECTORY with pictures
ls -ld $SOURCE_DIRECTORY/*jpg
-rw-r--r-- 1 user user 690978 Feb  4  2003 /home/user/mypictures/album1/20030204-222803.jpg
-rw-r--r-- 1 user user 733873 Feb  4  2003 /home/user/mypictures/album1/20030204-222819.jpg

# Generate gallery with face detection enabled
docker run --rm -it -u $(id -u):$(id -g) -v "$SOURCE_DIRECTORY":/mnt:ro \
	-v "`dirname $DESTINATION_DIRECTORY`":/destination kensanata/sitelen-mute \
	/mnt /destination/`basename $DESTINATION_DIRECTORY`-1 -f -j $(nproc)

# Generate gallery with face detection enabled, slim output (no original files
# and downloads), maximum full image size (1920x1080) and do not generate a
# full album download
docker run --rm -it -u $(id -u):$(id -g) -v "$SOURCE_DIRECTORY":/mnt:ro \
	-v "`dirname $DESTINATION_DIRECTORY`":/destination kensanata/sitelen-mute \
	/mnt /destination/`basename $DESTINATION_DIRECTORY`-2 -s -d -f -j $(nproc) \
	--max-full 1920x1080
```

(Thanks to: https://github.com/skorokithakis/docker-fgallery and https://github.com/pank/docker-fgallery)

## Usage notes

The images as shown by the viewer are scaled and compressed using the
specified quality to reduce viewing lag. They are also stripped of any
EXIF tag. However, the pictures in the generated zip album are
preserved *unchanged*.

Lossless auto-rotation is applied so that images can be opened with a
browser directly. JPEG and PNG files are also re-optimized (losslessy)
before being archived to furthermore save space.

Image captions are read from simple text files or directly from EXIF
metadata. Captions can be controlled by the user using the "bubble"
icon or by pressing the `c` keyboard shortcut, which cycles between
normal, always hidden and always shown visualization modes.

Preview and thumbnail images are converted to the sRGB color-space by
default, which provides better results on normal displays and browsers
without color management support.

All images can be included to be viewed individually at full
resolution in the gallery by using the `-i` flag. Panoramas are
automatically detected and the original image is included in full-size
by default, as often the image preview alone doesn't give it justice.

For best results when shooting with multiple cameras (or friends),
synchronize the camera clocks before starting to take pictures. Just
pick one camera's time as the reference. By doing this the album is
automatically shown in logical shooting order instead of file-name
order.

Never use the `-s` or `-d` flags. Let your friends and viewers
download the raw album at full resolution, not the downscaled crap.
Don't make me angry.

## Tuning thumbnail generation

The sizes of the thumbnails and the main image can be customized on
the command line with the appropriate flags. Two settings are
available for the thumbnail sizes: minimum (150x112) and maximum
(267x200). Thumbnails will always be as big as the minimum size, but
they can be enlarged up to the specified maximum depending on the
screen orientation. The default settings are tuned for a
mostly-landscape gallery, but they can be changed as needed.

Images having a different aspect ratio (like panoramas) are cut and
centered instead of being scaled-to-fit, so that the thumbnail shows
the central subject of the image instead of a thin, unwatchable strip.
When this happens, the viewer shows a sign on the thumbnail along the
cut edges (this effect can be seen in the demo gallery).

## Portraits and face detection

To simply favor photos shot in portrait format, invert the
width/height of the thumbnail sizes:

```
./sitelen-mute --min-thumb 112x150 --max-thumb 200x267 ...
```

This forces the thumbnails to always fit vertically, at the expense of
a higher horizontal thumbnail strip.

If your photos are mixed and can contain people, faces or portraits, you can
enable face detection by using the `-f` flag and installing 
[facedetect](https://www.thregr.org/~wavexx/software/facedetect/).

Face detection ensures that the thumbnails, especially when cut, will
be centred on the face of the subject. If face detection is enabled,
there's generally no need to increase the thumbnail size.

## Image captioning

Several sources for image captions are automatically read by *Sitelen Mute*.
These can be customized though the `-c` flag in the command line,
which consists of a comma-separated list of any of the following:

- `txt`: detached captions in a simple text file
- `xmp`: captions read from XMP sidecar metadata
- `exif`: captions read from EXIF metadata
- `cmt`: captions read from JPEG or PNG's built-in "comment" data

You can disable caption extraction entirely by using `-c none`. When
multiple methods are provided, the first available caption source is
used. By default, the method list is `txt,xmp,exif`.

The `txt` method reads the caption from a text file that has the same
name as the image, but with `txt` extension (for example `IMG1234.jpg`
reads from `IMG1234.txt`). The first line of the file (which can be
empty) constitutes the title, with any following line becoming the
description. These files can either be written manually, or can be
edited more conveniently using the `utils/fcaption` utility.
`fcaption` accepts a list of filenames or directories on the command
line, and provides a simple visual interface to quickly edit image
captions in this format.

`XMP` or `EXIF` captions can be edited easily with many other image
editing/previewing programs, such as
[Darktable](http://www.darktable.org/) (which writes XMP sidecar files
by default) or [Geeqie](http://geeqie.org/) (use `Ctrl+K` to bring up
the metadata editor).

Both JPEG and PNG have a built-in comment field, but it's not read by
default as it's often abused by editing software to put attribution or
copyright information. When enabled, the comment is parsed as for
`txt` files: the first line is the title, with any subsequent line
becoming the description.

Captions are intended to be short. Do not write long or distracting
descriptions. Captions should *never* contain copyright information.
*Do not abuse captions*.

## Color management

Since every camera is different, and every monitor is different, some
color transformation is necessary to reproduce the colors on your
monitor as *originally* captured by the camera.
[Color management](http://en.wikipedia.org/wiki/Color_management) is
an umbrella term for all the techniques required to perform this task.

Most image-viewing software support color management to some degree,
but it's rarely configured properly on most systems except for Safari
on Mac OSX. No other browser, unfortunately, supports decent color
management.

This causes the familiar effect of looking at the same picture from
your laptop and your tablet, and noticing that the blue of the sky is
just slightly off, or that colors look much more contrasty on one
screen as opposed to the other. Often the image *has* the information
required for a more balanced color reproduction, but the browser is
just ignoring it.

We're writing this down because Firefox *has* built-in color-management
support, but it's disabled by default on all platforms. It's also ranking very
low on the list of improvements to make, with some bugs being open for years.
In an attempt to raise awareness, please complain/contribute to any of the
existing
[bug reports](https://bugzilla.mozilla.org/buglist.cgi?component=GFX%3A%20Color%20Management&product=Core&bug_status=__open__),
citing the technical details below.

## Technical details

On Firefox, the installation of the
[Color Management](https://addons.mozilla.org/en-US/firefox/addon/color-management/)
add-on is recommended.

When installed, in the add-on configuration, you'll need to enable
color management for "All images" and restart the browser. Also, if
you have a multi-monitor setup, it's advisable to manually set the
"Display profile" to the external/calibrated screen, since FF won't
automatically select the color profile for the current monitor, and
just default to the primary. Firefox has also known bugs with LUT
profiles, though the more common Matrix profiles seem to work fine.

We understand that CM has a considerable impact on image rendering
performance, but strictly speaking CM doesn't need to be enabled on
all images by default. It would be perfectly fine to have an
additional attribute on the image tag to request CM. The current
method of enabling CM only on images with an ICC profile is clearly
not adequate, since images without a profile should be assumed to be
in sRGB color-space already.

Because of the general lack of color management, *Sitelen Mute*
transforms the preview and thumbnail images from the built-in color
profile to the sRGB color-space by default. On most devices this will
result in images appearing to be *closer* to true colors with only
minimal lack of absolute color depth. As usual, no transformation is
done on the original downloadable files.

## Dependencies

Frontend/viewer: none (static html/js/css)

Backend:

* [ImageMagick](http://www.imagemagick.org) (`imagemagick`)

* [LittleCMS2](http://www.littlecms.com/) utilities (`liblcms2-utils`)

* One of the following:

    * `exiftran` which is part of [fbida](http://www.kraxel.org/blog/linux/fbida/)

    * `exifautotran` which is part of [libjpeg-progs](http://libjpeg.sourceforge.net/)

* One of the following:

    * `7za` which is part of [7zip](http://7-zip.org/)
	
	* `zip`
	
* Perl >= 5.14 *with threading support*

* The following *required* Perl module:

    * `Image::ExifTool` which is part of [ExifTool](http://owl.phy.queensu.ca/~phil/exiftool/) (`libimage-exiftool-perl`)

* The following *recommended* Perl module:

    * `Cpanel::JSON::XS` (`libcpanel-json-xs-perl`)

Several other tools are supported, but are only used when installed.
Therefore it's also helpful to install:

* [jpegoptim](http://www.kokkonen.net/tjko/projects.html) for JPEG size optimization
* [pngcrush](http://pmt.sourceforge.net/pngcrush/) for PNG size optimization
* [facedetect](https://www.thregr.org/~wavexx/software/facedetect/) for face detection
* [p7zip](http://www.7-zip.org/) for faster and higher-compression zip archiving

On Debian or Ubuntu, you can install all the required dependencies with:

```
sudo apt install imagemagick exiftran zip liblcms2-utils \
                 libimage-exiftool-perl libcpanel-json-xs-perl
```

To save more space in the generated galleries, we recommend installing also the
optional dependencies:

```
sudo apt install jpegoptim pngcrush facedetect p7zip
```

`fcaption` is written in Python and requires either PyQT4 or PySide2 (Qt5). You
can install PySide2 with:

```
sudo apt install python-pyside2
```

Or PyQt4 with:

```
sudo apt install python-qt4
```

On a Mac, we recommend installing the dependencies using
[MacPorts](https://www.macports.org/).

After installing MacPorts, type:

```
sudo port install imagemagick lcms2 jpeg jpegoptim pngcrush facedetect
sudo port install p5-image-exiftool p5-cpanel-json-xs
```

If you use [Homebrew](https://brew.sh/) on a Mac...

```
# install perlbrew
sudo cpan App::perlbrew
perlbrew init
# build a perl with threading
perlbrew install --thread stable
perlbrew list
# pick the perl you just built
perlbrew switch XXX
# install cpanm for perlbrew
curl -L https://cpanmin.us | perl - App::cpanminus
cpanm Image::ExifTool
cpanm Cpanel::JSON::XS
brew install imagemagick lcms2 jpeg jpegoptim pngcrush facedetect
```

Test `facedetect` on some image.

## Installation

Installation is currently optional. If needed, copy the extracted
directory to a directory of your liking and link `sitelen-mute`
appropriately:

```
sudo cp -r sitelen-mute-X.Y /usr/local/share/sitelen-mute
sudo ln -s /usr/local/share/sitelen-mute/sitelen-mute /usr/local/bin
```

## Authors

[Sitelen Mute](https://github.com/kensanata/sitelen-mute) grew out of
[fgallery](https://github.com/wavexx/fgallery) by Yuri D'Elia because
the author said that their mind is
[on other projects](https://github.com/wavexx/fgallery/pull/76#issuecomment-368947439)
right now. *Sitelen Mute* is being developed by Alex
Schroeder with contributions by Adrian Steinmann (he maintains his own fork
called [efgallery](https://github.com/0-ast-0/efgallery)), and Petr
Ruzicka (who maintains our Docker integration).

## License

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.

## Extending Sitelen Mute

*Sitelen Mute* is composed of a backend (the `sitelen-mute` script)
and a viewer (contained in the `view` directory). Both are distributed
as one package, but they are designed to be used independently.

The backend just cares about generating the image previews and the
album data. All the presentation logic however is inside the viewer.

It's relatively easy to generate the album data dynamically and just
use the viewer. This was Yuri D'Elia's aim when they started to develop
*fgallery*, as it's much easier to just modify an existing CMS instead
of trying to reinvent the wheel. All a backend has to do is provide a
valid "data.json" at some prefixed address.

## Troubleshooting

This section talks about strange and weird problems and how to work
around them.

### cannot load gallery data

To test or preview the gallery locally, you might think that you can
just open the `index.html` file of the gallery. Sadly, this is no
longer the case for security reasons (see [same-origin
policy](https://en.wikipedia.org/wiki/Same-origin_policy) if you want
to know more).

If you have Python installed, a quick way to test the gallery locally
is to run the following inside the gallery:

```
python -m SimpleHTTPServer 8000
```

This serves all the files from `http://localhost:8000`.

### not built to support threads

If you're wondering about the use of Perlbrew, you're not alone. If
you cannot run *Sitelen Mute* because you're getting the error "This
Perl not built to support threads" then you'll need to get a Perl with
thread support. I find [Perlbrew](https://perlbrew.pl/) to be the
simplest solution. I installed it using my package manager, in this
case: `sudo apt install perlbrew`. Your mileage may vary.

Then I checked the available Perl versions using `perlbrew available`
and picked the first one with an *even* minor version. In the example
above that was 5.22.0, but as I write this right now it would be
5.30.0.

Build and install it using `perlbrew install --thread perl-5.30.0` (or
whatever version you picked). This takes a long time.

Use `perlbrew use perl-5.30.0` to switch your Perl for the current
shell; use `perlbrew switch perl-5.30.0` to switch your default Perl.

The problem is that you need to reinstall all your modules for this
version! If you used Perlbrew in the past, you might have used
`perlbrew clone-modules` to reinstall them. If you haven't used
Perlbrew before, I recommend installing App::cpanminus before doing
anything else and then using `cpanm` to install the rest. See
[Dependencies](#dependencies) for more.

```
perlbrew use perl-5.30.0
cpan install App::cpanminus
cpanm Image::ExifTool Cpanel::JSON::XS
```

Now you should have a Perl that works!

### convert: width or height exceeds limit

```text
Image file inspection 100% completed - will now process 79 image files
convert-im6.q16: width or height exceeds limit `/home/alex/Pictures/Galapagos/2018-quito/files/IMG_1040.jpg' @ error/cache.c/OpenPixelCache/3912.
convert-im6.q16: no images defined `tiff:/home/alex/Pictures/Galapagos/2018-quito/files/IMG_1040.jpg.tmp' @ error/convert.c/ConvertImageCommand/3258.
Thread 2 terminated abnormally: Fatal error:
close failed on "convert" "-quiet" "/home/alex/Pictures/Galapagos/2018-quito/files/IMG_1040.jpg" "-compress" "LZW" "-type" "truecolor" "tiff:/home/alex/Pictures/Galapagos/2018-quito/files/IMG_1040.jpg.tmp": 
Fatal error:
Thread failed in function 'process'; cannot proceed
```

The problem is that ImageMagick has a security policy that prevents
"image bombs" – images that are so large that they could bomb your
server if you are using ImageMagick to process images uploaded from
the Internet, for example.

You can show the limits using `identify -list resource`:

```text
Resource limits:
  Width: 16KP
  Height: 16KP
  List length: 18.446744EP
  Area: 128MP
  Memory: 256MiB
  Map: 512MiB
  Disk: 1GiB
  File: 768
  Thread: 4
  Throttle: 0
  Time: unlimited
```

Compare this to the image using `identify Quito/IMG_1040.JPG`:

```text
Quito/IMG_1040.JPG JPEG 16382x3628 16382x3628+0+0 8-bit sRGB 25.6993MiB 0.000u 0:00.000
```

As root, you need to change the security policy of your installation
if you want to process such large panorama shots. Edit
`/etc/ImageMagick-6/policy.xml` and make the following change:

```text
62c62
<   <policy domain="resource" name="width" value="16KP"/>
---
>   <policy domain="resource" name="width" value="32KP"/>
```

## Issues

Issues are being tracked
[on the wiki](https://alexschroeder.ch/software/Sitelen_Mute).

## Todo

- Videos

- "Live" images as created by iPhones consisting of a JPEG cover image
  and a very short video

- Improve EXIF header display
