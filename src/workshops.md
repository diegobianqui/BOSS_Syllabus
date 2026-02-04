# Part VIII: Engineering Labs

## Chapter 15: Workshop: Hand-Crafting Taproot

This workshop focuses on the "bare metal" construction of Taproot transactions. We will bypass high-level libraries to implement the cryptographic "plumbing" defined in BIP 340, 341, and 342. This is essential for understanding *why* the protocol works the way it does.

### 15.1 The "Plumbing" of Protocol Upgrades (BIP 341)

In Taproot, every output is technically a pay-to-public-key. Even complex scripts are "hidden" inside a tweaked public key. To construct a Taproot address manually, we must perform this tweaking process ourselves.

#### The NUMS Point (Nothing Up My Sleeve)
When we want to create an output that is *only* spendable via a script (like a strict multisig) and not by a single key, we cannot just pick a random private key for the "Internal Key." If we did, whoever knew that private key could bypass the script!

Instead, we use a **NUMS point**—a point on the curve for which no one knows the private key. A standard way to generate this is taking the hash of a seed string and treating it as the X-coordinate.

> **Source:** [BIP 341 - Constructing and Spending Taproot Outputs](https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki) (See "Constructing and spending Taproot outputs")

### 15.2 Manual Multisig Construction (BIP 342)

Tapscript (SegWit v1) changes how multisig works. The inefficient `OP_CHECKMULTISIG` (which required checking every public key against every signature) is removed.

Instead, we use a combination of `OP_CHECKSIG` and `OP_CHECKSIGADD`.

**The Logic:**
1.  **`<pubkey_A> OP_CHECKSIG`**: Consumes a signature. Pushes `1` (true) or `0` (false) to the stack.
2.  **`<pubkey_B> OP_CHECKSIGADD`**: Consumes a signature and the result of the previous operation. It checks the signature and *adds* the result (0 or 1) to the existing counter.
3.  **`<threshold> OP_EQUAL`**: Checks if the final sum equals the required threshold (e.g., 2).

**The Script:**
```bitcoin
<PubKey_A> OP_CHECKSIG <PubKey_B> OP_CHECKSIGADD OP_2 OP_EQUAL
```

> **Source:** [BIP 342 - Script Validation Rules](https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki) (See "Execution" regarding `OP_CHECKSIGADD`)

### 15.3 The Private Key Tweak (Key Path Spend)

This is the most common stumbling block. If you are spending via the **Key Path**, you are technically signing for the **Output Key (Q)**, not your original Internal Key (P).

The Output Key is defined as:
$$Q = P + H(P || m)G$$

Therefore, the valid private key for $Q$ is:
$$d_{tweaked} = d_{internal} + H(P || m)$$

You must manually compute this scalar addition modulo the curve order. If you try to sign with just `d_{internal}`, the network will reject the signature because it doesn't match the address on-chain.

> **Source:** [BIP 340 - Schnorr Signatures for secp256k1](https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki) (See "Design" regarding linearity)

### 15.4 Building the Control Block (Script Path Spend)

When spending via the **Script Path**, you must provide a "Control Block" in the witness stack. This block proves to the verifier that the script you are executing is indeed a leaf in the Merkle tree committed to in the address.

**Structure of the Control Block:**
1.  **Leaf Version (1 byte)**: Usually `0xC0` (Tapscript) + the **Parity Bit**.
    *   *Parity Bit*: Schnorr public keys must have an even Y-coordinate. If the tweaked key $Q$ ends up with an odd Y-coordinate, the parity bit is set (0x03), telling the verifier to flip the sign during validation.
2.  **Internal Key (32 bytes)**: The original `P` (or NUMS point).
3.  **Merkle Path (Variable)**: The list of hashes needed to prove the path from the script leaf to the root.

> **Source:** [BIP 341 - Spending rules](https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki) (See "Script validation")

### 15.5 Provably Unspendable Data (`OP_RETURN`)

To store data on-chain (like proving you completed a challenge), we use `OP_RETURN`. This opcode marks the output as invalid, meaning it can never be spent. This allows us to carry up to 80 bytes of arbitrary data without bloating the UTXO set, as full nodes can prune these outputs knowing they are dead ends.

```bitcoin
OP_RETURN <data_bytes>
```
