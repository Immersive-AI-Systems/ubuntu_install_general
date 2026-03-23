# ubuntu_install_general

Ansible playbooks for setting up a remote Ubuntu machine from your local computer over SSH.

## Two Machines Are Involved

- `controller machine`: your local computer, such as your Mac or laptop, where this repo is cloned and where you run the commands
- `target machine`: the remote Ubuntu machine that will actually be configured

You run this repo on the controller machine. Ansible connects from the controller machine to the target machine over the network and performs the install there.

## Prerequisites

### On The Controller Machine

The controller machine is the computer where you are reading this repo and running the commands. In many cases that will be your Mac or laptop.

The controller machine needs:

- `git`
- `ssh`
- `ansible`
- network access to the target machine

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

The target machine is the remote Ubuntu machine that will be configured by Ansible.

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

### SSH Must Already Work

Before using these playbooks, plain SSH from the controller machine to the target machine should already succeed.

From the controller machine, this should work:

```bash
ssh myuser@192.168.1.10
```

If the target uses a non-default SSH port, this should work:

```bash
ssh -p 2222 myuser@192.168.1.10
```

If those SSH commands do not work yet, fix that first. The Ansible setup in this repo assumes that the controller machine can already reach the target machine over SSH.

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

This is where you do the real workflow: clone the repo, create the inventory, verify SSH, and run Ansible.

Install the required collection:

```bash
ansible-galaxy collection install -r requirements.yml
```

Create your inventory file:

```bash
cp inventory/example.ini inventory.ini
```

Edit `inventory.ini` on the controller machine so it points at your target machine. Example:

```ini
[ubuntu]
my-machine ansible_host=192.168.1.10 ansible_user=myuser ansible_port=22
```

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
- `run_install.sh`: convenience wrapper for the default install
- `group_vars/all.yml`: default install settings and optional feature toggles
- `inventory/example.ini`: sample inventory file
- `playbooks/`: individual playbooks used by `site.yml`
