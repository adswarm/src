# Tools for analysis/data processing

During the SwarmFlawFinder project, we created several tools that can assist data analysis and processing tasks. The below list explains brief descriptions about the tools.

- **Profiling for the configuration definitions**
  - A profiling tool to compute the value that removes an object
    - [01_Analysis_value_remove](Analysis_value_remove)
  - A method for identifying configuration variables
    - [02_Identifying configuration variables](identifying_configuration_variables)

- Analysis on impacts of different safety distances (e.g., sensing distances)
  - [03_A1_safety_dist](A1_safety_dist)

- Generation of test runs for fix validation
  - A1
    - with 4 drones (default): [04_A1_validation_default](A1_validation_default)
    - with more than 4 drones: [05_A1_validation_large](A1_validation_large)
  - A2 and A4: [06_A2_validation](A2_validation)
  - A3: [07_A3_validation](A3_validation)

- Test run evaluation
  - [08_Test_eval](Test_eval)
    - Test run evaluation tool for A4. A4 is running on the matlab sharing the same process of fuzz.
      It contains comparing using NCC and interpolation (these functionalities for A1~3 are in their folder separately).
      Note that to use this tool on A4, customization of input data type is required.

- Generation possible coordinates for simulation before the physical experiment
  - [09_Simulation_physical](Simulation_physical)
- Crash detection from the traces
  - [10_crashdetect](crashdetect)
- Data formatting for validation testing
  - [11_data_processing_validation](data_processing_validation)

- Additional analysis for randomized coordinates as input
  - [12_randomize_input](randomize_input)

- Data preprocessing for distribution of coordinates
  - [13_hull_analysis](hull_analysis)
    - Analysis on outline (convex hull) of distribution of drones' coordinates.
  - [14_multi_layer](multi_layer)
    - Analysis on the possibility of the drones' locations in a overall distribution.
  - [15_preprocessing_shift_rotate](preprocessing_shift_rotate)
    - Analysis on alignment of individual drones' coordinates based on the flight direction and leader's coordinates.

- Analysis of possibility that drones can exist
  - [16_distribution](incremental)
    - Analysis on distribution of drones' coordinates according to configuration of coordinate distribution analysis tool.
  - [17_possible_space](possible_space)
    - Analysis on distirubion of drones' spawn point

- [18_Visualization_support](visualization)