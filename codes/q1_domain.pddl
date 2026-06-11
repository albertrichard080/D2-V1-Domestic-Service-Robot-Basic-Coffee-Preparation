;; Assignment D2-V1 - Basic Coffee Preparation
;; Q1: classical PDDL domain (STRIPS + typing)
;;
;; A fixed manipulator prepares coffee. The only object the robot actually
;; grasps is the cup; the water tap, powder dispenser and coffee machine
;; are fixed stations, so I model them as location capabilities instead of
;; separate objects. The contents of the cup go through a chain of states:
;;
;;    empty -> has-water -> has-powder -> coffee-ready
;;
;; The recipe order is never written explicitly anywhere. It comes out of
;; the preconditions: you cannot add powder before water, and the machine
;; refuses to brew unless both are in the cup.

(define (domain coffee-prep)

  (:requirements :strips :typing)

  (:types
    cup
    location
  )

  (:predicates
    ;; gripper state (the robot can hold one thing at a time)
    (gripper-empty)
    (holding ?c - cup)
    (at ?c - cup ?l - location)

    ;; what each fixed station can do
    (is-water-source ?l - location)
    (is-powder-source ?l - location)
    (is-machine ?l - location)

    ;; cup contents
    (empty ?c - cup)
    (has-water ?c - cup)
    (has-powder ?c - cup)
    (coffee-ready ?c - cup)
  )

  ;; pick the cup up; the gripper must be free
  (:action grasp
    :parameters (?c - cup ?l - location)
    :precondition (and (gripper-empty) (at ?c ?l))
    :effect (and (holding ?c)
                 (not (gripper-empty))
                 (not (at ?c ?l)))
  )

  ;; put the cup down at some location
  (:action place
    :parameters (?c - cup ?l - location)
    :precondition (holding ?c)
    :effect (and (at ?c ?l)
                 (gripper-empty)
                 (not (holding ?c)))
  )

  ;; Filling/brewing requires the cup PLACED at the right station and the
  ;; gripper free (the arm needs its hand to operate the tap or machine).
  ;; This is what makes grasp/place necessary steps and not decoration.

  (:action fill-water
    :parameters (?c - cup ?l - location)
    :precondition (and (at ?c ?l)
                       (is-water-source ?l)
                       (gripper-empty)
                       (empty ?c))         ; only an empty cup can be filled
    :effect (and (has-water ?c)
                 (not (empty ?c)))
  )

  (:action add-powder
    :parameters (?c - cup ?l - location)
    :precondition (and (at ?c ?l)
                       (is-powder-source ?l)
                       (gripper-empty)
                       (has-water ?c))     ; powder only after water
    :effect (has-powder ?c)
  )

  (:action brew-coffee
    :parameters (?c - cup ?l - location)
    :precondition (and (at ?c ?l)
                       (is-machine ?l)
                       (gripper-empty)
                       (has-water ?c)      ; machine needs both ingredients
                       (has-powder ?c))
    :effect (coffee-ready ?c)
  )
)
