# Part I: Bitcoin Core Architecture

## Chapter 1: The System Model

Bitcoin Core is the reference implementation of the protocol. For the developer, it serves as the authoritative state machine. It maintains the ledger, validates state transitions (transactions), and propagates data to the peer-to-peer network.

### 1.1 Separation of Concerns

The architecture strictly separates **Consensus** (immutable network rules) from **Policy** (local node hygiene). This ensures that while individual nodes may reject spam (Policy), they all agree on the ledger state (Consensus).

```mermaid
graph TB
    subgraph Network["Connectivity"]
        P2P["P2P Layer"]
        RPC["RPC Interface"]
    end

    subgraph Core["State Machine"]
        VAL["Validation Engine<br/>(Consensus)"]
        MEM["Mempool<br/>(Policy + Consensus)"]
        CHAIN["Chain State<br/>(UTXO Set)"]
    end

    subgraph Storage["Persistence"]
        DB["LevelDB"]
        BLK["Block Files"]
    end

    P2P --> MEM
    RPC --> MEM
    MEM --> VAL
    VAL --> CHAIN
    CHAIN --> DB
```

### 1.2 The RPC Contract

The JSON-RPC interface is the developer's bridge to the node. Unlike modern REST APIs, it is synchronous and strictly typed. It acts as a trusted interface, allowing the wallet software to query state and broadcast signed transactions.

*   **Synchronous**: The node processes requests sequentially per worker thread.
*   **Method-Based**: Interactions are defined by commands (e.g., `getblocktemplate`, `sendrawtransaction`).

```mermaid
sequenceDiagram
    participant Client as Wallet/Dev
    participant Server as Node (RPC)
    participant Engine as Consensus Engine

    Client->>Server: POST {"method": "gettxout"}
    Server->>Engine: Acquire cs_main lock
    Engine->>Engine: Lookup UTXO
    Engine-->>Server: Return Coin Data
    Server-->>Client: Result JSON
```

---

## Chapter 2: Operational Environment

### 2.1 Signet: Deterministic Development

To develop robust solutions, we require a stable environment. Mainnet is expensive; Testnet is chaotic. **Signet** (BIP 325) offers a centralized consensus mechanism on top of the Bitcoin codebase, mimicking Mainnet's topology but with predictable block generation.

*   **Stability**: No block storms or deep reorgs.
*   **Access**: Free coins for testing complex flows.
*   **Validation**: Identical script validation rules to Mainnet.

### 2.2 Data Propagation Flow

Data moves through the node in two phases: **Relay** (unconfirmed) and **Mining** (confirmed).

```mermaid
graph LR
    subgraph Phase1["Relay"]
        TX[Tx] -->|Policy Check| MP[Mempool]
    end

    subgraph Phase2["Confirmation"]
        MP -->|Fee Algo| BLOCK[Block Candidate]
        BLOCK -->|PoW| CHAIN[Active Chain]
    end
    
    style Phase1 fill:#f9f9f9,stroke:#333
    style Phase2 fill:#e1f5fe,stroke:#333
```

---

#### References
*   *Bitcoin Core Architecture Overview*
*   *BIP 325: Signet*
*   *Bitcoin RPC API Reference*
