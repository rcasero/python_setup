# python_setup
Scripts to install dependencies and set up python environments (mostly for machine learning and image processing).

I use Ubuntu, so the scripts may need some tweaking to work in other distributions.

* **build_SimpleElastix.sh:** This script downloads the SimpleElastix source code and and creates a conda local environment to build it. Afterwards, the user or another script can install SimpleElastix for python in another local environment.
* **install_cuda.sh:** Install Nvidia CUDA Toolkit in Ubuntu.
* **install_deepcell_environment.sh:** Install Ubuntu dependencies and create a DeepCell conda environment to run [DeepCell](https://github.com/CovertLab/DeepCell/) architectures using Keras 1/Theano.
* **install_keras_environment.sh:** Install Ubuntu dependencies and create a conda environment for the master version of Keras.
* **install_miniconda.sh:** Install Miniconda in Ubuntu to provide conda.
