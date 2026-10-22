ft_defaults;
data_path = 'C:\Users\elifn\Desktop\innernew\sub-01\ses-EEG\eeg\sub-01_ses-EEG_task-inner_eeg.bdf';

cfg = [];
cfg.dataset = data_path;
cfg.trialfun = 'ft_trialfun_general';
cfg.trialdef.eventtype  = 'STATUS';
cfg.trialdef.eventvalue = [111 112 113 114 125 126 127 128];
cfg.trialdef.prestim    = 1;
cfg.trialdef.poststim   = 3;
cfg.bpfilter  = 'yes';
cfg.bpfreq    = [0.1 50];
cfg.dftfilter = 'yes';
cfg.dftfreq   = 50;
cfg = ft_definetrial(cfg);
data_all = ft_preprocessing(cfg);

cfg_reref = [];
cfg_reref.reref      = 'yes';
cfg_reref.refchannel = data_all.label(~contains(data_all.label,'EXG') & ~strcmp(data_all.label,'Status'));
data_all = ft_preprocessing(cfg_reref, data_all);

trial_var = cellfun(@(x) var(x(:)), data_all.trial);
[sorted_tv, trial_order] = sort(trial_var, 'descend');
disp(table(trial_order(1:10), sorted_tv(1:10), 'VariableNames', {'TrialNo','Variance'}))

all_data = cat(2, data_all.trial{:});
chan_var = var(all_data, 0, 2);
[sorted_cv, chan_order] = sort(chan_var, 'descend');
disp(table(data_all.label(chan_order(1:10)), sorted_cv(1:10), 'VariableNames', {'Channel','Variance'}))
[sorted_cv, chan_order] = sort(chan_var, 'descend');
disp(table(data_all.label(chan_order(1:10)), sorted_cv(1:10), 'VariableNames', {'Channel','Variance'}))

% artifact removal 
cfg_reject = [];
cfg_reject.trials = setdiff(1:length(data_all.trial), [1, 2, 85]);
data_clean = ft_selectdata(cfg_reject, data_all);

addpath('C:\Users\elifn\Desktop\EEGLAB');
addpath('C:\Users\elifn\Desktop\EEGLAB\eeglab');
eeglab; close;
cfg_eegonly = [];
cfg_eegonly.channel = 'EEG';  
data_eeg = ft_selectdata(cfg_eegonly, data_clean);

EEG = fieldtrip2eeglab(data_eeg);  %64 chnl
EEG.chanlocs = readlocs('biosemi64.sfp');
idx = find(ismember({EEG.chanlocs.labels}, {'spmnas','spmlpa','spmrpa'}));
EEG.chanlocs(idx) = [];
EEG = pop_chanedit(EEG, 'load', {'biosemi64.sfp', 'filetype', 'sfp'});
EEG = eeg_checkset(EEG);

EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'interrupt', 'on');
EEG = eeg_checkset(EEG);

EEG = pop_iclabel(EEG, 'default');
EEG = pop_icflag(EEG, [0 0; 0.3 1; 0.2 1; 0.5 1; 0.5 1; 0.5 1; 0 0]);

rejected_comps = find(EEG.reject.gcompreject > 0);
disp(rejected_comps)  

pop_selectcomps(EEG, 1:size(EEG.icaweights,1));

cfg = [];
cfg.labels = {'Brain', 'Muscle', 'Eye', 'Heart', 'Line_Noise', 'Channel_Noise', 'Other'};
cfg.num_components = size(EEG.etc.ic_classification.ICLabel.classifications, 1);
probs = EEG.etc.ic_classification.ICLabel.classifications;
comp_id = (1:cfg.num_components)';
gcom = EEG.reject.gcompreject(:); 
ic_matrix_table = table(comp_id, 'VariableNames', {'ComponentID'});

for c = 1:7
    ic_matrix_table.(cfg.labels{c}) = probs(:, c);
end

ic_matrix_table.IsRejected = gcom;
[max_val, max_idx] = max(probs, [], 2);
dominant_classes = cfg.labels(max_idx);
ic_matrix_table.DominantClass = dominant_classes(:);
ic_matrix_table.MaxProbability = max_val(:);
ic_matrix_table = movevars(ic_matrix_table, {'DominantClass', 'MaxProbability'}, 'After', 'ComponentID');
assignin('base', 'ic_global_summary', ic_matrix_table);
openvar('ic_global_summary');


r_components = [1, 7, 9, 11, 12, 14, 15, 37, 61]; 
EEG_clean = pop_subcomp(EEG, r_components, 0);

data_final = data_eeg; 

for i = 1:size(EEG_clean.data, 3)
    data_final.trial{i} = double(EEG_clean.data(:, :, i));
end

cfg_prep = [];
cfg_prep.lpfilter = 'yes';
cfg_prep.lpfreq = 30; 
cfg_prep.lpfilttype = 'fir'  
cfg_prep.lpfiltdir = 'twopass' %onepass (for one direction)
cfg_prep.demean = 'yes';
cfg_prep.baselinewindow = [-0.5 0]; %check 
data_final_ready = ft_preprocessing(cfg_prep, data_final);

