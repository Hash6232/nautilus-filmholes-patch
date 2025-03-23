#!/bin/sh

set -e

ICONSPATH="/usr/share/icons"
THUMBNAILERPATH="/usr/share/thumbnailers/ffmpegthumbnailer.thumbnailer"
NEWCONFIG="export G_RESOURCE_OVERLAYS=/org/gnome/nautilus/icons/filmholes.png=$ICONSPATH/filmholes.png"

copy_overlay() {
  echo "Copying overlay file to $ICONSPATH"
  sudo cp "./filmholes.png" "$ICONSPATH"

  return 0
}

add_export() {
  if grep -q G_RESOURCE_OVERLAYS "$1"; then
    echo "Patch already applied to $1"
    echo "Removing previous export.."
    sed -i '/^export G_RESOURCE_OVERLAYS=/d' "$1"
  fi

  echo "Appending export to $1"
  echo "$NEWCONFIG" >> "$1"

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
      sudo sed -i '/^Exec=ffmpegthumbnailer/s/ -f//g' $THUMBNAILERPATH
    fi
  fi

  return 0
}

print_rec() {
  echo "Run this to clear the thumbnails cache: rm -r ~/.cache/thumbnails"
  echo "Logout and back in for the changes to your profile file to apply"
}

copy_overlay

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
