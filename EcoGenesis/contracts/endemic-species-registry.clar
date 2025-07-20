;; Biodiversity Tracking Smart Contract
;; A decentralized system for tracking species observations and biodiversity data

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-EXISTS (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INVALID-COORDINATES (err u103))
(define-constant ERR-INVALID-POPULATION (err u104))
(define-constant ERR-INVALID-INPUT (err u105))
(define-constant ERR-EMPTY-STRING (err u106))

;; Contract owner
(define-constant CONTRACT-OWNER tx-sender)

;; Data structures
(define-map researchers
  { address: principal }
  {
    name: (string-ascii 64),
    institution: (string-ascii 128),
    verified: bool,
    observations-count: uint
  }
)

(define-map species
  { species-id: uint }
  {
    scientific-name: (string-ascii 128),
    common-name: (string-ascii 64),
    kingdom: (string-ascii 32),
    conservation-status: (string-ascii 32),
    created-by: principal,
    created-at: uint
  }
)

(define-map observations
  { observation-id: uint }
  {
    species-id: uint,
    observer: principal,
    latitude: int,
    longitude: int,
    population-count: uint,
    observation-date: uint,
    habitat-description: (string-ascii 256),
    verified: bool,
    verification-date: (optional uint)
  }
)

(define-map locations
  { lat: int, lon: int }
  {
    region-name: (string-ascii 64),
    country: (string-ascii 32),
    ecosystem-type: (string-ascii 64),
    total-observations: uint
  }
)

;; Input validation helpers
(define-private (is-valid-string (input (string-ascii 256)))
  (and (> (len input) u0) (<= (len input) u256))
)

(define-private (is-valid-conservation-status (status (string-ascii 32)))
  (or (is-eq status "Extinct")
      (is-eq status "Extinct in Wild")
      (is-eq status "Critically Endangered")
      (is-eq status "Endangered")
      (is-eq status "Vulnerable")
      (is-eq status "Near Threatened")
      (is-eq status "Least Concern")
      (is-eq status "Data Deficient")
      (is-eq status "Not Evaluated"))
)

(define-private (is-valid-kingdom (kingdom (string-ascii 32)))
  (or (is-eq kingdom "Animalia")
      (is-eq kingdom "Plantae")
      (is-eq kingdom "Fungi")
      (is-eq kingdom "Protista")
      (is-eq kingdom "Bacteria")
      (is-eq kingdom "Archaea"))
)
(define-data-var next-observation-id uint u1)
(define-data-var total-species uint u0)
(define-data-var total-observations uint u0)

;; Data variables
(define-data-var next-species-id uint u1)
(define-public (register-researcher (name (string-ascii 64)) (institution (string-ascii 128)))
  (let ((researcher-exists (map-get? researchers { address: tx-sender })))
    (if (is-some researcher-exists)
      ERR-ALREADY-EXISTS
      (ok (map-set researchers 
        { address: tx-sender }
        {
          name: name,
          institution: institution,
          verified: false,
          observations-count: u0
        }
      ))
    )
  )
)

;; Verify a researcher (only contract owner)
(define-public (verify-researcher (researcher principal))
  (if (and 
    (is-eq tx-sender CONTRACT-OWNER)
    (not (is-eq researcher tx-sender)) ;; Can't verify self
  )
    (match (map-get? researchers { address: researcher })
      researcher-data 
      (ok (map-set researchers 
        { address: researcher }
        (merge researcher-data { verified: true })
      ))
      ERR-NOT-FOUND
    )
    ERR-NOT-AUTHORIZED
  )
)

