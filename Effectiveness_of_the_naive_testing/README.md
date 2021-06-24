# Effectiveness of the naive testing

To answer whether a naive testing approach would be effective, we run a random testing approach with the same configurations we used in Table 3. Our approach identified 20 unique attacks for A1, whereas the randomized testing approach found 12 of them under the same configuration and settings.
This is because random testing misses rare cases that require dense spawn in particular areas (e.g., near the victim drones). The details are below.

<table>
<thead>
  <tr>
    <th>ID</th>
    <th>Mission failure and root cause</th>
    <th>Unique</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="14">A1</td>
    <td>Crash between victim drones</td>
    <td>7</td>
  </tr>
  <tr>
    <td>- C1-1: Missing Collision detection</td>
    <td>3</td>
  </tr>
  <tr>
    <td>- C1-2: Naive multi-force handling</td>
    <td>3</td>
  </tr>
  <tr>
    <td>- C1-3: Unsupported static movement</td>
    <td>1</td>
  </tr>
  <tr>
    <td>Crash into external objects</td>
    <td>2</td>
  </tr>
  <tr>
    <td>- C1-1: Missing collision detection</td>
    <td>1</td>
  </tr>
  <tr>
    <td>- C1-2: Naive multi-force handling</td>
    <td>1</td>
  </tr>
  <tr>
    <td>- C1-3: Unsupported static movement</td>
    <td>0</td>
  </tr>
  <tr>
    <td>- C1-4: Excessive force in APF</td>
    <td>0</td>
  </tr>
  <tr>
    <td>Suspended progress</td>
    <td>2</td>
  </tr>
  <tr>
    <td>- C1-5: Naive swarm's pose measurement</td>
    <td>1</td>
  </tr>
  <tr>
    <td>- C1-6: Insensitive object detection</td>
    <td>1</td>
  </tr>
  <tr>
    <td>Slow progress</td>
    <td>1</td>
  </tr>
  <tr>
    <td>- C1-6: Insensitive object detection</td>
    <td>1</td>
  </tr>
  <tr>
    <td colspan="2" align="right">Total:</td>
    <td>12</td>
  </tr>
</tbody>
</table>
