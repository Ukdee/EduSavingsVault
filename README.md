# EduSavingsVault Smart Contract

A Clarity smart contract for creating time-locked education savings vaults on the Stacks blockchain.

## Overview

EduSavingsVault enables parents to create secure savings vaults for their children's education by locking STX tokens until a specified block height. Only designated beneficiaries can withdraw funds after the unlock conditions are met.

## Features

- **Secure Vault Creation**: Parents can deposit STX into time-locked vaults
- **Beneficiary Protection**: Only designated beneficiaries can withdraw funds
- **Time-Lock Mechanism**: Funds are locked until reaching specified block height
- **State Management**: Tracks vault status and prevents duplicate withdrawals
- **Read-Only Queries**: View vault details without state changes

## Functions

### create-vault
```clarity
(create-vault beneficiary unlock-height amount)
```
Creates a new education savings vault with:
- `beneficiary`: Principal who can withdraw funds (child)
- `unlock-height`: Block height when funds become available
- `amount`: STX tokens to lock in the vault

### withdraw
```clarity
(withdraw vault-id)
```
Allows beneficiary to withdraw funds when:
- Current block height ≥ unlock height
- Caller is the designated beneficiary
- Vault hasn't been withdrawn before

### get-vault
```clarity
(get-vault vault-id)
```
Returns vault details including:
- Parent principal
- Beneficiary principal
- Locked amount
- Unlock height
- Withdrawal status

## Error Codes

- `u100`: Not the parent
- `u101`: Not the beneficiary
- `u102`: Vault doesn't exist
- `u103`: Vault not unlocked yet
- `u104`: Already withdrawn
- `u200`: Invalid amount
- `u201`: Transfer failed
- `u202`: Withdrawal failed
- `u205`: Invalid unlock height
- `u206`: Invalid beneficiary

## Development

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet)
- [Stacks Wallet](https://www.hiro.so/wallet)

### Testing
```bash
clarinet test
```

### Deployment
```bash
clarinet deploy
```
