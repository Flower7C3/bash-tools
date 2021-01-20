#!/usr/bin/env bash

ffmpeg -framerate 15 -i img%05d.JPG -vf format=yuv420p video.mp4
