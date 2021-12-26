#!/bin/bash

if ! command -v gcc &> /dev/null; then
    sudo apt install gcc
fi
