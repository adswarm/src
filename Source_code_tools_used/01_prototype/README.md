# Prototype of our approach

## Code file description

- low_pass_filter.py

  > Functions for handling basic metrics of original simulation. Not used well for this experiments.

- new_tools.py

  > Most of functions for experiments (contribution score, recording drones' coordinates under certain situation, etc.) are placed.

- planner.py

  > Main code.

- potential_fields.py

  > For local planning.

- replay.py

  > This is same as planner.py, but it has replay functions. Not used now but it will be needed soon.

- rrt.py

  > For global planning. For the experimental goal, fixed random seed is used.

- test_potential.py

  > For test. **Not used**. Will be removed soon.

- tools.py
  > Basic functions for simulation (formation of drones, configurations about map, basic metrics, etc.) are placed.

## Quick start

```bash
$ python src/layered_planner_long_mission/planner.py test -k long
```

## Contact

Contact will be updated later.
