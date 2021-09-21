#!/bin/bash

i=0
s=1
declare -a jack
declare -a sys_out
sys_playback_pat="system:playback_"

#reaper_detect

#for lignes in $(jack_lsp -c |sed -n -e '/system/ p' -); do

i=1
n=$(jack_lsp -c | wc -l)
#echo $n
for j in $(seq 0 $n); do
	element="$(jack_lsp -c|head -n $j|tail -n 1)"

	echo "$j	$element"
	jack[$j]="$element"
	if [[ "$element" == "$sys_playback_pat"* ]]; then
#		echo "Main output $s"
		sys_out[$s]=$j
		s=$(($s+1))
	fi
	
done

#a=0
#for jd in ${jack[*]} ; do
#       echo "$a        $jd"
#        a=$(($a+1))
#done
#a=0
#for jd in ${sys_out[*]} ; do
#       echo "$a        $jd"
#        a=$(($a+1))
#done
#echo "Sortie 1: ${sys_out[1]}"


#echo suite
#sys_out1=$(jack_lsp -c|head -n ${sys_out[1]}|tail -n 1)
last_fx1=$(jack_lsp -c|head -n $((${sys_out[1]}+1))|tail -n 1)
if [[ "$last_fx1" == *"effect_"* ]]; then
	echo "jack_connect $last_fx1 Reaper3"
fi
last_fx2=$(jack_lsp -c|head -n $((${sys_out[2]}+1))|tail -n 1)
if [[ "$last_fx2" == *"effect_"* ]]; then
	echo "jack_connect $last_fx2 Reaper4"
fi


