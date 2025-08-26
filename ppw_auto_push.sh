#!/data/data/com.termux/files/usr/bin/bash

# === CONFIGURATION ===
REPO_DIR="$HOME/cloud-code-ppw"
CHAIN_FILE="ppw_proof_chain.json"
SIGN_FILE="$CHAIN_FILE.asc"
HASH_FILE="$REPO_DIR/ppw_proof_chain.hashes.json"
LOG_FILE="$REPO_DIR/ppw_git_auto.log"
COMMIT_MSG="Automated GPG-signed commit with multi-hashes"

# === NAVIGATE TO REPO ===
cd "$REPO_DIR" || { echo "Repository not found: $REPO_DIR"; exit 1; }

# === GENERATE MULTI-HASHES ===
if [ -f "$CHAIN_FILE" ]; then
    echo "Generating SHA256 and SHA3-512 hashes..."
    
    SHA256_HASH=$(sha256sum "$CHAIN_FILE" | awk '{print $1}')
    
    if command -v sha3sum >/dev/null 2>&1; then
        SHA3_512_HASH=$(sha3sum -a 512 "$CHAIN_FILE" | awk '{print $1}')
    else
        echo "sha3sum not found, installing..."
        pkg install -y sha3sum
        SHA3_512_HASH=$(sha3sum -a 512 "$CHAIN_FILE" | awk '{print $1}')
    fi

    cat > "$HASH_FILE" <<EOF
{
  "sha256": "$SHA256_HASH",
  "sha3_512": "$SHA3_512_HASH"
}
EOF

    echo "Hashes saved to $HASH_FILE"
else
    echo "File not found: $CHAIN_FILE"
    exit 1
fi

# === GPG SIGN THE CHAIN FILE ===
echo "Signing $CHAIN_FILE with GPG..."
gpg --armor --yes --batch --sign "$CHAIN_FILE"

# === ADD FILES TO GIT ===
git add "$CHAIN_FILE" "$SIGN_FILE" "$HASH_FILE"

# === COMMIT WITH GPG SIGNING ===
git commit -S -m "$COMMIT_MSG" >> "$LOG_FILE" 2>&1

# === PUSH TO GITHUB ===
git push origin main >> "$LOG_FILE" 2>&1

echo "✅ PPW automation complete. Log written to $LOG_FILE"
