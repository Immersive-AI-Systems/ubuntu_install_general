# ubuntu_install_general

Ansible playbooks for setting up an Ubuntu machine with a few simple install profiles.

This repo is meant to be run from your local computer against one or more remote Ubuntu machines over SSH.

## What You Get

- core Ubuntu packages and CLI tools
- optional Docker and NVIDIA Container Toolkit setup
- optional Anaconda-based Python environment
- optional GNOME appearance and workspace keybinding setup
- useful `.bashrc` aliases and Git defaults

## How This Is Used

There are two machines involved:

- `controller machine`: your local computer, for example your Mac or laptop, where this repo is cloned and where you run the Ansible commands
- `target machine`: the remote Ubuntu machine that will be configured by these playbooks

You run everything in this repo on the controller machine. Ansible then connects from the controller machine to the target machine over SSH and applies the setup there.

## Before You Start

Before using these playbooks, plain SSH access from the controller machine to the target machine should already work.

In practice, this means a command like this should succeed from your local machine:

```bash
ssh myuser@192.168.1.10
```

If the target uses a non-default SSH port, this should work:

```bash
ssh -p 2222 myuser@192.168.1.10
```

If SSH does not work yet, fix that first. This repo assumes the network path, username, SSH key or password, and host reachability are already in place.

Install the required Ansible collection:

```bash
ansible-galaxy collection install -r requirements.yml
```

Create your inventory file:

```bash
cp inventory/example.ini inventory.ini
```

Then edit `inventory.ini` so it points at your machine. A typical entry looks like this:

```ini
[ubuntu]
my-machine ansible_host=192.168.1.10 ansible_user=myuser ansible_port=22
```

Those inventory values should match the same connection details you would use manually with SSH.

## Quick Start

Choose one of the included profiles and run it:

```bash
./run_profile.sh minimal -i inventory.ini -K
```

```bash
./run_profile.sh desktop -i inventory.ini -K
```

```bash
./run_profile.sh ml -i inventory.ini -K
```

`-K` asks Ansible for the sudo password on the target machine.

## Profiles

### `minimal`

Installs the general Ubuntu packages, CLI tools, and shell helpers.

### `desktop`

Adds GNOME appearance settings, favorites, and arrow-based workspace switching.

### `ml`

Adds Docker, NVIDIA Container Toolkit, Anaconda, and a ready-made ML Python environment.

## Running Without The Wrapper

If you want direct control over Ansible arguments, run the site playbook yourself:

```bash
ansible-playbook -i inventory.ini site.yml -e @group_vars/profiles/minimal.yml -K
```

You can also combine profiles:

```bash
ansible-playbook -i inventory.ini site.yml -e @group_vars/profiles/desktop.yml -e @group_vars/profiles/ml.yml -K
```

## Common Overrides

The shared defaults live in `group_vars/all.yml`. A few useful overrides:

Enable keypad workspace bindings:

```bash
ansible-playbook -i inventory.ini site.yml -e @group_vars/profiles/desktop.yml -e enable_keypad_bindings=true -K
```

Install Google Chrome with the desktop profile:

```bash
ansible-playbook -i inventory.ini site.yml -e @group_vars/profiles/desktop.yml -e install_google_chrome=true -K
```

Auto-activate the ML conda environment on login:

```bash
ansible-playbook -i inventory.ini site.yml -e @group_vars/profiles/ml.yml -e conda_auto_activate_env=ml -K
```

## Files

- `site.yml`: main playbook entrypoint
- `run_profile.sh`: convenience wrapper for running named profiles
- `group_vars/all.yml`: shared defaults
- `group_vars/profiles/`: profile-specific settings
- `playbooks/`: the individual setup playbooks

## Notes

- The default Ansible target group is `ubuntu`.
- You can override the target with `-e host_target=<group-or-host>`.
- The GNOME tasks depend on the `community.general` collection from `requirements.yml`.
