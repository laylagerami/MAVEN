## Troubleshooting + FAQ

This page will be updated as we receieve question and queries about the software.

### General troubleshooting

### Data

### Targets

#### Why do I get no target predictions? (blank cells)
PIDGIN will output NaN for predictions which are outside of the defined applicability domain (AD) threshold for a particular model - which is displayed as blank cells in the results table. Try to reduce this number to a less stringent threshold. Alternatively, turn off the AD filter (input 0 as the option).

### Analysis

#### How do I decide on the thresholds for PROGENy and DoRoTHEA?

#### How do I choose the activation or inhibition states of predicted targets?
You can either review the literature to see whether target inhibition or activation would make more sense (for example, see which other compounds target the particular protein(s) and their phenotypic responses), or run CARNIVAL multiple times with activation and inhibition and decide based on the resulting network.

### Visualisation

