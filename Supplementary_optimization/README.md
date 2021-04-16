# Supplementary materials for the result of optimization (Mission completion time)

This page contains the result of attack mission optimization in terms of **mission completion time**, which is not covered in the paper due to the page limit.
As we mentioned in the paper, even though the attack was fully successfull so victim swarm was able to complete the mission, it can be meaningful when the attack can delay the mission.

![](https://github.com/adswarm/src/blob/main/Supplementary_optimization/graph/opti_comp_time.PNG)

## General explanation

- Except for y-axis (simulation tick as mission completion time), the structure of whole graphs including legend is the same as figure 17.
- Higher value of each bar means that attack is successful than the others as it takes longer time.
- Note that '-' means there is no delayed mission to be shown because all attacks are fully successful to stop the victim swarm reaching the goal.
- Original missions' completion times (Avg.) is as follow.
  | | A1 | A2 | A3 | A4 |
  | :------------: | :-----: | :-----: | :-----: | :-----: |
  | Compl. time (tick) | 199.92 | 90.11 | 1756.13 | 715.41 |

## A1

- The attack failure cases of A1-3 are not affected by any attack configurations.
  Some cases can be considered they delays a little bit as they are bigger than original missions' completion times, but it is not that significant.

## A2

- Most of attacks shows they can delay the victim's mission.
- Interesting thing is that A2 is not affected by attack drones' size. This is because default (basic) size of drone is already small to affect to each other.

## A3

- These results are the same as expected.
- All are effective and show they increase as the configuration changes.

## A4

- The general trends of results are similar to the figure 17.