cfg_erp = [];
cfg_erp.trials = find(ismember(data_final_ready.trialinfo, [111, 112, 113, 114]));
erp_social = ft_timelockanalysis(cfg_erp, data_final_ready);

cfg_erp.trials = find(ismember(data_final_ready.trialinfo, [125, 126, 127, 128]));
erp_number = ft_timelockanalysis(cfg_erp, data_final_ready);

cfg_plot = [];
cfg_plot.channel = {'Cz', 'CPz', 'Pz'}; 

figure('Name', 'Sosyal vs Sayısal İşlemleme (N400 & P300)', 'Color', 'w');
ft_singleplotER(cfg_plot, erp_social, erp_number);
title('Parieto-Central Elektrotlar (Cz, CPz, Pz) - 30Hz Filtreli');
xlabel('Zaman (saniye)');
ylabel('Amplitüd (mikroVolt)');
legend('Sosyal Kelimeler', 'Sayısal Kelimeler');
grid on;
save('C:\Users\elifn\Desktop\innernew\sub-01\ses-EEG\eeg\sub-01_clean_data.mat', 'data_final_ready', '-v7.3');

%%Statistcs
cfg_tl = [];
cfg_tl.keeptrials = 'yes';
cfg_tl.channel = setdiff(data_final_ready.label, {'Iz'});
cfg_tl.trials = find(ismember(data_final_ready.trialinfo, [111,112,113,114,125,126,127,128]));
tl_all = ft_timelockanalysis(cfg_tl, data_final_ready);

design = zeros(1, numel(tl_all.trialinfo));
design(ismember(tl_all.trialinfo, [111,112,113,114])) = 1;
design(ismember(tl_all.trialinfo, [125,126,127,128])) = 2;

cfg_neigh = [];
cfg_neigh.method = 'triangulation';
cfg_neigh.layout = 'biosemi64.lay';
neighbours = ft_prepare_neighbours(cfg_neigh, tl_all);
cfg_stat = [];
cfg_stat.method           = 'montecarlo';
cfg_stat.statistic        = 'indepsamplesT';
cfg_stat.correctm         = 'cluster';
cfg_stat.clusteralpha     = 0.05;
cfg_stat.clusterstatistic = 'maxsum';
cfg_stat.minnbchan        = 2;
cfg_stat.neighbours       = neighbours;
cfg_stat.tail             = 0;
cfg_stat.clustertail      = 0;
cfg_stat.alpha            = 0.025;
cfg_stat.numrandomization = 1000;
cfg_stat.design           = design;
cfg_stat.ivar             = 1;

stat = ft_timelockstatistics(cfg_stat, tl_all);

%%Bulunan cluster'lar gerçekten anlamlı mı?:

sig_pos = find([stat.posclusters.prob] < 0.025);
sig_neg = find([stat.negclusters.prob] < 0.025);

fprintf('Anlamlı pozitif cluster sayısı: %d\n', numel(sig_pos));
fprintf('Anlamlı negatif cluster sayısı: %d\n', numel(sig_neg));

disp('Pozitive clusters p-vals:')
disp([stat.posclusters.prob])

disp('Negative clusters p-vals:')
disp([stat.negclusters.prob])

%% Wavelet method 
cfg_tf = [];
cfg_tf.method     = 'wavelet';
cfg_tf.width      = 5;                     
cfg_tf.output     = 'pow';
cfg_tf.foi        = 2:1:40;                
cfg_tf.toi        = -0.8:0.02:2.8;         
cfg_tf.channel    = setdiff(data_final_ready.label, {'Iz'});
cfg_tf.keeptrials = 'yes';

cfg_tf.trials = find(ismember(data_final_ready.trialinfo, [111,112,113,114,125,126,127,128]));
tfr_all = ft_freqanalysis(cfg_tf, data_final_ready);

cfg_bl = [];
cfg_bl.baseline     = [-0.5 -0.1];
cfg_bl.baselinetype = 'db';
tfr_all = ft_freqbaseline(cfg_bl, tfr_all);

%% control
cfg_plot = [];
cfg_plot.channel = 'Cz';
figure;
ft_singleplotTFR(cfg_plot, tfr_all);
title('Cz - tüm koşullar, zaman-frekans gücü (dB)');

cfg_plot = [];
cfg_plot.channel = 'Cz';
cfg_plot.xlim = [-0.3 2.3];
cfg_plot.zlim = [-2 2];
figure;
ft_singleplotTFR(cfg_plot, tfr_all);
title('Cz - kenar etkisinden arındırılmış');

%% occipital as an examplw
cfg_plot = [];
cfg_plot.channel = {'O1', 'O2', 'Oz'}; 
cfg_plot.xlim = [-0.3 2.3]; 
cfg_plot.zlim = [-2 2];
figure('Name', 'Oksipital Görsel İşlemleme', 'Color', 'w');
ft_singleplotTFR(cfg_plot, tfr_all);
title('Occipital Bölge (O1, O2, Oz) - Zaman-Frekans Gücü');