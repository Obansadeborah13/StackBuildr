# StackBuildr Smart Contract 🏢

A Clarity smart contract for real estate tokenization on the Stacks blockchain, enabling fractional ownership and management of property assets.

## Features ✨

- **Property NFT Minting**: Create unique tokens representing real estate properties
- **Fractional Ownership**: Enable multiple investors to own shares of properties
- **Share Trading**: Buy and sell property shares using STX
- **Rent Distribution**: Manage and distribute rental income to shareholders
- **Property Management**: Control property sale status and ownership transfers

## Contract Functions 🛠️

### Core Functions

```clarity
(mint-property (name (string-ascii 50)) (location (string-ascii 100)) (total-shares uint) (price-per-share uint))
```
Creates a new property token with specified details.

```clarity
(buy-shares (property-id uint) (num-shares uint))
```
Purchase shares of an existing property.

```clarity
(distribute-rent (property-id uint) (rent-amount uint))
```
Distribute rental income to shareholders.

### Read-Only Functions

```clarity
(get-property (property-id uint))
```
Retrieve property details.

```clarity
(get-shares (property-id uint) (owner principal))
```
Check share ownership for a specific property and owner.

## Data Structure 📊

### Properties Map
```clarity
{
  name: (string-ascii 50),
  location: (string-ascii 100),
  total-shares: uint,
  available-shares: uint,
  price-per-share: uint,
  owner: principal,
  for-sale: bool
}
```

## Getting Started 🚀

1. Deploy the contract to the Stacks blockchain
2. Mint a property using `mint-property`
3. Investors can purchase shares using `buy-shares`
4. Property owner can distribute rent using `distribute-rent`

## Security Considerations 🔒

- Owner authentication for sensitive operations
- Balance checks for share purchases
- Error handling for invalid operations

## Requirements 📋

- Stacks blockchain account
- STX tokens for transactions
- Clarity-compatible wallet

