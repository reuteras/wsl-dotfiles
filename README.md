# wsl-dotfiles

Dotfiles for my wsl usage.

## Install

On Windows:

```bash
cd ~\Documents\workspace
git clone --config core.autocrlf=false git@github.com:reuteras/wsl-dotfiles.git
```

In the Debian shell:

```bash
/mnt/c/Users/$USER/Documents/workspace/wsl-dotfiles/wsl_debian_setup.sh
```

## Testing

Commands for wsl:

```bash
wsl --unregister Debian
wsl --install debian
wsl --set-default debian
```
