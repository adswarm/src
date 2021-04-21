# ADVERSARIAL SWARM: Discovering and Exploiting Logic Flaws of Swarm Algorithms

This is the project page for ADVERSARIAL SWARM: Discovering and Exploiting Logic Flaws of Swarm Algorithms. Contents that we was not able to cover in the paper due to the paper limit are placed here.

## Criteria for selecting the swarm algorithms in detail

- To select representative mature swarm algorithms for our evaluation, we search open-sourced research projects related to swarm robotics for the last 10 years (from 2010 to 2021). We listed 27 research papers and 46 algorithms with github repositories from the initial search. Among them, we were able to run 17 swarm algorithms. From the 17 runnable algorithms, we prune out algorithms that do not exhibit collective (or cooperative) behaviors.
- We present the criteria for selecting the swarm algorithms in detail this page.

More details are in **[Criteria_for_selecting_algorithms](https://github.com/adswarm/src/tree/main/Criteria_for_selecting_algorithms)**.

## Supplementary materials for attack scenarios

- In this section, we explain how each attack scenario works, which is not covered in the paper due to the space limit.

  ![](https://github.com/adswarm/src/blob/main/main_2_attack_sample_resized.gif)

  For example, attackers (cyan and red drones) block the swarm by attacking the follower 2 and 3, respectively.

  The other attack scenarios are in **[Details_attack_scenarios](https://github.com/adswarm/src/tree/main/Details_attack_scenarios)**.

## Supplementary materials for the result of additional experiment (Mission completion time)

- Variations (the number, the size, and the speed of attack drone) affect on the mission complete time as well as the number of the failed missions.

  ![](https://github.com/adswarm/src/blob/main/main_3_uncovered_graph.png)

  Figure (a) in the above figure shows the result according to the attack drones' size.

  We explain how the runs with unsuccessful attacks works in this section. For example, when 0.5 x victim's size is applied to attacker drones in A1-3 (red dotted box in (a)), explains about whether 48, 46, and 36 runs are the same as original ones or delayed because of the attack is needed.

  This data will be explained in **[Supplementary_optimization](https://github.com/adswarm/src/tree/main/Supplementary_optimization)**.

## Code used in this paper

- This page has code (in V. Evaluation A. Experiment setup and B. Effectiveness in finding logic flaws) used in this paper including tools, data, and fixes (with original algorithms).
- Following folder contains this. **[Source_code_tools_used](https://github.com/adswarm/src/tree/main/Source_code_tools_used)**.
