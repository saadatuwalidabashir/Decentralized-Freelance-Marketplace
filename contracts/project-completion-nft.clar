;; Project Completion NFT Contract

(define-non-fungible-token project-completion-nft uint)

(define-map project-completion-info
  { completion-id: uint }
  {
    job-id: uint,
    client: principal,
    freelancer: principal,
    title: (string-ascii 100),
    description: (string-utf8 1000),
    completion-date: uint
  }
)

(define-data-var completion-nonce uint u0)

(define-public (mint-project-completion
  (job-id uint)
  (freelancer principal)
  (title (string-ascii 100))
  (description (string-utf8 1000)))
  (let
    ((new-id (+ (var-get completion-nonce) u1))
     (job (unwrap! (contract-call? .job-posting get-job-posting job-id) (err u404))))
    (asserts! (is-eq tx-sender (get client job)) (err u403))
    (try! (nft-mint? project-completion-nft new-id freelancer))
    (map-set project-completion-info
      { completion-id: new-id }
      {
        job-id: job-id,
        client: tx-sender,
        freelancer: freelancer,
        title: title,
        description: description,
        completion-date: block-height
      }
    )
    (var-set completion-nonce new-id)
    (ok new-id)
  )
)

(define-read-only (get-project-completion-info (completion-id uint))
  (map-get? project-completion-info { completion-id: completion-id })
)

