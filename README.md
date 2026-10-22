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

* Data Acquisition and Preprocessing Pipeline

Neuroimaging data from the Alzheimer's Disease Neuroimaging Initiative (ADNI) database was utilized to computationally investigate this dynamic. A balanced cohort of 18 female subjects (9 AD patients and 9 healthy controls, aged 70-90, same manufacturer) was established to eliminate gender-based anatomical variance. The raw functional images were preprocessed using the CONN Toolbox and the totally automated workflow, including encompassing slicetiming correction, spatial realignment, outlier detection, and normalization, resulted in standardized 4D NIfTI volumes with spatial dimensions of 91 × 109 × 91 and an isotropic voxel size of 2.0 mm.

* Data-Driven Decomposition (CanICA) and Feature Extraction

In isolating intrinsic functional networks without relying on a priori anatomical templates, Canonical Independent Component Analysis (CanICA) was employed via the Nilearn library. ICA blindly decomposes the composite BOLD signal into spatially and temporally independent components. Mathematically, it is modelled as:  

                                                       X = 𝐴𝑆

Where; 
 * 𝑋 represents the observed signal matrix,
 * 𝑆 denotes the unknown independent source networks,
 * 𝐴 is the unknown mixing matrix.

A total of 30 independent network components were extracted. Through visual inspection and mathematical correlation with the Schaefer atlas, the target DMN and ECN components were isolated. Subsequently, dual regression framework was extracted with personalized 30 × 30 functional connectivity matrices and time-series for each subject. 

* Statistical Evaluation and Outcomes

As a final step, to test the compensatory hypothesis, the functional coupling levels between the DMN and ECN were extracted and evaluated using the SciPy library. The cross-network communication average for the AD group (0.3428) demonstrated a mathematically distinct increasing compared to the healthy control group (0.2847). However, the independent samples t-test resulted in a p-value of 0.1902, which represents the failing in crossing the statistical significance threshold (𝑝 < 0.05). Ultimately, while the observed connectivity increase supports the compensatory hyperconnectivity hypothesis, the limited statistical power inherent in the small sample size (𝑛 = 18) restricted the ability to capture the full effect size of this topological shift. 

#  Part 2: EEG-Based Inner Speech Analysis

Electroencephalography (EEG) is a non-invasive neuroimaging technique that records the summation of synchronous electrical activity generated by a large number of neurons in the brain. The recorded voltage fluctuations, which originate primarily from ionic currents within the central nervous system, typically range from 10 to 100 microvolts within a frequency band of 1100 Hz. While EEG possesses limited spatial resolution due to the volume-conduction effect of the scalp and skull, it offers temporal resolution capable of capturing neural dynamics on the order of milliseconds.

* EEG Pipeline for Inner Speech Data
To computationally investigate the neural correlates of inner speech, a multi-modal (EEG and fMRI) dataset, organized in accordance with Brain Imaging Data Structure (BIDS) standards, was utilized. The cognitive paradigm was meticulously structured into sequential cycles comprising a 1-second fixation period, a 2-second inner speech execution phase, and a 1-second rest period. The stimulus set consisted of 8 words categorized into Social (child, daughter, father, wife) and Numeric (four, three, ten, six) domains. Raw continuous EEG data, acquired via the BioSemi Active2 system, was algorithmically parsed into corresponding event categories using hardware trigger codes (111-114 for Social, 125-128 for Numeric). Recognizing a physical constraint in the reference methodology regarding the epoching window, the analysis timeframe was expanded to [-1, 3] seconds relative to stimulus onset, ensuring the complete second cognitive execution phase was captured without data truncation.

* Data Integration, Preprocessing, and ICA Workflow

A highly customized, cross-platform analytical pipeline was engineered utilizing MATLAB based FieldTrip and EEGLAB libraries. Following initial bandpass filtering (0.1 - 50 Hz) and 50 Hz Discrete Fourier Transform (DFT) notch filtering to eliminate powerline interference, the data was re-referenced to the common average of all cortical channels, excluding extraneous ocular and mastoid sensors. A rigorous trial- and channel-based variance analysis was executed, leading to the rejection of outlier trial 85. To prevent premature data loss, high-variance physiological artifacts in the frontal (Fp1) and occipital (Iz) channels were retained for algorithmic decomposition. After these steps, the preprocessed data was mapped into the EEGLAB environment where the runica algorithm decomposed the signals into 63 independent components. The ICLabel machine learning classifier was then deployed to generate probability distributions for each component, accurately identifying and eliminating 9 components (Components 1, 7, 9, 11, 12, 14, 15, 37, and 61) definitively associated with blinks, horizontal eye movements, and channel noise.

