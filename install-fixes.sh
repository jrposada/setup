#!/usr/bin/env sh

# NVIDIA fixes
USER_EXEC=$(ls -l "/usr/share/screen-resolution-extra/nvidia-polkit" | cut -c4)
if [ "$USER_EXEC" != "x" ]; then
  echo "NVIDIA: fixing \"Can't save X configuration file...\" error..."
  sudo chmod u+x "/usr/share/screen-resolution-extra/nvidia-polkit"
else
  echo "Nvidia save config fix already applied"
fi
