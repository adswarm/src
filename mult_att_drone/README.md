# Testing scenario with multiple attack drones

Figure below shows an example of multiple swarms
conducting a search mission. There are two attack drones A1
(< P1, S1 >) and A2 (< P2, S2 >) and 11 victim drones
v1∼11 . Observe that each attack drone’s impact is localized:
A1 only affects a swarm with v1∼3 while A2 only impacts
v8∼11. To decide the next pose and attack strategy of A1,
v3 is first identified since A1 appears in the DCC values of
v3 (i.e., A1 directly affecting v3). Other victim drones (v1
and v2) are identified because v3 appears in other victim
drones’ DCC values, indirectly affecting them. Similarly, v9 is
directly impacted by A2, while v8, v10, and v11 are affected by
v9 (indirectly affected by A2). When FLAWFINDER mutates
< P1, S1 >, DCC values of v1∼3 are used to compute NCC
values. For < P2, S2 >, DCC values of v8∼11 are used. By
doing so, even if A1 did not lead to exercise a new behavior
of the swarm v1∼3, it does not affect the mutation of A2.

![pdfresizer com-pdf-convert (1)](https://user-images.githubusercontent.com/82484800/130152443-0ada2b94-c640-476c-9135-bfacb39060f1.png)
