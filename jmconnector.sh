#!/bin/bash
#This script comes with no warranty .use at own risk
# Copyright (C) 2021 Joanny Krafft
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program or from the site that you downloaded it
# from; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA 02111-1307 USA

#Configuration settings
#Defaults are set to work with a pi-stomp from treefallsound
#Pattern for the program inputs you want to map your outputs to
out_pat="REAPER"
#Pattern for the name of the inputs
out_pin="in"
#List of the pin to map
pin_num=("3" "4")
#Pattern for your playback device
sys_playback_pat="system:playback_"
#pattern for the fx, "effect_" for fx created by MODEP
fx_pat="effect_"

#Config end - Don't touch anything beyond that...
trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

list(){
echo "Listing JACK connections..."
j_lsp="$(jack_lsp -c)"

n=$(echo "$j_lsp" | wc -l)
#echo $n
s=1
for j in $(seq 1 $n); do
	element=$(echo "$j_lsp"|head -n $j|tail -n 1)
#	echo "$j	$element"
	jack[$j]="$element"
	if [[ "$element" == "$sys_playback_pat"* ]]; then
		echo "Main output $s: $element (line $j)"
		sys_out[$s]=$j
		s=$(($s+1))
	fi
done

nb_sys_out=$(echo "${sys_out[*]}"|wc -l)
#echo "sys_out: ${sys_out[*]}"
#echo "nb_sysout: ${#sys_out[@]}"
}

detect(){
echo "Detecting where goes what..."
j=0
for sout in ${sys_out[@]}; do
    s=1
    n=$(($sout+1))
    while [[ "${jack[$n]}" == "   "* ]]; do
#        echo "$n - ${jack[$n]}"
        if [[ "${jack[$n]}" == "   $fx_pat"* ]]; then
            main_out[$s]=$n
#    	echo "$n - fx out $s: ${jack[$n]}"
            s=$(($s+1))
        fi
        n=$(($n+1))
    done
#echo "main_out: ${main_out[*]}"
    echo "Connecting ${jack[$sout]}"
    for element in ${main_out[@]}; do
        echo "	jack_connect $(trim ${jack[$element]}) $out_pat:$out_pin${pin_num[$j]}"
        jack_connect $(trim ${jack[$element]}) $out_pat:$out_pin${pin_num[$j]}
    done
    j=$(($j+1))
    unset main_out
done
}

app_name="JACK-MODEP Connector"
app_version=0.1
app_author="Joanny Krafft"
app_description="Connecting MODEP's outputs to a DAW"
echo "$app_name $app_version - by $app_author"
echo "$app_description"

declare -a jack
declare -a sys_out
declare -a main_out

list
detect
