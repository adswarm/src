# Supplementary materials for attack scenarios

This page presents the video contents about attack missions created (6.2.1 Attack mission creation) to help readers to understand how the attacks are applied. All visual aids are when the attackers start to attack from 'close' distance.

## A1-1

![](https://github.com/psaresearch/swarm_attack/blob/main/Details_attack_scenarios/video/A1/A1_1_C.gif)

There are 2 attackers (cyan and red drones). Each attacker attacks follower 2 and 3, respectively. Follower 2 and 3 cannot escape from the attackers because this algorithm cannot handle this kind of dynamic obstacles. Consequentially, the swarm cannot go forward because the followers does not catch up the leader.

## A1-3

![](https://github.com/psaresearch/swarm_attack/blob/main/Details_attack_scenarios/video/A1/A1_3_C2.gif)

In this mission, attack is not effective. Though attackers are between drones, this swarm can move forward. They reached the goal at 207 tick.

![](https://github.com/psaresearch/swarm_attack/blob/main/Details_attack_scenarios/video/A1/A1_3_C1.gif)

This is a case that the attack is successful. Attack itself is not successful but it makes the swarm impossible to overcome the obstacle (wall) so the victim swarm cannot go forward after 180 tick.

## A1-4

![](https://github.com/psaresearch/swarm_attack/blob/main/Details_attack_scenarios/video/A1/A1_4_C.gif)

Attacker 1 (red) and attacker 2 (cyan) tries to push the swarm right (the opposite of the moving direction) and down, respectively. Due to the obstacle (wall) swarm is stuck after 80 tick. Yellow drone indicates the target of attacker 1 and brown means the target of attacker 2, these color changes frequently because the outmost drone in each direction becomes the target dynamically.

## A2-1

![](https://github.com/psaresearch/swarm_attack/blob/main/Details_attack_scenarios/video/A2/A2_1_C.gif)

In this video, selected drones are attackers. They try to push their own target from left to right direction. As a result, whole swarm is torn off and performs the ineffectively.

## A2-4

![](https://github.com/psaresearch/swarm_attack/blob/main/Details_attack_scenarios/video/A2/A2_4_C.gif)

The selected drones are attackers. They are pushing the swarm from outside to inside to shrink the swarm. This attack makes the swarm hard to reach the corner area.

## A3-4

![](https://github.com/psaresearch/swarm_attack/blob/main/Details_attack_scenarios/video/A3/A3_4_C.gif)

Attacker (gray) tries to attack the leader of swarm to break the swarm. Aligned drones (from the flocking behavior by Raynolds) are represented as blue ones. They deviate from the swarm as soon as leader is hindered by attacker. This attacker makes the drones hard to flock together.

## A4-3

![](https://github.com/psaresearch/swarm_attack/blob/main/Details_attack_scenarios/video/A4/A4_3_C.gif)

The attackers tried to place between drones those has the closest distance. This hinders multiple drones are gathered at same spot.

## A4-4

![](https://github.com/psaresearch/swarm_attack/blob/main/Details_attack_scenarios/video/A4/A4_4_C.gif)

In this strategy, attackers try to block the drones so that victim drones hardly reach to corner spots.
