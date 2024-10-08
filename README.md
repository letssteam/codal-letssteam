# Codal Let's STEAM tooling [![build-target](https://github.com/letssteam/codal-letssteam/actions/workflows/build-target.yml/badge.svg)](https://github.com/letssteam/codal-letssteam/actions/workflows/build-target.yml)

This repository provides the tooling needed to set up the development environment for working with Codal on programmable boards such as the [STeaMi board](https://www.steami.cc/). This set of tools aims to make the development process simpler, faster, and more reproducible.

Codal is developed by Lancaster University. It provides an easy-to-use environment for programming board in the C/C++ language. It contains device drivers for all the hardware capabilities, and a suite of runtime mechanisms to make programming easier and more flexible. These range from control of the LED matrix display display control to peer-to-peer radio communication and secure Bluetooth Low Energy services.

Besides supporting development in C/C++, the runtime is specifically designed to support higher level languages targeting physical computing and computer science education. It is currently used as a support library for Microsoft MakeCode

## Overview

### 1. Makefile for lifecycle management

The repository includes a pre-configured Makefile with a set of targets to efficiently manage the lifecycle of a program written with Codal. This allows you to:

- Compile the code.
- Manage dependencies.
- Deploy the program to the target board.
- Clean up generated intermediate files.

The Makefile contains predefined targets for each stage of the development cycle to simplify repetitive operations.

### 2. Ready-to-use Docker image

To avoid issues with installing various dependencies and to ensure a standardized environment, this repository offers a Docker image. This image contains all the dependencies needed to develop with Codal, making it easy to set up the development environment.

The Docker image allows you to:

- Quickly get a complete environment without manually installing tools on your machine.
- Ensure reproducibility across different developers or machines.

### 3. Dev container

The repository includes a configuration for a Dev Container compatible with VSCode. This setup allows you to use the Docker image directly within the editor, providing a consistent and ready-to-use development environment.

The advantages of the Dev Container are:

- Having a unified environment that launches automatically when the workspace is opened.
- Integrating all dependencies and configurations directly within the editor.

### 4. VSCode workspace configuration

This repository contains a pre-configured workspace for VSCode with:

- The necessary folders for a Codal STM32 target.
- C/C++ failback configuration to use Intellisense feature before first compilation
- Build tasks that directly use the targets defined in the Makefile.
- Debugger configuration to provide a complete development experience, from code editing to end-to-end debugging.

This setup allows developers to benefit from a consistent experience when writing, compiling, and debugging their code for Codal.

## Prerequisites

- Docker must be installed on your machine.
- VSCode with the `Remote - Containers` extension installed.

## Usage

1. **Clone the repository**:

   ```bash
   git clone https://github.com/letssteam/codal-letssteam.git
   cd codal-letssteam
   ```

2. **Open with VSCode**:

   - Open VSCode.
   - Open the file `codal-letssteam.code-workspace` and click on `Open Workspace` button.
   - Choose the "Open in a Dev Container" option to automatically configure the environment.

3. **Use build tasks**:

   - Use the tasks defined in the Makefile to compile and deploy your program.

## Examples

Here are some common targets you can use to manage your project (all these make target are avalaible through VSCode tasks):

1. **Setup the environment**:

   ```bash
   make setup
   ```

   This target installs all necessary dependencies and sets up the environment for development.

2. **Build the project**:

   ```bash
   make build
   ```

   This target compiles the source code and produces the binary ready to be deployed to the target board. By default, the first build will configure codal for the STeaMi target. If you want to use a specific target, you need to call make one time with a codal target specific build command (_i.e_ `build_codal-stm32-DISCO_L475VG_IOT`, `build_codal-stm32-PNUCLEO_WB55RG` or `build_codal-stm32-STEAM32_WB55RG`).

3. **Clean the project**:

   ```bash
   make clean
   ```

   This target cleans up the intermediate files generated during the build process, keeping the workspace tidy.

4. **Flash the firmware**:

   ```bash
   make flash
   ```

   This target flashes the compiled binary to the board, making it ready for execution.

5. **List all the makefile targets**:
   ```bash
   make list
   ```
   This target give the list of all the targets available. Some target are generic so it's hard to find it directly by opening the makefile.

## Contributions

Contributions are welcome. Please open an issue before submitting a pull request to discuss your proposal.

## License

This project is licensed under the MIT License.
