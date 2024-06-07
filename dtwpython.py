import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, filtfilt
from dtw import dtw

def bandpass_filter(data, fs, lowcut, highcut):
    nyquist = 0.5 * fs
    low = lowcut / nyquist
    high = highcut / nyquist
    b, a = butter(1, [low, high], btype='band')
    y = filtfilt(b, a, data)
    return y

def dtw_distance(x, y):
    alignment = dtw(x, y, keep_internals=False)
    return alignment.distance

def dynamictimewarper(data1, data2, fs):
    if not isinstance(data1, dict):
        data1 = {'erp': data1.T}
    if not isinstance(data2, dict):
        data2 = {'erp': data2.T}

    meanAbsLatency = []

    for i in range(data1['erp'].shape[1]):
        query = (data1['erp'][:, i] - np.mean(data1['erp'][:, i])) / np.std(data1['erp'][:, i])
        reference = (data2['erp'][:, i] - np.mean(data2['erp'][:, i])) / np.std(data2['erp'][:, i])
        
        alignment = dtw(query, reference, keep_internals=True)
        ix, iy = np.array(alignment.index1), np.array(alignment.index2)
        latency = ix - iy
        meanAbsLatency.append(latency)

    fs_inv = 1 / fs
    lat = np.full((len(meanAbsLatency), max(map(len, meanAbsLatency))), np.nan)
    for i in range(len(meanAbsLatency)):
        lat[i, :len(meanAbsLatency[i])] = meanAbsLatency[i]

    pathlength = len(ix) * fs_inv

    # find iqr of absolute latency
    maxlatmedian = np.nanmedian(lat, axis=0) * fs_inv

    # weighted median using zscores of each point on dtw path
    weightedLats = []
    for i in range(len(ix)):
        avgZscore = round(np.mean(np.abs(query[ix[i]]) + np.abs(reference[iy[i]])))
        avgZscore = max(avgZscore, 1)
        weightedLats.extend([lat[i]] * avgZscore)
    
    maxWeightedlatmedian = np.median(weightedLats)
    maxlat = maxWeightedlatmedian * fs_inv

    # 95th percentile of absolute latency
    abs_lat = np.abs(lat)
    maxlat95 = np.percentile(abs_lat, 95)
    maxlat95_idx = np.nanargmin(np.abs(abs_lat - maxlat95))
    maxlat95 = lat.flat[maxlat95_idx] * fs_inv

    return maxlatmedian, maxlat, maxlat95

def woody(trials):
    # Placeholder for woody filtering equivalent in Python
    return np.mean(trials, axis=1)  # Placeholder: Replace with actual implementation

# Script config
n_components = 4
component_widths = np.arange(25, 351)
component_amplitude = [-3, 3]
trials_per_ERP = 500
jitter_amount = 0.1
n_signals_generate = 50
sig_len = 0.5
fs = 1000
snr = 5

def DTWJitterLow(jitter_amount, sig_len, fs, trials_per_ERP, component_amplitude, component_widths, snr, n_components):
    trials = np.random.randn(trials_per_ERP, int(sig_len * fs))
    baseSignal = np.mean(trials, axis=0)
    grandAvg = np.mean(trials, axis=0)
    jitters = np.random.rand(trials_per_ERP) * jitter_amount
    return trials, baseSignal, grandAvg, jitters

trials, baseSignal, grandAvg, jitters = DTWJitterLow(jitter_amount, sig_len, fs, trials_per_ERP, component_amplitude, component_widths, snr, n_components)

filteredGA = bandpass_filter(grandAvg, fs, 1, 30)

cov_matrix = np.zeros((trials.shape[0], trials.shape[0]))

for i in range(trials.shape[0]):
    for j in range(trials.shape[0]):
        cov_matrix[i, j] = dtw_distance(trials[i, :], trials[j, :])

sum_cov = np.sum(cov_matrix, axis=1)
min_idx = np.argmin(sum_cov)

baseDTW = trials[min_idx, :]
warped_trials = np.zeros_like(trials)

plt.figure()
plt.plot(baseDTW)
latencies = []

for i in range(trials.shape[0]):
    _, dtw_weighted_median, _ = dynamictimewarper(trials[i, :], baseDTW, fs)
    offset = int(round(dtw_weighted_median * fs))
    latencies.append(offset)
    
    if offset > 0:
        try:
            warped_trials[i, :] = np.concatenate((trials[i, offset:], np.flip(trials[i, -offset:])))
        except:
            print('Error')
    elif offset < 0:
        try:
            warped_trials[i, :] = np.concatenate((np.flip(trials[i, :abs(offset)]), trials[i, :offset]))
        except:
            print('Error')
    else:
        warped_trials[i, :] = trials[i, :]

    plt.plot(warped_trials[i, :])

filtered_warped = bandpass_filter(np.mean(warped_trials, axis=0), fs, 1, 30)
unfiltered_warped = np.mean(warped_trials, axis=0)

plt.figure()
plt.plot(baseSignal, linewidth=2)
plt.plot(filteredGA, linewidth=2)
plt.plot(unfiltered_warped, linewidth=2)
plt.plot(filtered_warped, linewidth=2)
plt.legend(['Base signal', 'Filtered grand average', 'Mean warped unfiltered', 'Mean warped filtered', 'Woody Filtering'])

R = dtw_distance(filteredGA, baseSignal)
print('Correlation between base signal and grand average:', R)
R = dtw_distance(filtered_warped, baseSignal)
print('Correlation between base signal and mean of warped trials filtered:', R)
R = dtw_distance(unfiltered_warped, baseSignal)
print('Correlation between base signal and mean of warped trials:', R)

plt.show()
