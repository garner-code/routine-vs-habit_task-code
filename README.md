# Routine vs Habit Task: Visual Foraging Experiment

A MATLAB-based behavioral experiment platform for studying routine versus habitual behavior through visual foraging tasks using Psychtoolbox-3.

## Overview

This repository contains the experimental code for a visual search/foraging task where participants learn to find targets hidden behind doors in different probabilistic contexts. The task is designed to study how people develop routines and habits by manipulating context predictability and door location probabilities.

**Key Features:**
- Multi-stage learning paradigm (Learning → Training → Test)
- Probabilistic target locations with context-dependent probabilities
- Counterbalanced experimental design for up to 80+ participants
- Real-time behavioral data collection with BIDS-inspired output format
- Psychtoolbox-3 graphics with optional eye-tracker integration
- Auditory feedback for target discovery

## Experimental Design

### Stages

1. **Stage 1: Learning (`run_learn_doors.m`)**
   - Participants learn two separate contexts (houses) with distinct door probability distributions
   - 4 out of 16 doors have p=0.25 of containing the target in each context
   - Colored borders distinguish the two contexts
   - Continues until accuracy criterion is met (40 correct in ≤4 door openings)

2. **Stage 2: Training (`run_learn_uncertainty.m`)**
   - Participants practice with predictable context switches (A → B → A → B)
   - No colored borders to indicate context
   - Must infer context from door probabilities
   - 20 trials per block, 4 blocks total (80 trials)

3. **Stage 3: Test** (future stages)
   - Transfer tests with hybrid contexts
   - Measures routine vs. habit formation

### Visual Task

Participants see a 4×4 grid of doors and must:
1. Click on doors to open them and search for the target
2. Find the hidden target image as quickly as possible
3. Learn which doors are more likely to contain targets in each context
4. Adapt behavior based on context cues or probabilistic patterns

## Requirements

### Software Dependencies

