#!/usr/bin/env python

import sys
import johnnycanencrypt.johnnycanencrypt as rjce
import johnnycanencrypt as jce
from pprint import pprint
import getpass
import datetime

if len(sys.argv) < 2:
    print("Usage: python update_expiry.py GPG_KEY.pub")
    sys.exit(1)
# Now we have a path to the public key.
with open(sys.argv[1], "rb") as f:
    olddata = f.read()

# Now first print the KEY IDs

uids, fingerprint, keytype, expirationtime, creationtime, othervalues = (
    rjce.parse_cert_bytes(olddata)
)
print(f"Primary key {fingerprint}")
print(f"Key expiring on: {expirationtime}")
subkeys = othervalues.get("subkeys", [])
sub_fingerprints = []
for subkey in subkeys:
    print(f"Subkey: {subkey[1]} expiring on: {subkey[3]} of type: {subkey[4]}")
    sub_fingerprints.append(subkey[1])

allokay = input("If all looks good, entter YES : ")
if allokay.strip().upper() != "YES":
    sys.exit(0)

newdate = input("\nEnter new expiry date YYYY-MM-DD: ")
newdate = newdate.strip()
newdate = datetime.datetime.strptime(newdate, "%Y-%m-%d")

now = datetime.datetime.now()
diff = newdate - now
new_expiry_in_future = int(diff.total_seconds() + 86400) # Added 1 day for buffer

newtimestamp = int(newdate.timestamp())

input("Now connect the Yubikey and make sure you have only one Yubikey inserted. Press Enter when ready.")
userpin = getpass.getpass("Enter your Yubikey PIN: ")
PIN = userpin.encode("utf-8")

print("First we will have update the primary key's expiry date. Touch the Yubikey when flashing.")

updated_data_with_primary_key = rjce.update_primary_expiry_on_card(olddata, new_expiry_in_future, PIN)

print("Now we will update the subkeys' expiry dates. Touch the Yubikey when flashing.")

updated_data = rjce.update_subkeys_expiry_on_card(updated_data_with_primary_key, sub_fingerprints, new_expiry_in_future, PIN)

print("Now saving the data.")

with open(f"updated_{fingerprint}.pub", "wb") as f:
    f.write(updated_data)

print(f"Updated key saved as updated_{fingerprint}.pub")