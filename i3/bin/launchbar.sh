#!/usr/bin/env bash

## Files and Directories
DIR="$HOME/.config/i3/polybar"
SFILE="$DIR/system"
RFILE="$DIR/.system"
MFILE="$DIR/.module"

## Get system variable values for various modules
get_values() {
	CARD=$(basename "$(find /sys/class/backlight/* | head -n 1)")
	BATTERY=$(basename "$(find /sys/class/power_supply/*BAT* | head -n 1)")
	ADAPTER=$( "$(find /sys/class/power_supply/*AC* | head -n 1)")
	INTERFACE=$(ip link | awk '/state UP/ {print $2}' | tr -d :)
}

## Write values to `system` file
set_values() {
	if [[ "$ADAPTER" ]]; then
		sed -i -e "s/adapter = .*/adapter = $ADAPTER/g" "$SFILE"
	fi
	if [[ "$BATTERY" ]]; then
		sed -i -e "s/battery = .*/battery = $BATTERY/g" "$SFILE"
	fi
	if [[ "$CARD" ]]; then
		sed -i -e "s/graphics_card = .*/graphics_card = $CARD/g" "$SFILE"
	fi
	if [[ "$INTERFACE" ]]; then
		sed -i -e "s/network_interface = .*/network_interface = $INTERFACE/g" "$SFILE"
	fi
}

## Launch Polybar with selected style
launch_bar() {
	CARD=$(basename "$(find /sys/class/backlight/* | head -n 1)")
	if [[ "$CARD" != *"intel_"* ]]; then
		if [[ ! -f "$MFILE" ]]; then
			sed -i -e 's/backlight/brightness/g' "$DIR"/config
			touch "$MFILE"
		fi
	fi
		
	if [[ ! $(pidof polybar) ]]; then
		polybar -q main -c "$DIR"/config &
	else
		polybar-msg cmd restart
	fi

	if type "xrandr">/dev/null; then
  echo "Lanching polybar for each screen"
  xrandr --listactivemonitors | grep -oP '(HDMI\-\d+$|eDP\-\d+$)' | xargs -P1 -I{} bash -c "MONITOR={} polybar -q -r p00 &"
fi
}


launch_bar
