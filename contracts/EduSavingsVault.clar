;; Contract Name: EduSavingsVault
;; A time-locked education savings contract in Clarity
;; Parents deposit STX into a vault for their child
;; Funds are locked until a target block height or age
;; Beneficiary (child) can only withdraw after unlock

(define-data-var vault-id uint u0)

;; Vault struct: id, parent, beneficiary, amount, unlock-height, withdrawn?
(define-map vaults
  {id: uint}
  {parent: principal, beneficiary: principal, amount: uint, unlock: uint, withdrawn: bool})

;; Errors
(define-constant ERR-NOT-PARENT (err u100))
(define-constant ERR-NOT-BENEFICIARY (err u101))
(define-constant ERR-NO-SUCH-VAULT (err u102))
(define-constant ERR-NOT-UNLOCKED (err u103))
(define-constant ERR-ALREADY-WITHDRAWN (err u104))

;; Parent creates a vault by depositing STX locked until a future block height
;; Parent creates a vault by depositing STX locked until a future block height
(define-public (create-vault (beneficiary principal) (unlock uint) (amount uint))
  (let 
    ((current-height burn-block-height)
     (parent tx-sender))
    (begin
      (asserts! (> amount u0) (err u200))
      (asserts! (> unlock current-height) (err u205))
      (asserts! (is-some (some beneficiary)) (err u206))
      (let ((transfer (stx-transfer? amount parent (as-contract tx-sender))))
        (match transfer
          success
            (let ((id (+ u1 (var-get vault-id)))
                  (vault {parent: parent, 
                         beneficiary: beneficiary, 
                         amount: amount, 
                         unlock: unlock, 
                         withdrawn: false}))
              (var-set vault-id id)
              (map-set vaults {id: id} vault)
              (ok id))
          failure (err u201))))))

;; Beneficiary withdraws funds after unlock height
(define-public (withdraw (id uint))
  (begin
    (asserts! (<= id (var-get vault-id)) ERR-NO-SUCH-VAULT)
    (let ((vault (unwrap! (map-get? vaults {id: id}) ERR-NO-SUCH-VAULT))
          (beneficiary (get beneficiary vault))
          (amount (get amount vault))
          (unlock-height (get unlock vault))
          (withdrawn (get withdrawn vault))
          (parent (get parent vault)))
      (begin
        (asserts! (is-eq beneficiary tx-sender) ERR-NOT-BENEFICIARY)
        (asserts! (>= burn-block-height unlock-height) ERR-NOT-UNLOCKED)
        (asserts! (not withdrawn) ERR-ALREADY-WITHDRAWN)
        (let ((transfer (stx-transfer? amount (as-contract tx-sender) tx-sender))
              (vault-entry {id: id})
              (updated-vault {parent: parent, 
                            beneficiary: beneficiary, 
                            amount: amount, 
                            unlock: unlock-height, 
                            withdrawn: true}))
          (match transfer
            success (begin 
              (map-set vaults vault-entry updated-vault)
              (ok true))
            failure (err u202)))))))

;; View vault details
(define-read-only (get-vault (id uint))
  (map-get? vaults {id: id}))
