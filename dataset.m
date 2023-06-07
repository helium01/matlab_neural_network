function [trainData, trainLabel, testData, testLabel] = splitDataset(data, label, proportion)
% Menggunakan:
% [trainData, trainLabel, testData, testLabel] = splitDataset(data, label, proportion)
%
% Memisahkan dataset menjadi data pelatihan dan data pengujian berdasarkan proporsi yang ditentukan.
%
% Parameter input:
% - data: matriks data dengan m baris dan n kolom
% - label: vektor label dengan m elemen
% - proportion: proporsi data pelatihan yang diinginkan (dalam rentang 0 hingga 1)
%
% Parameter output:
% - trainData: matriks data pelatihan dengan jumlah baris sesuai proporsi
% - trainLabel: vektor label pelatihan dengan jumlah elemen sesuai proporsi
% - testData: matriks data pengujian dengan jumlah baris sesuai proporsi
% - testLabel: vektor label pengujian dengan jumlah elemen sesuai proporsi

% Menghitung jumlah data pelatihan berdasarkan proporsi
jumlahDataPelatihan = round(size(data, 1) * proportion);

% Memisahkan data menjadi data pelatihan dan data pengujian
trainData = data(1:jumlahDataPelatihan, :);
trainLabel = label(1:jumlahDataPelatihan, :);
testData = data(jumlahDataPelatihan+1:end, :);
testLabel = label(jumlahDataPelatihan+1:end, :);
end
