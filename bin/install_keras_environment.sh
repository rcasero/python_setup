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

# install Miniconda 3
${THIS_DIR}/install_miniconda.sh 3

# install CUDA toolkit
#
#    Options:
#
#      ubuntu_packages: (def) From Ubuntu official packages.
#
#      nvidia_ubuntu_16.04: From the Nvidia website, CUDA 9.1 .deb packages for Ubuntu 16.04 (x86_64).
#
#      nvidia_ubuntu_17.04: From the Nvidia website, CUDA 9.1 .deb packages for Ubuntu 17.04 (x86_64),
#                           with Patch 1 (Released Jan 25, 2018)
${THIS_DIR}/install_cuda.sh ubuntu_packages
#${THIS_DIR}/install_cuda.sh nvidia_ubuntu_17.04

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

# check that the variable with the path to the local environment is set
if [[ ! -v CONDA_PREFIX ]];
then
    echo "Error! Variable CONDA_PREFIX not set in this local environment: $CONDA_ENV"
    exit 1
fi

# install Keras
pip install git+https://github.com/fchollet/keras.git --upgrade --no-deps

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
	
	# fix bug: 'To use MKL 2018 with Theano you MUST set "MKL_THREADING_LAYER=GNU" in your environement.'
	export MKL_THREADING_LAYER=GNU

	# install Theano's latest version
	pip install git+https://github.com/Theano/Theano.git --upgrade --no-deps

	# install dependencies for theano
	conda install -y Cython numpy<=1.12 scipy<0.17.1 mkl-service nose>=1.3.0 sphinx>=0.5.1 pygments pydot-ng cudnn 

	# install libgpuarray from source, with python bindings
	cd ~/Software
	if [ -d libgpuarray ]; then # previous version present
	    cd libgpuarray
	    git checkout tags/v0.7.5
	else # no previous version exists
	    git clone --branch v0.7.5 https://github.com/Theano/libgpuarray.git
	    cd libgpuarray
	    mkdir Build
	fi
	cd Build
	cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$CONDA_PREFIX
	make
	make install
	cd ..
	python setup.py -q build_ext -L $CONDA_PREFIX/lib -I $CONDA_PREFIX/include
	python setup.py -q install --prefix=$CONDA_PREFIX
	
	# clear Theano cache. Previous runs of Keras may cause CUDA compilation/version compatibility problems
	theano-cache purge
	
	;;
    
    *)
	echo "** Error: Backend no recognised"
	exit 1
	;;
esac

exit 0

# install Tensorflow, Theano and keras latest version from source
pip install nose-parameterized
conda install -y scipy Cython mkl-service 
pip install pycuda scikit-cuda

# install libgpuarray from source, with python bindings
cd ~/Software
if [ -d libgpuarray ]; then # previous version present
    cd libgpuarray
    git pull
else # no previous version exists
    git clone https://github.com/Theano/libgpuarray.git
    cd libgpuarray
    mkdir Build
fi
cd Build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$CONDA_PREFIX
make
make install
cd ..
python setup.py -q build_ext -L $CONDA_PREFIX/lib -I $CONDA_PREFIX/include
python setup.py -q install --prefix=$CONDA_PREFIX

# clear Theano cache. Previous runs of Keras may cause CUDA compilation/version compatibility problems
theano-cache purge

tput setaf 1; echo "** Exiting install_keras_environment.sh"; tput sgr0
