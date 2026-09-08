#!/bin/bash

echo "=================================================="
echo "🎯 Automated Cloud Terminal Installer Initialized"
echo "=================================================="

# 1. Prompt for User Configurations Separately
read -p "🔑 Enter your GitHub Personal Access Token (classic): " USER_TOKEN
read -p "👤 Enter your GitHub Username: " USER_NAME

if [ -z "$USER_TOKEN" ] || [ -z "$USER_NAME" ]; then
    echo "❌ Error: Configuration profiles cannot be blank. Setup aborted."
    exit 1
fi

# Combine the username automatically with the repository name (assumes name remains matching)
USER_REPO="${USER_NAME}/remote"

# 2. Write Environment Configuration securely to the Shell Profile
SHELL_PROFILE="$HOME/.bashrc"
if [ -n "$ZSH_VERSION" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -d "$HOME/.termux" ] && [ -f "$HOME/.bash_profile" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
fi

echo "" >> "$SHELL_PROFILE"
echo "# --- Cloud Terminal Engine Configurations ---" >> "$SHELL_PROFILE"
echo "export GH_TOKEN=\"$USER_TOKEN\"" >> "$SHELL_PROFILE"
echo "export GH_REPO=\"$USER_REPO\"" >> "$SHELL_PROFILE"

# 3. Construct the Standalone Execution Binary
cat << 'EOF' > ~/gh-shell
#!/bin/bash

if [ -z "$GH_TOKEN" ] || [ -z "$GH_REPO" ]; then
    echo "❌ Configuration Missing! Ensure your environment variables are set."
    exit 1
fi

COMMAND="$*"
if [ -z "$COMMAND" ]; then
    echo "❌ Usage: gh-shell <command>"
    echo "Example: gh-shell lscpu"
    exit 1
fi

OWNER=$(echo "$GH_REPO" | cut -d'/' -f1)
REPO=$(echo "$GH_REPO" | cut -d'/' -f2)

echo "🛰️ Transmitting payload down to GitHub runner..."

RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GH_TOKEN" \
  https://github.com \
  -d "{\"event_type\": \"terminal-input\", \"client_payload\": {\"command\": \"$COMMAND\"}}")

if [ "$RESPONSE" != "204" ] && [ "$RESPONSE" != "201" ]; then
    echo "❌ Connection Denied (Status: $RESPONSE)."
    exit 1
fi

echo "⏳ Handshake confirmed. Awaiting processor provisioning..."
sleep 6

RUN_ID=$(curl -s -H "Authorization: Bearer $GH_TOKEN" \
  "https://github.com" \

  | grep -m 1 '"id":' | awk '{print $2}' | sed 's/,//')

if [ -z "$RUN_ID" ]; then
    echo "❌ Failed to secure runtime channel tracking index."
    exit 1
fi

while true; do
    STATUS_JSON=$(curl -s -H "Authorization: Bearer $GH_TOKEN" \
      "https://github.com")
    STATUS=$(echo "$STATUS_JSON" | grep '"status":' | head -n 1 | awk -F'"' '{print $4}')
    
    if [ "$STATUS" = "completed" ]; then
        break
    fi
    echo "🔄 Cloud status: [ $STATUS ] ... monitoring line"
    sleep 4
done

echo "📄 Streaming execution results raw..."
curl -s -L -H "Authorization: Bearer $GH_TOKEN" \
  "https://github.com/logs" > terminal-logs.zip

if [ -f terminal-logs.zip ]; then
    unzip -p terminal-logs.zip "*RUN LOCAL COMMAND PAYLOAD.txt" 2>/dev/null || unzip -p terminal-logs.zip "*.txt" | head -n 150
    rm terminal-logs.zip
fi
EOF

# 4. Bind Binary to Active System Path Locations
chmod +x ~/gh-shell

if [ -d "/usr/local/bin" ]; then
    sudo mv ~/gh-shell /usr/local/bin/gh-shell 2>/dev/null || mv ~/gh-shell /usr/local/bin/gh-shell
elif [ -n "$PREFIX" ] && [ -d "$PREFIX/bin" ]; then
    mv ~/gh-shell "$PREFIX/bin/gh-shell"
else
    mv ~/gh-shell "$HOME/gh-shell"
    echo "⚠️ System binary bin directory not discovered. Script placed at: ~/gh-shell"
fi

echo "=================================================="
echo "✅ Installation Complete!"
echo "🔄 Run: 'source $SHELL_PROFILE' to activate settings."
echo "🚀 Then type: 'gh-shell lscpu' to execute commands."
echo "=================================================="
