## SwarmFlawFinder: Discovering and Exploiting Logic Flaws of Swarm Algorithms

This is the project page for the submission "SwarmFlawFinder: Discovering and Exploiting Logic Flaws of Swarm Algorithms." 
Supplementary materials to the paper, not included due to the paper's space limit, can be found below.
Specifically, this repository includes all the developed tools, data, and results. 


### 1. [Developed Tools and Code](https://github.com/adswarm/src/tree/main/Source_code_tools_used)
- This sub page has code used in this paper including tools, data, and fixes (with original algorithms).
- [Link to open the subpage](https://github.com/adswarm/src/tree/main/Source_code_tools_used)


### 2. [Illustration of Swarm Attack Strategies](https://github.com/adswarm/src/tree/main/atk_strategies)
- In **Section IV. Design; A. Test-run Definition and Creation**, we mention "Attack Strategy (S)" refer to this webpage to illustrate the attack strategies.
- [Link to open the subpage](https://github.com/adswarm/src/tree/main/atk_strategies)


### 3. [Multiple Attack Drones Scenario Example](https://github.com/adswarm/src/tree/main/mult_att_drone)
- In **Section IV. Design; D. Testing with Multiple Attack Drones**, we refer to this webpage for an example scenario with multiple attack drones to elaborate how our system handle multiple drones.
- [Link to open the subpage](https://github.com/adswarm/src/tree/main/mult_att_drone)


### 3. (Updated) Effectiveness of the naive testing

- To support the naive testing approach is less effective than FlawFinder (RA-Q4), this page shows the number of identified unique attacks from the random testing taking an example of A<sub>1</sub>.

Following folder contains this. **[Effectiveness_of_the_naive_testing](https://github.com/adswarm/src/tree/main/Effectiveness_of_the_naive_testing)**.

### (Updated) Comparison to randomized sampling

- To give supplementary information for RD-Q6 of rebuttal, this page explains that the instances on the top of the gray circle are variants of what FlawFinder already identified.

Following folder contains this. **[Comparison_to_randomized_sampling](https://github.com/adswarm/src/tree/main/Comparison_to_randomized_sampling)**.


### Swarm attack strategies during evaluation

- To outlines the activated attack strategies during evaluation of FlawFinder.

Following folder contains this. [attack_strategy_eval](https://github.com/adswarm/src/tree/main/attack_strategy_eval)

### Visual difference between coverage of FlawFinder and random search

- To visually differentiate the coverage between FlawFinder and random search by testing them on A<sub>3</sub> and A<sub>4</sub>.

Following folder contains this. [Coverage_of_A3_and_A4_With_FLAWFINDER_and_Random](https://github.com/adswarm/src/tree/main/Coverage_of_A3_and_A4_With_FLAWFINDER_and_Random)

### Detailed results for FlawFinder vs random search w.r.t search space

- To give further breakdown of results of search space for FlawFinder and random search.

Following folder contains this. [flawfinder_vs_random_wrt_search_space](https://github.com/adswarm/src/tree/main/flawfinder_vs_random_wrt_search_space)

### Quality of fixes for A<sub>2</sub> and A<sub>3</sub>

- To give details on the quality of fixes for A<sub>2</sub> and A<sub>3</sub> excluded from the paper.

Following folder contains this. [quality_of_fixes_A2_and_A3](https://github.com/adswarm/src/tree/main/quality_of_fixes_A2_and_A3)

### Criteria for selecting the swarm algorithms in detail

- To select representative mature swarm algorithms for our evaluation, we search open-sourced research projects related to swarm robotics for the last 10 years (from 2010 to 2021). We listed 27 research papers and 46 algorithms with github repositories from the initial search. Among them, we were able to run 17 swarm algorithms. From the 17 runnable algorithms, we prune out algorithms that do not exhibit collective (or cooperative) behaviors.
- We present the criteria for selecting the swarm algorithms in detail this page.

More details are in **[Criteria_for_selecting_algorithms](https://github.com/adswarm/src/tree/main/Criteria_for_selecting_algorithms)**.


### Detail of algorithms that failed to run

- To give detail of why we were unable to run the algorithms and so include our studies.

Following folder contains this. [failed_algo](https://github.com/adswarm/src/tree/main/failed_algo)

