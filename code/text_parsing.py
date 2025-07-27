# ---
# jupyter:
#   jupytext:
#     formats: py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.17.2
#   kernelspec:
#     display_name: Python [conda env:base] *
#     language: python
#     name: conda-base-py
# ---

# %%
#Parsing Test File 
#26th July 2025

import re
import pandas as pd
import os

# Define theme names in order and corresponding short prefixes for columns
themes = [
    ("Hindu-Muslim Relations", "hindu_muslim"),
    ("Gender Relations", "gender_relations"),
    ("Nationalism", "nationalism"),
    ("LGBTQIA+ Themes", "lgbtq")
]

# Axis labels as they appear in the text (note the en dash character in each)
axis_labels = [
    "Exclusionary–Inclusionary",
    "Negative–Positive",
    "Conservative–Progressive"
]

#NOTE: Please change file paths accordingly 
#Input File: sentiment_raw_output.txt as the result of sentiment_analysis_new.ipynb 

# Input and output paths
input_path = os.path.expanduser("~/Desktop/ra_app/sentiment_raw_output.txt")
output_path = os.path.expanduser("~/Desktop/ra_app/sentiment_parsed_output.csv")

# Ensure the output directory exists
os.makedirs(os.path.dirname(output_path), exist_ok=True)

# Read the entire text content
with open(input_path, "r", encoding="utf-8") as f:
    content = f.read()

# Split content into lines for easier parsing
lines = content.splitlines()

# Regular expression to identify movie title lines (=== Title (ttXXXXXXX) ===)
title_pattern = re.compile(r'^={3,}\s*(?P<title>.*?)\s*\((?P<imdb_id>tt\d+)\)\s*={3,}$')

movies_data = []  # list to collect each movie's data as a dictionary

# Find all movie title lines and their indices
title_indices = []
for i, line in enumerate(lines):
    match = title_pattern.match(line)
    if match:
        title_indices.append((i, match.group("title"), match.group("imdb_id")))
title_indices.sort(key=lambda x: x[0])  # sort by line number just in case

# Loop through each identified movie block
for idx, title, imdb_id in title_indices:
    # Determine the range of lines belonging to this movie (up to the next title or EOF)
    # Find the next title index after the current one
    next_title_idx = None
    for j, _, _ in title_indices:
        if j > idx:
            next_title_idx = j
            break
    # If this is the last movie, set end index to end of file
    end_idx = next_title_idx if next_title_idx is not None else len(lines)
    
    block_lines = lines[idx:end_idx]
    # Remove any separator lines consisting of only '=' characters at the end of the block
    while block_lines and re.match(r'^[=\s]+$', block_lines[-1]) and not title_pattern.match(block_lines[-1]):
        block_lines.pop()
    
    # Prepare a dictionary for this movie's data
    movie_record = {
        "title": title.strip(),
        "imdb_id": imdb_id.strip()
    }
    
    # Find all "Presence" lines in this block (account for bold formatting with **)
    presence_line_indices = []
    for k, line in enumerate(block_lines):
        # Regex allows for optional bold markup around "Presence"
        if re.search(r'Presence\**\s*:', line):
            presence_line_indices.append(k)
    presence_line_indices.sort()
    
    # There should be 4 presence lines (one per theme). If not, try a fallback by removing asterisks:
    if len(presence_line_indices) != 4:
        presence_line_indices = []
        for k, line in enumerate(block_lines):
            if "Presence:" in line.replace("*", ""):
                presence_line_indices.append(k)
        presence_line_indices.sort()
    
    # Iterate through each theme
    for t_index, (theme_name, prefix) in enumerate(themes):
        # Default values for presence and scores
        presence_status = None
        excl_incl = neg_pos = cons_prog = None
        
        if t_index < len(presence_line_indices):
            # Extract the presence line text for this theme
            pres_idx = presence_line_indices[t_index]
            pres_line = block_lines[pres_idx]
            # Split at the first colon to separate the status
            if ":" in pres_line:
                _, status_part = pres_line.split(":", 1)
            else:
                status_part = ""
            # Clean up the status text
            status_part = status_part.strip().strip("*").rstrip(".")
            # Normalize the presence status to one of the expected values
            if status_part.lower().startswith("present"):
                presence_status = "Present"
            elif status_part.lower().startswith("not"):
                presence_status = "Not Present"
            elif status_part.lower().startswith("ambiguous"):
                presence_status = "Ambiguous"
            else:
                presence_status = status_part or None
        else:
            presence_status = None
        
        # If theme is present, find its three axis score lines
        if presence_status == "Present":
            # Determine the range of lines to search for scores (after presence line, before next theme's presence)
            start_line = pres_idx + 1
            # End at the next presence line index if exists, otherwise end of block
            if t_index < len(presence_line_indices) - 1:
                end_line = presence_line_indices[t_index + 1]
            else:
                end_line = len(block_lines)
            
            # Loop through expected axis labels and find their values
            for axis_label in axis_labels:
                value = None
                # Search within the theme's sub-block for the axis label
                for line in block_lines[start_line:end_line]:
                    if axis_label in line:
                        # Remove formatting asterisks for easier parsing
                        clean_line = line.replace("*", "")
                        # Split at colon to get the value part (which may include commentary)
                        if ":" in clean_line:
                            _, val_part = clean_line.split(":", 1)
                        else:
                            val_part = ""
                        # Use regex to find the first float or integer in the value part
                        match = re.search(r'[-+]?[\d]+(?:\.[\d]+)?', val_part)
                        if match:
                            num_str = match.group(0)
                            # Replace any unicode minus sign or en dash with a standard hyphen
                            num_str = num_str.replace("\u2212", "-").replace("\u2013", "-")
                            try:
                                value = float(num_str)
                            except ValueError:
                                value = None
                        else:
                            # If no number found, check for "N/A"
                            if "N/A" in val_part or "n/a" in val_part:
                                value = None
                        break  # stop searching this theme once the axis is found
                # Assign the parsed value to the correct variable
                if axis_label.startswith("Exclusionary"):
                    excl_incl = value
                elif axis_label.startswith("Negative"):
                    neg_pos = value
                elif axis_label.startswith("Conservative"):
                    cons_prog = value
        
        # If theme is not present or ambiguous, leave scores as None (NaN in DataFrame)
        
        # Store the results in the movie record dictionary
        movie_record[f"{prefix}_presence"] = presence_status
        movie_record[f"{prefix}_exclusionary_inclusionary"] = excl_incl
        movie_record[f"{prefix}_negative_positive"] = neg_pos
        movie_record[f"{prefix}_conservative_progressive"] = cons_prog
    
    # Add this movie's data to the list
    movies_data.append(movie_record)

# Create DataFrame from the collected data
df = pd.DataFrame(movies_data)

# Print the DataFrame to the console
print(df.to_string(index=False))

# Save the DataFrame to CSV
df.to_csv(output_path, index=False)

