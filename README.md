# ubuntu_install_general

Small Ansible-based Ubuntu setup for colleagues and shared machines.

This repo is intentionally generic:

- no shared `/etc/hosts` management
- no lab hostnames or usernames
- no private repo cloning
- no machine self-update logic
- optional GNOME keypad bindings, disabled by default

## What it covers

- base Ubuntu packages and CLI tools
- optional Docker and NVIDIA Container Toolkit
- optional Anaconda environment setup
- optional GNOME appearance and keybindings
- lightweight `.bashrc` helpers

## Setup

Install Ansible and the required collection:

```bash
ansible-galaxy collection install -r requirements.yml
```

Create an inventory from the example:

```bash
cp inventory/example.ini inventory.ini
```

Edit `inventory.ini` so it points at your target host.

## Profiles

Three simple profiles are included:

- `minimal`: base packages and shell helpers only
- `desktop`: GNOME appearance, favorites, and arrow-based workspace switching
- `ml`: Docker, NVIDIA container toolkit, and an Anaconda ML environment

Run them like this:

```bash
./run_profile.sh minimal -i inventory.ini -K
```

```bash
./run_profile.sh desktop -i inventory.ini -K
```

```bash
./run_profile.sh ml -i inventory.ini -K
```

You can also combine profiles directly with `ansible-playbook`:

```bash
ansible-playbook -i inventory.ini site.yml -e @group_vars/profiles/desktop.yml -e @group_vars/profiles/ml.yml -K
```

## Customization

The defaults live in `group_vars/all.yml`.

Typical overrides:

- disable keypad bindings entirely: already the default
- enable keypad bindings:

```bash
ansible-playbook -i inventory.ini site.yml -e @group_vars/profiles/desktop.yml -e enable_keypad_bindings=true -K
```

- install Chrome alongside the desktop profile:

```bash
ansible-playbook -i inventory.ini site.yml -e @group_vars/profiles/desktop.yml -e install_google_chrome=true -K
```

- auto-activate the ML conda environment on login:

```bash
ansible-playbook -i inventory.ini site.yml -e @group_vars/profiles/ml.yml -e conda_auto_activate_env=ml -K
```

## Notes

- The playbooks target the inventory group `ubuntu` by default.
- Override the target group or host with `-e host_target=<name>` if needed.
- The GNOME tasks require the `community.general` collection.
