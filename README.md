# python_setup
Scripts to install dependencies and set up python environments (mostly for machine learning and image processing).

I use Ubuntu, so the scripts may need some tweaking to work in other distributions.

* **build_SimpleElastix.sh:** This script downloads the SimpleElastix source code and and creates a conda local environment to build it. Afterwards, the user or another script can install SimpleElastix for python in another local environment.
* **install_cuda.sh:** Install Nvidia CUDA Toolkit in Ubuntu.
* **install_deepcell_environment.sh:** Install Ubuntu dependencies and create a DeepCell conda environment to run [DeepCell](https://github.com/CovertLab/DeepCell/) architectures using Keras 1/Theano.
* **install_keras_environment.sh:** Install Ubuntu dependencies and create a conda environment for the master version of Keras.
* **install_miniconda.sh:** Install Miniconda in Ubuntu to provide conda.

# Common errors

These errors apply to the following set up: 

* An NVIDIA graphics card (in my case, GeForce GTX 1060 6GB).
* NVIDIA drivers and CUDA installed globally in Ubuntu linux (currently 17.10) using the script `install_cuda.sh` provided in this project
  * Currently working with CUDA 9.0 installed from the NVIDA website, not the Ubuntu packages
* Conda 3 installed with the script `install_miniconda.sh` provided in this project.
* Python projects running in local [conda environments](https://conda.io/docs/user-guide/tasks/manage-environments.html)
  * Thus, python packages are installed to e.g. `~/.conda/envs/MY_CONDA_ENVIRONMENT/lib/python3.5/site-packages/`
* Keras 2 installed with script `install_keras_environment.sh` provided in this project, in a conda environment
  * Separate environments for Keras with Theano or Keras with Tensorflow
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
