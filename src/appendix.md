# Appendix: Quick Reference

## A. BIP Standards Summary

| BIP | Name | Purpose |
|-----|------|---------|
| BIP32 | HD Wallets | Deterministic key derivation from seed |
| BIP86 | Taproot Single Key | Standard derivation path for single-key Taproot |
| BIP341 | Taproot | The rules for SegWit v1 outputs |
| BIP342 | Tapscript | The new opcodes for Taproot scripts |

## B. Conceptual Glossary

| Term | Conceptual Definition |
|------|----------------------|
| **UTXO** | An unspent coin waiting in a lockbox on the blockchain. |
| **Outpoint** | The unique ID of a UTXO (TXID + output index). |
| **Witness** | The signature data, kept separate from the transaction to fix malleability. |
| **Tweak** | A mathematical shift applied to a key to commit to a script tree. |
| **Dust** | An output so small it's worth less than the fee required to spend it. |
