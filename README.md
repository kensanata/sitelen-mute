# NAME

Sitelen Mute - a static, minimalist photo gallery

# SYNOPSIS

**sitelen-mute** \[**OPTION** ...\] _SOURCE_ _DIRECTORY_

# DESCRIPTION

**Sitelen Mute** is a static photo gallery generator. It takes all the images it
can find in the source directory and writes a static gallery to the output
directory: scaled images, zipped originals, thumbnails, Javascript code for
navigation, and an HTML file. You can upload this to a simple web server.

**-h**, **--help** shows this help.

**-v** increases the verbosity. Repeat for more detail.

**-s** produces "slim" output: no original files or album to download. The
default is to create a zip file with all the originals in it. Creating a zip
files requires the `zip` or `7za` (7-Zip).

**-i** include originals as individual files. The default is to create a just a
zip file with all the originals in it.

**-d** skip creation of a full album zip file for download. Visitors can download
it by clicking the floppy icon with the downward arrow in the top left corner.

**-c** _METHODS_ names the caption extraction methods, separated by commas.
Valid options are `txt`, `xmp`, `exif`, `cmt`, and `none`. When multiple
methods are provided, the first available caption source is used. By default,
the method list is `txt,xmp,exif`. You can disable caption extraction entirely
by using `none`.

`txt` reads the caption from a text file that has the same name as the image,
but with `txt` extension (for example `IMG1234.jpg` reads from
`IMG1234.txt`). The first line of the file (which can be empty) constitutes the
title, with any following line becoming the description. These files can either
be written manually, or can be edited more conveniently using `fcaption`. It
accepts a list of filenames or directories on the command line, and provides a
simple visual interface to quickly edit image captions in this format.

`xmp` reads the caption from XMP sidecar metadata and `exif` reads the caption
from EXIF metadata. Tools such as _Darktable_ or _Geeqie_ can write such
files. Use `Ctrl+K` to bring up the metadata editor.

`cmt` reads the caption from JPEG or PNG's built-in comment data. Both JPEG and
PNG have a built-in comment field, but it's not read by default as it's often
abused by editing software to put attribution or copyright information.

Captions can be controlled by the user using the speech bubble icon or by
pressing the `c` keyboard shortcut, which cycles between normal, always hidden
and always shown visualisation modes.

**-k** prevents the modification of the image files. The default is to
auto-orient images and to optimise JPEG and PNG files. Optimisation requires
`jpegoptim` or `pngcrush`.

**-o** prevents auto-orientation of images. Lossless auto-orientation requires
one of `exiftran` or `exifautotran`.

**-t** prevents sorting by time. Sorting by time is important if mixing the
pictures of multiple cameras.

**-t** reverses the album order.

**-p** prevents the inclusion of full-sized panoramas.

**-n** _NAME_ sets the album name, i.e. the title in the browser window.

**--index** _URL_ is the location for the index/back button.

The following three options add meta tags for previews on social media. They
must all three be specified, if at all.

**--url** _URL_ is the eventual URL of the gallery. That is, you need to know
where you're uploading the gallery to.

**--title** _TITLE_ is the title for previews on social media.

**--description** _DESCRIPTION_ is the (longer) description to use for the
preview on social media.

**-f** improves thumbnails by using face detection. This requires `facedet`.

**--noblur** skips the generation of blurry backdrops and simply uses dark noise
instead.

**--max-full** _WxH_ specifies the maximum full image size (the default is
1600×1200).

**--max-thumb** _WxH_ specifies the maximum thumbnail size (the default is
267×200).

**--min-thumb** _WxH_ specifies the minimum thumbnail size (the default is
150×112).

**--no-sRGB** prevents the remapping of previews and thumbnail colour profiles to
sRGB. The remapping requires `tificc`.

**--quality** _Q_ specifies the preview image quality (0-100, currently: 90).

**--link-orig** _method_ specifies the copy method to use: one of `copy`,
`hard`, `sym`, or `ref`); the default is `copy`. `copy` uses regular `cp`;
`hard` uses hard links: `cp --link`, or `ln` on BSD; `sym` uses symbolic
links: `cp --symbolic-link`, or `ln -s` on BSD; `ref` uses lightweight copy,
where the data blocks are copied only when modified: `cp --reflink`, and it is
not supported on BSD.

**--viewdir** specifies the directory containing CSS/JavaScript that is copied
into the target directory.

**--version** prints the version.

# EXAMPLES

You can see example galleries at the following address:

https://alexschroeder.ch/gallery

Generate a simple gallery:

    sitelen-mute photo-dir my-gallery

To favour photos shot in portrait format, invert the
width/height of the thumbnail sizes:

    sitelen-mute --min-thumb 112x150 --max-thumb 200x267 \
       photo-dir my-gallery

This forces the thumbnails to always fit vertically, at the expense of a higher
horizontal thumbnail strip.

For a real world example including face detection and meta data for social
media, with the images stored in the `Quito` directory and the gallery ending
up in `2020-quito`:

    sitelen-mute -f --title "Quito 2020" \
      --description "On our way to the Galápagos we stopped for a few days in Quito, Ecuador." \
      --url https://alexschroeder.ch/gallery/2020-quito/ \
      Quito \
      2020-quito

# TROUBLESHOOTING

This section talks about strange and weird problems and how to work around them.

## cannot load gallery data

To test or preview the gallery locally, you might think that you can just open
the `index.html` file of the gallery. Sadly, this is no longer the case for
security reasons (the "same-origin policy"; learn more about it on Wikipedia).

