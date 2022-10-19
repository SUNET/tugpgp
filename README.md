## tugpgp

An utility to create and upload OpenPGP keys to Yubikey. The tool will not write the generated key on disk unless specifically asked.

Under active development.


### LICENSE: GPL-3.0-or-later

### Install the dependencies

This requires [Johnnycanencrypt](https://github.com/kushaldas/johnnycanencrypt/), check the readme there for
build instructions.

`apt install python3-newt` or `dnf install python3-newt`, or `brew install newt` on Mac.

Then

```
python3 -m venv .venv
source .venv/bin/activate/
python3 -m pip install johnnycanencrypt
```
