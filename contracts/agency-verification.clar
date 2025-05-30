;; Agency Verification Contract
;; Validates consciousness-enhanced disaster response systems

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_AGENCY_EXISTS (err u101))
(define-constant ERR_AGENCY_NOT_FOUND (err u102))
(define-constant ERR_INVALID_CONSCIOUSNESS_LEVEL (err u103))

;; Agency data structure
(define-map agencies
  { agency-id: uint }
  {
    name: (string-ascii 50),
    consciousness-level: uint,
    verification-status: bool,
    capabilities: (list 10 (string-ascii 30)),
    verified-at: uint,
    verifier: principal
  }
)

(define-map agency-counter { id: uint } { count: uint })

;; Initialize counter
(map-set agency-counter { id: u0 } { count: u0 })

;; Get next agency ID
(define-private (get-next-agency-id)
  (let ((current-count (default-to u0 (get count (map-get? agency-counter { id: u0 })))))
    (begin
      (map-set agency-counter { id: u0 } { count: (+ current-count u1) })
      (+ current-count u1)
    )
  )
)

;; Register new agency
(define-public (register-agency
  (name (string-ascii 50))
  (consciousness-level uint)
  (capabilities (list 10 (string-ascii 30)))
)
  (let ((agency-id (get-next-agency-id)))
    (if (and (>= consciousness-level u1) (<= consciousness-level u10))
      (begin
        (map-set agencies
          { agency-id: agency-id }
          {
            name: name,
            consciousness-level: consciousness-level,
            verification-status: false,
            capabilities: capabilities,
            verified-at: u0,
            verifier: tx-sender
          }
        )
        (ok agency-id)
      )
      ERR_INVALID_CONSCIOUSNESS_LEVEL
    )
  )
)

;; Verify agency
(define-public (verify-agency (agency-id uint))
  (match (map-get? agencies { agency-id: agency-id })
    agency-data
    (begin
      (map-set agencies
        { agency-id: agency-id }
        (merge agency-data {
          verification-status: true,
          verified-at: block-height,
          verifier: tx-sender
        })
      )
      (ok true)
    )
    ERR_AGENCY_NOT_FOUND
  )
)

;; Get agency details
(define-read-only (get-agency (agency-id uint))
  (map-get? agencies { agency-id: agency-id })
)

;; Check if agency is verified
(define-read-only (is-agency-verified (agency-id uint))
  (match (map-get? agencies { agency-id: agency-id })
    agency-data (get verification-status agency-data)
    false
  )
)

;; Get agencies by consciousness level
(define-read-only (get-consciousness-level (agency-id uint))
  (match (map-get? agencies { agency-id: agency-id })
    agency-data (some (get consciousness-level agency-data))
    none
  )
)
