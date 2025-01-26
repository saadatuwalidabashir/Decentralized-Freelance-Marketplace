;; Escrow Service Contract

(define-map escrows
  { escrow-id: uint }
  {
    job-id: uint,
    client: principal,
    freelancer: principal,
    amount: uint,
    status: (string-ascii 20)
  }
)

(define-data-var escrow-nonce uint u0)

(define-public (create-escrow (job-id uint) (freelancer principal) (amount uint))
  (let
    ((new-id (+ (var-get escrow-nonce) u1))
     (job (unwrap! (contract-call? .job-posting get-job-posting job-id) (err u404))))
    (asserts! (is-eq tx-sender (get client job)) (err u403))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set escrows
      { escrow-id: new-id }
      {
        job-id: job-id,
        client: tx-sender,
        freelancer: freelancer,
        amount: amount,
        status: "funded"
      }
    )
    (var-set escrow-nonce new-id)
    (ok new-id)
  )
)

(define-public (release-escrow (escrow-id uint))
  (let
    ((escrow (unwrap! (map-get? escrows { escrow-id: escrow-id }) (err u404))))
    (asserts! (is-eq tx-sender (get client escrow)) (err u403))
    (asserts! (is-eq (get status escrow) "funded") (err u400))
    (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get freelancer escrow))))
    (map-set escrows
      { escrow-id: escrow-id }
      (merge escrow { status: "released" })
    )
    (ok true)
  )
)

(define-public (refund-escrow (escrow-id uint))
  (let
    ((escrow (unwrap! (map-get? escrows { escrow-id: escrow-id }) (err u404))))
    (asserts! (is-eq tx-sender (get client escrow)) (err u403))
    (asserts! (is-eq (get status escrow) "funded") (err u400))
    (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get client escrow))))
    (map-set escrows
      { escrow-id: escrow-id }
      (merge escrow { status: "refunded" })
    )
    (ok true)
  )
)

(define-read-only (get-escrow (escrow-id uint))
  (map-get? escrows { escrow-id: escrow-id })
)

