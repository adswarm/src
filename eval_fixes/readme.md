## Evaluation of the Fixes

### 1. Quality of fixes
Following is the results of the quality of fixes for A2, A3, and A4 (A1 is presented in the paper). 

### 1.1. Quality of fixes for A2
![A2_table](https://user-images.githubusercontent.com/82484800/130008177-4b4fe3af-f430-4ddf-8910-7e179591ca27.png)

Note that all the individual fixes and the integrated fixes successfully resolve the logic flaws. We do not observe any side effects for A2 as well (e.g., introducing new errors).

### 1.2. Quality of fixes for A3
<img src="https://user-images.githubusercontent.com/82484800/130008200-8095ed59-0167-4e79-9ef3-8b95ba2d120d.png" alt="drawing" width="760"/>

Note that all the individual fixes and the integrated fixes successfully resolve the logic flaws. We do not observe any side effects for A3 as well (e.g., introducing new errors).

### 1.3. Quality of fixes for A4

<img src=https://user-images.githubusercontent.com/82484800/130185096-628e5296-868c-4f53-bb05-d8f8eb3806bb.png width=70%>


Note that all the individual fixes successfully resolve the logic flaws. 
However, the integrated fix fails to resolve C4-3. Our manual analysis suggests that this is caused by the conflict between the fixed for C4-1 and C4-3.
The fix for C4-3 improves the drone's sensing sensitivity, and the fix for C4-1 makes the drone more actively avoid obstacles.
When both are applied, the drone becomes extremely sensitive in avoiding obstacles, making it challenging to fly toward a corner or narrow area.

We tune the fix by reducing the sensitivity of the sensing (4 to 3). The tuned fix successfully resolves all the logic flaws without introducing additional flaws.

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

