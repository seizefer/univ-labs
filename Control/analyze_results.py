#!/usr/bin/env python3
"""
Python Analysis Script for Hybrid Energy Storage System
Course: UESTC4003 - Control
MATLAB Based Design Exercise

This script analyzes the simulation results from MATLAB and generates
additional visualizations and statistical analysis.
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats
from scipy.signal import welch
import warnings
warnings.filterwarnings('ignore')

# Set plot style
plt.style.use('seaborn-v0_8-whitegrid')
plt.rcParams['figure.figsize'] = [12, 8]
plt.rcParams['font.size'] = 10

def load_wind_data():
    """Load and preprocess wind power data."""
    df = pd.read_csv('gridwatch wind data.csv')
    df.columns = ['id', 'timestamp', 'wind']
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    return df

def load_simulation_results():
    """Load simulation results from MATLAB."""
    try:
        results = pd.read_csv('simulation_results.csv')
        return results
    except FileNotFoundError:
        print("Warning: simulation_results.csv not found.")
        print("Please run main_simulation.m first.")
        return None

def analyze_wind_data(df):
    """Perform statistical analysis on wind power data."""
    wind = df['wind'].values

    stats_dict = {
        'Mean': np.mean(wind),
        'Std Dev': np.std(wind),
        'Min': np.min(wind),
        'Max': np.max(wind),
        'Range': np.max(wind) - np.min(wind),
        'Coefficient of Variation': np.std(wind) / np.mean(wind) * 100
    }

    print("\n" + "="*50)
    print("Wind Power Statistical Analysis")
    print("="*50)
    for key, value in stats_dict.items():
        if key == 'Coefficient of Variation':
            print(f"{key}: {value:.2f}%")
        else:
            print(f"{key}: {value:.2f} kW")

    return stats_dict

def plot_wind_analysis(df):
    """Create wind power analysis plots."""
    wind = df['wind'].values
    time_hours = np.arange(len(wind)) * 5 / 60  # 5-minute intervals in hours

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Time series
    ax1 = axes[0, 0]
    ax1.plot(time_hours, wind, 'b-', linewidth=1.5)
    ax1.axhline(y=450, color='r', linestyle='--', label='Load (450 kW)')
    ax1.axhline(y=np.mean(wind), color='g', linestyle=':', label=f'Mean ({np.mean(wind):.0f} kW)')
    ax1.set_xlabel('Time (hours)')
    ax1.set_ylabel('Wind Power (kW)')
    ax1.set_title('Wind Power Time Series')
    ax1.legend()
    ax1.grid(True)

    # Histogram
    ax2 = axes[0, 1]
    ax2.hist(wind, bins=30, color='skyblue', edgecolor='black', alpha=0.7)
    ax2.axvline(x=np.mean(wind), color='r', linestyle='--', linewidth=2, label=f'Mean: {np.mean(wind):.0f} kW')
    ax2.axvline(x=450, color='g', linestyle=':', linewidth=2, label='Load: 450 kW')
    ax2.set_xlabel('Wind Power (kW)')
    ax2.set_ylabel('Frequency')
    ax2.set_title('Wind Power Distribution')
    ax2.legend()

    # Power spectral density
    ax3 = axes[1, 0]
    fs = 1 / (5 * 60)  # Sampling frequency (1 / 5 minutes)
    freqs, psd = welch(wind, fs, nperseg=min(64, len(wind)//4))
    ax3.semilogy(freqs * 3600, psd)  # Convert to cycles per hour
    ax3.set_xlabel('Frequency (cycles/hour)')
    ax3.set_ylabel('Power Spectral Density')
    ax3.set_title('Wind Power Spectral Analysis')
    ax3.grid(True)

    # Autocorrelation
    ax4 = axes[1, 1]
    max_lag = 50
    autocorr = [np.corrcoef(wind[:-i], wind[i:])[0, 1] if i > 0 else 1.0 for i in range(max_lag)]
    ax4.bar(range(max_lag), autocorr, color='coral')
    ax4.set_xlabel('Lag (samples, 5-min intervals)')
    ax4.set_ylabel('Autocorrelation')
    ax4.set_title('Wind Power Autocorrelation')
    ax4.axhline(y=0, color='k', linestyle='-', linewidth=0.5)

    plt.tight_layout()
    plt.savefig('wind_analysis.png', dpi=150)
    plt.savefig('wind_analysis.pdf')
    print("\nSaved: wind_analysis.png, wind_analysis.pdf")

    return fig

def analyze_system_performance(results):
    """Analyze system performance from simulation results."""
    if results is None:
        return

    print("\n" + "="*50)
    print("System Performance Analysis")
    print("="*50)

    # Case 1 Analysis
    print("\nCase 1: Constant Load (450 kW)")
    print("-" * 30)

    battery_power_1 = results['battery_power_case1'].values
    battery_soc_1 = results['battery_soc_case1'].values

    print(f"Battery Power - Max discharge: {np.max(battery_power_1):.2f} kW")
    print(f"Battery Power - Max charge: {np.min(battery_power_1):.2f} kW")
    print(f"Battery SOC - Final: {battery_soc_1[-1]*100:.2f}%")
    print(f"Battery SOC - Range: [{np.min(battery_soc_1)*100:.2f}%, {np.max(battery_soc_1)*100:.2f}%]")

    # Energy balance
    wind_energy = np.sum(results['wind_power'].values) * 5 / 60  # kWh
    load_energy_1 = np.sum(results['load_case1'].values) * 5 / 60  # kWh
    print(f"Total Wind Energy: {wind_energy:.2f} kWh")
    print(f"Total Load Energy: {load_energy_1:.2f} kWh")
    print(f"Net Energy: {wind_energy - load_energy_1:.2f} kWh")

    # Case 2 Analysis
    print("\nCase 2: Load with Disturbance")
    print("-" * 30)

    battery_power_2 = results['battery_power_case2'].values
    battery_soc_2 = results['battery_soc_case2'].values
    sc_power = results['sc_power'].values

    print(f"Battery Power - Max discharge: {np.max(battery_power_2):.2f} kW")
    print(f"Battery Power - Max charge: {np.min(battery_power_2):.2f} kW")
    print(f"Super-capacitor - Max power: {np.max(np.abs(sc_power)):.2f} kW")
    print(f"Battery SOC - Final: {battery_soc_2[-1]*100:.2f}%")

    # Disturbance response
    load_2 = results['load_case2'].values
    disturbance_idx = np.where(load_2 > 500)[0]
    if len(disturbance_idx) > 0:
        print(f"Disturbance detected at samples: {disturbance_idx}")
        print(f"SC power during disturbance: {sc_power[disturbance_idx[0]]:.2f} kW")

def plot_comparative_analysis(results):
    """Create comparative analysis plots."""
    if results is None:
        return

    time = results['time_hours'].values

    fig, axes = plt.subplots(3, 2, figsize=(14, 12))

    # Wind vs Load comparison
    ax1 = axes[0, 0]
    ax1.plot(time, results['wind_power'], 'b-', label='Wind Power', linewidth=1.5)
    ax1.plot(time, results['load_case1'], 'r--', label='Case 1 Load', linewidth=1.5)
    ax1.plot(time, results['load_case2'], 'g:', label='Case 2 Load', linewidth=1.5)
    ax1.set_xlabel('Time (hours)')
    ax1.set_ylabel('Power (kW)')
    ax1.set_title('Power Profiles')
    ax1.legend()
    ax1.grid(True)

    # Battery SOC comparison
    ax2 = axes[0, 1]
    ax2.plot(time, results['battery_soc_case1'] * 100, 'b-', label='Case 1', linewidth=1.5)
    ax2.plot(time, results['battery_soc_case2'] * 100, 'r-', label='Case 2', linewidth=1.5)
    ax2.set_xlabel('Time (hours)')
    ax2.set_ylabel('SOC (%)')
    ax2.set_title('Battery State of Charge Comparison')
    ax2.legend()
    ax2.grid(True)
    ax2.set_ylim([0, 100])

    # Battery power comparison
    ax3 = axes[1, 0]
    ax3.plot(time, results['battery_power_case1'], 'b-', label='Case 1', linewidth=1.5)
    ax3.plot(time, results['battery_power_case2'], 'r-', label='Case 2', linewidth=1.5)
    ax3.axhline(y=0, color='k', linestyle='-', linewidth=0.5)
    ax3.set_xlabel('Time (hours)')
    ax3.set_ylabel('Power (kW)')
    ax3.set_title('Battery Power Comparison')
    ax3.legend()
    ax3.grid(True)

    # Super-capacitor performance
    ax4 = axes[1, 1]
    ax4.plot(time, results['sc_power'], 'orange', linewidth=1.5)
    ax4.axhline(y=0, color='k', linestyle='-', linewidth=0.5)
    ax4.set_xlabel('Time (hours)')
    ax4.set_ylabel('Power (kW)')
    ax4.set_title('Super-capacitor Power (Case 2)')
    ax4.grid(True)

    # Super-capacitor voltage
    ax5 = axes[2, 0]
    ax5.plot(time, results['sc_voltage'], 'purple', linewidth=1.5)
    ax5.set_xlabel('Time (hours)')
    ax5.set_ylabel('Voltage (V)')
    ax5.set_title('Super-capacitor Voltage')
    ax5.grid(True)

    # Energy flow summary
    ax6 = axes[2, 1]
    dt_hours = 5 / 60
    categories = ['Wind\nGeneration', 'Load\n(Case 1)', 'Load\n(Case 2)',
                  'Battery\n(Case 1)', 'Battery\n(Case 2)', 'SC\n(Case 2)']
    energies = [
        np.sum(results['wind_power']) * dt_hours,
        np.sum(results['load_case1']) * dt_hours,
        np.sum(results['load_case2']) * dt_hours,
        np.sum(np.abs(results['battery_power_case1'])) * dt_hours,
        np.sum(np.abs(results['battery_power_case2'])) * dt_hours,
        np.sum(np.abs(results['sc_power'])) * dt_hours
    ]
    colors = ['blue', 'red', 'green', 'cyan', 'magenta', 'orange']
    bars = ax6.bar(categories, energies, color=colors, alpha=0.7)
    ax6.set_ylabel('Energy (kWh)')
    ax6.set_title('Energy Flow Summary (24 hours)')
    ax6.grid(True, axis='y')

    # Add value labels on bars
    for bar, energy in zip(bars, energies):
        ax6.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 5,
                f'{energy:.0f}', ha='center', va='bottom', fontsize=8)

    plt.tight_layout()
    plt.savefig('comparative_analysis.png', dpi=150)
    plt.savefig('comparative_analysis.pdf')
    print("\nSaved: comparative_analysis.png, comparative_analysis.pdf")

    return fig

def generate_summary_table(df, results):
    """Generate summary tables for the report."""

    # Wind data summary
    wind = df['wind'].values
    wind_summary = pd.DataFrame({
        'Parameter': ['Mean Power', 'Std Deviation', 'Min Power', 'Max Power',
                      'Total Energy (24h)', 'Capacity Factor'],
        'Value': [f'{np.mean(wind):.2f} kW', f'{np.std(wind):.2f} kW',
                  f'{np.min(wind):.2f} kW', f'{np.max(wind):.2f} kW',
                  f'{np.sum(wind) * 5/60:.2f} kWh', f'{np.mean(wind)/np.max(wind)*100:.1f}%']
    })

    print("\n" + "="*50)
    print("Summary Tables")
    print("="*50)
    print("\nWind Power Summary:")
    print(wind_summary.to_string(index=False))

    if results is not None:
        # System performance summary
        perf_data = {
            'Parameter': ['Battery Capacity', 'Battery Max Power', 'SC Capacitance',
                         'SC Max Power', 'Load (Constant)', 'Load (Disturbance)'],
            'Value': ['500 kWh', '300 kW', '100 F', '500 kW', '450 kW', '750 kW']
        }
        perf_summary = pd.DataFrame(perf_data)
        print("\nSystem Parameters:")
        print(perf_summary.to_string(index=False))

        # Save tables to CSV
        wind_summary.to_csv('wind_summary.csv', index=False)
        perf_summary.to_csv('system_parameters_summary.csv', index=False)
        print("\nSaved: wind_summary.csv, system_parameters_summary.csv")

def main():
    """Main analysis function."""
    print("="*60)
    print("Hybrid Energy Storage System - Python Analysis")
    print("UESTC4003 Control - MATLAB Based Design Exercise")
    print("="*60)

    # Load data
    print("\nLoading data...")
    df = load_wind_data()
    results = load_simulation_results()

    # Wind data analysis
    analyze_wind_data(df)
    plot_wind_analysis(df)

    # System performance analysis
    if results is not None:
        analyze_system_performance(results)
        plot_comparative_analysis(results)

    # Generate summary tables
    generate_summary_table(df, results)

    print("\n" + "="*60)
    print("Analysis Complete!")
    print("="*60)

    # Show plots
    plt.show()

if __name__ == "__main__":
    main()
