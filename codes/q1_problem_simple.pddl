;; Q1, simple problem: everything within reach.
;; One counter acts as water source, powder source and machine, and the
;; cup already sits on it, so no transport is needed at all.
;; Expected plan (3 steps): fill-water, add-powder, brew-coffee.

(define (problem coffee-simple)
  (:domain coffee-prep)

  (:objects
    cup1    - cup
    counter - location
  )

  (:init
    (gripper-empty)
    (at cup1 counter)
    (empty cup1)
    (is-water-source counter)
    (is-powder-source counter)
    (is-machine counter)
  )

  (:goal (coffee-ready cup1))
)
