## tugpgp

An utility to create and upload OpenPGP keys to Yubikey. The tool will not write the generated key on disk unless specifically asked.

Under active development.


### LICENSE: GPL-3.0-or-later

## Install the dependencies

### On Linux

`apt install python3-newt` or `dnf install python3-newt`.

### On Mac

`brew install newt` on Mac.


### Next create the virtualenv

```
python3 -m venv .venv --system-site-packages
source .venv/bin/activate/
python3 -m pip install johnnycanencrypt
```

This requires
[Johnnycanencrypt](https://github.com/kushaldas/johnnycanencrypt/), check the
readme there for build instructions. Best option is to build a wheel file
locally and then to use it. In future we will make sure to provide these
wheels.

### How to use the tool?


```
python3 -m tugpgp
```

![](./images/tugpgp_01.png)

