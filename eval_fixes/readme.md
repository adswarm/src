## Evaluation of the Fixes

### 1. Quality of fixes
Following is the results of the quality of fixes for A2, A3, and A4 (A1 is presented in the paper). 

#### Quality of fixes for A2
![A2_table](https://user-images.githubusercontent.com/82484800/130008177-4b4fe3af-f430-4ddf-8910-7e179591ca27.png)

#### Quality of fixes for A3
<img src="https://user-images.githubusercontent.com/82484800/130008200-8095ed59-0167-4e79-9ef3-8b95ba2d120d.png" alt="drawing" width="760"/>
<!-- ![A3_table](https://user-images.githubusercontent.com/82484800/130008200-8095ed59-0167-4e79-9ef3-8b95ba2d120d.png) -->


### 2. Normalized Overhead

<img src="https://user-images.githubusercontent.com/82484800/130171479-c5e2f050-0b3b-4f70-bcf9-90e580b47e7f.png" width=60%>

After applying each fix and the integrated fix (all fixes combined), we measure 
whether the patched algorithms take longer to achieve the
original missions. Since the fixed swarm algorithms become
more robust, it is expected to have a certain overhead. 

We observe 3.9%, 2.5%, 1.2%, and 1.5% average overhead for
A1, A2, A3, and A4, respectively. 

For the integrated fix, we find that a fix with the most overhead mostly determines the
overhead: 11.4%, 9.0%, 2.2%, and 4.7% average overhead for
A1, A2, A3, and A4, respectively.

