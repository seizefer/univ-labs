# MATLAB Based Design Exercise - Hybrid Energy Storage System

**Course:** UESTC4003 - Control
**Topic:** Super-capacitor Energy Storage for Grid Stability

## Overview

This project implements a hybrid energy storage system (battery + super-capacitor) for maintaining grid stability with wind power generation.

## Files

### MATLAB Files
- `main_simulation.m` - Main simulation script (run this first)
- `battery_model.m` - Battery charge/discharge model function
- `supercapacitor_model.m` - Super-capacitor model function
- `create_simulink_model.m` - Script to generate Simulink model

### Python Files
- `analyze_results.py` - Data analysis and visualization

### Data Files
- `gridwatch wind data.csv` - 24-hour wind power data (5-min intervals)

### Documentation
- `MATLAB_Design_Exercise_Report.md` - Technical report
- `super-capacitor_MATLAB_Design_Exercise.pdf` - Exercise requirements

## How to Run

### MATLAB Simulation

1. Open MATLAB and navigate to this directory
2. Run the main simulation:
   ```matlab
   main_simulation
   ```
3. Results will be saved as:
   - `case1_constant_load.png/fig`
   - `case2_disturbance.png/fig`
   - `system_comparison.png/fig`
   - `simulation_results.csv`

### Simulink Model

1. Create the Simulink model:
   ```matlab
   create_simulink_model
   ```
2. Open and configure the model as needed

### Python Analysis

1. After running MATLAB simulation:
   ```bash
   python analyze_results.py
   ```
2. Additional plots saved as:
   - `wind_analysis.png/pdf`
   - `comparative_analysis.png/pdf`

## System Parameters

### Battery
- Capacity: 500 kWh
- Max Power: 300 kW
- Efficiency: 95%
- SOC Range: 20% - 90%

### Super-capacitor
- Capacitance: 100 F
- Max Power: 500 kW
- Voltage Range: 400V - 800V
- ESR: 0.01 Ω

### Load
- Case 1: 450 kW constant
- Case 2: 450 kW + 300 kW disturbance at mid-day (5 min)

## Results Summary

- Battery maintains SOC within safe limits for 24-hour operation
- Super-capacitor provides rapid response (< 100 ms) to load transients
- System remains stable under both test conditions
