
;; STX-ResQFund
;; <add a description here>



(define-data-var admin principal tx-sender)       
(define-data-var min-donation uint u10)          
(define-data-var withdrawal-limit uint u1000)   


(define-public (set-admin (new-admin principal))
  (let ((current-admin (var-get admin)))
    (if (and 
          (is-eq tx-sender current-admin)
          (not (is-eq new-admin current-admin))
          (not (is-eq new-admin 'SP000000000000000000002Q6VF78)))
      (begin
        (var-set admin new-admin)
        (ok new-admin)
      )
      (err u401) 
    )
  )
)


(define-public (set-min-donation (amount uint))
  (if (is-eq tx-sender (var-get admin))
    (if (> amount u0)
      (begin
        (var-set min-donation amount)
        (ok amount)
      )
      (err u402)
    )
    (err u401) 
  )
)

;; Function to update the maximum withdrawal limit
(define-public (set-withdrawal-limit (amount uint))
  (if (is-eq tx-sender (var-get admin))
    (if (> amount u0)
      (begin
        (var-set withdrawal-limit amount)
        (ok amount)
      )
      (err u403) 
    )
    (err u401) 
  )
)

;; Read-only function to check the current admin
(define-read-only (get-admin)
  (ok (var-get admin))
)

;; Read-only function to get the minimum donation amount
(define-read-only (get-min-donation)
  (ok (var-get min-donation))
)

(define-read-only (get-withdrawal-limit)
  (ok (var-get withdrawal-limit))
)


(define-map signers principal bool)

(define-data-var required-signatures uint u3)


(define-map pending-transactions 
  { tx-id: uint } 
  { action: (string-ascii 50), params: (list 10 int), approvals: (list 10 principal) })

(define-data-var tx-nonce uint u0)



(define-public (validate-donation (amount uint))
  (if (>= amount (var-get min-donation))
    (ok true)
    (err u404) 
  )
)

(define-public (validate-withdrawal (amount uint))
  (if (<= amount (var-get withdrawal-limit))
    (ok true)
    (err u405) 
  )
)


(define-public (add-signer (new-signer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u401))
    (asserts! (is-none (map-get? signers new-signer)) (err u403))
    (ok (map-set signers new-signer true))))


(define-public (remove-signer (signer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u401))
    (asserts! (is-some (map-get? signers signer)) (err u404))
    (ok (map-delete signers signer))))

;; 
;; Function to change the admin
(define-public (change-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u401))
    (asserts! (not (is-eq new-admin (var-get admin))) (err u403))
    (asserts! (not (is-eq new-admin 'SP000000000000000000002Q6VF78)) (err u404))  ;; Prevent setting to zero address
    (var-set admin new-admin)
    (ok true)))

;; Function to propose a new transaction
(define-public (propose-transaction (action (string-ascii 50)) (params (list 10 int)))
  (let 
    (
      (tx-id (var-get tx-nonce))
      (action-length (len action))
    )
    (asserts! (is-some (map-get? signers tx-sender)) (err u401))
    (asserts! (and (> action-length u0) (<= action-length u50)) (err u402))
    (asserts! (<= (len params) u10) (err u403))
    (asserts! (< tx-id (- (pow u2 u128) u1)) (err u404))  ;; Check for potential overflow
    (map-set pending-transactions
      { tx-id: tx-id }
      { action: action, params: params, approvals: (list tx-sender) })
    (var-set tx-nonce (+ tx-id u1))
    (ok tx-id)))

;; Function to get pending transaction details
(define-read-only (get-pending-transaction (tx-id uint))
  (map-get? pending-transactions { tx-id: tx-id }))

;; Function to get the current transaction nonce
(define-read-only (get-tx-nonce)
  (ok (var-get tx-nonce)))

;; Private function to execute a transaction
(define-private (execute-transaction (tx-id uint))
  (let ((tx (unwrap! (map-get? pending-transactions { tx-id: tx-id }) (err u404))))
    ;; Implementation of execute-transaction would go here
    ;; This would involve pattern matching on the action and calling the appropriate function
    (map-delete pending-transactions { tx-id: tx-id })
    (ok true)))

;; Read-only function to check if an address is a signer
(define-read-only (is-signer (address principal))
  (is-some (map-get? signers address)))

;; Read-only function to get the required number of signatures
(define-read-only (get-required-signatures)
  (ok (var-get required-signatures)))

;; Function to change the required number of signatures (only callable by admin)
(define-public (set-required-signatures (new-required uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u401))
    (asserts! (> new-required u0) (err u403))
    (var-set required-signatures new-required)
    (ok true)))
