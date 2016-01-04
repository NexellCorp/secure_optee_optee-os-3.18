#!/bin/bash

make build-optee-linuxdriver
cp optee_linuxdriver/armtz/optee_armtz.ko ./
cp optee_linuxdriver/core/optee.ko ./
