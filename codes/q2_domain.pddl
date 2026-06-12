;; Assignment D2-V1 - Basic Coffee Preparation
;; Q2: PDDL+ domain (processes, events, numeric fluents)
;;
;; Same kitchen as Q1, but now the world keeps moving on its own:
;;   - cooling   (process): hot coffee loses 1 degC per time unit
;;   - coffee-got-cold (event): at the drinkable threshold the coffee
;;     becomes unusable, automatically
;;
;; Brewing and delivery take time. ENHSP does not support durative
;; actions (its README says to compile them out), and the planners that
;; do support them (OPTIC/POPF) cannot handle processes. So every timed
;; activity here is encoded with the usual PDDL+ workaround:
;;
;;   start-x   instantaneous action: sets a flag, resets a clock to 0
;;   x-process clock grows while the flag holds: (increase clock (* #t 1))
;;   x-done    event that fires when the clock reaches the duration
;;
;; which behaves exactly like a durative action.
;;
;; ENHSP parser quirks worth knowing: the predicate name "at" is reserved
;; (renamed to cup-at here), and the requirements list must stay minimal,
;; tokens like :time or :negative-preconditions are rejected.

(define (domain coffee-prep-plus)

  (:requirements :typing :fluents)

  (:types
    cup
    location
  )

  (:predicates
    (gripper-empty)
    (holding ?c - cup)
    (cup-at ?c - cup ?l - location)

    (is-water-source ?l - location)
    (is-powder-source ?l - location)
    (is-machine ?l - location)

    (empty ?c - cup)
    (has-water ?c - cup)
    (has-powder ?c - cup)
    (coffee-ready ?c - cup)   ; hot, drinkable coffee in the cup

    (brewing ?c - cup)        ; machine currently running for this cup
    (delivering ?c - cup)     ; hand-over to the user in progress

    (spoiled ?c - cup)        ; went cold, unusable (set by the event)
    (served ?c - cup)         ; goal: delivered while still hot
  )

  (:functions
    (temperature ?c - cup)
    (brew-clock ?c - cup)
    (deliver-clock ?c - cup)
    (drinkable-temp)          ; minimum acceptable temperature
    (brew-duration)
    (delivery-time)
  )

  ;; ---- manipulation, same as Q1 ----

  (:action grasp
    :parameters (?c - cup ?l - location)
    :precondition (and (gripper-empty) (cup-at ?c ?l))
    :effect (and (holding ?c) (not (gripper-empty)) (not (cup-at ?c ?l)))
  )

  ;; A started hand-over is a committed motion, so placing the cup back
  ;; down mid-delivery is forbidden. Without this guard ENHSP found a
  ;; ridiculous "solution" to the slow-delivery problem: park the cup in
  ;; the machine during the delivery and re-brew it when it goes cold.
  (:action place
    :parameters (?c - cup ?l - location)
    :precondition (and (holding ?c) (not (delivering ?c)))
    :effect (and (cup-at ?c ?l) (gripper-empty) (not (holding ?c)))
  )

  (:action fill-water
    :parameters (?c - cup ?l - location)
    :precondition (and (cup-at ?c ?l) (is-water-source ?l)
                       (gripper-empty) (empty ?c))
    :effect (and (has-water ?c) (not (empty ?c)))
  )

  (:action add-powder
    :parameters (?c - cup ?l - location)
    :precondition (and (cup-at ?c ?l) (is-powder-source ?l)
                       (gripper-empty) (has-water ?c))
    :effect (has-powder ?c)
  )

  ;; ---- brewing: start action + clock process + completion event ----

  ;; (not (spoiled ?c)): spoiling is irreversible, you cannot turn cold
  ;; spoiled coffee back into fresh coffee by running the machine again.
  (:action start-brew
    :parameters (?c - cup ?l - location)
    :precondition (and (cup-at ?c ?l) (is-machine ?l) (gripper-empty)
                       (has-water ?c) (has-powder ?c)
                       (not (brewing ?c)) (not (coffee-ready ?c))
                       (not (spoiled ?c)))
    :effect (and (brewing ?c)
                 (assign (brew-clock ?c) 0))
  )

  (:process brewing-process
    :parameters (?c - cup)
    :precondition (brewing ?c)
    :effect (increase (brew-clock ?c) (* #t 1))
  )

  ;; the machine stops by itself: hot coffee at 90 degC now exists
  (:event brew-done
    :parameters (?c - cup)
    :precondition (and (brewing ?c)
                       (>= (brew-clock ?c) (brew-duration)))
    :effect (and (not (brewing ?c))
                 (coffee-ready ?c)
                 (assign (temperature ?c) 90))
  )

  ;; ---- cooling: the process required by the assignment ----
  ;; Constant rate, a deliberate simplification of Newton's cooling law.
  ;; Runs autonomously: doing nothing still changes the world.

  (:process cooling
    :parameters (?c - cup)
    :precondition (coffee-ready ?c)
    :effect (decrease (temperature ?c) (* #t 1))
  )

  ;; ---- the event required by the assignment ----
  ;; Fires on its own the instant the threshold is crossed.

  (:event coffee-got-cold
    :parameters (?c - cup)
    :precondition (and (coffee-ready ?c)
                       (<= (temperature ?c) (drinkable-temp)))
    :effect (and (not (coffee-ready ?c))
                 (spoiled ?c))
  )

  ;; ---- delivery: start action + clock process + completion event ----

  (:action start-delivery
    :parameters (?c - cup)
    :precondition (and (holding ?c)
                       (coffee-ready ?c)
                       (not (delivering ?c)))
    :effect (and (delivering ?c)
                 (assign (deliver-clock ?c) 0))
  )

  (:process delivering-process
    :parameters (?c - cup)
    :precondition (delivering ?c)
    :effect (increase (deliver-clock ?c) (* #t 1))
  )

  ;; Succeeds only if the coffee is still hot when the hand-over ends.
  ;; If coffee-got-cold fired in transit, coffee-ready is gone and this
  ;; event can never trigger, so (served) becomes unreachable.
  (:event delivery-complete
    :parameters (?c - cup)
    :precondition (and (delivering ?c)
                       (coffee-ready ?c)
                       (>= (deliver-clock ?c) (delivery-time)))
    :effect (and (not (delivering ?c))
                 (served ?c))
  )
)