- **MATLAB** (tested on R2020a or later)
- **Psychtoolbox-3** (http://psychtoolbox.org/)
  - Requires working OpenGL graphics
  - Audio support via PsychPortAudio
- **Operating System:** Windows, macOS, or Linux with X11

### Hardware Specifications

The task is calibrated for:
- **Monitor:** 530mm × 300mm display (e.g., ASUS VG248)
- **Viewing Distance:** 570mm
- **Refresh Rate:** 100 Hz
- **Input Device:** Mouse (or eye-tracker for gaze-contingent selection)

> ⚠️ **Important:** If using different hardware, update monitor dimensions and viewing distance in the main task scripts (lines ~131-132 in `run_learn_doors.m`)

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/garner-code/routine-vs-habit_task-code.git
   cd routine-vs-habit_task-code
   ```

2. **Install Psychtoolbox-3:**
   Follow the installation guide at http://psychtoolbox.org/download
   
   Quick install in MATLAB:
   ```matlab
   % In MATLAB command window
   cd /path/to/Psychtoolbox
   SetupPsychtoolbox
   ```

3. **Verify installation:**
   ```matlab
   % Test Psychtoolbox
   PsychtoolboxVersion
   
   % Test audio
   InitializePsychSound
   ```

## Usage

### Running an Experiment

1. **Ensure all dependencies are in place:**
   - `sub_infos.mat` (participant counterbalancing)
   - `probs_cert_world_v2.mat` (probability distributions)
   - Target images in `tgts/` directory
   - Audio feedback files in `win/` directory

2. **Run Stage 1 (Learning):**
   ```matlab
   run_learn_doors
   ```
   When prompted:
   - Enter participant number (1-80)
   - Enter house number:
     - `1` = Learn context A only
     - `2` = Learn context B only
     - `9` = Mixed contexts (both A and B)

3. **Run Stage 2 (Training):**
   ```matlab
   run_learn_uncertainty
   ```
   When prompted:
   - Enter participant number

### Data Output

Data is organized in BIDS-inspired structure:

```
hvr_data/
└── sub-XXX/
    ├── ses-1/          # Learning stage
    │   └── beh/
    │       ├── sub-XXX_ses-1_house-X_beh.txt
    │       └── sub-XXX_ses-1_house-X_sess-params.mat
    └── ses-2/          # Training stage
        └── beh/
            ├── sub-XXX_ses-2_beh.txt
            └── sub-XXX_ses-2_sess-params.mat
```

**Behavioral data format** (`.txt` files):
- Tab-separated values (TSV)
- Columns: `sub`, `sess`, `t` (trial), `cond` (context), `loc` (door), `prob`, `tgt` (target ID)
- Mouse tracking data with timestamps

## Repository Structure

```
.
├── README.md                    # This file
├── run_learn_doors.m           # Stage 1: Learning script
├── run_learn_uncertainty.m     # Stage 2: Training script
├── sub_infos.mat               # Counterbalancing matrix (80×10)
├── probs_cert_world_v2.mat     # Probability distributions
│
├── functions/                   # Core task functions
│   ├── generate_trial_structure_learn.m
│   ├── generate_trial_structure_uncertain.m
│   ├── generate_sub_info_mat.m
│   ├── query_door_select.m     # Door selection polling
│   ├── query_open_door.m       # Door opening & target check
│   ├── draw_*.m                # Graphics rendering functions
│   ├── run_instructions.m      # Instruction screens
│   ├── write_trials_and_params_file.m
│   └── ...
│
├── tgts/                       # Target images
│   ├── catA/
│   ├── catB/
│   ├── catC/
│   └── catD/
│
├── breakphotos/                # Break screen images
└── win/                        # Audio feedback files
```

## Counterbalancing System

The `sub_infos.mat` file contains an 80×10 matrix controlling:
- **Columns 2-5:** Context A door indices (which 4 of 16 doors have p=0.25)
- **Columns 6-9:** Context B door indices
- **Column 10:** Color assignment (green vs. purple for contexts)

Generate a new counterbalancing file:
```matlab
% Edit and run this function
functions/generate_sub_info_mat.m
```

## Customization

### Common Modifications

1. **Change trial counts:**
   - Edit `ntrials` variable in main scripts (e.g., line 63 in `run_learn_doors.m`)
   - Ensure divisibility by number of contexts

2. **Adjust learning criterion:**
   - Modify `n_correct_required` (line 62 in `run_learn_doors.m`)
   - Adjust `moves_goal` for door opening threshold

3. **Modify display parameters:**
   - Door size: `doorPix` variable (line 159)
   - Display scale: `display_scale` (line 150)
   - Colors: Context colors defined at lines 99-110

4. **Change break frequency:**
   - Adjust `breaks` variable (line 116 for Stage 1, line 84 for Stage 2)

## Troubleshooting

### Common Issues

**"Invalid MEX-file" or Psychtoolbox errors:**
- Ensure Psychtoolbox is properly installed and in MATLAB path
- Run `PsychtoolboxPostInstallRoutine` after installation
- Check `Screen('Preference', 'SkipSyncTests', 1)` is enabled for testing

**Monitor synchronization warnings:**
- The code includes `Screen('Preference', 'SkipSyncTests', 1)` for development
- For production, ensure proper monitor settings and remove skip sync tests

**Missing files errors:**
- Verify all `.mat` data files are present
- Check `tgts/` and `win/` directories contain required images/sounds

**Audio not working:**
- Run `InitializePsychSound` manually to check audio subsystem
- Ensure `.mp3` files are in the `win/` directory
- Check system audio is not muted

## Development Notes

### Code Conventions

- **Random seeding:** Subject and stage numbers seed the RNG for reproducibility
  ```matlab
  r_num = str2double([num2str(sub_num) num2str(stage)]);
  rand('state', r_num);
  ```

- **Door indexing:** Doors numbered 1-16 in a 4×4 grid (left-to-right, top-to-bottom)

- **Context encoding:** 
  - Context 1 = House A
  - Context 2 = House B
  - Context 3 = Practice (rarely used)

### Future Enhancements

- [ ] Stage 3 transfer test implementation
- [ ] Eye-tracker integration (SMI Red support framework exists)
- [ ] Extended BIDS metadata generation
- [ ] Automated data quality checks
- [ ] Python analysis pipeline integration

## Citation

If you use this code in your research, please cite:

```
Garner, K. (2026). Routine vs. Habit Task Code [Software]. 
GitHub: https://github.com/garner-code/routine-vs-habit_task-code
```

## License

This project is licensed under the terms specified in the repository. Please contact the authors for usage permissions and academic collaboration inquiries.

## Contact & Support

For questions, issues, or contributions:
- **Issues:** Open an issue on GitHub
- **Email:** Contact repository maintainers through GitHub profile

## Acknowledgments

- Built with Psychtoolbox-3 (Brainard, 1997; Pelli, 1997; Kleiner et al., 2007)
- Inspired by visual foraging and probabilistic learning paradigms
- Audio feedback samples for participant engagement

---

**Version:** 2026.1  
**Last Updated:** February 2026  
**Status:** Active Development