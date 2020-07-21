# file: install_miniconda.sh
#
#    Summary:
#    ====================================================================
#
#    Install Miniconda in Ubuntu to provide conda.
#
#    Syntax:
#    ====================================================================
#
#    ./install_miniconda.sh [VERSION]
#
#         Install Miniconda. VERSION is the version number (def
#         VERSION=3). Miniconda will be installed in ~/Software/miniconda-${VERSION},
#         e.g. ~/Software/miniconda3 for version 3.

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

# assign default input argument
if [[ "$#" -eq 0 ]]
then
    # default input value
    VERSION=3
else
    # input value provided by user
    VERSION="$1"
fi

if [[ -d "${HOME}/Software/miniconda${VERSION}" ]];
then
    /usr/bin/tput setaf 1; echo "** Conda ${VERSION} package manager already installed"; /usr/bin/tput sgr0
else
    /usr/bin/tput setaf 1; echo "** Installing conda ${VERSION} package manager"; /usr/bin/tput sgr0
    mkdir -p ~/Dowloads
    pushd ~/Downloads
    # download installer
    if [[ ! -e "Miniconda${VERSION}-latest-Linux-x86_64.sh" ]];
    then
	wget https://repo.continuum.io/miniconda/Miniconda${VERSION}-latest-Linux-x86_64.sh
    fi
    # install conda
    chmod u+x Miniconda${VERSION}-latest-Linux-x86_64.sh
    ./Miniconda${VERSION}-latest-Linux-x86_64.sh -b -p "$HOME"/Software/miniconda${VERSION}
    set +e
    isInBashrc=`grep  -c "export PATH=${HOME}/Software/miniconda${VERSION}/bin" ~/.bashrc`
    set -e
    if [[ "$isInBashrc" -eq 0 ]];
    then
	echo "Adding ${HOME}/Software/miniconda${VERSION}/bin to PATH in ~/.bashrc"
	echo "
# added by pysto/tools/install_miniconda.sh
export PATH=${HOME}/Software/miniconda${VERSION}/bin:\"\$PATH\"" >> ~/.bashrc
	source ~/.bashrc
    else
	echo "${HOME}/Software/miniconda${VERSION}/bin already in PATH in ~/.bashrc"
    fi
    popd
fi
