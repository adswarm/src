# Tools for analysis/data processing

During the SwarmFlawFinder project, we created several tools and scripts that can assist our data analysis and processing tasks. The below list gives brief descriptions about the different tools.

- **Profiling for the configuration definitions**
  - A profiling tool to compute the value that removes an object
    - [01_Analysis_value_remove](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/01_Analysis_value_remove)
  - A method for identifying configuration variables
    - [02_Identifying configuration variables](identifying_configuration_variables) - missing

- Analysis on impacts of different safety distances (e.g., sensing distances)
  - [03_A1_safety_dist](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/03_alg_safety_dist)

- Generation of test runs for fix validation
  - A1
    - with 4 drones (default): [04_A1_default](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/04_A1_default)
    - with more than 4 drones: [05_A1_more_than_4](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/05_A1_more_than_4)
  - A2 and A4: [06_A2_validation](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/06_A2_validation)
  - A3: [07_A3_validation](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/07_A3_validation)

- Test run for evaluation
  - [08_Test_eval](Test_eval) - missing
    - Test run evaluation tool for A4. A4 is running on the matlab sharing the same process of fuzz.
      It contains comparing using NCC and interpolation (these functionalities for A1~3 are in their folder separately).
      Note that to use this tool on A4, customization of input data type is required.

- Generation of possible coordinates for simulation before the physical experiment
  - [09_Simulation_physical](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/09_Simulation_physical)
- Crash detection from the traces
  - [10_crashdetect](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/10_Crashdetect)
- Data formatting for validation testing
  - [11_data_processing_validation](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/11_Data_processing)

- Additional analysis for randomized coordinates as input
  - [12_randomize_input](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/12_Randomize_input)

- Data preprocessing for distribution of coordinates
  - [13_hull_analysis](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/13_Hull_analysis)
    - Analysis on outline (convex hull) of distribution of drones' coordinates.
  - [14_multi_layer](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/14_Multi_layer)
    - Analysis on the possibility of the drones' locations in a overall distribution.
  - [15_preprocessing_shift_rotate](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/15_preprocessing_shift_rotate)
    - Analysis on alignment of individual drones' coordinates based on the flight direction and leader's coordinates.

- Analysis of possibility that drones can exist
  - [16_distribution](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/16_Distribution)
    - Analysis on distribution of drones' coordinates according to configuration of coordinate distribution analysis tool.
  - [17_possible_space](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/17_Possible_space)
    - Analysis on distirubion of drones' spawn point

- [18_Visualization_support](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/18_Visualization_support)
- [19 etc](https://github.com/adswarm/src/tree/main/Source_code_tools_used/02_tools/19_etc.)
