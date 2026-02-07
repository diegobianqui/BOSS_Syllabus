# Chapter 16: Route Mathematics & Logistics

In the Lightning Network, the burden of calculating a route falls entirely on the sender. This paradigm, known as **Source Routing**, contrasts sharply with the IP routing model where each router decides the next hop. This chapter explores the mathematical and logistical challenges a node faces when constructing a valid path for a payment.

## 1. Source Routing Paradigm

In the Lightning Network, the sender (Source) must construct the entire route to the destination before sending a single satoshi. This is critical for:
*   **Privacy:** Intermediate nodes only know their immediate predecessor and successor (Onion Routing). They do not know the ultimate sender or receiver.
*   **Fee Predictability:** The sender can calculate the exact cost of the transaction upfront.
*   **Reliability:** The sender can avoid nodes known to be offline or unreliable based on their local network view.

To achieve this, the sender maintains a local map of the network graph, built via the Gossip Protocol.

*   **Reference:** [BOLT #7: P2P Node and Channel Discovery](https://github.com/lightning/bolts/blob/master/07-routing-gossip.md)

## 2. The Backward Propagation Algorithm

When calculating a route, one might intuitively start from the sender and move forward. However, in Lightning, route construction must happen **backwards**, from the Destination to the Source.

### Why Backwards?
To construct a valid HTLC (Hash Time Locked Contract) for Hop `N`, you must know exactly how much to forward to Hop `N+1`. However, Hop `N+1` will deduct a fee from the incoming amount before forwarding to Hop `N+2`. Therefore, you cannot know the input amount for Hop `N` until you have calculated the input amount for Hop `N+1`.

This dependency chain means we start with the **Receiver**, who expects a fixed `Final Amount`, and propagate the requirements backwards.

### The Fee Formula

For each channel, the fee is composed of a base fee and a proportional fee (parts per million).

$$ Fee = BaseFee + \frac{Amount \times ProportionalFee}{1,000,000} $$

The amount to be received by the previous node is:
$$ Amount_{prev} = Amount_{next} + Fee $$

*   **Reference:** [BOLT #7: Fee Calculation](https://github.com/lightning/bolts/blob/master/07-routing-gossip.md#htlc-fees)

## 3. HTLC Dynamics (Time & Value)

Money is not the only variable that propagates backwards; time does as well.

### CLTV (CheckSequenceVerify) Delta
To ensure safety against cheating, each hop requires a time-lock buffer. If Hop `N+1` claims funds, Hop `N` needs enough time to claim funds from Hop `N-1` before the timeout. This buffer is the `cltv_expiry_delta`.

*   **Cumulative Time-Lock:** The sender must start with the current block height + receiver's delay + sum(all intermediate deltas).
*   **Validation:** If a node receives an HTLC with insufficient expiry time (too close to the present), it will reject the payment to protect itself from race conditions.

*   **Reference:** [BOLT #2: Channel Operations (HTLCs)](https://github.com/lightning/bolts/blob/master/02-peer-protocol.md#adding-an-htlc-update_add_htlc)

## 4. Multi-Part Payments (MPP) & TLV

Modern Lightning payments often exceed the capacity of a single channel. **Multi-Part Payments (MPP)** allow a sender to split a payment into multiple smaller "shards," routed through different paths, which are reassembled by the receiver.

### Atomicity in MPP
The receiver must not settle *any* shard until *all* shards have arrived. To coordinate this safely without revealing the total amount to intermediate nodes, we use **TLV (Type-Length-Value)** payloads in the final hop.

*   **payment_secret:** A secret known only to the sender and receiver. All shards must include this to prove they are part of the same payment.
*   **total_msat:** Tells the receiver the total amount expected. The receiver waits until the sum of incoming HTLCs equals this value before settling.

*   **Reference:** [BOLT #4: Onion Routing Protocol (TLV)](https://github.com/lightning/bolts/blob/master/04-onion-routing.md#packet-structure)
