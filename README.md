# proxyfs 

Hey there!

I wrote this little bash script to make switching proxies in the terminal a bit easier for my own daily workflow. I found myself typing `export http_proxy=...` way too often, so I wrapped it all into a simple tool. 

I'm just putting this up here because it works well for me, and I thought it might be helpful to someone else who uses a lot of different proxy tools (like Throne, Tor, I2P, etc.) and wants a quick way to manage them.

## What it does

It's just a simple script that modifies your current shell's environment variables (`http_proxy`, `https_proxy`, `ALL_PROXY`, etc.). You can use it as a quick CLI command, or just type `proxyfs` to open a little Text User Interface (TUI) if you don't want to memorize anything.

* **Interactive TUI:** Just type `proxyfs` to get a simple menu.
* **Fast CLI:** Type `proxyfs on tor` or `proxyfs off` to toggle instantly.
* **Presets:** Built-in ports for Throne/V2Ray, I2P, Tor, Clash, and Shadowsocks (easily editable if your ports are different).
* **Single App Proxy:** Run a single command through a proxy without changing your whole terminal session (e.g., `proxyfs run tor curl ifconfig.me`).

## Setup

Because a bash script runs in a subshell by default, it can't change the environment variables of your active terminal unless it is `sourced`. To make it feel like a native command, we just use a shell alias!

1. Download the script and put it in your home directory. (I like to keep it hidden with a dot):
   ```bash
   mv proxyfs.sh ~/.proxyfs.sh



2. Add this alias to your `~/.bashrc` (or `~/.zshrc` if you use Zsh):
```bash
alias proxyfs="source ~/.proxyfs.sh"

```


3. Reload your terminal configuration:
```bash
source ~/.bashrc

```



## How to use it

If you want the menu, just run:

```bash
proxyfs

```

If you prefer the command line, here are the shortcuts:

```bash
proxyfs on                 # Turns on the default proxy (Throne)
proxyfs on tor             # Turns on the Tor profile
proxyfs on 192.168.1.5:80  # Connect to a custom IP and port
proxyfs status             # Check what proxies are currently active
proxyfs off                # Clears all proxy environment variables

```

**Proxying a single command:**
If you want to keep your terminal normal, but run one specific command through a proxy, use the `run` argument:

```bash
proxyfs run i2p wget http://some-i2p-site.i2p
proxyfs run tor git clone [https://github.com/example/repo.git](https://github.com/example/repo.git)

```

## A quick note

This is just a personal script, so feel absolutely free to fork it, rip it apart, change the default ports at the top of the file to match your own setup, or just copy-paste whatever bits you find useful.

Hope it makes your terminal life a little easier!

```

```
