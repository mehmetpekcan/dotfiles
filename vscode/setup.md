## keybindings.json

Copy & Paste

## settings.json

Copy & Paste

## extensions.tsx

code --list-extensions

### Install extensions

#### On Unix
extensions.txt | xargs -L 1 echo code --install-extension

### #On Windows
extensions.txt | % { "code --install-extension $_" }

