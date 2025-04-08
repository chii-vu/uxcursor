
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from glob import glob
import re

# Glob over results/ folder and find all CSV files
csv_files = glob("results/**/*.csv", recursive=True)

# Colour for plots
sns.set_palette("Set2")

# Read and concatenate all CSVs
dfs = []
for f in csv_files:
    df = pd.read_csv(f)
    df["source_filename"] = f
    dfs.append(df)
combined_df = pd.concat(dfs, ignore_index=True)

# Convert columns to numeric
combined_df["CompletionTime"] = pd.to_numeric(combined_df["CompletionTime"], errors='coerce')
combined_df["Error"] = pd.to_numeric(combined_df["Error"], errors='coerce')
combined_df["FittsID"] = pd.to_numeric(combined_df["FittsID"], errors='coerce')

# Extract target size and count from filename (for density calculation)
def extract_metadata_from_filename(filename):
    match = re.search(r'(STANDARD|BUBBLE|AREA)_(\d+)_(\d+)', filename)
    if match:
        cursor_type = match.group(1)
        target_count = int(match.group(2))
        target_size = int(match.group(3))
        return pd.Series([cursor_type, target_count, target_size])
    else:
        return pd.Series([None, None, None])

combined_df[['CursorTypeFromFile', 'TargetCount', 'TargetSize']] = combined_df['source_filename'].apply(extract_metadata_from_filename)
combined_df['CursorType'] = combined_df['CursorTypeFromFile'].fillna(combined_df['CursorType'])

# Density = target_count * target_size
combined_df['DensityScore'] = combined_df['TargetCount'] * combined_df['TargetSize']

# Define density categories based on score
# The fatter the target and the more there are,
# the higher the density
def density_from_score(score):
    if score >= 3500:
        return "High"
    elif score >= 1500:
        return "Moderate"
    else:
        return "Low"

combined_df['Density'] = combined_df['DensityScore'].apply(density_from_score)

# --------- Overall Performance Plots ---------

# Completion Time
plt.figure(figsize=(8, 5))
sns.barplot(data=combined_df, x="CursorType", y="CompletionTime", estimator=np.mean, ci="sd", palette="Set2")
plt.title("Average Completion Time by Cursor Type")
plt.ylabel("Completion Time (ms)")
plt.xlabel("Cursor Type")
plt.tight_layout()
plt.show()

# Error Rate
plt.figure(figsize=(8, 5))
sns.barplot(data=combined_df, x="CursorType", y="Error", estimator=np.mean, ci="sd", palette="Set2")
plt.title("Average Error Rate by Cursor Type")
plt.ylabel("Error Rate")
plt.xlabel("Cursor Type")
plt.tight_layout()
plt.show()

# Fitts' ID
plt.figure(figsize=(8, 5))
sns.barplot(data=combined_df, x="CursorType", y="FittsID", estimator=np.mean, ci="sd", palette="Set2")
plt.title("Average Fitts' ID by Cursor Type")
plt.ylabel("Fitts' ID")
plt.xlabel("Cursor Type")
plt.tight_layout()
plt.show()

# --------- Performance by Density ---------

# Bar Plot with Values - Completion Time by Density
plt.figure(figsize=(12, 6))
ax = sns.barplot(data=combined_df, x="Density", y="CompletionTime", hue="CursorType", ci="sd",
                 order=["High", "Moderate", "Low"])
plt.title("Completion Time by Cursor Type and Density")
plt.xlabel("Target Density")
plt.ylabel("Completion Time (ms)")
plt.legend(title="Cursor Type")
for container in ax.containers:
    ax.bar_label(container, fmt="%.1f", label_type="center", padding=5)
plt.tight_layout()
plt.show()

# Facet Grid - Error Rate by Density
g = sns.FacetGrid(combined_df, col="CursorType", col_wrap=3, height=4, sharey=True)
g.map(sns.barplot, "Density", "Error", order=["High", "Moderate", "Low"], palette="Set2")
g.set_titles("{col_name}")
g.set_axis_labels("Target Density", "Error Rate")
g.tight_layout()
plt.show()

# Box Plot - Fitts' ID by Density
plt.figure(figsize=(12, 6))
sns.boxplot(data=combined_df, x="Density", y="FittsID", hue="CursorType",
            order=["High", "Moderate", "Low"])
plt.title("Fitts' ID by Cursor Type and Density")
plt.xlabel("Target Density")
plt.ylabel("Fitts' ID")
plt.legend(title="Cursor Type")
plt.tight_layout()
plt.show()

# --------- Summary Table ---------

# Group by CursorType and calculate stats
summary = combined_df.groupby("CursorType").agg({
    "CompletionTime": ["mean", "std"],
    "Error": ["mean", "sum"],
    "FittsID": ["mean", "std"]
}).round(2)

summary.columns = [
    "Avg CT (ms)", "CT (Std Dev)", 
    "Avg Error Rate", "Total Errors", 
    "Avg Fitts’ ID", "Fitts’ ID Std Dev"
]

summary = summary.reset_index()
print(summary)
