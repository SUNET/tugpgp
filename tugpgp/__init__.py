#!/usr/bin/env python3

from snack import *
import pathlib
import os
import sys
import datetime

from johnnycanencrypt import Cipher
import johnnycanencrypt.johnnycanencrypt as rjce

screen = None


def next_year(d, years: int):
    "Adds the given years to the given datetime"
    try:
        return d.replace(year=d.year + years)
    except ValueError:
        # For February 29th situation
        return d.replace(year=d.year + years, day=28)


def create_mainscreen():
    """
    Create a main screen and return it
    """
    screen = SnackScreen()
    screen.pushHelpLine("Follow the steps")
    screen.drawRootText(0, 0, "tugpgp")
    screen.drawRootText(0, 1, "Author: Kushal Das <kushal@sunet.se>")
    return screen


def show_error(screen, text):
    "Shows the error message."
    g = GridForm(screen, "tugpgp", 1, 2)
    em = TextboxReflowed(55, f"ERROR: \n\n{text}")
    g.add(em, 0, 0)
    bb = ButtonBar(screen, (("Next", "next"),))
    g.add(bb, 0, 1)
    result: Button = g.runOnce()


def get_name_emails(screen, name="", emails=""):
    em = EntryWindow(
        screen,
        "tugpgp",
        "Tell us your name and email address(s) in a comma separated list",
        [("Name", name), ("Email", emails)],
        buttons=["Next", "Cancel"],
    )
    return em


def get_one_input(
    screen, text: str, input_name: str = "", value: str = "", can_skip: bool = False
):
    without_skip = [
        "Next",
    ]
    withskip = ["Skip", "Next"]
    if can_skip:
        buttons = withskip
    else:
        buttons = without_skip
    em = EntryWindow(
        screen,
        "tugpgp",
        text,
        [
            (input_name, value),
        ],
        buttons=buttons,
    )
    return em


def show_and_take_input(screen, text, buttons):
    g = GridForm(screen, "tugpgp", 1, 2)

    em = TextboxReflowed(55, text)
    g.add(em, 0, 0)
    bb = ButtonBar(screen, buttons)
    g.add(bb, 0, 1)
    result: Button = g.runOnce()
    return bb.buttonPressed(result)


def show_and_take_password(screen, toptext, text, buttons):
    "Shows 2 password inputs and returns the correct password at the end"
    toptext = f"{toptext}\n\n"
    while True:
        # The main grid for the screen
        g = GridForm(screen, "tugpgp", 1, 3)

        # Below are the two inputs for password, em1 and em2
        maingr = Grid(2, 2)
        text_w = TextboxReflowed(20, text)
        maingr.setField(text_w, 0, 0)
        em1 = Entry(35, password=1)
        maingr.setField(em1, 1, 0)
        text_w2 = TextboxReflowed(20, "Repeat:")
        maingr.setField(text_w2, 0, 1)
        em2 = Entry(35, password=1)
        maingr.setField(em2, 1, 1)

        top = TextboxReflowed(40, toptext)
        g.add(top, 0, 0)
        g.add(maingr, 0, 1)

        bb = ButtonBar(screen, buttons)
        g.add(bb, 0, 2)
        result = g.runOnce()
        pass1 = em1.value()
        pass2 = em2.value()
        if pass1 == pass2:
            return pass1
        else:
            toptext = "Pins did not match, please try again.\n\n"
        # Now we loop back as the passwords did not match.


