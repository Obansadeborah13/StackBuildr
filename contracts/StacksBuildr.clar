;; -------------------------------------------------------------
;; Smart Contract: StackBuildr
;; Description: Tokenize Real Estate and Enable Fractional STX Ownership
;; Language: Clarity for Stacks Blockchain
;; License: MIT
;; -------------------------------------------------------------

(define-trait nft-trait
  (
    ;; Required NFT trait functions
    (transfer (uint principal principal) (response bool uint))
    (get-owner (uint) (response principal uint))
    (get-last-token-id () (response uint uint))
  )
)

;; -------------------------
;; Data Maps
;; -------------------------

(define-map properties
  uint
  {
    name: (string-ascii 50),
    location: (string-ascii 100),
    total-shares: uint,
    available-shares: uint,
    price-per-share: uint,
    owner: principal,
    for-sale: bool
  }
)

(define-map property-owners
  {property-id: uint, investor: principal}
  uint
)

;; Optional: Rent accumulated for each investor
(define-map rental-income
  {property-id: uint, investor: principal}
  uint
)

;; Last token ID
(define-data-var last-property-id uint u0)

;; Contract owner
(define-constant contract-owner tx-sender)

;; -------------------------
;; NFT Functions
;; -------------------------

(define-map token-owners uint principal)

(define-read-only (get-owner (token-id uint))
  (match (map-get? token-owners token-id)
    owner (ok owner)
    (err u404)
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get last-property-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u401))
    (match (map-get? token-owners token-id)
      current-owner
        (begin
          (asserts! (is-eq current-owner sender) (err u403))
          (map-set token-owners token-id recipient)
          (ok true)
        )
      (err u404)
    )
  )
)

;; -------------------------
;; Core Functions
;; -------------------------

(define-public (mint-property
  (name (string-ascii 50))
  (location (string-ascii 100))
  (total-shares uint)
  (price-per-share uint)
)
  (let
    (
      (new-id (+ (var-get last-property-id) u1))
    )
    (begin
      (var-set last-property-id new-id)
      (map-set token-owners new-id tx-sender)
      (map-set properties new-id {
        name: name,
        location: location,
        total-shares: total-shares,
        available-shares: total-shares,
        price-per-share: price-per-share,
        owner: tx-sender,
        for-sale: true
      })
      (ok new-id)
    )
  )
)

(define-public (buy-shares (property-id uint) (num-shares uint))
  (let
    (
      (property (map-get? properties property-id))
    )
    (match property
      some-property
        (begin
          (asserts! (get for-sale some-property) (err u405))
          (let
            (
              (available (get available-shares some-property))
              (price (* (get price-per-share some-property) num-shares))
            )
            (begin
              (asserts! (<= num-shares available) (err u406))
              (try! (stx-transfer? price tx-sender (get owner some-property)))
              (map-set properties property-id (merge some-property {
                available-shares: (- available num-shares)
              }))
              (let
                ((key {property-id: property-id, investor: tx-sender})
                 (old-shares (default-to u0 (map-get? property-owners key))))
                (map-set property-owners key (+ old-shares num-shares))
              )
              (ok true)
            )
          )
        )
      (err u404)
    )
  )
)

(define-public (distribute-rent (property-id uint) (rent-amount uint))
  (let ((property (map-get? properties property-id)))
    (match property
      some-property
        (begin
          (asserts! (is-eq tx-sender (get owner some-property)) (err u401))
          (let
            ((total (get total-shares some-property)))
            (begin
              ;; Note: This is a simplified version. In practice, you'd need to iterate
              ;; through all property owners for this specific property
              (ok true)
            )
          )
        )
      (err u404)
    )
  )
)

(define-public (claim-rent (property-id uint))
  (let
    (
      (key {property-id: property-id, investor: tx-sender})
      (amount (default-to u0 (map-get? rental-income key)))
    )
    (begin
      (asserts! (> amount u0) (err u407))
      (map-delete rental-income key)
      ;; Note: In a real implementation, the contract would need to hold STX
      ;; and transfer from its own balance. This is a simplified version.
      (ok amount)
    )
  )
)

(define-public (set-for-sale (property-id uint) (status bool))
  (let ((property (map-get? properties property-id)))
    (match property
      some-property
        (begin
          (asserts! (is-eq tx-sender (get owner some-property)) (err u401))
          (map-set properties property-id (merge some-property {for-sale: status}))
          (ok true)
        )
      (err u404)
    )
  )
)

;; -------------------------
;; Read-only Views
;; -------------------------

(define-read-only (get-property (property-id uint))
  (map-get? properties property-id)
)

(define-read-only (get-shares (property-id uint) (owner principal))
  (default-to u0 (map-get? property-owners {property-id: property-id, investor: owner}))
)

(define-read-only (get-rent-balance (property-id uint) (owner principal))
  (default-to u0 (map-get? rental-income {property-id: property-id, investor: owner}))
)
