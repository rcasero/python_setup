**Note: This project is deprecated. Just kept here as a historical record.**

Table of Contents
=================

   * [Table of Contents](#table-of-contents)
   * [Summary](#summary)
   * [Creating an environment for Keras](#creating-an-environment-for-keras)
      * [With TensorFlow as the backend](#with-tensorflow-as-the-backend)
      * [With Theano as the backend](#with-theano-as-the-backend)
   * [Testing environments](#testing-environments)
   * [Common errors](#common-errors)
      * [Cannot activate the conda environment](#cannot-activate-the-conda-environment)
      * [Theano cannot compile cudnn library](#theano-cannot-compile-cudnn-library)
      * [Theano cannot find cudnn library](#theano-cannot-find-cudnn-library)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

# Summary

**python_setup** are some scripts to install dependencies and set up conda environments, mostly for machine learning and image processing python projects.

I use Ubuntu and bash, so the scripts may need some tweaking to work in other setups.

List of scripts:
* **install_miniconda.sh:** Install Miniconda in Ubuntu to provide conda.
* **install_cuda.sh:** Install Nvidia drivers and CUDA Toolkit in Ubuntu.
* **install_keras_environment.sh:** Install Ubuntu dependencies and create a conda environment for the master version of Keras.
* **build_SimpleElastix.sh:** This script downloads the [SimpleElastix source code](https://github.com/SuperElastix/SimpleElastix) and and creates a conda local environment to build it. Afterwards, the user or another script can install SimpleElastix for python in another local environment.
* **install_deepcell_environment.sh:** Install Ubuntu dependencies and create a DeepCell conda environment to run [DeepCell](https://github.com/CovertLab/DeepCell/) architectures using Keras 1/Theano.

# Creating an environment for Keras

[Official instructions to install Keras](https://keras.io/#installation) are available from the Keras website. These here are some personal notes on how to install Keras in a particular way that works for me, using the scripts I provide in this project.

First, you need to have installed NVIDIA drivers and CUDA globally in the machine, e.g. (this only needs to be done once per machine)

```
cd ~/Software/python_setup/bin
./install_cuda.sh nvidia_9.0_ubuntu_17.04
```

Then, you need to install conda globally in your machine (this only needs to be done once too), e.g. for Miniconda 3

```
./install_miniconda.sh 3
```

Then, create a conda environment for Keras projects. You need to choose which backend you want to use, `tensorflow` or `theano` ([Theano is being phased out](https://groups.google.com/d/msg/theano-users/7Poq8BZutbY/rNCIfvAEAwAJ))

## With TensorFlow as the backend

```
./install_keras_environment.sh  -e my_environment -b tensorflow
```

Afterwards, you can make a directory for the project, and activate the local environment (note that one local environment can be used for several projects)

```
cd ~/Software
mkdir new_project
cd new_project
source activate my_environment
```

## With Theano as the backend

```
./install_keras_environment.sh  -e my_environment -b theano
```

Afterwards, you can make a directory for the project, and activate the local environment (note that one local environment can be used for several projects)

```
cd ~/Software
mkdir new_project
cd new_project
source activate my_environment
```

# Testing environments

Once you have created an environment with Keras, you can test it with `pytest`, e.g.

```
cd ~/Software/python_setup
source activate my_environment
```
If the environment is for TensorFlow

```
pytest test/test_tensorflow_setup.py
```

and if everything is fine, you should get an output like this (the warning will disappear in future versions of `h5py`)

```
===================================== test session starts ======================================
platform linux -- Python 3.6.2, pytest-3.4.2, py-1.5.2, pluggy-0.6.0
rootdir: /home/rcasero/Software/python_setup, inifile:
collected 1 item                                                                               

test/test_tensorflow_setup.py .                                                          [100%]

======================================= warnings summary =======================================
test/test_tensorflow_setup.py::test_keras_tensorflow
  /home/rcasero/.conda/envs/cytometer_tensorflow/lib/python3.6/site-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
    from ._conv import register_converters as _register_converters

-- Docs: http://doc.pytest.org/en/latest/warnings.html
============================= 1 passed, 1 warnings in 0.82 seconds =============================```
```

Or, if the backend is Theano,

```
pytest test/test_theano_setup.py
```

and if everything is fine, you should get an output like this

```
===================================== test session starts ======================================
platform linux -- Python 3.5.4, pytest-3.4.2, py-1.5.2, pluggy-0.6.0
rootdir: /home/rcasero/Software/python_setup, inifile:
collected 1 item                                                                               

test/test_theano_setup.py .                                                              [100%]

=================================== 1 passed in 1.95 seconds ===================================
```

# Common errors

These errors apply to the following set up: 

* An NVIDIA graphics card (in my case, GeForce GTX 1060 6GB).
* NVIDIA drivers and CUDA installed globally in Ubuntu linux (currently 17.10) using the script `install_cuda.sh` provided in this project
  * Currently working with CUDA 9.0 installed from the NVIDA website, not the Ubuntu packages
* Conda 3 installed with the script `install_miniconda.sh` provided in this project.
* Python projects running in local [conda environments](https://conda.io/docs/user-guide/tasks/manage-environments.html)
  * Thus, python packages are installed to e.g. `~/.conda/envs/MY_CONDA_ENVIRONMENT/lib/python3.5/site-packages/`
* Keras 2 installed with script `install_keras_environment.sh` provided in this project, in a conda environment
  * Separate environments for Keras with Theano or Keras with TensorFlow
* [Theano bleeding-edge installation](http://deeplearning.net/software/theano/install_ubuntu.html#bleeding-edge-installation-recommended)

## Cannot activate the conda environment

If you are trying to activate a conda environment from the `bash` command line and get the error

```
$ source activate my_local_environment
bash: activate: No such file or directory
```

you may be missing a path like this in your `~/.bashrc`, that should have been added by `install_miniconda.sh` when you ran it

```
# added by pysto/tools/install_miniconda.sh
export PATH=/opt/miniconda3/bin:"$PATH"
```

## Theano cannot compile cudnn library

If you are trying to import theano with cuDNN in python, e.g.

```
import os
os.environ['KERAS_BACKEND'] = 'theano'
os.environ['THEANO_FLAGS'] = 'floatX=float32,device=cuda0,dnn.enabled=True'

import theano
```

you can get the error

```
RuntimeError: You enabled cuDNN, but we aren't able to use it: cannot compile with cuDNN. We got this error:
b'/tmp/try_flags__rve35p_.c:4:10: fatal error: cudnn.h: No such file or directory\n #include <cudnn.h>\n 
```

To let ~Theano find the required include files and libraries in the conda environment, you can use something like

```
os.environ['THEANO_FLAGS'] = 'floatX=float32,device=cuda0,dnn.enabled=True,' \
                             + 'dnn.library_path=' + os.path.join(conda_env_path, 'lib') + ',' \
                             + 'dnn.include_path=' + os.path.join(conda_env_path, 'include')
```

where `conda_env_path` is a variable with the path to your conda environment, e.g. `conda_env_path=/home/myuser/.conda/envs/MY_CONDA_ENVIRONMENT`.

## Theano cannot find cudnn library

With the previous section change, Theano can compile cuDNN, but cannot find it as a library, e.g.

```
import os
os.environ['KERAS_BACKEND'] = 'theano'
os.environ['THEANO_FLAGS'] = 'floatX=float32,device=cuda0,dnn.enabled=True,' \
                             + 'dnn.library_path=' + os.path.join(conda_env_path, 'lib') + ',' \
                             + 'dnn.include_path=' + os.path.join(conda_env_path, 'include')

import theano
```

gives the error

```
RuntimeError: Could not find cudnn library (looked for v5* to v7*). Check your cudnn installation. Maybe using the Theano flag dnn.base_path can help you. Current value ""
```

You can fix this adding the path to the library to the environment variable `LIBRARY`, e.g.

```
# to tell Theano to use cuDNN, and where the include files and libraries required for compilation are
os.environ['THEANO_FLAGS'] = 'floatX=float32,device=cuda0,dnn.enabled=True,' \
                             + 'dnn.library_path=' + os.path.join(conda_env_path, 'lib') + ',' \
                             + 'dnn.include_path=' + os.path.join(conda_env_path, 'include')
```
