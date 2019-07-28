## VNET jails

Lets try building an iocell setup with VNET on a binarylane server

- Load up a new VPS
- Use bootonly iso, ignore kernel-dbg and lib32
- Add self to wheel and operator groups
- After install, set to dual nics, reboot (src/dest check - select no check, and dual nics)

```bash
pkg update
pkg install git htop doas vim-console tmux iocell
```