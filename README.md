# Evaluating the Impact of Python Multithreading Techniques on Energy Efficiency and Performance
### Introduction
- We used a Raspberry Pi 4 Model B (4GB RAM, Cortex-A72 64-bit 1.8GHz SoC with ARM v8) for our experiments.
- We conducted the experiments for three different types of applications: CPU-bound, I/O-bound, and Memory-bound.
- We used four different multithreading techniques: `threading`, `multiprocessing`, `pp`, and `mpi4py`.
- We used the tool `powerjoular` to measure the energy consumption.
- We used `time` module to measure the execution time.
- We wrote a script to use `psutil` to measure three different types of CPU time: user, system, and i/o.
- We also wrote a script to use `psutil` to measure the memory usage.

### Conduct Experiments
Before the experiments, we create a Python virtual environment
- `python3 -m venv labvenv`
and source it
- `source labvenv/bin/activate`

and next, we need to install the required packages:
- `apt install libopenmpi-dev openmpi-bin`
- `pip install pp mpi4py numpy psutil`

To measure the energy consumption and other metrics, we used the following commands:
- `python experiment-runner/ CPU-bound/RunnerConfig.py`
- `python experiment-runner/ io_bound/RunnerConfig.py`
- `python experiment-runner/ memory_bound/RunnerConfig.py`

For each application type, the four multithreading technique programs will be executed sequentially and repeated 30 times. Between every two runs, there is a 60-second cooling period.  
And the run tables will be saved in their respective experiment folders.
