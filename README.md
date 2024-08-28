# Codal Let's STEAM tooling

This repository is the tooling to ease the life of the Let's STEAM development team. It constain some scripts to support the life cycle of a codal project with many target.

## Overview

The codal runtime provides an easy to use environment for programming the board in the C/C++ language, written by Lancaster University. It contains device drivers for all the hardware capabilities, and also a suite of runtime mechanisms to make programming the easier and more flexible. These range from control of the LED matrix display to peer-to-peer radio communication and secure Bluetooth Low Energy services.

In addition to supporting development in C/C++, the runtime is also designed specifically to support higher level languages provided by our partners that target physical computing and computer science education. It is currently used as a support library for Microsoft MakeCode.

## Installation

To prepare the working folder, after clone this repository, you need to run the following commands :

```sh
cd codal-letssteam
make setup
scripts/create-git-hook-pre-commit-format
```

After this step, you can open the workspace on VS Code and use tasks to build a specific codal target.
