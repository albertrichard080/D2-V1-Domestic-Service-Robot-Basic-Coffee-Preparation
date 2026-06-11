;; Q1, complex problem: each station is a different location and the cup
;; starts on a shelf. Every operation needs the cup placed at the right
;; station with the gripper free, so the robot has to grasp and place the
;; cup between stations. Expected plan length: 9.

(define (problem coffee-complex)
  (:domain coffee-prep)

  (:objects
    cup1             - cup
    shelf            - location
    water-source     - location
    powder-dispenser - location
    coffee-machine   - location
  )

  (:init
    (gripper-empty)
    (at cup1 shelf)
    (empty cup1)
    (is-water-source  water-source)
    (is-powder-source powder-dispenser)
    (is-machine       coffee-machine)
  )

  (:goal (coffee-ready cup1))
)
