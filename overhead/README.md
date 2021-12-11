# Details of the Number of Additional Attack Drones and Overhead

Note that our paper aims to conduct economically efficient attacks, meaning that we prefer fewer attack drones (e.g., attacks with multiple attack drones are easy but expensive). We clarify multiple attack drones scenarios as illustrated below. Specifically, the time required to conduct a single round of our experiment on an algorithm can be computed as follows. Note that we iteratively run the experiments during our testing. 

```c=
EqTime = (#ofDrones * SingleExec) + (#ofDrones * SingleExec * #ofFactors)
```

Note that to compute Dcc values, we compute delta values between the original swarm's mission and each counterfactual execution (see Figure 5 in the paper). The first part of the equation, `#ofDrones * SingleExec`, is the original swarm mission’s execution (Figure 5 (a)). The second part of the equation, `#ofDrones * SingleExec * #ofFactors`, represents the counterfactual execution instances (Figure 5 (b)~(f)) where we perturb a single factor in each execution (details in Section IV-B Test Execution and Evaluation).

Each variable is defined as follows:
- `#ofDrones`: the number of drones in the target (victim) swarm
- `#ofFactors`  = `(#ofDrones -1) + #ofAttackDrones + #ofObjects`
  - the number of factors that can impact a victim drone's behavior
- `#ofAttackDrones`: the number of attack drones
- `#ofObjects`: the number of objects in the world except for drones in target swarm  and attack drones
- `SingleExec`: the duration of a single execution of the mission 

As shown in the above equation of `EqTime`, the number of attack drones is a part of `#ofFactors`. In general, `N` additional attack drones would cause `(#ofDrones) * N` additional execution of a mission (i.e., `SingleExec`). In our experiment, when we add 1, 2, 3, and 4 additional attack drones, we observe 8%, 14%, 21%, and 28% overhead for Adaptive Swarm (A1), respectively. Note that the overhead with additional attack drones for other algorithms shown in the below table.

|                  | A1  | A2  | A3  | A4  | 
| ---------------- | --- | --- | --- | --- |
| +1 attack drones | 8%  | 3%  | 6%  | 4%  |
| +2 attack drones | 14% | 7%  | 11% | 7%  |
| +3 attack drones | 21% | 11% | 16% | 12% |
| +4 attack drones | 28% | 16% | 20% | 17% |
* A1: Adaptive Swarm, A2: SocraticSwarm, A3: Sciadro, A4: Pietro's

Observe that the overhead differs between the algorithms. There are two factors that cause the differences. First, the number of victim drones in the algorithms is different. We use 4, 8, 10, and 15 victim drones for A1, A2, A3, and A4, respectively. When the number of victim drones is small, adding attack drones causes a substantial slow down. When there are already many victim drones, adding a few does not affect the overhead. 
A2 is an exception in that it has fewer victim drones than A3 but has lower overhead. This is because A2 has a substantially larger codebase (e.g., it contains a large portion of the code for 3D visualization), making its vanilla execution slower than others (resulting in a large value of `SingleExec`). As a result, the impact of the number of attack drones is reduced.
