## Slack REPL

A REPL usable from slack using messages like so:

![Screenshot](scrot.png?raw=true "Screenshot")

## Setup

This REPL relies on [playpen](https://github.com/thestinger/playpen) to sandbox the running code.
On Archlinux, playpen can be installed using pacman: `pacman -S playpen`. To help install
packages into the sandbox, installing `arch-install-scripts` would be helpful too.

Then setup the sandbox:

```
> mkdir sandbox
> pacstrap -c -d root-nightly.new \
    bash \
    coreutils \
    grep \
    dash \
    filesystem \
    glibc \
    pacman \
    procps-ng \
    shadow \
    util-linux \
    gcc \
    racket \
    ghc \
    python \
		ruby
> arch-chroot sandbox
> useradd -m repl; exit
```

To setup rust, we need to install the nightly version of rust so we can use rusti (a rust REPL) to
eval rust code. This can be done by downloading the `rust-nightly-bin` PKGBUILD from AUR, and building
it with `makepkg -s`. Similary, `rusti-git` PKGBUILD from AUR can be used to build the rusti
binaries. Then we can simply copy the built files into the sandbox.

The gems can be installed with `bundle install`.

Once everything is setup, we can start bot:

`sudo ruby slack-repl.rb <token>`

The sudo can be omitted depending on the cgroups setup.

## Security

All code received from Slack is run in a sandbox provided by [playpen](https://github.com/thestinger/playpen).
Playpen uses seccomp, namespaces, and cgroups to limit resource usage by the apps running in the sandbox.
The config used by this REPL has the following limits:

- Memory: 64M
- Timeout: 5s
- Max tasks: 1

The code is also run as a non-privileged user to avoid it being able to modify the filesystem.

## Languages

The following languages are supported:

- Rust
- Ruby
- Python
- Haskell
- Brainfuck
- Shell
- Scheme

Adding new languages is very simple: just install some compiler/interpreter for the language
and add a new case statement.

## Requirements

In order to use this integration, the following Ruby libraries are needed:

* slack-rtmapi

But they can be installed by using `bundle`:

`bundle install`
