# 🚀 Serverless Remote CLI Builder

Turn any Linux terminal into a high-performance build interface powered by free, fast GitHub Actions cloud runners. 

By following this guide, you will deploy a private personal cloud compiler loop. You don't share your keys with anyone, and you control your own execution engine completely from scratch.

---

## 🛠️ Phase 1: GitHub Cloud Setup (Do this once)

### 1. Fork or Create Your Repository
1. Create a new repository on GitHub (or use this one if you are using it as a template).
2. Inside your repository, ensure you have a file exactly located at `.github/workflows/remote-build.yml` with the following configuration:

```yaml
name: Remote Compiler Pipeline
on:
  repository_dispatch:
    types: [compile-job]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Project Files
        uses: actions/checkout@v4

      - name: Execute CLI Command
        run: |
          echo "🏁 Remote Execution Engine Initialized..."
          \${{ github.event.client_payload.command }}
```

### 2. Generate Your Secure Access Token
To authorize your local terminal to communicate securely with your GitHub repository:
1. Navigate to **GitHub Settings** -> **Developer Settings** -> **Personal Access Tokens** -> **Tokens (classic)**.
2. Click **Generate new token (classic)**.
3. Provide a clear label note (e.g., `my-remote-cli`).
4. Select the **`repo`** checkbox and the **`workflow`** checkbox.
5. Click **Generate token** at the bottom of the screen.
6. **Copy the token string instantly.** You will not be shown this code block again.

---

## 💻 Phase 2: Local Linux Machine Setup

Open your local Linux terminal (`Bash` or `Zsh`) and execute the following automated steps to compile the custom client globally onto your operating system.

### 1. Store Your Personal Credentials Securely
Run the following commands to add your personal token and repo configuration directly into your terminal profile environment variables:

```bash
# Add your GitHub Token (Replace 'ghp_yourToken' with your real token)
echo "export GITHUB_CLI_TOKEN=\"ghp_yourToken\"" >> ~/.bashrc

# Add your exact GitHub repository path (Replace with your actual username and repo)
echo "export GITHUB_CLI_REPO=\"your_github_username/your_repo_name\"" >> ~/.bashrc

# Reload your shell profile settings to apply configuration changes
source ~/.bashrc
```

### 2. Install the Unified Command Execution Tool
Copy and paste this single command block into your local terminal. It will create, build, verify, and system-link your custom standalone local client program (`gh-exec`) automatically from scratch:

```bash
cat << 'EOF' > ~/gh-exec
#!/bin/bash

COMMAND="\$*"

if [ -z "\(GITHUB_CLI_TOKEN" ] \vert{}\vert{} [ -z "\)GITHUB_CLI_REPO" ]; then
    echo "❌ Error: System environment target properties are unconfigured."
    echo "Please ensure GITHUB_CLI_TOKEN and GITHUB_CLI_REPO are configured inside your ~/.bashrc file."
    exit 1
fi

if [ -z "\$COMMAND" ]; then
    echo "❌ Usage Error: No remote targets passed to cloud loop."
    echo "Usage syntax: gh-exec <terminal command strings>"
    exit 1
fi

REPO_OWNER=\((echo "\)GITHUB_CLI_REPO" | cut -d'/' -f1)
REPO_NAME=\((echo "\)GITHUB_CLI_REPO" | cut -d'/' -f2)

echo "🚀 Transmitting build command instructions to GitHub Actions: (\$GITHUB_CLI_REPO)..."

# 1. Trigger the workflow through the Repository Dispatch pipeline
RESPONSE=\$(curl -s -w "%{http_code}" -o /dev/null \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer \$GITHUB_CLI_TOKEN" \
  https://github.com\(REPO_OWNER/\)REPO_NAME/dispatches \
  -d "{\"event_type\": \"compile-job\", \"client_payload\": {\"command\": \"\$COMMAND\"}}")

if [ "\(RESPONSE" != "204" ] && [ "\)RESPONSE" != "201" ]; then
    echo "❌ Cloud Handshake Refused. API verification return code: \$RESPONSE"
    exit 1
```

```bash
fi

echo "⏳ Trigger accepted. Syncing with remote cloud computer instance..."
sleep 6

# 2. Extract the unique tracking ID for this specific run execution thread
RUN_ID=\$(curl -s \
  -H "Authorization: Bearer \$GITHUB_CLI_TOKEN" \
  "https://github.com\(REPO_OWNER/\)REPO_NAME/actions/runs?per_page=1" \

  | grep -m 1 '"id":' | awk '{print \$2}' | sed 's/,//')

if [ -z "\$RUN_ID" ]; then
    echo "❌ Process tracking reference identifier lost."
    exit 1
fi

# 3. Poll monitoring loop until processing state returns completed
while true; do
    STATUS_JSON=\$(curl -s \
      -H "Authorization: Bearer \$GITHUB_CLI_TOKEN" \
      "https://github.com\$REPO_OWNER/\(REPO_NAME/actions/runs/\)RUN_ID")
    
    STATUS=\((echo "\)STATUS_JSON" | grep '"status":' | head -n 1 | awk -F'"' '{print \$4}')
    CONCLUSION=\((echo "\)STATUS_JSON" | grep '"conclusion":' | head -n 1 | awk -F'"' '{print \$4}')
    
    echo "🔄 Cloud Running State: [ \$STATUS ]"
    
    if [ "\$STATUS" = "completed" ]; then
        echo "🏁 Build job execution pipeline finalized. Result: \$CONCLUSION"
        break
    fi
    sleep 4
done

# 4. Extract and print runtime console log output
echo "📄 Streaming execution results raw..."
curl -s -L \
  -H "Authorization: Bearer \$GITHUB_CLI_TOKEN" \
  "https://github.com\$REPO_OWNER/\(REPO_NAME/actions/runs/\)RUN_ID/logs" > run-logs.zip

if [ -f run-logs.zip ]; then
    unzip -p run-logs.zip "*Execute CLI Command.txt" 2>/dev/null || unzip -p run-logs.zip "*.txt" | head -n 150
    rm run-logs.zip
fi
EOF

# Grant binary execution permissions globally to your system
chmod +x ~/gh-exec
sudo mv ~/gh-exec /usr/local/bin/gh-exec
echo "✅ Installation completed successfully! Your 'gh-exec' engine binary is live."
```

---

## 🔥 Phase 3: Run Any Workloads Anywhere

Open a fresh shell on your Linux PC. You can now pipe heavy execution payloads to your personal cloud machine directly from any path:

```bash
# Example 1: Extract hardware profile attributes of your cloud runner engine
gh-exec lscpu

# Example 2: Compile software and evaluate runtime states inside the sandbox
gh-exec "gcc -v && echo 'Cloud environment is running smoothly'"
```
