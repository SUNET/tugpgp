## tugpgp

An utility to create and upload OpenPGP keys to Yubikey. The tool will not write the generated key on disk unless specifically asked.

Under active development.


### LICENSE: GPL-3.0-or-later

## Install the dependencies


### Next create the virtualenv

```
python3 -m venv .venv 
python3 -m pip install wheel
python3 -m pip install -U pip
python3 -m pip install -r requirements.txt
```

We need [johnnycanencrypt](https://github.com/kushaldas/johnnycanencrypt) version 0.11.0 or above.

### How to use the tool?


```
briefcase dev
```

![](./images/tugpgp_01.png)


### To turn off or on touch policy of the authentication in Yubikey


```
python -m tugpgp --touch-auth-off
Admin pin of the Yubikey: 
Your Yubikey's touch policy is now changed.
```

To turn on again

```
python -m tugpgp --touch-auth-on
Admin pin of the Yubikey: 
Your Yubikey's touch policy is now changed.
```

