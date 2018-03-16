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
    
    ubuntu_packages)
	
	# Option 1. CUDA Toolkit from the Ubuntu distribution packages
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
    
    nvidia_9.1_ubuntu_16.04)

	# Option 2. From Nvidia website:
	# CUDA Toolkit 9.1 for Ubuntu 16.04
	CUDA_VERSION=cuda-repo-ubuntu1604-9-1-local_9.1.85-1_amd64
	;;
    
    nvidia_9.1_ubuntu_17.04)

	# Option 2. From Nvidia website:
	# CUDA Toolkit 9.1 for Ubuntu 17.04
	CUDA_VERSION=cuda-repo-ubuntu1704-9-1-local_9.1.85-1_amd64
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
echo "** Install Nvidia website packages"

# check whether package cuda is already installed
#
# The following line of code produces 0 if the package is not listed
# yet in APT or is not installed, and 1 if it's installed. E.g.,
# assuming that the cuda package is installed
#
#   $ dpkg-query -l cuda 2>/dev/null
#   Desired=Unknown/Install/Remove/Purge/Hold
#   | Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
#   |/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
#   ||/ Name                    Version          Architecture     Description
#   +++-=======================-================-================-====================================================
#   ii  cuda                    9.1.85-1         amd64            CUDA meta-package
#
#   $ dpkg-query -l cuda 2>/dev/null| tail -n 1
#   ii  cuda           9.1.85-1     amd64        CUDA meta-package
#
#   $ dpkg-query -l cuda 2>/dev/null| tail -n 1 | sed 's/  */ /g'
#   ii cuda 9.1.85-1 amd64 CUDA meta-package
#
#   $ dpkg-query -l cuda 2>/dev/null| tail -n 1 | sed 's/  */ /g' | cut -f 3 -d ' '
#   9.1.85-1
#
#   $ dpkg-query -l cuda 2>/dev/null| tail -n 1 | sed 's/  */ /g' | cut -f 3 -d ' ' | sed 's/[a-Z<>]//g'
#   9.1.85-1
#
#   $ dpkg-query -l cuda 2>/dev/null | tail -n 1 | sed 's/  */ /g' | cut -f 3 -d ' ' | sed 's/[a-Z<>]//g' | wc -w
#   1

CHECK=`dpkg-query -l cuda 2>/dev/null | tail -n 1 | sed 's/  */ /g' | cut -f 3 -d ' ' | sed 's/[a-Z<>]//g' | wc -w`

if [ $CHECK -eq 0 ]
then
    echo "** Installing cuda package"
    pushd ~/Downloads
    if [ ! -e "${CUDA_VERSION}.deb" ];
    then
	wget https://developer.nvidia.com/compute/cuda/9.1/Prod/local_installers/${CUDA_VERSION}
	mv ${CUDA_VERSION} ${CUDA_VERSION}.deb
    fi
    sudo dpkg -i ${CUDA_VERSION}.deb
    sudo apt-key add /var/cuda-repo-9-1-local/7fa2af80.pub
    sudo apt-get update
    sudo apt-get install -y cuda

    # add cuda to the path
    set +e
    isInBashrc=`grep  -c "export PATH=/usr/local/cuda-9.1/bin" ~/.bashrc`
    set -e
    if [ "$isInBashrc" -eq 0 ];
    then
	echo "Adding /usr/local/cuda-9.1/bin to PATH in ~/.bashrc"
	echo "
# added by pysto/tools/install_cuda.sh
export PATH=/usr/local/cuda-9.1/bin:\"\$PATH\"" >> ~/.bashrc
	source ~/.bashrc
    else
	echo "/usr/local/cuda-9.1/bin already in PATH in ~/.bashrc"
    fi
       
    popd
else
    echo "** cuda package already installed, skipping"
fi

# install patch to version for Ubuntu 17.04
if [ "${CUDA_VERSION}" == "cuda-repo-ubuntu1704-9-1-local_9.1.85-1_amd64" ];
then 
    echo "** Patching cuda package"
    pushd ~/Downloads
    if [ ! -e "cuda-repo-ubuntu1704-9-1-local-cublas-performance-update-1_1.0-1_amd64.deb" ];
    then
	wget https://developer.nvidia.com/compute/cuda/9.1/Prod/patches/1/cuda-repo-ubuntu1704-9-1-local-cublas-performance-update-1_1.0-1_amd64
	mv cuda-repo-ubuntu1704-9-1-local-cublas-performance-update-1_1.0-1_amd64 cuda-repo-ubuntu1704-9-1-local-cublas-performance-update-1_1.0-1_amd64.deb
    fi
    sudo dpkg -i cuda-repo-ubuntu1704-9-1-local-cublas-performance-update-1_1.0-1_amd64.deb
fi

# output which version of CUDA has been installed
tput setaf 1; echo "** Installed CUDA version:"; tput sgr0
nvcc --version
