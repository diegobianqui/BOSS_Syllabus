# Chapter 17: The Sphinx Protocol & Onion Construction

While Route Mathematics handles the *logistics* (amounts and delays), the **Sphinx Protocol** handles the *cryptography* and *packaging*. It ensures that the route information remains confidential and tamper-evident as it traverses the network.

## 1. The Onion Privacy Model

The Lightning Network uses a Sphinx-based onion routing packet. The core property of this design is **Bitwise Unlinkability**:
*   **No Position Awareness:** A node cannot tell if it is the first, fifth, or last hop (except by checking if the next hop is null).
*   **Constant Size:** The packet is always 1366 bytes. It does not shrink as layers are peeled off.
*   **Indistinguishability:** To an outside observer, all packets look like random noise.

*   **Video Resource:** [Christian Decker - Onion Deep Dive](https://www.youtube.com/watch?v=D4kX0gR-H0Y)

## 2. Shared Secrets & Key Derivation

The sender does not encrypt the packet with a single key. Instead, they perform an **Elliptic Curve Diffie-Hellman (ECDH)** key exchange with every node in the path.

### The Ephemeral Key
The sender generates a `session_key`. From this, they derive an initial ephemeral public key.
For each hop, the sender:
1.  Derives a `Shared Secret` using the hop's public key and the current ephemeral key.
2.  Mixes the `Shared Secret` with the ephemeral key to generate the *next* ephemeral key (Blinding Factor).

This creates a chain where the Sender knows the secrets for everyone, but each Node only derives the secret meant for them.

From each `Shared Secret`, specific keys are derived:
*   `rho`: Used to generate the stream cipher (ChaCha20) for encryption.
*   `mu`: Used to generate the HMAC for integrity checks.
*   `pad`: Used for generating random padding (rarely used directly in modern construction).

*   **Reference:** [BOLT #4: Key Generation](https://github.com/lightning/bolts/blob/master/04-onion-routing.md#key-generation)

## 3. The Fixed-Size Packet Problem

To maintain privacy, the packet size must not reveal the distance to the destination.
*   **Size:** Fixed at 1366 bytes.
*   **Structure:**
    *   `Version` (1 byte)
    *   `Public Key` (33 bytes)
    *   `Hop Payloads` (1300 bytes)
    *   `HMAC` (32 bytes)

### The "Shift & Insert" Technique
The onion is built **backwards**.
1.  Start with 1300 bytes of random noise.
2.  For the last hop: "Wrap" the payload.
3.  For the second-to-last hop:
    *   Shift the entire 1300-byte frame to the right by the size of the payload.
    *   Insert the current hop's payload at the front.
    *   Encrypt the whole frame using the ChaCha20 stream derived from `rho`.
    *   Calculate the HMAC.

This ensures that when a node receives the packet, it decrypts it (peeling a layer) and sees *its* payload at the front, followed by what looks like more random noise (the next hop's encrypted packet).

## 4. Filler Generation (The Hardest Part)

When a node "peels" a layer (decrypts and shifts left), the packet would naturally shrink. To prevent this, the node adds zero-padding at the end. However, if the node adds *known* zeroes, the next node could detect this.

To solve this, the sender calculates a **Filler** string. This filler is pre-calculated such that when a node adds its "zeroes" and decrypts, the "zeroes" transform into the exact encrypted bytes required for the end of the packet to look like random noise for the *next* hop.

> "The filler is the overhanging end of the routing information."

*   **Guide:** [Elle Mouton: Understanding the Sphinx Construction](https://ellemouton.com/posts/sphinx/)

## 5. Integrity & HMAC Chaining

The packet includes a 32-byte HMAC.
*   The sender calculates the HMAC for Hop `N` based on the encrypted packet for Hop `N+1`.
*   When Hop `N` receives the packet, it verifies the HMAC using its derived `mu` key.
*   If the HMAC is valid, it guarantees the packet has not been tampered with and was constructed by someone who knows the shared secret.

This chaining mechanism ensures that if any bit is flipped in transit, the packet is rejected immediately.

## References

*   **BOLT #04:** [Onion Routing Protocol Specification](https://github.com/lightning/bolts/blob/master/04-onion-routing.md)
*   **BOLT #07:** [P2P Node and Channel Discovery](https://github.com/lightning/bolts/blob/master/07-routing-gossip.md)
*   **Deep Dive:** [Elle Mouton: Understanding the Sphinx Construction](https://ellemouton.com/posts/sphinx/)
*   **Library Reference:** [Lightning Dev Kit (LDK) Docs](https://lightningdevkit.org/)
