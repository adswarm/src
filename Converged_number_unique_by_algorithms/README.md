# The converged number of the unique patterns while fuzz testing

This pape shows more detailed data that is used to show that the number of the unique patterns is converged over time. Basic representation is the same as the paper. The unique pattern (i.e., Dcc trends that has NCC over the threshold) is explaine in the paper as well.

## A1 (Adaptive Swarm)

![](https://github.com/adswarm/src/blob/main/Converged_number_unique_by_algorithms/detailed_graph/a1_1.png)

It is clear that new unique pattern is hardly shown after 400 minutes (around 7 hours). Note that we use the basic unit of x-axis as 5 minutes for readibility, this is because each run has different mission complete time.

![](https://github.com/adswarm/src/blob/main/Converged_number_unique_by_algorithms/detailed_graph/a1_2.png)

This is another representation (i.e., basic unit of x-axis is 0.5 hour) of the first graph. This graph is used in the paper.

## A2 (SocraticSwarm)

![](https://github.com/adswarm/src/blob/main/Converged_number_unique_by_algorithms/detailed_graph/a2_1.png)

The reason why the numbers are sparse compared to the first algorithm is that each mission takes more time than Adaptive Swarm and drones are more distant to each other so they cannot be affected as much as the the first algorithm one. The latter is reflected the number of characterless Dcc trends. This data shows it is converged after around 5 hours.

![](https://github.com/adswarm/src/blob/main/Converged_number_unique_by_algorithms/detailed_graph/a2_2.png)
This is another representation (i.e., basic unit of x-axis is 0.5 hour) of the first graph.

## A3 (Sciadro)

![](https://github.com/adswarm/src/blob/main/Converged_number_unique_by_algorithms/detailed_graph/a3_1.png)

These trends show flat part in the early of elapsed time. However, it also shows it is converged after around 7 hours.

![](https://github.com/adswarm/src/blob/main/Converged_number_unique_by_algorithms/detailed_graph/a3_2.png)
This is another representation (i.e., basic unit of x-axis is 1.0 hour) of the first graph. In 3rd algorithm, as 1 mission takes around 3.5 minutes (it depends on the attack configurations), major interval of y-axis is 2 times of the others.

## A4 (Pietro's)

![](https://github.com/adswarm/src/blob/main/Converged_number_unique_by_algorithms/detailed_graph/a4_1.png)

Because drones in this algorithm has more randomness in movement, even after 4 hours trend maintains the certain level. However, it is converged after 8 hours as well.

![](https://github.com/adswarm/src/blob/main/Converged_number_unique_by_algorithms/detailed_graph/a4_2.png)
This is another representation (i.e., basic unit of x-axis is 0.5 hour) of the first graph.
