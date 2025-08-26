#!/data/data/com.termux/files/usr/bin/bash

# === CONFIGURATION ===
REPO_DIR="$HOME/cloud-code-ppw"
CHAIN_FILE="ppw_proof_chain.json"
SIGN_FILE="$CHAIN_FILE.asc"
LOG_FILE="$REPO_DIR/ppw_git_auto.log"
COMMIT_MSG="Automated GPG-signed commit"

# === NAVIGATE TO REPO ===
cd "$REPO_DIR" || { echo "Repository not found: $REPO_DIR"; exit 1; }

# === GPG SIGN THE CHAIN FILE ===
if [ -f "$CHAIN_FILE" ]; then
    echo "Signing $CHAIN_FILE with GPG..."
    gpg --armor --yes --batch --sign "$CHAIN_FILE"
else
    echo "File not found: $CHAIN_FILE"; exit 1
fi

# === ADD FILES TO GIT ===
git add "$SIGN_FILE" "$CHAIN_FILE"

# === COMMIT WITH GPG SIGNING ===
git commit -S -m "$COMMIT_MSG" >> "$LOG_FILE" 2>&1

# === PUSH TO GITHUB ===
git push origin main >> "$LOG_FILE" 2>&1

echo "✅ PPW GPG automation complete. Log written to $LOG_FILE"
