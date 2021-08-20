# Example scenario for Multiple Attack Drones

Figure below shows an example of multiple swarms
conducting a search mission. There are two attack drones A<sub>1</sub>
(< P<sub>1</sub> , S<sub>1</sub> >) and A<sub>2</sub> (< P<sub>2</sub>, S<sub>2</sub> >) and 11 victim drones
v<sub>1∼11</sub> . Observe that each attack drone’s impact is localized:
A<sub>1</sub> only affects a swarm with v<sub>1∼3</sub> while A<sub>2</sub> only impacts
v<sub>8∼11</sub>. To decide the next pose and attack strategy of A<sub>1</sub>,
v<sub>3</sub> is first identified since A<sub>1</sub> appears in the DCC values of
v<sub>3</sub> (i.e., A<sub>1</sub> directly affecting v<sub>3</sub>). Other victim drones (v<sub>1</sub>
and v<sub>2</sub>) are identified because v<sub>3</sub> appears in other victim
drones’ DCC values, indirectly affecting them. Similarly, v<sub>9</sub> is
directly impacted by A<sub>2</sub>, while v<sub>8</sub>, v<sub>10</sub>, and v<sub>11</sub> are affected by
v<sub>9</sub> (indirectly affected by A<sub>2</sub>). When FlawFinder mutates
< P<sub>1</sub>, S<sub>1</sub> >, DCC values of v<sub>1∼3</sub> are used to compute NCC
values. For < P<sub>2</sub>, S<sub>2</sub> >, DCC values of v<sub>8∼11</sub> are used. By
doing so, even if A<sub>1</sub> did not lead to exercise a new behavior
of the swarm v<sub>1∼3</sub>, it does not affect the mutation of A<sub>2</sub>.

<img src=https://user-images.githubusercontent.com/82484800/130152443-0ada2b94-c640-476c-9135-bfacb39060f1.png width=70%>
