
import os

os.environ['KERAS_BACKEND'] = 'theano'

# different versions of conda keep the path in different variables
if 'CONDA_ENV_PATH' in os.environ:
    conda_env_path = os.environ['CONDA_ENV_PATH']
elif 'CONDA_PREFIX' in os.environ:
    conda_env_path = os.environ['CONDA_PREFIX']
else:
    conda_env_path = '.'

os.environ['MKL_THREADING_LAYER'] = 'GNU'
os.environ['THEANO_FLAGS'] = 'floatX=float32,device=cuda0,dnn.enabled=False,' \
                             + 'dnn.library_path=' + os.path.join(conda_env_path, 'lib') + ',' \
                             + 'dnn.include_path=' + os.path.join(conda_env_path, 'include')
if 'LD_LIBRARY_PATH' in os.environ:
    os.environ['LD_LIBRARY_PATH'] = os.path.join(conda_env_path, 'lib') + ':' \
                                    + '/usr/lib/x86_64-linux-gnu:' \
                                    + '/usr/lib/nvidia-384:' \
                                    + os.environ['LD_LIBRARY_PATH']
else:
    os.environ['LD_LIBRARY_PATH'] = os.path.join(conda_env_path, 'lib') + ':' \
                                    + '/usr/lib/x86_64-linux-gnu:' \
                                    + '/usr/lib/nvidia-384'

if 'LIBRARY_PATH' in os.environ:
    os.environ['LIBRARY_PATH'] = os.path.join(conda_env_path, 'lib') + ':' \
                                 + '/usr/lib/x86_64-linux-gnu:' \
                                 + '/usr/lib/nvidia-384:' \
                                 + os.environ['LIBRARY_PATH']
else:
    os.environ['LIBRARY_PATH'] = os.path.join(conda_env_path, 'lib') + ':' \
                                 + '/usr/lib/x86_64-linux-gnu:' \
                                 + '/usr/lib/nvidia-384'

if 'CPATH' in os.environ:
    os.environ['CPATH'] = os.path.join(conda_env_path, 'include') + ':' \
                          + os.environ['CPATH']
else:
    os.environ['CPATH'] = os.path.join(conda_env_path, 'include')

if 'PATH' in os.environ:
    os.environ['PATH'] = '/usr/lib/nvidia-384:' \
                          + os.environ['PATH']
else:
    os.environ['PATH'] = '/usr/lib/nvidia-384'

os.environ['DEVICE'] = 'cuda0'
#os.environ['GPUARRAY_FORCE_CUDA_DRIVER_LOAD'] = '1'
#import pygpu
#pygpu.test()

import theano

