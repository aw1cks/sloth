#!/usr/bin/env python3

#######
#
#          dd script
# ============================
# Select disk with curses menu
#   dd image to selected disk
#
#######
   ###
    #

import argparse
import curses
import os
import pathlib
import subprocess
import sys
import time


def menu(stdscr):
    while(True):
        horizontal_padding = int((curses.COLS / 3) - 2)
        horizontal_padding_str = horizontal_padding * " "
        vertical_padding = int(curses.LINES / 4)
        stdscr.addstr(vertical_padding, horizontal_padding, "Select a disk:\n\n")
        # Get our disks
        # Iterate over /dev/disk/by-id - populated by udev
        # Use a lambda to add a newline
        disks = list(map(
            lambda x: str(x) + "\n",
            list(pathlib.Path("/dev/disk/by-id").iterdir()),
        ))
        # Filter out partitions
        # Also remove devicemapper devices
        disks = [ d for d in disks if "part" not in d.split("-")[-1] and (d.split("/")[-1])[:3] != "dm-" ]
        # List comprehension to iterate & add the index
        [ stdscr.addstr("{}{}) {}".format(horizontal_padding_str, disks.index(disk)+1, disk)) for disk in disks ]
        # Move down a line
        cur_y, _ = stdscr.getyx()
        stdscr.move(cur_y + 1, horizontal_padding)

        # Turn on echo, get our user input
        curses.echo()
        choice = stdscr.get_wch()
        curses.noecho()

        # Construct a list of allowed values, based on list indices
        accepted_values = list(map(str, range(1, len(disks) + 1)))
        if choice in accepted_values:
            while(True):
                time.sleep(0.3)
                stdscr.clear()
                stdscr.addstr(vertical_padding, horizontal_padding, disks[int(choice) - 1])
                stdscr.addstr(vertical_padding + 1, horizontal_padding, "WARNING! This disk will be WIPED. Please press 'y' to continue")
                cur_y, _ = stdscr.getyx()
                stdscr.move(cur_y + 1, horizontal_padding)
                curses.echo()
                confirmation = stdscr.get_wch()
                curses.noecho()
                if confirmation.lower() == "y":
                    time.sleep(0.3)
                    return disks[int(choice) - 1]
                elif confirmation.lower() == "q":
                    sys.exit(1)
        else:
            # Get our current cursor position
            # Then move down 2 lines, print our error, move back
            cur_y, _ = stdscr.getyx()
            stdscr.move(cur_y + 2, horizontal_padding)
            stdscr.addstr("Enter a valid choice between 1 and {}".format(len(disks)))
            stdscr.move(cur_y, horizontal_padding)
            time.sleep(0.3)


def diskdestroyer(disk):
    subprocess.run("dd if=/archlinux.img of={} bs=4M status=progress conv=fsync".format(disk).split(" "))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-n", "--noop",
        help="Do not run dd, only select a disk",
        action="store_true"
    )
    args = parser.parse_args()
    disk = curses.wrapper(menu)
    if not args.noop:
        diskdestroyer(disk.rstrip())
    else:
        with open(pathlib.Path(__file__).parent.joinpath("disk"), "w") as f:
                f.write(disk.rstrip())


if __name__ == "__main__":
    main()
