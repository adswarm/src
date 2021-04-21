# ADVERSARIAL SWARM: Discovering and Exploiting Logic Flaws of Swarm Algorithms

This is the project page for ADVERSARIAL SWARM: Discovering and Exploiting Logic Flaws of Swarm Algorithms. Contents that we was not able to cover in the paper due to the paper limit are placed here.

## Criteria for selecting the swarm algorithms in detail

- To select representative mature swarm algorithms for our evaluation, we search open-sourced research projects related to swarm robotics for the last 10 years (from 2010 to 2021). We listed 27 research papers and 46 algorithms with github repositories from the initial search. Among them, we were able to run 17 swarm algorithms. From the 17 runnable algorithms, we prune out algorithms that do not exhibit collective (or cooperative) behaviors.
- We present the criteria for selecting the swarm algorithms in detail this page.

More details are in **[Criteria_for_selecting_algorithms](https://github.com/adswarm/src/tree/main/Criteria_for_selecting_algorithms)**.

## The converged number of the unique pattern while fuzz testing

- We decide the reasonable number of fuzz testing after we observe the number of newly found unique pattern while fuzz testing.

  ![](https://github.com/adswarm/src/blob/main/main_1_converged.png)

  From the above data, 8 hours can be considered enough time for fuzz testing using the observation.

  More details are in **[Converged_number_unique_by_algorithms](https://github.com/adswarm/src/tree/main/Converged_number_unique_by_algorithms)**.

## Supplementary materials for attack scenarios

- In this section, we explain how each attack scenario works, which is not covered in the paper due to the space limit.

  ![](https://github.com/adswarm/src/blob/main/main_2_attack_sample_resized.gif)

  For example, attackers (cyan and red drones) block the swarm by attacking the follower 2 and 3, respectively.

  The other attack scenarios are in **[Details_attack_scenarios](https://github.com/adswarm/src/tree/main/Details_attack_scenarios)**.

## Code used in this paper

- Following folders contain this. **[Source_code_tools_used](https://github.com/adswarm/src/tree/main/Source_code_tools_used)**.
