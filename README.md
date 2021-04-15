# Attacking Swarm Robotics Operations via Fuzz Testing

This is the project page for Attacking Swarm Robotics Operations via Fuzz Testing. Contents that we was not able to cover in the paper due to the paper limit are placed here.

## The converged number of the unique pattern while fuzz testing

- We decide the reasonable number of fuzz testing after we observe the number of newly found unique pattern while fuzz testing.

  ![](https://github.com/psaresearch/swarm_attack/blob/main/main_1_converged.png)

  From the above data, 8 hours can be considered enough time for fuzz testing using the observation.

  More details are in **[Converged_number_unique_by_algorithms](https://github.com/psaresearch/swarm_attack/tree/main/Converged_number_unique_by_algorithms)**.

## Supplementary materials for attack scenarios

- In this section, we explain how each attack scenario works, which is not covered in the paper due to the space limit.

  ![](https://github.com/psaresearch/swarm_attack/blob/main/main_2_attack_sample_resized.gif)

  For example, attackers (cyan and red drones) block the swarm by attacking the follower 2 and 3, respectively in A1-1 (Close).

  The other attack scenarios are in **[Details_attack_scenarios](https://github.com/psaresearch/swarm_attack/tree/main/Details_attack_scenarios)**.

## Supplementary materials for the result of optimization (Mission completion time)

- Variations for the optimization affect on the mission complete time as well as the number of the failed missions.

  ![](https://github.com/psaresearch/swarm_attack/blob/main/main_3_uncovered_graph.png)

  In figure 17, we explain attack mission optimization results using the number of runs with successful attacks.

  Figure (a) in the above figure is a part of figure 17: the attack drones' size.

  We explain how the runs with unsuccessful attacks works in this section. For example, when 0.5 x victim's size is applied to attacker drones in A1-3 (red dotted box in (a)), explains about whether 48, 46, and 36 runs are the same as original ones or delayed because of the attack is needed.

  This data will be explained in **[Supplementary_optimization](https://github.com/psaresearch/swarm_attack/tree/main/Supplementary_optimization)**.

## Code used in this paper

- Following folders contain this. **[Source_code_tools_used](https://github.com/psaresearch/swarm_attack/tree/main/Source_code_attack)**.
