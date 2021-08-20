# Need a2 as well!
# Results from testing A3 and A4 with FlawFinder and Random Testing
Figure below shows the results from the two versions for 24 hours of testing of A3 and A4. Specifically, (a) and (c) are the results from FlawFinder. 
(b) and (d) are from the random testing version. The silver round circles approximately show the size of the tested area. Each dot in the figure represents a
test case. Large dots indicate they result in new unique DCC values, where small dots are not. Red and orange dots are the test cases that caused mission 
failures (i.e., discovering logic flaws). Silver and blue dots are the test cases that do not cause mission failures. The shaded areas in (b) and (d) represent 
the explored area by FlawFinder in (a) and (c), respectively.
Observations. 

<!-- ![pdfresizer com-pdf-convert](https://user-images.githubusercontent.com/82484800/130122648-4eea6408-302b-4933-9166-4ab1b306cc65.png) -->
<img src="https://user-images.githubusercontent.com/82484800/130122648-4eea6408-302b-4933-9166-4ab1b306cc65.png" alt="drawing" width="760"/>

Observe that (a) has a particular pattern while (b) does not have such a pattern, and the test cases in (b) are more uniformly distributed. 
The pattern is indirectly revealing the characteristics of the swarm mission (e.g., where are the victim swarms heading). We can also observe that the upper half of 
the (c) is more crowded than other areas.
