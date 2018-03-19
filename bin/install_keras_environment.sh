# file: install_keras_environment.sh
#
#    Summary:
#    ====================================================================
#
#    Install Ubuntu dependencies and create a conda environment for
#    the master version of Keras.
#
#    Syntax:
#    ====================================================================
#
#    ./install_keras_environment.sh -e conda_env -b tensorflow|theano
#
#    Options:
#
#    -e conda_env:
#       name of the conda environment to be created or added to (def. "keras").
#
#    -b tensorflow|theano:
#       backend for keras (def. "tensorflow").
#
#    Prerequisites:
#    ====================================================================
#
#    You need to have installed conda (for local conda environments and python
#    package management) and CUDA (for access to your Nvidia GPU). We provide
#    scripts for both in this repository.
#
#    To install conda with Miniconda v3, you can use
#
#        ./install_miniconda 3
#
#    To install the Nvidia drivers and CUDA, use e.g.
#
#        ./install_cuda.sh nvidia_9.0_ubuntu_17.04
#
#    The particular version depends on your system, the version of Ubuntu you have
#    installed and your graphics card (e.g. my GeForce GTX 1050 Mobile doesn't work
#    with the Nvidia drivers v387, so I cannot use CUDA 9.1, and need to use CUDA 9.0).

#    Author: Ramon Casero <rcasero@gmail.com>
#    Version: 1.0
#    Copyright © 2018  Ramón Casero <rcasero@gmail.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

#!/bin/bash

# exit immediately on errors that are not inside an if test, etc.
set -e

# defaults for input arguments
CONDA_ENV=keras
BACKEND=tensorflow

# read input arguments
while getopts e:b: option
do
    case "${option}"
    in
	e) CONDA_ENV=${OPTARG};;
	b) BACKEND=${OPTARG};;
    esac
done

######################################################################
## DEPENDENCIES COMMON TO ALL BACKENDS
######################################################################

# directory where this script lives
THIS_DIR=`dirname $0`

######################################################################

tput setaf 1; echo "** Build tools"; tput sgr0

# build tools
sudo apt install -y cmake

# python IDE
sudo snap install pycharm-community --classic

######################################################################
## python conda environment

# select python version
case "${BACKEND}"
in
    tensorflow)
	PYTHON_VERSION=3.6
	;;
    
    theano) 
	PYTHON_VERSION=3.5
	;;
    
    *)
	echo "** Error: Backend no recognised"
	exit 1
	;;
esac

# if the environment doesn't exist, we create a new one. If it does,
# we add the python packages to it

# check whether the environment already exists
if [ -z "$(conda info --envs | sed '/^#/ d' | cut -f1 -d ' ' | grep -w $CONDA_ENV)" ]; then
    tput setaf 1; echo "** Create conda local environment: $CONDA_ENV"; tput sgr0
    conda create -y --name $CONDA_ENV python=$PYTHON_VERSION
else
    tput setaf 1; echo "** Conda local environment already exists: $CONDA_ENV"; tput sgr0
fi

# switch to the local environment
source activate $CONDA_ENV

# check that the variable with the path to the local environment is
# set. Note that different versions of conda use different variable
# names for the path
if [[ ! -v CONDA_PREFIX ]];
then
    if [[ ! -v CONDA_ENV_PATH ]];
    then
	echo "Error! Neither CONDA_PREFIX nor CONDA_ENV_PATH set in this local environment: $CONDA_ENV"
	exit 1
    else
	CONDA_PREFIX="$CONDA_ENV_PATH"
    fi
fi

######################################################################
## DEPENDENCIES SPECIFIC TO EACH BACKEND
######################################################################

case "${BACKEND}"
in
    tensorflow)
	echo "** Dependencies for Tensorflow backend"

	pip install tensorflow-gpu pyyaml
	;;
    
    theano) 
	echo "** Dependencies for Theano backend"
	
	# install Theano's latest version (with dependencies: numpy, scipy, six)
	pip install git+https://github.com/Theano/Theano.git --upgrade

	# install dependencies for theano
	conda install -y -c mila-udem pygpu # libgpuarray, mako, markupsafe, mkl, numpy, pygpu, six
	conda install -y 'nose>=1.3.0'      # to run Theano’s test-suite
	conda install -y 'sphinx>=0.5.1'    # for building the documentation
	conda install -y pygments           # for building the documentation
	pip install pydot-ng                # to handle large picture for gif/images
	pip install pycuda                  # for some extra operations on the GPU like fft and solvers
	pip install git+https://github.com/lebedov/scikit-cuda.git#egg=scikit-cuda # for some extra operations on the GPU like fft and solvers
	#conda install -y warp-ctc           # for Theano CTC implementation
	conda install -y mkl-service        # BLAS installation (with Level 3 functionality)
	;;
    
    *)
	echo "** Error: Backend no recognised"
	exit 1
	;;
esac

	
# install Keras
pip install keras

# install dependencies for Keras
conda install -y cudnn              # to run Keras on GPU
conda install -y h5py               # to save Keras models to disk
conda install -y graphviz           # used by visualization utilities to plot model graphs
pip install pydot                   # used by visualization utilities to plot model graphs

tput setaf 1; echo "** Exiting install_keras_environment.sh"; tput sgr0
