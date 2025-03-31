# Feedback-Study

## Usage

### 1. Analyze Raw Data and Generate Psychometric Curves
Download the Main folder.

Run the MATLAB script 'MAIN_ALL_YaelAndShir_no_feedback' four times:
- For each modality: visual (vis) and vestibular (ves)
- For each feedback condition: feedback and no feedback
  
Run the MATLAB script 'MAIN_ALL_YaelAndShir_feedback' two times:
- For each modality (vis and ves) under the feedback condition only
  
### 2. Create Data Tables
Download the Tables folder.

Run the MATLAB script 'mixed_effect_no_feedback' to create data tables for each modality. The table will contain the following columns:

- SubjNum – Subject number
- SubjSex – Subject sex
- Response – Response (right = 1 / left = 0)
- CurrStim – Current stimulus (normalized)
- PrevChoice – Previous choice (right = 1 / left = -1 / no response = 0)
- PrevStim – Previous stimulus (normalized)
- FeedbackType – Feedback type (no feedback, feedback after correct choices, feedback after incorrect choices)

Run 'mixed_effect_feedback' to create similar data tables for correct and incorrect feedback types for each modality. 

The script will also combine the tables into a single large table for each modality.

### 3. Fit Mixed Effect Model
Download and run the R script 'Mixed_Effect_Model.R'.

The script will:
- Fit a generalized linear mixed-effects model (GLMM)
- Output a CSV file containing beta estimates for each subject (including random and fixed effects)

### For access to the data, please send an email to shirhabusha6@gmail.com
