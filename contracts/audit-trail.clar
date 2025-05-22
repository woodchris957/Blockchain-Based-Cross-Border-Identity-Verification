;; Audit Trail Contract
;; Records history of identity verifications

(define-map verification-events
  { event-id: uint }
  {
    verifier: principal,
    subject: principal,
    action-type: (string-ascii 20),
    jurisdiction: (string-ascii 10),
    timestamp: uint,
    request-id: (optional uint)
  })

(define-data-var event-counter uint u0)

;; Record a verification event
(define-public (record-event
    (subject principal)
    (action-type (string-ascii 20))
    (jurisdiction (string-ascii 10))
    (request-id (optional uint)))
  (let ((event-id (var-get event-counter)))
    (begin
      (map-set verification-events
        { event-id: event-id }
        {
          verifier: tx-sender,
          subject: subject,
          action-type: action-type,
          jurisdiction: jurisdiction,
          timestamp: block-height,
          request-id: request-id
        })
      (var-set event-counter (+ event-id u1))
      (ok event-id))))

;; Get verification event details
(define-read-only (get-event (event-id uint))
  (map-get? verification-events { event-id: event-id }))

;; Get total number of events
(define-read-only (get-event-count)
  (var-get event-counter))
