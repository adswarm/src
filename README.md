# SWARM FLAW FINDER: Discovering and Exploiting Logic Flaws of Swarm Algorithms


This is the project page for SWARM FLAWFINDER: Discovering and Exploiting Logic Flaws of Swarm Algorithms. Contents that we was not able to cover in the paper due to the paper limit are placed here.

## (Updated) Effectiveness of the naive testing

- To support the naive testing approach is less effective than FLAWFINDER (RA-Q4), this page shows the number of identified unique attacks from the random testing taking an example of A1.

Following folder contains this. **[Effectiveness_of_the_naive_testing](https://github.com/adswarm/src/tree/main/Effectiveness_of_the_naive_testing)**.

## (Updated) Comparison to randomized sampling

- To give supplementary information for RD-Q6 of rebuttal, this page explains that the instances on the top of the gray circle are variants of what FLAWFINDER already identified.

Following folder contains this. **[Comparison_to_randomized_sampling](https://github.com/adswarm/src/tree/main/Comparison_to_randomized_sampling)**.

## Criteria for selecting the swarm algorithms in detail

- To select representative mature swarm algorithms for our evaluation, we search open-sourced research projects related to swarm robotics for the last 10 years (from 2010 to 2021). We listed 27 research papers and 46 algorithms with github repositories from the initial search. Among them, we were able to run 17 swarm algorithms. From the 17 runnable algorithms, we prune out algorithms that do not exhibit collective (or cooperative) behaviors.
- We present the criteria for selecting the swarm algorithms in detail this page.

More details are in **[Criteria_for_selecting_algorithms](https://github.com/adswarm/src/tree/main/Criteria_for_selecting_algorithms)**.

## Code used in the paper

- This page has code (in V. Evaluation A. Experiment setup and B. Effectiveness in finding logic flaws) used in this paper including tools, data, and fixes (with original algorithms).

Following folder contains this. **[Source_code_tools_used](https://github.com/adswarm/src/tree/main/Source_code_tools_used)**.
