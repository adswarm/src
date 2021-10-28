# Tools for analysis/data processing

During the SwarmFlawFinder project, we created several tools and scripts that can assist our data analysis and processing tasks. The below list gives brief descriptions about the different tools.
Note that correct I/O paths should be set before using tools (current paths are removed as they include author's name).
- **Profiling for the configuration definitions**
  - A profiling tool to compute the value that removes an object
    - [01_Analysis_value_remove](01_Analysis_value_remove)
  - A method for identifying configuration variables
    - [02_Configuration_variables](02_Configuration_variables)
- Analysis on impacts of different safety distances (e.g., sensing distances)
  - [03_A1_safety_dist](03_alg_safety_dist)
- Generation of test runs for fix validation
  - A1
    - with 4 drones (default): [04_A1_default](04_A1_default)
    - with more than 4 drones: [05_A1_more_than_4](05_A1_more_than_4)
  - A2: [06_A2_validation](06_A2_validation)
  - A3 and A4: [07_A3_validation](07_A3_validation)
- Generation of possible coordinates for simulation before the physical experiment
  - [08_Simulation_physical](08_Simulation_physical)
- Crash detection from the traces
  - [09_Collision_detect](09_Collision_detect)
- Data formatting for validation testing
  - [10_Data_formatting](10_Data_formatting)
- Additional analysis for randomized coordinates as input
  - [11_Randomize_input](11_Randomize_input)
- Data preprocessing for distribution of coordinates
  - [12_Hull_analysis](12_Hull_analysis)
    - Analysis on outline (convex hull) of distribution of drones' coordinates.
  - [13_Stepwise_hull_analysis](13_Stepwise_hull_analysis)
    - Analysis on the possibility of the drones' locations in a overall distribution.
  - [14_Preprocessing_alignment](14_Preprocessing_alignment)
    - Analysis on alignment of individual drones' coordinates based on the flight direction and leader's coordinates.
- Analysis of possibility that drones can exist
  - [15_Distribution](15_Distribution)
    - Analysis on distribution of drones' coordinates according to configuration of coordinate distribution analysis tool.
  - [16_Possible_space](16_Possible_space)
    - Analysis on distirubion of drones' spawning point
- [17_Visualization_support](17_Visualization_support)