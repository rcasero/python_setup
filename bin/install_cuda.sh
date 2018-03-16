# file: install_cuda.sh
#
#    Summary:
#    ====================================================================
#
#    Install Nvidia CUDA Toolkit in Ubuntu.
#
#    Syntax:
#    ====================================================================
#
#    ./install_cuda.sh [ubuntu_packages | nvidia_9.1_ubuntu_16.04 | nvidia_9.1_ubuntu_17.04]
#
#    Options:
#
#      ubuntu_packages: (def) From Ubuntu official packages.
#
#      nvidia_9.0_ubuntu_17.04: From the Nvidia website, CUDA 9.0 .deb packages for Ubuntu 17.04 (x86_64),
#                               with Patch 1 (Released Jan 25, 2018) and Patch 2 (Released Mar 5, 2018)
#
#      nvidia_9.1_ubuntu_16.04: From the Nvidia website, CUDA 9.1 .deb packages for Ubuntu 16.04 (x86_64).
#
#      nvidia_9.1_ubuntu_17.04: From the Nvidia website, CUDA 9.1 .deb packages for Ubuntu 17.04 (x86_64),
#                               with Patch 1 (Released Jan 25, 2018)
#
#    Note: If you choose an Nvidia website installation, and the cuda
#      package is already installed, installation is skipped. To
#      manually uninstall the previous version:
#
#      sudo apt remove -y --purge cuda
#      sudo apt autoremove -y --purge


#!/bin/bash

# exit immediately on errors that are not inside an if test, etc.
set -e

# assign default input argument
if [ "$#" -eq 0 ]
then
    # default input value
    CUDA_TYPE=ubuntu_packages
else
    # input value provided by user
    CUDA_TYPE="$1"
fi

######################################################################

tput setaf 1; echo "** Installing Nvidia CUDA Toolkit"; tput sgr0

## CUDA Toolkit installation. There are several options (uncomment the preferred one):

case "$CUDA_TYPE"
in

    # For the Ubuntu packages, we do all the installation here, and then exit the script
    
    ubuntu_packages)
	
	# CUDA Toolkit from the Ubuntu distribution packages
	echo "** Remove Nvidia website packages, if present, as they take the same role as Ubuntu official packages"
	set +e
	sudo apt remove -y --purge cuda
	sudo apt autoremove -y
	set -e
	echo "** Install current Ubuntu official packages"
	# Note: My workstation with a GeForce GTX 1060 6GB graphics card doesn't boot with nvidia-387, but work with nvidia-384
	sudo apt install -y nvidia-cuda-dev nvidia-cuda-toolkit nvidia-384
	
	# output which version of CUDA has been installed
	tput setaf 1; echo "** Installed CUDA version:"; tput sgr0
	nvcc --version
	
	exit 0
	;;

    # For the packages directly from the NVIDIA website, here we only
    # assign variable names, and then in the rest of the script we
    # take care of the installation of the packages
    
    nvidia_9.0_ubuntu_17.04)
	
	# From Nvidia website:
	# CUDA Toolkit 9.0 for Ubuntu 17.04
	CUDA_VERSION=9.0
	CUDA_PACKAGE=cuda-repo-ubuntu1704-9-0-local_9.0.176-1_amd64-deb
	CUDA_URL=https://developer.nvidia.com/compute/cuda/9.0/Prod/local_installers/${CUDA_PACKAGE}
	;;

    nvidia_9.1_ubuntu_16.04)
	
	# From Nvidia website:
	# CUDA Toolkit 9.1 for Ubuntu 16.04
	CUDA_VERSION=9.1
	CUDA_PACKAGE=cuda-repo-ubuntu1604-9-1-local_9.1.85-1_amd64
	CUDA_URL=https://developer.nvidia.com/compute/cuda/9.1/Prod/local_installers/${CUDA_PACKAGE}
	;;
    
    nvidia_9.1_ubuntu_17.04)

	# From Nvidia website:
	# CUDA Toolkit 9.1 for Ubuntu 17.04
	CUDA_VERSION=9.1
	CUDA_PACKAGE=cuda-repo-ubuntu1704-9-1-local_9.1.85-1_amd64
	CUDA_URL=https://developer.nvidia.com/compute/cuda/9.1/Prod/local_installers/${CUDA_PACKAGE}
	;;

    *)
	
	echo "Error: Option not recognised: $CUDA_TYPE"
	exit 1
	;;
