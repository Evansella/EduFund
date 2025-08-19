;; Academic Scholarship Distribution Contract
;; A blockchain-powered scholarship distribution system ensuring transparency, fairness, and accountability in awarding academic funds

;; Define constants
(define-constant UNIVERSITY-ADMIN tx-sender)
(define-constant ERROR-NOT-UNIVERSITY-ADMIN (err u100))
(define-constant ERROR-SCHOLARSHIP-ALREADY-AWARDED (err u101))
(define-constant ERROR-STUDENT-NOT-QUALIFIED (err u102))
(define-constant ERROR-INSUFFICIENT-SCHOLARSHIP-FUNDS (err u103))
(define-constant ERROR-PROGRAM-NOT-ACTIVE (err u104))
(define-constant ERROR-INVALID-SCHOLARSHIP-AMOUNT (err u105))
(define-constant ERROR-WITHDRAWAL-PERIOD-NOT-ENDED (err u106))
(define-constant ERROR-INVALID-STUDENT (err u107))
(define-constant ERROR-INVALID-SEMESTER-PERIOD (err u108))

;; Define data variables
(define-data-var is-program-active bool true)
(define-data-var total-scholarships-awarded uint u0)
(define-data-var scholarship-amount-per-student uint u100)
(define-data-var program-launch-block uint stacks-block-height)
(define-data-var withdrawal-semester-length uint u10000) ;; Number of blocks after which unused scholarships can be withdrawn

;; Define data maps
(define-map qualified-scholarship-students principal bool)
(define-map awarded-scholarship-amounts principal uint)

;; Define fungible token
(define-fungible-token academic-scholarship-token)

;; Define events
(define-data-var next-record-id uint u0)
(define-map academic-records uint {record-type: (string-ascii 20), details: (string-ascii 256)})

;; Record logging function
(define-private (log-academic-record (record-type (string-ascii 20)) (details (string-ascii 256)))
  (let ((record-id (var-get next-record-id)))
    (map-set academic-records record-id {record-type: record-type, details: details})
    (var-set next-record-id (+ record-id u1))
    record-id))

;; Admin functions

(define-public (add-qualified-student (student-address principal))
  (begin
    (asserts! (is-eq tx-sender UNIVERSITY-ADMIN) ERROR-NOT-UNIVERSITY-ADMIN)
    (asserts! (is-none (map-get? qualified-scholarship-students student-address)) ERROR-INVALID-STUDENT)
    (log-academic-record "student-qualified" "new qualified student")
    (ok (map-set qualified-scholarship-students student-address true))))

(define-public (remove-qualified-student (student-address principal))
  (begin
    (asserts! (is-eq tx-sender UNIVERSITY-ADMIN) ERROR-NOT-UNIVERSITY-ADMIN)
    (asserts! (is-some (map-get? qualified-scholarship-students student-address)) ERROR-STUDENT-NOT-QUALIFIED)
    (log-academic-record "student-disqualified" "removed qualified student")
    (ok (map-delete qualified-scholarship-students student-address))))

(define-public (bulk-add-qualified-students (student-addresses (list 200 principal)))
  (begin
    (asserts! (is-eq tx-sender UNIVERSITY-ADMIN) ERROR-NOT-UNIVERSITY-ADMIN)
    (log-academic-record "bulk-qualified" "students qualified")
    (ok (map add-qualified-student student-addresses))))

(define-public (update-scholarship-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender UNIVERSITY-ADMIN) ERROR-NOT-UNIVERSITY-ADMIN)
    (asserts! (> new-amount u0) ERROR-INVALID-SCHOLARSHIP-AMOUNT)
    (var-set scholarship-amount-per-student new-amount)
    (log-academic-record "amount-updated" "scholarship amount changed")
    (ok new-amount)))

(define-public (update-withdrawal-period (new-period uint))
  (begin
    (asserts! (is-eq tx-sender UNIVERSITY-ADMIN) ERROR-NOT-UNIVERSITY-ADMIN)
    (asserts! (> new-period u0) ERROR-INVALID-SEMESTER-PERIOD)
    (var-set withdrawal-semester-length new-period)
    (log-academic-record "period-updated" "withdrawal period changed")
    (ok new-period)))

;; Scholarship distribution function

(define-public (claim-scholarship-tokens)
  (let (
    (student-address tx-sender)
    (award-amount (var-get scholarship-amount-per-student))
  )
    (asserts! (var-get is-program-active) ERROR-PROGRAM-NOT-ACTIVE)
    (asserts! (is-some (map-get? qualified-scholarship-students student-address)) ERROR-STUDENT-NOT-QUALIFIED)
    (asserts! (is-none (map-get? awarded-scholarship-amounts student-address)) ERROR-SCHOLARSHIP-ALREADY-AWARDED)
    (asserts! (<= award-amount (ft-get-balance academic-scholarship-token UNIVERSITY-ADMIN)) ERROR-INSUFFICIENT-SCHOLARSHIP-FUNDS)
    (try! (ft-transfer? academic-scholarship-token award-amount UNIVERSITY-ADMIN student-address))
    (map-set awarded-scholarship-amounts student-address award-amount)
    (var-set total-scholarships-awarded (+ (var-get total-scholarships-awarded) award-amount))
    (log-academic-record "scholarship-claimed" "scholarship awarded")
    (ok award-amount)))

;; Token withdrawal function

(define-public (withdraw-unclaimed-scholarships)
  (let (
    (current-block stacks-block-height)
    (withdrawal-allowed-after (+ (var-get program-launch-block) (var-get withdrawal-semester-length)))
  )
    (asserts! (is-eq tx-sender UNIVERSITY-ADMIN) ERROR-NOT-UNIVERSITY-ADMIN)
    (asserts! (>= current-block withdrawal-allowed-after) ERROR-WITHDRAWAL-PERIOD-NOT-ENDED)
    (let (
      (total-minted (ft-get-supply academic-scholarship-token))
      (total-awarded (var-get total-scholarships-awarded))
      (unclaimed-amount (- total-minted total-awarded))
    )
      (try! (ft-burn? academic-scholarship-token unclaimed-amount UNIVERSITY-ADMIN))
      (log-academic-record "funds-withdrawn" "unclaimed scholarships burned")
      (ok unclaimed-amount))))

;; Read-only functions

(define-read-only (get-program-active-status)
  (var-get is-program-active))

(define-read-only (is-student-qualified (student-address principal))
  (default-to false (map-get? qualified-scholarship-students student-address)))

(define-read-only (has-student-claimed-scholarship (student-address principal))
  (is-some (map-get? awarded-scholarship-amounts student-address)))

(define-read-only (get-student-awarded-amount (student-address principal))
  (default-to u0 (map-get? awarded-scholarship-amounts student-address)))

(define-read-only (get-total-scholarships-awarded)
  (var-get total-scholarships-awarded))

(define-read-only (get-scholarship-amount-per-student)
  (var-get scholarship-amount-per-student))

(define-read-only (get-withdrawal-period)
  (var-get withdrawal-semester-length))

(define-read-only (get-program-launch-block)
  (var-get program-launch-block))

(define-read-only (get-academic-record (record-id uint))
  (map-get? academic-records record-id))

;; Contract initialization

(begin
  (ft-mint? academic-scholarship-token u1000000000 UNIVERSITY-ADMIN))