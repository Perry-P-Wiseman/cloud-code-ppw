#!/data/data/com.termux/files/usr/bin/bash
# PPW Termux Automation: JSON Proof Chain + Punnett Square HTML + GPG-signed Git Push

# --- CONFIG ---
REPO_DIR="$HOME/cloud-code-ppw"
JSON_FILE="$REPO_DIR/ppw_proof_chain.json"
HTML_FILE="$REPO_DIR/immunity_punnett.html"
GPG_KEY="B9FCA58C3B497F222912FCC3B556758E7358A8F0"

# --- STEP 1: Generate multi-hashes for JSON ---
echo "🔹 Generating SHA256 & SHA3-512 hashes..."
SHA256=$(sha256sum "$JSON_FILE" | awk '{print $1}')
SHA3_512=$(sha3sum -a 512 "$JSON_FILE" | awk '{print $1}')
echo "✅ SHA256: $SHA256"
echo "✅ SHA3-512: $SHA3_512"

# --- STEP 2: Sign JSON with GPG ---
echo "🔹 Signing JSON..."
gpg --default-key "$GPG_KEY" --armor --output "$JSON_FILE.asc" --sign "$JSON_FILE"
echo "✅ JSON signed: $JSON_FILE.asc"

# --- STEP 3: Update HTML with JSON hash reference ---
echo "🔹 Updating HTML Punnett Square..."
# Remove previous hash info section
sed -i '/ppw_proof_chain.json SHA256/,/div>/d' "$HTML_FILE"
# Append updated hash
cat <<EOT >> "$HTML_FILE"
<div class="file-info">
    <div class="file-header">📄 ppw_proof_chain.json SHA256</div>
    <div>$SHA256</div>
</div>
EOT
echo "✅ HTML updated with JSON hash."

# --- STEP 4: Git add & commit ---
echo "🔹 Staging files for commit..."
cd "$REPO_DIR"
git add "$JSON_FILE.asc" "$HTML_FILE"

echo "🔹 Committing changes with GPG signing..."
git commit -S -m "Update PPW proof chain and Punnett Square HTML"

# --- STEP 5: Push to remote ---
echo "🔹 Pushing to GitHub..."
git push origin main

echo "✅ Workflow complete!"
