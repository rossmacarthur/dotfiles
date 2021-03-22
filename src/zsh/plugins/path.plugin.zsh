#!/usr/bin/env bash

# Add a directory to the PATH environment variable.
path_push() {
    path_remove "$1"
    PATH=$1:$PATH
}

# Add a directory to the back of the PATH environment variable.
path_push_back() {
    path_remove "$1"
    PATH=$PATH:$1
}

# Remove a directory from the PATH environment variable.
path_remove() {
    PATH=${PATH//":$1:"/":"} # delete any instances in the middle
    PATH=${PATH/#"$1:"/} # delete any instance at the beginning
    PATH=${PATH/%":$1"/} # delete any instance in the at the end
}
