# Using Python 3.6 and 2.7

## Mac

6.036 Instructions:
1. To install xcode tools, type `sudo xcode-select --install` in the terminal and follow instructions.
2. Check if you already have Python 3.5. If not, get the installer here Python 3.6.4 for Mac OS X 10.6+
3. Type `pip3 -V` in the terminal and check that pip is intalled for Python 3.5+
4. Install Numpy and Matplotlib with `sudo pip3 install --upgrade numpy matplotlib`
5. Install Tensorflow with `sudo pip3 install --upgrade tensorflow`. If this command does not work, use `sudo python3 -m pip install --upgrade https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-0.12.0-py3-none-any.whl`
6. Install Keras with `sudo pip3 install --upgrade keras==2.0.0`
7. Create Keras by typing `python3` and then `import keras`
`cat ~/.keras/keras.json` and make sure the backend is tensorflow.

Perfect and clean

## Ubuntu

Python 3.5 is too strongly baked into Ubuntu 16. Don’t attempt to `apt remove` it! [Source][1]
6.036 instructions assume 3.6 in repo, unusable.

Install python3.6
```bash
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install python3.6
```

Delete pip for 3.5, install pip
```bash
curl https://bootstrap.pypa.io/get-pip.py | sudo python3.6
```

Necessaries
```bash
sudo -H pip install numpy scipy matplotlib pandas sklearn jupyter
sudo -H pip install tensorflow-gpu
sudo -H pip install keras
```

_Warning: forgot to uninstall jupyter beforehands, system is slightly dirty; functional nevertheless._

[1]:	https://askubuntu.com/questions/865554/how-do-i-install-python-3-6-using-apt-get