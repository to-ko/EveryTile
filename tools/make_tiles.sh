#!/bin/bash

sed "s#[^ ]\+ [^ ]\+ [^ ]\+ [^ <]\+</coordinates>#\n#g" explorer2.kml |sed "s/.*<coordinates>//" | sed "s/,/ /" | sed "s#</LineString>.*##">tiles.txt

