import os
import sys
sys.path.append('./')

import numpy as np
from random import shuffle
from scipy.io import wavfile
from librosa import feature
from librosa.util import fix_length

import matplotlib.pyplot as plt
import seaborn as sn
%matplotlib inline

from scipy.stats import norm
import IPython

data_dir = "audio_mnist/recordings"
data_size = 2600



## Step1: Read the raw data and play it in jupyter notebook
samplerate, audio = wavfile.read(r"audio_mnist/recordings/1_george_0.wav")
IPython.display.Audio(audio, rate=samplerate)



## Step2: Read the full name of each data file
#first we only read the file name of each data
file_list = os.listdir(data_dir)
print("Data file list: ", file_list[:20])



## Step3: Split dataset into training data and test data
def test_train_split(data_list, test_ratio=0.3):
    n = len(data_list)
    shuffle(data_list)
    test_list = data_list[:int(n*test_ratio)]
    train_list = data_list[int(n*test_ratio):]
    return train_list, test_list

train_list, test_list = test_train_split(file_list)
train_list

print("training data: ", train_list[:10], ", total number: ", len(train_list))
print("testing data: ", test_list[:10], ", total number: ", len(test_list))



## Step4: Read raw data from audio file and stack them as a tensor(matrix)
def read_data(dir, file_list):
    labels = []
    datas = []
    for file_name in file_list:
        sample_rate, data = wavfile.read(os.path.join(dir, file_name))
        data = fix_length(data, size=data_size)
        label = int(file_name.split('_')[0])

        #mfcc feature extraction
        data = data.astype(float)
        data = feature.mfcc(y=data, sr=sample_rate, n_fft=1024, n_mfcc=20)

        datas.append(data.flatten())
        labels.append(label)

    return np.stack(datas), np.array(labels, dtype=int)

train_set, train_label = read_data(data_dir, train_list)
test_set, test_label = read_data(data_dir, test_list)

print("train set: ", type(train_set).__name__,train_set.shape, "\t", "train label:", type(train_label).__name__, train_label.shape)
print("test set: ", type(test_set).__name__,test_set.shape, "\t", "test label:", type(test_label).__name__, test_label.shape)



## Step5: Preprocessing - Data standardization
def standardization(data):
    mu = np.mean(data, axis=0)
    sigma = np.std(data, axis=0)
    return (data-mu)/sigma

train_set = standardization(train_set)
test_set = standardization(test_set)

fig, ax = plt.subplots()
ax.hist(train_set[:, 0], density=True, label="data distribution")
x = np.arange(-3, 3, 0.01)
ax.plot(x, norm.pdf(x, 0, 1.), label="standard norm distribution")
plt.legend()



## Step6: Implement k-nearest neighbors algorithm, and evaluate with confusion matrix and F1-score
from sklearn.neighbors import KNeighborsClassifier

KNN = KNeighborsClassifier(n_neighbors=5, metric="minkowski")
#use the training set to train the model
KNN.fit(train_set, train_label)

test_prediction = KNN.predict(test_set)

print("Test label: ", test_label[:10])
print("Test prediction: ", test_prediction[:10])

from sklearn.metrics import confusion_matrix, f1_score
mat = confusion_matrix(test_label, test_prediction)
plt.figure(figsize = (10,7))
sn.heatmap(mat, annot=True)
plt.title("confusion matrix")
plt.ylabel("ground truth")
plt.xlabel("predicted")

f1_score(test_label, test_prediction, average="micro")

from sklearn.svm import SVC

svc = SVC(gamma="auto", kernel="rbf")
svc.fit(train_set, train_label)
test_prediction_svm = svc.predict(test_set)

print("Test label: ", test_label[:20])
print("Test prediction: ", test_prediction_svm[:20])

mat = confusion_matrix(test_label, test_prediction_svm)
plt.figure(figsize = (10,7))
sn.heatmap(mat, annot=True)
plt.title("confusion matrix")
plt.ylabel("ground truth")
plt.xlabel("predicted")

f1_score(test_label, test_prediction_svm, average="micro")

