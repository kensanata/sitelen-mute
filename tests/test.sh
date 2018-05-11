#!/bin/bash -eux

IMAGES_DESTINATION="/tmp/images"
SITELEN_MUTE_DESTINATION="/tmp/sitelen-mute"
IMAGES="
https://static.pexels.com/photos/38554/girl-people-landscape-sun-38554.jpeg
https://static.pexels.com/photos/541520/pexels-photo-541520.jpeg
https://static.pexels.com/photos/7919/pexels-photo.jpg
https://static.pexels.com/photos/161798/stonehenge-architecture-history-monolith-161798.jpeg
https://static.pexels.com/photos/407237/pexels-photo-407237.jpeg
https://static.pexels.com/photos/159787/man-white-shirt-male-person-159787.jpeg
https://static.pexels.com/photos/41366/brunette-cute-fashion-female-41366.jpeg
"

if [ -d "$SITELEN_MUTE_DESTINATION" ] || [ -d "$IMAGES_DESTINATION" ] ; then
  echo "The \"$SITELEN_MUTE_DESTINATION\" or \"$IMAGES_DESTINATION\" exists... Cannot continue!"
  exit 1
fi

mkdir "$IMAGES_DESTINATION"

wget -c $IMAGES -P "$IMAGES_DESTINATION"

docker run --rm -it -u $(id -u):$(id -g) -v "$IMAGES_DESTINATION":/mnt:ro -v "`dirname $SITELEN_MUTE_DESTINATION`":/destination kensanata/sitelen-mute /mnt /destination/`basename $SITELEN_MUTE_DESTINATION` -s -d -f -j $(nproc) --max-full 1920x1080
