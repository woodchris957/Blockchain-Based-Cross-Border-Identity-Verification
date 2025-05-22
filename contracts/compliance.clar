;; Compliance Contract
;; Ensures adherence to jurisdictional requirements

;; Map of jurisdiction codes to their compliance rules
(define-map jurisdiction-rules
  { jurisdiction-code: (string-ascii 10) }
  {
    min-age: uint,
    required-attributes: (list 10 (string-ascii 64)),
    last-updated: uint,
    active: bool
  })

;; Map of approved verifiers for each jurisdiction
(define-map jurisdiction-verifiers
  { jurisdiction-code: (string-ascii 10), verifier: principal }
  { approved-at: uint, active: bool })

(define-data-var admin principal tx-sender)

;; Set compliance rules for a jurisdiction
(define-public (set-jurisdiction-rules
    (jurisdiction-code (string-ascii 10))
    (min-age uint)
    (required-attributes (list 10 (string-ascii 64))))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (map-set jurisdiction-rules
      { jurisdiction-code: jurisdiction-code }
      {
        min-age: min-age,
        required-attributes: required-attributes,
        last-updated: block-height,
        active: true
      })
    (ok true)))

;; Approve a verifier for a jurisdiction
(define-public (approve-jurisdiction-verifier
    (jurisdiction-code (string-ascii 10))
    (verifier principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (map-set jurisdiction-verifiers
      { jurisdiction-code: jurisdiction-code, verifier: verifier }
      { approved-at: block-height, active: true })
    (ok true)))

;; Revoke a verifier for a jurisdiction
(define-public (revoke-jurisdiction-verifier
    (jurisdiction-code (string-ascii 10))
    (verifier principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (map-set jurisdiction-verifiers
      { jurisdiction-code: jurisdiction-code, verifier: verifier }
      { approved-at: block-height, active: false })
    (ok true)))

;; Check if a verifier is approved for a jurisdiction
(define-read-only (is-approved-verifier
    (jurisdiction-code (string-ascii 10))
    (verifier principal))
  (let ((verifier-info (map-get? jurisdiction-verifiers
                        { jurisdiction-code: jurisdiction-code, verifier: verifier })))
    (if (is-some verifier-info)
      (get active (unwrap-panic verifier-info))
      false)))

;; Get jurisdiction rules
(define-read-only (get-jurisdiction-rules (jurisdiction-code (string-ascii 10)))
  (map-get? jurisdiction-rules { jurisdiction-code: jurisdiction-code }))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u3))
    (var-set admin new-admin)
    (ok true)))
