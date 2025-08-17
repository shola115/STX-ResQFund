

#  STX-ResQFund

## Overview

This Clarity smart contract is designed for disaster-relief organizations to manage donations and withdrawals in a secure and controlled manner. It includes features such as:

* Admin management
* Minimum donation enforcement
* Withdrawal limits
* Multi-signature transaction approval
* Proposal-based transaction execution

## 🔐 Core Features

### 1. **Admin Controls**

The contract is controlled by an admin account that has elevated privileges to manage other variables and settings.

#### Functions:

* `set-admin(new-admin)` – Assign a new admin (non-zero address).
* `get-admin()` – View current admin.
* `change-admin(new-admin)` – Change admin (alternate method with added checks).

---

### 2. **Donation & Withdrawal Policy**

#### Minimum Donation

Ensures users meet a minimum threshold before donating.

* `set-min-donation(amount)` – Set a new minimum donation.
* `get-min-donation()` – Read the current minimum.
* `validate-donation(amount)` – Validate a donation against the threshold.

#### Withdrawal Limit

Caps the withdrawal amount that a recipient can request.

* `set-withdrawal-limit(amount)` – Set a new max withdrawal.
* `get-withdrawal-limit()` – Read the current withdrawal limit.
* `validate-withdrawal(amount)` – Ensure withdrawal is under limit.

---

### 3. **Multi-Signature Transaction Governance**

The contract includes a robust multisig mechanism to secure transaction execution.

#### Signer Management

* `add-signer(new-signer)` – Add a new signer (admin-only).
* `remove-signer(signer)` – Remove an existing signer (admin-only).
* `is-signer(address)` – Check if an address is a signer.

#### Transaction Proposals

* `propose-transaction(action, params)` – Propose a transaction (signers only).
* `get-pending-transaction(tx-id)` – View transaction proposal details.
* `get-tx-nonce()` – Get current transaction ID counter.

#### Multisig Settings

* `set-required-signatures(new-required)` – Admin sets how many signers are required for approval.
* `get-required-signatures()` – Read current approval threshold.

> ⚠️ **Note**: The `execute-transaction` function is defined but not fully implemented. Developers should implement the logic to execute proposed actions based on transaction type and parameters.

---

## 🛠 Installation & Deployment

1. Install the [Clarity CLI](https://docs.stacks.co/write-smart-contracts/clarity-cli) or use a Stacks-compatible development environment (e.g., Clarinet).
2. Save the contract code to a `.clar` file.
3. Deploy the contract on a local Devnet or Stacks Testnet.
4. Use Clarity console or scripts to interact with the contract functions.

---

## 📘 Example Usage

### Set Admin

```clarity
(set-admin 'ST3J...ADMIN')
```

### Validate Donation

```clarity
(validate-donation u15) ;; returns (ok true) if above min-donation
```

### Propose Transaction

```clarity
(propose-transaction "distribute-funds" (list 100 200))
```

### Add a Signer

```clarity
(add-signer 'ST3J...SIGNER1)
```

---

## 🔒 Error Codes

| Error Code | Meaning                                                     |
| ---------- | ----------------------------------------------------------- |
| `u401`     | Unauthorized access                                         |
| `u402`     | Invalid input (e.g., zero value or empty string)            |
| `u403`     | Invalid operation (e.g., already exists or already removed) |
| `u404`     | Not found / Below required threshold                        |
| `u405`     | Withdrawal exceeds limit                                    |

---
