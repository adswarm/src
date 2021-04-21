@echo off
for /l %%i in (41,1,100) do (
	echo %%i
	python src/layered_planner/planner.py 2 %%i 0.2 i 1
	python src/layered_planner/planner.py 2 %%i 0.2 a 1
	python src/layered_planner/planner.py 2 %%i 0.2 b 1
	python src/layered_planner/planner.py 2 %%i 0.2 v 1
	python src/layered_planner/planner.py 2 %%i 2.0 i 1
	python src/layered_planner/planner.py 2 %%i 2.0 a 1
	python src/layered_planner/planner.py 2 %%i 2.0 b 1
	python src/layered_planner/planner.py 2 %%i 2.0 v 1
)