* Cognitive ERP and Time-Frequency Analysis

Following the artifact removal step, the cognitive signals were low-pass filtered at 30 Hz and baseline-corrected utilizing the [-0.5, 0] second pre-stimulus window. From there, the isolated neuronal responses to Social and Numeric conditions were quantified, focusing specifically on N400 and P300 waveforms across parieto-central electrodes (Cz, CPz, Pz). As the final step of processing, statistical inference was conducted employing the Monte Carlo method with 1000 permutations and a cluster-based independent samples T-test. Given the high variance inherent in single-subject event-related potentials, group-level significance thresholds were not breached. On the other hand, to capture the spectral power dynamics of the non-stationary event-related signals, a Time-Frequency Representation (TFR) was computed via Wavelet transformation (2 to 40 Hz). The result of spectrograms were optimized by analysing the [-0.3, 2.3] second window that effectively mitigates algorithmic edge artifacts and revealing the oscillatory neural dynamics during inner speech. 

# My humble recommendations for who interested in this field:

  * Stay Fascinated by the Brain: Always remember that behind every noisy EEG epoch or complex fMRI matrix lies the most elegant and profound system in the universe. Do not let the heavy computation disconnect you from the biology. Let your deep curiosity and fascination with the human mind drive your code.
  * Question Everything: Never treat an algorithm or a toolbox as a black box. Ask why a specific mathematical threshold was chosen, or what an independent component truly represents in reality. True neuroengineering requires constantly thinking, questioning the methodology, and understanding the philosophy behind the numbers.
  * Cultivate Resilience: Real-world neuroimaging data is inherently chaotic. You will spend days battling physiological artifacts, debugging scripts, and facing statistically insignificant results. Approach these moments not as failures, but as humbling reminders of how much we still have to learn. Patience and resilience are your most valuable tools here.

# References for my work
* Yang, X., Islam, M. S., & Khaled, A. A. (2019, May). Functional connectivity magnetic resonance imaging classification of autism spectrum disorder using the multisite ABIDE dataset. In 2019 IEEE EMBS international conference on biomedical & health informatics (BHI) (pp. 1-4). IEEE.
* Di Martino, A., Yan, C. G., Li, Q., Denio, E., Castellanos, F. X., Alaerts, K., & Milham, M. P. (2014). The autism brain imaging data exchange: towards a large-scale evaluation of the intrinsic brain architecture in autism. Molecular psychiatry, 19(6), 659-667.
* Lv, D., Ou, Y., Chen, Y., Ding, Z., Ma, J., Zhan, C., & Li, P. (2022). Anatomical distance affects functional connectivity at rest in medicine-free obsessive–compulsive disorder. BMC psychiatry, 22(1), 462.
* Ahmadi, H., Fatemizadeh, E., & MOTIE, N. A. (2020). A comparative study of the effect of weighted or binary functional brain networks in fMRI data analysis.
* Greicius, M. D., Srivastava, G., Reiss, A. L., & Menon, V. (2004). Default-mode network activity distinguishes Alzheimer's disease from healthy aging: evidence from functional MRI. Proceedings of the National Academy of Sciences, 101(13), 4637-4642.19
* Agosta, F., Pievani, M., Geroldi, C., Copetti, M., Frisoni, G. B., & Filippi, M. (2012). Resting state fMRI in Alzheimer's disease: beyond the default mode network. Neurobiology of aging, 33(8), 1564-1578.
* Beckmann, C. F., Mackay, C. E., Filippini, N., & Smith, S. M. (2009). Group comparison of resting-state FMRI data using multi-subject ICA and dual regression. Neuroimage, 47(Suppl 1), S148.
* He, B. (Ed.). (2020). Neural engineering. Springer Nature.
* Kaur, J., & Kaur, A. (2015, March). A review on analysis of EEG signals. In 2015 international conference on advances in computer engineering and applications(pp. 957-960).IEEE.
* Liwicki, F. S., Gupta, V., Saini, R., De, K., Abid, N., Rakesh, S., & Eriksson, J. (2022). Bimodal pilot study on inner speech decoding reveals the potential of combining EEG and fMRI.
