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
