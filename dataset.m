function [trainData, trainLabel, testData, testLabel] = dataset()
    load('dataset2.mat');
    data = dataset(:, 1:3);
    label = dataset(:, 4);
    proportion = 0.7; % Contoh proporsi 70% data pelatihan

    % Menghitung jumlah data pelatihan berdasarkan proporsi
    jumlahDataPelatihan = round(size(data, 1) * proportion);

    % Memisahkan data menjadi data pelatihan dan data pengujian
    trainData = data(1:jumlahDataPelatihan, :);
    trainLabel = label(1:jumlahDataPelatihan, :);
    testData = data(jumlahDataPelatihan+1:end, :);
    testLabel = label(jumlahDataPelatihan+1:end, :);
end
