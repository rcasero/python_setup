
def test_keras_theano():
    """
    Minimalist import of Keras with Theano as backend
    :return:
    """

    import os

    os.environ['KERAS_BACKEND'] = 'theano'

    # different versions of conda keep the path in different variables
    if 'CONDA_ENV_PATH' in os.environ:
        conda_env_path = os.environ['CONDA_ENV_PATH']
    elif 'CONDA_PREFIX' in os.environ:
        conda_env_path = os.environ['CONDA_PREFIX']
    else:
        conda_env_path = '.'

    # to avoid error "RuntimeError: Could not find cudnn library (looked for v5* to v7*). Check your cudnn installation."
    if 'LIBRARY_PATH' in os.environ:
        os.environ['LIBRARY_PATH'] = os.path.join(conda_env_path, 'lib') + ':' \
                                     + os.environ['LIBRARY_PATH']
    else:
        os.environ['LIBRARY_PATH'] = os.path.join(conda_env_path, 'lib')

    # to tell Theano to use cuDNN, and where the include files and libraries required for compilation are
    os.environ['THEANO_FLAGS'] = 'floatX=float32,device=cuda0,dnn.enabled=True,' \
                                 + 'dnn.library_path=' + os.path.join(conda_env_path, 'lib') + ',' \
                                 + 'dnn.include_path=' + os.path.join(conda_env_path, 'include')

    import theano
    import keras

