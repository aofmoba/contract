# Cyberpop Governance

Built upon the openzeppelin governance contracts, which replicate compound governor alpha and beta behaviour.

Proposals are created differently, they are not executable, instead each proposal is like a NFT that meta data can be fetch via the Meta API.

```js
// Fetch meta data URL
governor.proposalURI(proposalId)
```