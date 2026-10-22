# Neurosignal-Analysis-Training
This repository contains scripts and analytical pipelines developed during my Neurosignal Analysis Lab internship at Biomedical Engineering Institute of Boğaziçi University. I mainly focused on functional connectivity network analysis with rsfMRI (via SPM, CONN and Nilearn) and EEG-ERP (via FieldTrip, EEGLAB and MNE) analyses.
# Part 1: Functional Connectivity Analysis from Resting-State fMRI (rsfMRI)
# 1.1. Investigating Topological Network Deficits in Autism Spectrum Disorder (ASD):

Autism Spectrum Disorder (ASD) is a developmental brain disorder predominantly characterized by social and communication impairments, alongside restricted and repetitive behaviours. In the context of understanding the ASD, recent neuroimaging frameworks suggest that these clinical symptoms are manifestations of an underlying brain connectivity disorder. Within this context, anatomical distance plays a crucial role in functional integration; specifically, long range functional connectivity is universally defined as connections spanning an anatomical distance greater than 75 mm. Driven by this, a computational hypothesis was evaluated during the internship: *Long-range functional connectivity is significantly disrupted in individuals with ASD compared to neurotypical controls.*

* Data Acquisition and Preprocessing Pipeline:

The Autism Brain Imaging Data Exchange (ABIDE) Preprocessed Connectomes Project (PCP) database was utilized to test this hypothesis. A highly controlled pilot cohort was isolated based on phenotypic parameters: 2 atypical (ASD) and 2 typical control (TC) female subjects, aged between 18 and 30, with a Full-Scale IQ (FIQ) > 100 and the functional imaging data was acquired as already preprocessed via the DPARSF pipeline, which is structurally compatible with SPM environment. Consequently, SPM was utilized for metadata extraction and spatial quality control and from this step, the time series were extracted, standardized, detrended, and band-pass filtered (0.01-0.1 Hz) with a repetition time (TR) of 3.0 seconds. Python libraries, specifically Nilearn and NetworkX, were deployed to construct the computational workflow, including data acquisition, preprocessing, and topological analysis.

 * Phase 1: Binary Network Topology and Long-Range Isolation  
   In the first phase, the brain was parcellated into 100 distinct macroscopic regions using the Schaefer 2018 atlas. In quantifying neural interactions, partial correlation matrices were computed, and absolute values were thresholded (|𝑟| > 0.1) to create a binary adjacency matrix. To specifically isolate long-range connections, the physical distance between region centroids was calculated using the Euclidean distance algorithm:  

                                               D𝑖𝑗 = √((𝑥𝑖 −𝑥𝑗)2 +(𝑦𝑖 −𝑦𝑗)2 +(𝑧𝑖 −𝑧𝑗)2)

   Connections spanning a distance below the 75 mm threshold were systematically filtered out. Topological evaluation via NetworkX demonstrated that Global Efficiency within these long range networks was noticeably reduced in ASD subjects (0.438, 0.461) relative to neurotypical controls (0.470, 0.505). Furthermore, Degree Centrality mapping identified topological shifts in critical functional hubs.


 * Phase 2: High-Resolution Weighted Analysis 

   To validate and expand upon the initial findings, a subsequent pipeline was executed with three critical methodological adjustments: 

   * Spatial Granularity: The parcellation was scaled from 100 to 400 ROIs to provide a finer, voxel-level representation of connectivity patterns.  
   * Connectivity Metric: The transition from partial to Pearson correlation captured the total functional synchrony that accounts for both direct and indirect neural pathways. 
   * Weighted Graph Preservation: While binary thresholding methods reduce computational costs, they heavily rely on arbitrary, operator-based thresholds that often fail to consider the underlying physiological and pathological conditions of the brain. Eliminating binary thresholding and utilizing weighted graphs preserved the natural biological information and offers a more robust and mathematically accurate depiction of functional connectivity without subjective thresholding bias.

# 1.2. Evaluating Cross-Network Dynamics and Compensatory Mechanisms in Alzheimer’s Disease (AD): 


Alzheimer’s Disease (AD) is characterized by the progressive alteration and disconnection of large-scale functional brain networks. While pathological declines in Default Mode Network (DMN) and Precuneus connectivity are documented, recent frameworks suggest that the brain engages in compensatory hyperconnectivity within DMN and executive networks in an attempt to maintain cognitive efficiency against AD. Moving beyond this intra-network dynamics, a cross-network hypothesis was formulated during this internship: *The natural anti-correlation between the DMN and the Executive Control Network (ECN) is disrupted in AD, which results as increased functional coupling as a compensatory effort.*
