#!/usr/bin/env python3

from snack import *
import pathlib
import sys


def create_mainscreen():
    """
    Create a main screen and return it
    """
    screen = SnackScreen()
    screen.pushHelpLine("Follow the steps")
    screen.drawRootText(0, 0, "tugpgp")
    screen.drawRootText(0, 1, "Author: Kushal Das <kushal@sunet.se>")
    return screen


def get_name_emails(name="", emails=""):
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
    withskip = ["Next", "Skip"]
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
    # home_dir = str(pathlib.Path().home())
    # em = get_one_input(screen, "Save the public key in the following directory:\n\n", "Directory:", value=home_dir, can_skip=True)
    # # First get the name and email addresses
    # password = show_and_take_password(screen, "The following will be the new Admin pin for your Yubikey.", "Pin:", (("Next",)))

    # screen.finish()
    # # breakpoint()
    # print(password)
    # print(em)
    # sys.exit(0)

    name = ""
    emails_list = ""
    emails = []
    while True:
        em = get_name_emails(name, emails_list)
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

    # Now ask the user to connect Yubikey
    show_and_take_input(
        screen,
        "Now connect the Yubikey to the system, and press Next\n\n",
        (("Next", "next"),),
    )
    show_and_take_input(
        screen,
        "At first we will reset the Yubikey.\n\n",
        (("Next", "next"),),
    )
    # TODO: reset the key
    show_and_take_input(
        screen,
        "Now we will upload the new OpenPGP key to the Yubikey.\n\n",
        (("Next", "next"),),
    )

    # TODO: Upload to the Yubikey
    show_and_take_input(
        screen,
        "Upload to Yubikey is successful.\n\n",
        (("Next", "next"),),
    )

    # TODO: Save the public key
    # TODO: Save the private key (OPTIONAL)

    # TODO: Get the pin user pin
    # TODO: Get the new admin pin
    show_and_take_input(
        screen,
        "Your Yubikey is now ready to be used. Remember to import the public key to any system as required.\n\n",
        (("Done", "done"),),
    )



if __name__ == "__main__":
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
