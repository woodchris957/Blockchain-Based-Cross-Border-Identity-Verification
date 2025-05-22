;; Identity Provider Verification Contract
;; This contract validates credential issuers in the system

(define-data-var admin principal tx-sender)

;; Map of verified identity providers
(define-map verified-providers principal bool)

;; Events
(define-public (register-provider (provider-address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can register providers
    (map-set verified-providers provider-address true)
    (ok true)))

(define-public (revoke-provider (provider-address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u2)) ;; Only admin can revoke providers
    (map-delete verified-providers provider-address)
    (ok true)))

(define-read-only (is-verified-provider (provider-address principal))
  (default-to false (map-get? verified-providers provider-address)))

(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u3)) ;; Only current admin can transfer
    (var-set admin new-admin)
    (ok true)))

(define-read-only (get-admin)
  (var-get admin))
