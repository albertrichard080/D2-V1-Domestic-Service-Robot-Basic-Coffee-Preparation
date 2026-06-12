;; Q2, problem B: slow delivery, the timing cannot work.
;;
;; Identical to problem A except delivery-time = 70. The hot window after
;; brewing is only 50 time units (90 -> 40 degC at 1 degC/unit), so the
;; coffee is guaranteed to go cold in transit: coffee-got-cold fires,
;; coffee-ready is retracted, and delivery-complete can never trigger.
;;
;; ENHSP exhausts the search space and prints "Problem unsolvable"
;; (see q2_problem_late.enhsp_output.txt). One changed duration flips the
;; instance from solvable to unsolvable, which is exactly the point.

(define (problem coffee-plus-late)
  (:domain coffee-prep-plus)

  (:objects
    cup1    - cup
    counter - location
  )

  (:init
    (gripper-empty)
    (cup-at cup1 counter)
    (empty cup1)
    (is-water-source counter)
    (is-powder-source counter)
    (is-machine counter)

    (= (temperature cup1) 20)
    (= (brew-clock cup1) 0)
    (= (deliver-clock cup1) 0)
    (= (drinkable-temp) 40)
    (= (brew-duration) 5)
    (= (delivery-time) 70)
  )

  (:goal (served cup1))
)