esac

## Common code to NVIDA website CUDA Toolkit installation

echo
echo "** Remove Ubuntu official packages, if present"
set +e
sudo apt remove -y --purge nvidia-cuda-dev nvidia-cuda-toolkit
sudo apt autoremove -y
set -e

echo
echo "** Install packages from Nvidia website"

# check whether package cuda with the desired version is already installed

set +e
# we only want the major.minor part of the version number, e.g. 9.1.85-1 -> 9.1
CUDA_PACKAGE_INSTALLED_VERSION=`dpkg-query --showformat='${Version}' --show cuda | grep -o '^[0-9]*\.[0-9]*'`
set -e

# if there's an installed cuda package, with the version we want, we can skip re-installation
if [ ! -z $CUDA_PACKAGE_INSTALLED_VERSION ] && [ $CUDA_PACKAGE_INSTALLED_VERSION == $CUDA_VERSION ]
then
    echo "** cuda package already installed, skipping"

else
    echo "** Removing cuda package with undesired version"
    set +e
    sudo apt remove --purge -y cuda
    sudo apt autoremove -y
    sudo apt remove --purge cuda-repo-*
    set -e
    export CUDA_PACKAGE_INSTALLED_VERSION=""
    
    echo "** Installing cuda package"
    pushd ~/Downloads
    if [ ! -e "${CUDA_PACKAGE}.deb" ];
    then
	wget ${CUDA_URL}
	mv ${CUDA_PACKAGE} ${CUDA_PACKAGE}.deb
    fi
    sudo dpkg -i ${CUDA_PACKAGE}.deb
    case "$CUDA_VERSION"
    in
	9.0)
	    sudo apt-key add /var/cuda-repo-9-0-local/7fa2af80.pub ;;
	9.1)
	    sudo apt-key add /var/cuda-repo-9-1-local/7fa2af80.pub ;;
    esac
    sudo apt update
    sudo apt install -y cuda

    # add cuda to the path
    set +e
    isInBashrc=`grep  -c "export PATH=/usr/local/cuda-${CUDA_VERSION}/bin" ~/.bashrc`
    set -e
    if [ "$isInBashrc" -eq 0 ];
    then
	echo "Adding /usr/local/cuda-${CUDA_VERSION}/bin to PATH in ~/.bashrc"
	echo "
# added by pysto/tools/install_cuda.sh
export PATH=/usr/local/cuda-${CUDA_VERSION}/bin:\"\$PATH\"" >> ~/.bashrc
	source ~/.bashrc
    else
	echo "/usr/local/cuda-${CUDA_VERSION}/bin already in PATH in ~/.bashrc"
    fi
       
    popd
fi

# install patches when available
case "$CUDA_VERSION"
in
    9.0)
	
	echo "** Patching cuda 9.0 package"
	pushd ~/Downloads
	PATCH=cuda-repo-ubuntu1704-9-0-local-cublas-performance-update_1.0-1_amd64-deb
	if [ ! -e "$PATCH.deb" ];
	then
	    wget https://developer.nvidia.com/compute/cuda/9.0/Prod/patches/1/${PATCH}
	    mv ${PATCH} ${PATCH}.deb
	fi
	sudo dpkg -i ${PATCH}.deb
	PATCH=cuda-repo-ubuntu1704-9-0-local-cublas-performance-update-2_1.0-1_amd64-deb
	if [ ! -e "$PATCH.deb" ];
	then
	    wget https://developer.nvidia.com/compute/cuda/9.0/Prod/patches/2/${PATCH}
	    mv ${PATCH} ${PATCH}.deb
	fi
	sudo dpkg -i ${PATCH}.deb
	;;

    9.1)
	
	echo "** Patching cuda 9.1 package"
	pushd ~/Downloads
	PATCH=cuda-repo-ubuntu1704-9-1-local-cublas-performance-update-1_1.0-1_amd64
	if [ ! -e "$PATCH.deb" ];
	then
	    wget https://developer.nvidia.com/compute/cuda/9.1/Prod/patches/1/${PATCH}
	    mv ${PATCH} ${PATCH}.deb
	fi
	sudo dpkg -i ${PATCH}.deb
	;;
esac

# output which version of CUDA has been installed
tput setaf 1; echo "** Installed CUDA version:"; tput sgr0
/usr/local/cuda-${CUDA_VERSION}/bin/nvcc --version
