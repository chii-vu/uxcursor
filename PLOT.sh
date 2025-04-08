#!/bin/bash
set -e

# Create and actiavte a virtual environment with all dependencies
python3 -m venv .plot_results_env
source .plot_results_env/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Run the plot script
python plot_results.py