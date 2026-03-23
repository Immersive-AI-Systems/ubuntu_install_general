# ubuntu_install_general

Ansible playbooks for setting up an Ubuntu machine with a few simple install profiles.

This is meant to be used from your local controller machine against one or more Ubuntu targets over SSH.

## What You Get

- core Ubuntu packages and CLI tools
- optional Docker and NVIDIA Container Toolkit setup
- optional Anaconda-based Python environment
- optional GNOME appearance and workspace keybinding setup
- useful `.bashrc` aliases and Git defaults

## Before You Start

You should already be able to SSH into the target machine.

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