def main(screen):
    # This will be our creation time
    now = datetime.datetime.now()
    expiration = next_year(now, 1)
    # First get the name and email addresses
    name = ""
    emails_list = ""
    emails = []
    while True:
        em = get_name_emails(screen, name, emails_list)
        if em[0] == "cancel":
            # We should exit
            screen.finish()
            sys.exit(0)
        else:
            # Means user pushed for next
            name = em[1][0]
            emails_list = em[1][1]
            emails = [email.strip() for email in emails_list.split(",")]
            uids = [f"{name} <{email}>" for email in emails]
            # Now let us get a confirmation
            verify_text = "Verify the following user ids, if any typing mistake then press edit, or press next.\n\n{}\n".format(
                "\n".join(uids)
            )
            if (
                show_and_take_input(
                    screen, verify_text, (("Next", "next"), ("Edit", "edit"))
                )
                == "next"
            ):
                # Means we can go to next step
                break

    key_password = show_and_take_password(
        screen,
        "Passphrase for the new key, 4+ words are better.",
        "Passphrase:",
        (("Next",)),
    )
    show_and_take_input(
        screen,
        "Now the screen will go black for a few seconds to create the key.\n\n",
        (("Next", "next"),),
    )

    # TODO: Create the new key here
    # Primary key can sign and subkeys will expire
    public, secret, fingerprint = rjce.create_key(
        key_password,
        uids,
        Cipher.RSA4k.value,
        int(now.timestamp()),
        int(expiration.timestamp()),
        True,
        5,
        True,
    )

    # Now ask the user to connect Yubikey
    show_and_take_input(
        screen,
        "Now connect the Yubikey to the system, and press Next\n\n",
        (("Next", "next"),),
    )
    # Now make sure that the card is actually connected
    while True:
        if not rjce.is_smartcard_connected():
            show_error(screen, "No Yubikey found on the system.\nPlease reconnect.\n\n")
        else:
            break

    show_and_take_input(
        screen,
        "At first we will reset the Yubikey.\n\n",
        (("Next", "next"),),
    )
    # TODO: In case we fail, show nice error dialog
    assert rjce.reset_yubikey()
    show_and_take_input(
        screen,
        "Now we will upload the new OpenPGP key to the Yubikey.\n\n",
        (("Next", "next"),),
    )

    try:
        # TODO: Upload to the Yubikey
        # First upload the primary key
        rjce.upload_primary_to_smartcard(
            secret.encode("utf-8"), b"12345678", key_password, whichslot=2
        )
        # now upload the subkeys
        rjce.upload_to_smartcard(
            secret.encode("utf-8"), b"12345678", key_password, whichkeys=5
        )
    except Exception as e:
        show_error(screen, "Error while uploading the keys. Copy paste the error from next screen and show to the developers.")
        screen.finish()
        print(e)


    show_and_take_input(
        screen,
        "Upload to Yubikey is successful.\n\n",
        (("Next", "next"),),
    )

    home_dir = str(pathlib.Path().home())
    em = get_one_input(
        screen,
        "Save the public key in the following directory:\n\n",
        "Directory:",
        value=home_dir,
        can_skip=False,
    )
    # Format of em: ('next', ('/home/kdas/code',))
    public_key_dir: str = em[1][0]
    public_key_file = os.path.join(public_key_dir, f"{fingerprint}.pub")
    # TODO: Save the public key
    with open(public_key_file, "w") as fobj:
        fobj.write(public)

    # Now tell the user where is the key.
    show_and_take_input(
        screen, f"Your publick key is saved at {public_key_file}.", (("Next", "next"),)
    )

    em = get_one_input(
        screen,
        "Export the private key in the following directory:\n\n",
        "Directory:",
        value=home_dir,
        can_skip=True,
    )
    # Format of em: ('next', ('/home/kdas/code',))
    if em[0] == "next":
        private_export_dir = em[1][0]
        private_key_file = os.path.join(private_export_dir, f"{fingerprint}.sec")
        # TODO: Save the private key (OPTIONAL)
        with open(private_key_file, "w") as fobj:
            fobj.write(secret)

    user_pin = ""
    while len(user_pin) < 6:
        user_pin = show_and_take_password(
            screen,
            "Set new User pin (daily use), 6 characters at least.",
            "Pin:",
            (("Next",)),
        )
    # TODO: Set the pin user pin
    rjce.change_user_pin(b"12345678", user_pin.encode("utf-8"))
    admin_pin = ""
    while len(admin_pin) < 8:
        admin_pin = show_and_take_password(
            screen,
            "Set new Admin pin, 8 characters at least.",
            "Pin:",
            (("Next",)),
        )
    # TODO: Set the new admin pin
    rjce.change_admin_pin(b"12345678", admin_pin.encode("utf-8"))
    show_and_take_input(
        screen,
        "Your Yubikey is now ready to be used. Remember to import the public key to any system as required.\n\n",
        (("Done", "done"),),
    )


def start():
    """Entry point"""
    screen = create_mainscreen()
    g = GridForm(screen, "tugpgp", 1, 2)
    em = TextboxReflowed(
        55,
        "Welcome to tugpgp\n\nWe will help you to create new OpenPGP key and upload it to a Yubikey.",
    )

    g.add(em, 0, 0)
    bb = ButtonBar(screen, (("Next", "next"),))
    g.add(bb, 0, 1)
    result: Button = g.runOnce()
    main(screen)
    screen.finish()


if __name__ == "__main__":
    start()
