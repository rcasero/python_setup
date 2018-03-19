
def test_keras_tensorflow():
    """
    Minimalist import of Keras with Tensorflow as backend
    :return:
    """

    import os

    os.environ['KERAS_BACKEND'] = 'tensorflow'

    # different versions of conda keep the path in different variables
    if 'CONDA_ENV_PATH' in os.environ:
        conda_env_path = os.environ['CONDA_ENV_PATH']
    elif 'CONDA_PREFIX' in os.environ:
        conda_env_path = os.environ['CONDA_PREFIX']
    else:
        conda_env_path = '.'

    import keras

