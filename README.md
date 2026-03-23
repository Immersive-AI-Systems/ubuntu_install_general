# ubuntu_install_general

Ansible playbooks for setting up a remote Ubuntu machine from your local computer over SSH.

## Two Machines Are Involved

- `controller machine`: your local computer, such as your Mac or laptop, where this repo is cloned and where you run the commands
- `target machine`: the remote Ubuntu machine that will actually be configured

You run this repo on the controller machine. Ansible connects from the controller machine to the target machine over the network and performs the install there.

## Prerequisites

### On The Controller Machine

The controller machine needs:

- `git`
- `ssh`
- `ansible`
- network access to the target machine
- `ssh-copy-id` if you want `init_remote_host.sh` to install your local SSH key on the target

If your controller machine is a Mac, you can install Ansible with:

```bash
brew install ansible
```

If your controller machine is Ubuntu or another Debian-based Linux machine, you can install Ansible with:

```bash
sudo apt-get install -y ansible
```

Install the required Ansible collection:

```bash
ansible-galaxy collection install -r requirements.yml
```

### On The Target Machine

Before you run this repo, the target machine should already have:

- Ubuntu installed
- a user account you can log in as over SSH
- `sudo` access for that user
- `python3`
- `openssh-server`
- an IP address or hostname reachable from the controller machine

If you are preparing a fresh Ubuntu machine and `python3` or SSH is missing, log into the target machine directly, on the target machine itself, and run:

```bash
sudo apt-get update
sudo apt-get install -y python3 openssh-server
```

### SSH Access Before Running The Install

Before you run the main install, the controller machine must be able to reach the target machine over SSH.

If plain SSH already works, a command like this should succeed from the controller machine:

```bash
ssh myuser@192.168.1.10
```

If the target uses a non-default SSH port, this should work:

```bash
ssh -p 2222 myuser@192.168.1.10
```

If you can reach the machine over the network and log in with a password but have not set up key-based SSH yet, `./init_remote_host.sh` can help with that by running `ssh-copy-id` for you.

If the controller machine cannot reach the target machine at all yet, fix that first. This repo assumes the network path, hostname or IP, and login credentials are already known.

Your `inventory.ini` values should match the same username, host, and port that work when you SSH manually.

## What Gets Installed By Default

The default install enables:

- core Ubuntu packages
- general CLI tools
- shell aliases and Git defaults

The repo also contains optional support for:

- Docker
- NVIDIA Container Toolkit
- Anaconda
- GNOME appearance settings
- GNOME workspace keybindings
- Google Chrome

Those optional pieces are off by default and can be enabled with Ansible variables.

## What Runs Where

### On The Target Machine

Usually, you only do initial machine preparation here, if needed:

```bash
sudo apt-get update
sudo apt-get install -y python3 openssh-server
```

After that, you normally do not run this repo on the target machine directly. The actual Ansible run happens from the controller machine.

### On The Controller Machine

This is where you do the real workflow.

Install the required collection:

```bash
ansible-galaxy collection install -r requirements.yml
```

Create `inventory.ini` with:

```bash
./init_remote_host.sh
```

That helper runs on the controller machine. It asks for the target hostname or IP, SSH username, and port, can optionally install your local SSH key on the target using `ssh-copy-id`, and then writes `inventory.ini` for you.

If you want, verify Ansible connectivity before running the install:

```bash
ansible -i inventory.ini ubuntu -m ping
```

Run the default install:

```bash
./run_install.sh -i inventory.ini -K
```

`-K` tells Ansible to ask for the sudo password on the target machine.

## Optional Features

If you want extra components beyond the default install, enable them with `-e`.

Enable Anaconda:

```bash
./run_install.sh -i inventory.ini -K -e install_anaconda=true
```

Enable Docker:

```bash
./run_install.sh -i inventory.ini -K -e install_docker=true
```

Enable Docker plus NVIDIA Container Toolkit:

```bash
./run_install.sh -i inventory.ini -K -e install_docker=true -e install_nvidia_container_toolkit=true
```

Enable GNOME appearance and workspace arrow bindings:

```bash
./run_install.sh -i inventory.ini -K -e configure_gnome_appearance=true -e configure_gnome_favorites=true -e configure_gnome_keybindings=true
```

Enable keypad workspace bindings too:

```bash
./run_install.sh -i inventory.ini -K -e configure_gnome_appearance=true -e configure_gnome_favorites=true -e configure_gnome_keybindings=true -e enable_keypad_bindings=true
```

Enable Google Chrome:

```bash
./run_install.sh -i inventory.ini -K -e install_google_chrome=true
```

## Important Files

- `site.yml`: main playbook entrypoint
- `init_remote_host.sh`: helper for writing `inventory.ini` and optionally installing your local SSH key on the target
- `run_install.sh`: convenience wrapper for the default install
- `group_vars/all.yml`: default install settings and optional feature toggles
- `inventory/example.ini`: reference inventory format
- `playbooks/`: individual playbooks used by `site.yml`