;; Add a new species
(define-public (add-species 
  (scientific-name (string-ascii 128))
  (common-name (string-ascii 64))
  (kingdom (string-ascii 32))
  (conservation-status (string-ascii 32))
)
  (let ((species-id (var-get next-species-id)))
    (if (and
      (> (len scientific-name) u0) (<= (len scientific-name) u128)
      (> (len common-name) u0) (<= (len common-name) u64)
      (is-valid-kingdom kingdom)
      (is-valid-conservation-status conservation-status)
    )
      (match (map-get? researchers { address: tx-sender })
        researcher-data
        (if (get verified researcher-data)
          (begin
            (map-set species
              { species-id: species-id }
              {
                scientific-name: scientific-name,
                common-name: common-name,
                kingdom: kingdom,
                conservation-status: conservation-status,
                created-by: tx-sender,
                created-at: block-height
              }
            )
            (var-set next-species-id (+ species-id u1))
            (var-set total-species (+ (var-get total-species) u1))
            (ok species-id)
          )
          ERR-NOT-AUTHORIZED
        )
        ERR-NOT-FOUND
      )
      ERR-INVALID-INPUT
    )
  )
)

;; Record a biodiversity observation
(define-public (record-observation
  (species-id uint)
  (latitude int)
  (longitude int)
  (population-count uint)
  (habitat-description (string-ascii 256))
)
  (let ((observation-id (var-get next-observation-id)))
    (if (and 
      (> species-id u0) ;; Valid species ID
      (>= latitude -90000000) (<= latitude 90000000)  ;; Valid latitude range
      (>= longitude -180000000) (<= longitude 180000000) ;; Valid longitude range
      (> population-count u0)
      (> (len habitat-description) u0) (<= (len habitat-description) u256)
    )
      (match (map-get? researchers { address: tx-sender })
        researcher-data
        (match (map-get? species { species-id: species-id })
          species-data
          (begin
            ;; Record the observation
            (map-set observations
              { observation-id: observation-id }
              {
                species-id: species-id,
                observer: tx-sender,
                latitude: latitude,
                longitude: longitude,
                population-count: population-count,
                observation-date: block-height,
                habitat-description: habitat-description,
                verified: false,
                verification-date: none
              }
            )
            ;; Update location data
            (map-set locations
              { lat: latitude, lon: longitude }
              (match (map-get? locations { lat: latitude, lon: longitude })
                existing-location
                (merge existing-location { total-observations: (+ (get total-observations existing-location) u1) })
                { region-name: "Unknown", country: "Unknown", ecosystem-type: "Unknown", total-observations: u1 }
              )
            )
            ;; Update researcher observation count
            (map-set researchers 
              { address: tx-sender }
              (merge researcher-data { observations-count: (+ (get observations-count researcher-data) u1) })
            )
            ;; Update global counters
            (var-set next-observation-id (+ observation-id u1))
            (var-set total-observations (+ (var-get total-observations) u1))
            (ok observation-id)
          )
          ERR-NOT-FOUND
        )
        ERR-NOT-FOUND
      )
      ERR-INVALID-COORDINATES
    )
  )
)

;; Verify an observation (for verified researchers)
(define-public (verify-observation (observation-id uint))
  (if (> observation-id u0) ;; Valid observation ID
    (match (map-get? researchers { address: tx-sender })
      researcher-data
      (if (get verified researcher-data)
        (match (map-get? observations { observation-id: observation-id })
          observation-data
          (if (not (is-eq (get observer observation-data) tx-sender)) ;; Can't verify own observation
            (ok (map-set observations
              { observation-id: observation-id }
              (merge observation-data { 
                verified: true,
                verification-date: (some block-height)
              })
            ))
            ERR-NOT-AUTHORIZED
          )
          ERR-NOT-FOUND
        )
        ERR-NOT-AUTHORIZED
      )
      ERR-NOT-FOUND
    )
    ERR-INVALID-INPUT
  )
)

;; Read-only functions
(define-read-only (get-researcher (address principal))
  (map-get? researchers { address: address })
)

(define-read-only (get-species (species-id uint))
  (map-get? species { species-id: species-id })
)

(define-read-only (get-observation (observation-id uint))
  (map-get? observations { observation-id: observation-id })
)

(define-read-only (get-location-data (latitude int) (longitude int))
  (map-get? locations { lat: latitude, lon: longitude })
)

(define-read-only (get-contract-stats)
  {
    total-species: (var-get total-species),
    total-observations: (var-get total-observations),
    next-species-id: (var-get next-species-id),
    next-observation-id: (var-get next-observation-id)
  }
)