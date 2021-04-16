# ADVERSARIAL SWARM: Discovering and Exploiting Logic Flaws of Swarm Algorithms

This is the project page for ADVERSARIAL SWARM: Discovering and Exploiting Logic Flaws of Swarm Algorithms. Contents that we was not able to cover in the paper due to the paper limit are placed here.

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

- Following folders contain this. **[Source_code_tools_used](https://github.com/adswarm/src/tree/main/Source_code_attack)**.
