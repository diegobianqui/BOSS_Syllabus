# Part V: Scripting & Contracts

> "A contract is a predicate. It takes inputs and outputs either true or false." — John Newbery

## Chapter 9: The Philosophy of Verification

### 9.1 Verification vs. Computation

In the broader blockchain ecosystem, there is often a debate between "World Computer" models (like Ethereum) and "Digital Gold" models (like Bitcoin). This distinction is deeply rooted in the design of the scripting language.

**Post's Theorem & The Validation Gap**
As explained by John Newbery, we can view this through the lens of mathematical logic (Post's Theorem):
*   **$\Sigma_1$ (Sigma-1)**: Unbounded search or "Computation." This equates to **finding** a solution (e.g., "Find a number $x$ such that $x^2 = y$"). This is expensive and potentially infinite.
*   **$\Delta_0$ (Delta-0)**: Bounded verification. This equates to **checking** a solution (e.g., "Check if $5^2 = 25$"). This is cheap, constant-time, and deterministic.

**Bitcoin Script is $\Delta_0$**.
It does not run complex calculations. It does not "loop" until it finds an answer. It simply checks the **Witness** provided by the spender.
*   **The Spender (Wallet)**: Performs the computationally expensive task (creating the transaction, deriving paths, creating signatures).
*   **The Verifier (Node)**: Performs the cheap task (executing the Script).

This asymmetry is intended. It ensures that a Raspberry Pi can verify the work of a supercomputer, preserving the decentralization of the network.

### 9.2 Predicates, Not Programs
Bitcoin Script is often misunderstood as a "limited programming language." It is more accurate to call it a **Predicate**.
A predicate is a logical statement that evaluates to strictly `TRUE` or `FALSE`.
*   Code: `OP_DUP OP_HASH160 <Hash> OP_EQUALVERIFY OP_CHECKSIG`
*   Meaning: "Does the provided public key hash to $X$, and does the signature match that key?"

If the predicate returns `TRUE`, the funds move. If `FALSE` (or if the script fails), the state transition is rejected.

---

## Chapter 10: The Evolution of Contracts

The "Dynamics of Core Development" can be traced through the evolution of how we lock funds. The goal has always been to move complexity **off-chain** and increase **fungibility**.

### 10.1 P2PK (Pay-to-PubKey)
*   **Mechanism**: The output script contains the raw Public Key. `pubKey OP_CHECKSIG`.
*   **Dynamics**:
    *   *Pros*: Simple, efficient CPU verification.
    *   *Cons*: Public Keys (65 bytes uncompressed) are large and permanently stored in the UTXO set. Privacy is poor; the crypto-system is revealed immediately.

### 10.2 P2PKH (Pay-to-PubKey-Hash)
*   **Mechanism**: The output contains a Hash. The Key is revealed only when spending.
*   **Dynamics**: Satoshi introduced this to shorten addresses and add a layer of quantum resistance (if ECDSA is broken, unspent keys remain hidden behind SHA256).

### 10.3 P2SH (Pay-to-Script-Hash)
The revolution of 2012 (BIP 16).
*   **Problem**: If Bob wanted a complex "2-of-3 Multisig," he had to give Alice a huge, ugly script to put in the transaction output. Alice paid the fees for Bob's security.
*   **Solution**: Alice sends to a concise **Hash**. Bob reveals requirements only when he spends.
*   **Dynamics**:
    *   **Privacy**: The sender doesn't know the spending conditions.
    *   **Cost**: The storage cost moves from the UTXO (everyone pays) to the Input (spender pays). This aligns incentives.

---

## Chapter 11: Miniscript & Policy

### 11.1 The Problem with "Raw Script"
Bitcoin Script is effectively assembly language. It is unstructured and notoriously difficult to reason about safely.
*   **Example**: `OP_CHECKMULTISIG` has a famous off-by-one bug where it pops one too many items from the stack.
*   **Composability**: Combining a "Time Lock" and a "Multisig" manually often leads to unspendable coins or security holes.

### 11.2 Miniscript: Structured Scripting
**Miniscript** is a modern language that describes spending conditions in a structured, analyzable tree.

*   `descriptor = "wsh(and_v(v:pk(A),after(100)))"`
    *   *Meaning*: "Pay to Witness Script Hash: Require signature from A AND block height > 100".

**Benefits**:
1.  **Analysis**: Tools can mathematically prove a script is valid and spendable.
2.  **Fee Estimation**: The wallet can calculate the exact maximum size of the witness before constructing the transaction.
3.  **Interoperability**: A policy written in Miniscript works across different hardware wallets and software stacks.

### 11.3 Policy vs. Consensus
Why don't we just add every cool feature to Script?
*   **Consensus Rules**: Hard limits (e.g., Max Script Size 10,000 bytes). Violating these makes a block invalid.
*   **Policy (Standardness)**: Soft limits applied by nodes to *unconfirmed* transactions.
    *   *IsStandard()*: Core nodes will reject "weird" scripts (e.g., using NOP opcodes) from the mempool to prevent DOS attacks.
    *   *Dynamics*: New features (like CLTV or Taproot) often start as "Non-Standard." A **Soft Fork** elevates them to Standard, allowing the network to upgrade safely without splitting the chain.
