---
date: 1980-01-01
section: 1
title: nixos-clean
---

# NAME

nixos-clean - Old generation cleaner for NixOS/home-manager.

# SYNOPSIS

**nixos-clean** \[*OPTIONS*\]...

Unsupported arguments will cause the program to fast fail.

# DESCRIPTION

**nixos-clean** is a script to clean old generations from a running NixOS system
and/or home-manager.

Running it without arguments clears out all the old generations and re-creates
the boot entries without any output to the console.

# OPTIONS

**\-d**, **\-\-dry\-run**

> Show the steps that this script will perform without actually performing any
> sort of cleanup.

**\-v**, **\-\-verbose**

> Don't suppress the output from any of the commands run within the script.
> This can fill up your terminal fast with a lot of verbose text, but it will
> be significantly more informative.

**\-h**, **\-\-help**

> Show a minimal help prompt and quit the program.

# AUTHOR

**Ali Rizvi** \<contact@frontear.dev\>

# LICENSE

This program is released under the **GNU Affero General Public License**.
