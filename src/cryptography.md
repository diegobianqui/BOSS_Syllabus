# Part II: Cryptographic Foundations

## Chapter 3: Hash Functions in Bitcoin ✅

### 3.1 The Role of Hashing ✅

At its core, Bitcoin is a giant chain of hash commitments. Hash functions allow us to take huge amounts of data (like a 2MB block) and represent it as a tiny, unique 32-byte string. This fingerprint is **deterministic** (always the same for the same data) and **one-way** (you can't reconstruct the block from the hash).

These properties are what make the blockchain immutable: if you change a single bit in a transaction, its hash changes, which changes the block's hash, which breaks the connection to every subsequent block in the chain.

```mermaid
graph LR
    subgraph Input["Any Input"]
        I1["'Hello'"]
        I2["Entire block data"]
        I3["Transaction bytes"]
    end
    
    subgraph SHA256["SHA256 Function"]
        F["One-way transformation"]
    end
    
    subgraph Output["Fixed 32-byte Output"]
        O["256-bit hash"]
    end
    
    I1 --> F
    I2 --> F
    I3 --> F
    F --> O
```

### 3.2 Double SHA256 vs Single SHA256 ✅

Bitcoin uses different hashing strategies for different contexts. **Double SHA256** (hashing the hash) was originally used by Satoshi to protect against potential future vulnerabilities in a single SHA256 pass. Modern upgrades like Taproot use **Tagged Hashing**, which prepends a domain-specific tag to the data to prevent "cross-protocol" attacks where a signature from one part of the system might be valid in another.

```mermaid
graph TD
    subgraph DoubleSHA["Double SHA256 (Legacy)"]
        D1[Input] --> D2["SHA256"]
        D2 --> D3["SHA256 again"]
        D3 --> D4["32-byte hash"]
    end
    
    subgraph SingleSHA["Single SHA256 (Taproot/BIP340)"]
        S1[Input] --> S2["SHA256"]
        S2 --> S3["32-byte hash"]
    end
    
    subgraph Tagged["Tagged Hash (BIP340)"]
        T1["tag + input"] --> T2["SHA256(SHA256(tag) || SHA256(tag) || data)"]
        T2 --> T3["32-byte hash"]
    end
```

---

## Chapter 4: Elliptic Curve Cryptography ✅

### 4.1 Keys Without the Math ✅

Elliptic Curve Cryptography (ECC) provides the "ownership" layer of Bitcoin. A **Private Key** is simply a secret random number. The **Public Key** is a coordinate on the `secp256k1` curve derived from that secret number. The "trapdoor" of ECC is that while it's easy to multiply a point to get a public key, it is mathematically impossible to "divide" to find the original secret number.

```mermaid
graph LR
    subgraph Private["Private Key"]
        PK["256-bit random number<br/>(Keep secret!)"]
    end
    
    subgraph Public["Public Key"]
        PUB["Point on secp256k1 curve<br/>(Share freely)"]
    end
    
    subgraph Relationship["One-Way Relationship"]
        R["Easy: Private → Public<br/>Impossible: Public → Private"]
    end
    
    PK -->|"Elliptic curve multiplication"| PUB
    PUB -.->|"Computationally infeasible"| PK
```

### 4.2 Key Formats in Bitcoin ✅

As Bitcoin evolved, key serialization became more efficient. Standard SegWit uses **Compressed Keys** (33 bytes), while Taproot introduces **X-only keys** (32 bytes). By assuming the "Y" coordinate of the point is always even, we can discard it entirely, saving space on the blockchain and simplifying signature verification.

```mermaid
graph TD
    subgraph PrivateKey["Private Key (32 bytes)"]
        SK["256-bit secret scalar"]
    end
    
    subgraph PublicKeyFormats["Public Key Formats"]
        FULL["Uncompressed (65 bytes)<br/>04 + x-coord + y-coord"]
        COMP["Compressed (33 bytes)<br/>02/03 + x-coord"]
        XONLY["X-only (32 bytes)<br/>Just x-coord"]
    end
    
    SK --> FULL
    SK --> COMP
    SK --> XONLY
    
    FULL -.->|"Legacy"| L1["P2PKH addresses"]
    COMP -.->|"Standard"| L2["P2WPKH, P2SH"]
    XONLY -.->|"Taproot"| L3["P2TR addresses"]
```
