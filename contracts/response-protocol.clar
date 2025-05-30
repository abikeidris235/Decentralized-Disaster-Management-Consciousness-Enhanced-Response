;; Response Protocol Contract
;; Manages consciousness-informed disaster response protocols

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u200))
(define-constant ERR_PROTOCOL_EXISTS (err u201))
(define-constant ERR_PROTOCOL_NOT_FOUND (err u202))
(define-constant ERR_INVALID_SEVERITY (err u203))

;; Protocol data structure
(define-map response-protocols
  { protocol-id: uint }
  {
    name: (string-ascii 50),
    disaster-type: (string-ascii 30),
    severity-level: uint,
    consciousness-requirements: uint,
    response-steps: (list 20 (string-ascii 100)),
    estimated-duration: uint,
    required-resources: (list 10 (string-ascii 50)),
    created-by: principal,
    created-at: uint,
    active: bool
  }
)

(define-map protocol-counter { id: uint } { count: uint })

;; Initialize counter
(map-set protocol-counter { id: u0 } { count: u0 })

;; Get next protocol ID
(define-private (get-next-protocol-id)
  (let ((current-count (default-to u0 (get count (map-get? protocol-counter { id: u0 })))))
    (begin
      (map-set protocol-counter { id: u0 } { count: (+ current-count u1) })
      (+ current-count u1)
    )
  )
)

;; Create response protocol
(define-public (create-protocol
  (name (string-ascii 50))
  (disaster-type (string-ascii 30))
  (severity-level uint)
  (consciousness-requirements uint)
  (response-steps (list 20 (string-ascii 100)))
  (estimated-duration uint)
  (required-resources (list 10 (string-ascii 50)))
)
  (let ((protocol-id (get-next-protocol-id)))
    (if (and (>= severity-level u1) (<= severity-level u5))
      (begin
        (map-set response-protocols
          { protocol-id: protocol-id }
          {
            name: name,
            disaster-type: disaster-type,
            severity-level: severity-level,
            consciousness-requirements: consciousness-requirements,
            response-steps: response-steps,
            estimated-duration: estimated-duration,
            required-resources: required-resources,
            created-by: tx-sender,
            created-at: block-height,
            active: true
          }
        )
        (ok protocol-id)
      )
      ERR_INVALID_SEVERITY
    )
  )
)

;; Get protocol details
(define-read-only (get-protocol (protocol-id uint))
  (map-get? response-protocols { protocol-id: protocol-id })
)

;; Activate/deactivate protocol
(define-public (toggle-protocol-status (protocol-id uint))
  (match (map-get? response-protocols { protocol-id: protocol-id })
    protocol-data
    (if (is-eq (get created-by protocol-data) tx-sender)
      (begin
        (map-set response-protocols
          { protocol-id: protocol-id }
          (merge protocol-data {
            active: (not (get active protocol-data))
          })
        )
        (ok true)
      )
      ERR_UNAUTHORIZED
    )
    ERR_PROTOCOL_NOT_FOUND
  )
)

;; Get protocols by disaster type
(define-read-only (get-protocol-by-type (disaster-type (string-ascii 30)))
  ;; This would require iteration in a real implementation
  ;; For simplicity, returning a placeholder
  none
)

;; Check protocol consciousness requirements
(define-read-only (get-consciousness-requirements (protocol-id uint))
  (match (map-get? response-protocols { protocol-id: protocol-id })
    protocol-data (some (get consciousness-requirements protocol-data))
    none
  )
)
