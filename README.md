# D2-V1 - Domestic Service Robot: Basic Coffee Preparation

Files to grade: the PDDL (Q1) model is `codes/q1_domain.pddl` with the two problems `codes/q1_problem_simple.pddl` and `codes/q1_problem_complex.pddl`. The PDDL+ (Q2) model is `codes/q2_domain.pddl` with `codes/q2_problem_intime.pddl` and `codes/q2_problem_late.pddl`. There is only one version of each file.

This is my project for Assignment D2-V1 of Artificial Intelligence for Robotics II.

A fixed robot arm in a kitchen has to make a cup of coffee: take an empty cup,
fill it with water, add coffee powder, and brew it with the machine. It can
only handle one object at a time. Q1 models this in classical PDDL. Q2 extends
it to PDDL+ so the coffee cools down on its own over time and becomes unusable
if it gets cold, which means the plan is only valid if the timing works out.

## Folders

- `codes/` - the PDDL and PDDL+ files, plus the planner output in `codes/outputs/`
- `Report/` - the report (PDF)
- `slide/` - the presentation (PPTX and a PDF copy)

## Running the models

Q1 (classical PDDL) runs with pyperplan, or in the online editor at
editor.planning.domains:

```
cd codes
pyperplan q1_domain.pddl q1_problem_simple.pddl     # plan length 3
pyperplan q1_domain.pddl q1_problem_complex.pddl    # plan length 9
```

The "Plan correct" line at the end comes from VAL, a separate plan validator
that pyperplan runs if it is installed.

Q2 (PDDL+) needs a planner that supports processes and events. I used ENHSP
(version enhsp20-0.9.0, built with Java 17):

```
cd codes
java -jar enhsp.jar -o q2_domain.pddl -f q2_problem_intime.pddl   # Problem Solved
java -jar enhsp.jar -o q2_domain.pddl -f q2_problem_late.pddl     # Problem unsolvable
```

A few things I ran into with ENHSP: it does not support durative actions, so
brewing and delivery are written as a start action plus a clock process plus a
completion event. The name "at" is reserved by its parser, so the location
predicate is called "cup-at" in the Q2 domain. The requirements list has to
stay short (:typing :fluents).

## Results

| Instance | Planner | Result |
|----------|---------|--------|
| Q1 simple | pyperplan | plan, 3 steps |
| Q1 complex | pyperplan | plan, 9 steps |
| Q2, delivery-time = 10 | ENHSP | solved, served at about 80 C |
| Q2, delivery-time = 70 | ENHSP | unsolvable |

The two Q2 problems differ in one number only. The coffee brews at 90 C, cools
1 C per time unit, and is too cold below 40 C, so it stays drinkable for about
50 time units. A delivery that takes 70 units always lets the coffee go cold on
the way, the cold event removes coffee-ready, and the goal can no longer be
reached. The planner outputs for all four runs are in `codes/outputs/`.

One thing worth mentioning: in my first Q2 version ENHSP "solved" the slow case
by putting the cup back in the machine in the middle of the delivery and
re-brewing the cold coffee. I fixed that by forbidding place while delivering
and making spoiling irreversible. It is a good reminder that the model has to
state every constraint explicitly. This is explained in the report.
