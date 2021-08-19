
# Attack Strategies

The following figure illustrates the attack strategies (S1 to S4) in Section 4A in the paper. 

![0001](https://user-images.githubusercontent.com/82484800/129994860-d75aaa37-d0c4-4451-bd66-e1cf30aaa64a.jpg)

**Activated Attack Strategies on Each Algorithm during Evaluation.**
Following figure shows the proportions of attack strategies used during our fuzz testing evaluation in section 5 of the paper. Note that during our fuzz testing, we prioritize strategies that lead to new dcc values. Hence, there can be a correlation (Not a strong correlation since there is also randomness in choosing the strategy during the test) between each strategy's effectiveness and the number of tests using the strategy.


![aead48ef42aa4af5bccb7cca7250a067-0001](https://user-images.githubusercontent.com/82484800/129995258-e57d6c16-cf90-4746-85d4-016c66db7beb.jpg)



We have a few observations. First, S1 (Pushing back) and S4 (Herding) are the most frequently used, meaning that they might be effective on diverse swarm algorithms in general. Second, in A1 and A3, S3 (Dividing) are frequently used (17\% and 20\% of the all tests). This implies that the performance of A1 and A3 depends on the coherence of the swarm. A1 needs to maintain the formation and incoherent swarms in A3 lead to many small groups of drones searching, slowing down the performance.
