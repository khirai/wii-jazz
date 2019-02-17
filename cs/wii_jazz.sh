#!/bin/bash 

csound -+rtaudio=alsa -o dac -b512 -B512 -m 0 -d wii_jazz2.orc wii-w1.sco
