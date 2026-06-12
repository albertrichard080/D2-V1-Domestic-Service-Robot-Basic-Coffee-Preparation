;; Q2, problem A: fast delivery, the timing works out.
;;
;; Coffee is brewed at 90 degC, cools 1 degC per time unit, and the user
;; accepts >= 40 degC, so there is a 50-unit window after brewing.
;; Delivery takes only 10 units here, well inside the window.
;;
;; ENHSP output (see q2_problem_intime.enhsp_output.txt):
;;   0.0: fill-water, add-powder, start-brew
;;   5.0: brew-done fires (temp := 90), grasp, start-delivery
;;  15.0: delivery-complete fires at ~80 degC -> served

(define (problem coffee-plus-intime)
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
    (= (delivery-time) 10)
  )

  (:goal (served cup1))
)
