#!/bin/sh

set -e

IMAGEPATH=$(realpath -- ./filmholes.png)
THUMBNAILERPATH="/usr/share/thumbnailers/ffmpegthumbnailer.thumbnailer"
NEWCONFIG="export G_RESOURCE_OVERLAYS=/org/gnome/nautilus/icons/filmholes.png=$IMAGEPATH"

add_export() {
  if grep -q G_RESOURCE_OVERLAYS "$1"; then
    echo "Patch already applied to $1"
  else
    echo "Appending export to $1"
    echo "$NEWCONFIG" >> "$1"
  fi

  return 0
}

edit_thumbnailer() {
  if [ ! -f "$THUMBNAILERPATH" ]; then
    echo "No ffmpegthumbnailer thumbnailer detected"
  else
    if ! grep -q " -f" $THUMBNAILERPATH; then
      echo "-f flag already removed from $THUMBNAILERPATH"
    else
      # Remove -f flag responsible for overlaying a movie strip to thumbnails
      echo "Removing -f flag from ffmpegthumbnailer.thumbnailer"
      sudo sed -i '/Exec=ffmpegthumbnailer/s/ -f//g' $THUMBNAILERPATH
    fi
  fi

  return 0
}

print_rec() {
  echo "Run this to clear the thumbnails cache: rm -r ~/.cache/thumbnails"
}

if [ -f "$HOME/.profile" ]; then
  add_export "$HOME/.profile"
elif [ -f "$HOME/.bash_profile" ]; then
  add_export "$HOME/.bash_profile"
else
  echo "No profile file detected.."
  echo "Manually add the following line to your profile file and reboot:"
  echo "$NEWCONFIG"
fi

edit_thumbnailer

print_rec
