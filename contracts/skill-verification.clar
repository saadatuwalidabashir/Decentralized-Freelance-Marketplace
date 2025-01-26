;; Skill Verification Contract

(define-non-fungible-token skill-nft uint)

(define-map skill-info
  { skill-id: uint }
  {
    name: (string-ascii 50),
    description: (string-utf8 500),
    issuer: principal,
    holder: principal,
    expiration: uint
  }
)

(define-data-var skill-nonce uint u0)

(define-public (issue-skill
  (name (string-ascii 50))
  (description (string-utf8 500))
  (holder principal)
  (expiration uint))
  (let
    ((new-id (+ (var-get skill-nonce) u1)))
    (try! (nft-mint? skill-nft new-id holder))
    (map-set skill-info
      { skill-id: new-id }
      {
        name: name,
        description: description,
        issuer: tx-sender,
        holder: holder,
        expiration: expiration
      }
    )
    (var-set skill-nonce new-id)
    (ok new-id)
  )
)

(define-public (revoke-skill (skill-id uint))
  (let
    ((skill (unwrap! (map-get? skill-info { skill-id: skill-id }) (err u404))))
    (asserts! (is-eq tx-sender (get issuer skill)) (err u403))
    (try! (nft-burn? skill-nft skill-id (get holder skill)))
    (map-delete skill-info { skill-id: skill-id })
    (ok true)
  )
)

(define-read-only (get-skill-info (skill-id uint))
  (map-get? skill-info { skill-id: skill-id })
)

(define-read-only (verify-skill (skill-id uint) (holder principal))
  (match (map-get? skill-info { skill-id: skill-id })
    skill (and
      (is-eq (get holder skill) holder)
      (> (get expiration skill) block-height)
    )
    false
  )
)

