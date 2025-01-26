;; Job Posting Contract

(define-map job-postings
  { job-id: uint }
  {
    client: principal,
    title: (string-ascii 100),
    description: (string-utf8 1000),
    required-skills: (list 10 uint),
    budget: uint,
    deadline: uint,
    status: (string-ascii 20)
  }
)

(define-data-var job-nonce uint u0)

(define-public (create-job-posting
  (title (string-ascii 100))
  (description (string-utf8 1000))
  (required-skills (list 10 uint))
  (budget uint)
  (deadline uint))
  (let
    ((new-id (+ (var-get job-nonce) u1)))
    (map-set job-postings
      { job-id: new-id }
      {
        client: tx-sender,
        title: title,
        description: description,
        required-skills: required-skills,
        budget: budget,
        deadline: deadline,
        status: "open"
      }
    )
    (var-set job-nonce new-id)
    (ok new-id)
  )
)

(define-public (update-job-status (job-id uint) (new-status (string-ascii 20)))
  (let
    ((job (unwrap! (map-get? job-postings { job-id: job-id }) (err u404))))
    (asserts! (is-eq tx-sender (get client job)) (err u403))
    (map-set job-postings
      { job-id: job-id }
      (merge job { status: new-status })
    )
    (ok true)
  )
)

(define-read-only (get-job-posting (job-id uint))
  (map-get? job-postings { job-id: job-id })
)