If you have Python installed, a quick way to test the gallery locally is to run
the following inside the gallery:

    python -m SimpleHTTPServer 8000

This serves all the files from `http://localhost:8000`.

## convert: width or height exceeds limit

An error message containing "convert-im6.q16: width or height exceeds limit" is
a sign that your ImageMagick installation has a security policy that prevents
"image bombs" – images that are so large that they could bomb your server if you
is using ImageMagick to process images uploaded from the Internet. If you a
_sure_ that you are not using ImageMagick in this way, here's a way to disable
this security policy.

You can show the limits using `identify -list resource`:

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

Compare this to the image using `identify IMG_1234.JPG`. Clearly, this panorama
image is too big.

    IMG_1234.JPG JPEG 16382x3628 16382x3628+0+0 8-bit sRGB 25.6993MiB 0.000u 0:00.000

As root, you need to change the security policy of your installation
if you want to process such large panorama shots. Edit
`/etc/ImageMagick-6/policy.xml` and make the following change:

    62c62
    <   <policy domain="resource" name="width" value="16KP"/>
    ---
    >   <policy domain="resource" name="width" value="32KP"/>

# FEATURES

There is no server-side processing, only static generation. The resulting
gallery can be uploaded anywhere without additional requirements and works with
any modern browser.

- Automatically orients pictures without quality loss.
- Multi-camera friendly: automatically sorts pictures by time: just throw
  your (and your friends) photos and movies in a directory. The resulting
  gallery shows the pictures in seamless shooting order.
- Adapts to the current screen size and proportions, switching from
  horizontal/vertical layout and scaling thumbnails automatically.
- Supports face detection for improved thumbnail centring.
- Loads fast! Especially over slow connections.
- Images shown by the viewer are scaled, compressed, and stripped of EXIF
  tags for size
- Includes original (raw) pictures in a zip file for downloading.
- Panoramas can be seen full-size by default.

# COLOUR MANAGEMENT

Since every camera is different, and every monitor is different, some colour
transformation is necessary to reproduce the colours on your monitor as
\*originally\* captured by the camera. Colour management is an umbrella term for
all the techniques required to perform this task.

Most image-viewing software support colour management to some degree, but it's
rarely configured properly on most systems except for Safari on macOS. No other
browser, unfortunately, supports decent colour management.

This causes the familiar effect of looking at the same picture from your laptop
and your tablet, and noticing that the blue of the sky is just slightly off, or
that the contrast seems to be much higher on one screen as opposed to the other.
Often the image has the information required for a more balanced colour
reproduction, but the browser is just ignoring it.

Colour management has a considerable impact on image rendering performance, but
strictly speaking colour management doesn't need to be enabled on all images by
default. It would be perfectly fine to have an additional attribute on the image
tag to request colour management. The current method of enabling colour
management only on images with an ICC profile is clearly not adequate, since
images without a profile should be assumed to be in sRGB colour-space already.

Because of the general lack of colour management, \*Sitelen Mute\* transforms the
preview and thumbnail images from the built-in colour profile to the sRGB
colour-space by default. On most devices this will result in images appearing to
be \*closer\* to true colours with only minimal lack of absolute colour depth. As
usual, no transformation is done on the original downloadable files.

# DEPENDENCIES

The viewer has no external dependencies. It's static HTML/CSS, and Javascript.

To resize images, `convert` must be installed. It comes with _ImageMagick_.

The remaining dependencies are optional. Sometimes you'll have to use certain
options work around missing dependencies.

To create the zip file: `7za` (which comes with _7-Zip_), or `zip`.

To convert previews and thumbnails to the sRGB colour space: `tificc` (which
comes with _LittleCMS2_).

To auto-orient images: `exiftran`, or `exifautotran`.

To optimise JPEG file size: `jpegoptim`.

To optimise PNG file size: `pngcrush`.

To center thumbnails on faces: `facedetect`.

On Debian or Ubuntu, you can all the dependencies with:

    sudo apt install \
      imagemagick p7zip liblcms2-utils exiftran \
      jpegoptim pngcrush facedetect

`fcaption` is written in Python and requires either _PyQT4_ or _PySide2_
(Qt5). On Debian or Ubuntu, you can it with:

    sudo apt install python-pyside2

# ARCHITECTURE

_Sitelen Mute_ is composed of a backend (the `sitelen-mute` script which
generates the gallery) and a viewer (which is copied into the `view`
directory). The two are designed to be used independently.

The backend just cares about generating the image previews and the
album data. All the presentation logic however is inside the viewer.

It's relatively easy to generate the album data dynamically and just
use the viewer. This was Yuri D'Elia's aim when they started to develop
\*fgallery\*, as it's much easier to just modify an existing CMS instead
of trying to reinvent the wheel. All a backend has to do is provide a
valid "data.json" at some prefixed address.

The Gemini wiki `phoebe` has an extension that acts as an independent viewer
for the data generated by the backend. Example:
[gemini://alexschroeder.ch/do/gallery](gemini://alexschroeder.ch/do/gallery).

# TODO

Videos.

"Live" images as created by iPhones consisting of a JPEG cover image and a very
short video.

# HISTORY

_Sitelen Mute_ grew out of _fgallery_ by Yuri D'Elia because the author said
that their mind is "on other projects".
[https://github.com/wavexx/fgallery/pull/76#issuecomment-368947439](https://github.com/wavexx/fgallery/pull/76#issuecomment-368947439)

# LICENSE

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see &lt;http://www.gnu.org/licenses/>.
