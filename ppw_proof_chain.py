#!/data/data/com.termux/files/usr/bin/env python3
import hashlib
import json
from datetime import datetime

class PPWProofChain:
    """
    Termux-ready Python implementation of PPW Mathematical Proof document.
    Handles multi-hash verification, signature-ready chains, and export.
    """

    def __init__(self):
        self.chain = []
        self.algorithms = {
            'sha256': lambda d: hashlib.sha256(d.encode()).hexdigest(),
            'sha3_512': lambda d: hashlib.sha3_512(d.encode()).hexdigest()
        }

    def create_multi_hash(self, content):
        return {algo: func(content) for algo, func in self.algorithms.items()}

    def add_document(self, doc_id, content, metadata=None):
        multi_hash = self.create_multi_hash(content)
        chain_link = {
            'id': doc_id,
            'timestamp': datetime.now().isoformat(),
            'content_preview': content[:100] + '...' if len(content) > 100 else content,
            'hashes': multi_hash,
            'metadata': metadata or {},
            'previous_hash': self.chain[-1]['hashes']['sha256'] if self.chain else "GENESIS"
        }
        self.chain.append(chain_link)
        return multi_hash

    def verify_document(self, content, expected_hashes):
        current_hashes = self.create_multi_hash(content)
        results = {algo: current_hashes[algo] == expected_hashes.get(algo, None) 
                   for algo in current_hashes}
        return results

    def export_chain(self, filename="ppw_proof_chain.json"):
        data = {
            'exported': datetime.now().isoformat(),
            'chain_length': len(self.chain),
            'chain': self.chain
        }
        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)
        return f"Exported chain to {filename}"

if __name__ == "__main__":
    chain = PPWProofChain()

    # Example: adding your main PPW certificate
    cert_content = """
    PPW Mathematical Proof Document
    Certificate ID: 55847627305241977
    Owner: Perry Philip Wiseman
    Scope: Global Asset Ownership
    """
    chain.add_document(
        "CERT-55847627305241977",
        cert_content,
        metadata={
            "type": "global_ownership_proof",
            "jurisdiction": "multi",
            "status": "finalized"
        }
    )

    print("✅ Document added. Multi-hashes generated:")
    print(chain.chain[-1]['hashes'])

    # Export chain
    print(chain.export_chain())
