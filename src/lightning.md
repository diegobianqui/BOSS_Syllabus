# Part VIII: The Lightning Network

## Chapter 15: Architecture & Operations

The Lightning Network is a Layer 2 protocol operating on top of Bitcoin. It enables instant, high-volume micropayments by keeping the majority of transactions "off-chain" and only settling the final results on the main Bitcoin blockchain.

This chapter explores the practical architecture of running a Lightning node, specifically focusing on the interaction between the **Bitcoin Core** (Layer 1) and **LND** (Layer 2) daemons.

### 15.1 Layer 1 to Layer 2 Communication (ZMQ)

A Lightning node cannot operate in isolation. It requires a real-time feed of blockchain data to detect:
1.  **Channel Funding:** When a funding transaction is confirmed.
2.  **Channel Closing:** When a channel is cooperatively or forcefully closed.
3.  **Fraud Attempts:** If a counterparty tries to broadcast an old state (breach).

To achieve this low-latency communication, we do not rely solely on RPC polling. Instead, we use **ZeroMQ (ZMQ)**, a high-performance asynchronous messaging library. Bitcoin Core publishes events to specific ports (typically 28332/28333), and LND subscribes to them.

*   `zmqpubrawblock`: Publishes raw block data immediately.
*   `zmqpubrawtx`: Publishes raw transactions entering the mempool.

> **Source:** [Bitcoin Core - ZeroMQ Interface](https://github.com/bitcoin/bitcoin/blob/master/doc/zmq.md)

### 15.2 Node Initialization & Compatibility

Running a Lightning node involves orchestrating two distinct services. Compatibility between the L1 backend and the L2 node is critical. For instance, modern Bitcoin Core versions (v28+) often require updated LND versions (v0.18.4-beta+) to handle changes in RPC responses or fee estimation logic.

**Key Configuration (`lnd.conf`):**
```ini
[Bitcoin]
bitcoin.active=1
bitcoin.node=bitcoind
bitcoin.zmqpubrawblock=tcp://127.0.0.1:28332
bitcoin.zmqpubrawtx=tcp://127.0.0.1:28333
```

> **Source:** [LND Configuration Guide](https://docs.lightning.engineering/lightning-network-tools/lnd/run-lnd)

### 15.3 Liquidity: From On-Chain to Off-Chain

In the Lightning Network, "funds" are UTXOs locked in a 2-of-2 multisignature output shared between two peers. This is known as a **Channel**.

1.  **Funding:** You send on-chain Bitcoin to a generated multi-sig address.
2.  **Locking:** The transaction is mined (usually requiring 3-6 confirmations).
3.  **Active:** The channel is now "open," and the balance is represented off-chain.

To fund a node, you typically generate a Layer 2 wallet address (`lncli newaddress np2wkh`), send Bitcoin from your Layer 1 wallet (`bitcoin-cli sendtoaddress`), and wait for the mining process.

> **Source:** [LND Wallet Management](https://docs.lightning.engineering/lightning-network-tools/lnd/wallet-management)

### 15.4 The Payment Lifecycle (BOLT 11)

Lightning payments are invoice-based. A **BOLT 11** invoice contains encoded instructions, including the payment hash, amount, and expiry.

**The Flow:**
1.  **Invoice:** Recipient generates a request (`lncli addinvoice`).
2.  **Route:** Sender calculates a path through the network graph.
3.  **HTLC:** Sender locks funds to the first hop hash.
4.  **Settlement:** If the path is valid, the recipient reveals the **Preimage** (a 32-byte secret). This preimage cascades back through the route, unlocking the funds for each hop.

The **Preimage** serves as cryptographic proof of payment.

> **Source:** [BOLT 11: Invoice Protocol](https://github.com/lightning/bolts/blob/master/11-payment-encoding.md)

### 15.5 Network Topology & Gossip (BOLT 7)

Nodes discover each other via the **Gossip Protocol**. They broadcast:
*   **Node Announcements:** "I exist, here is my IP and PubKey."
*   **Channel Announcements:** "We opened a channel (proven by this txid)."
*   **Channel Updates:** "My fee policy for this channel is X base sats + Y%."

You can inspect the network graph using `lncli describegraph` or analyze specific channel policies with `lncli getchaninfo`. This data is essential for calculating fees and finding cheap routes.

> **Source:** [BOLT 7: P2P Node and Channel Discovery](https://github.com/lightning/bolts/blob/master/07-routing-gossip.md)

### 15.6 Source Routing

While LND typically automates pathfinding, users can enforce **Source Routing** to manually dictate the payment path. This is useful for:
*   **Privacy:** Avoiding surveillance nodes.
*   **Cost:** Forcing a route through cheaper channels.
*   **Testing:** Debugging specific connections.

In LND, this is achieved by specifying the `outgoing_chan_id` (first hop) and `last_hop` (penultimate node) during payment.

> **Source:** [LND Routing & Pathfinding](https://docs.lightning.engineering/lightning-network-tools/lnd/pathfinding)
