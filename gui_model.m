function sensor_gui()
    % Membuat GUI
    f = figure('Visible','off','Position',[360,500,450,285]);

    % Membuat panel untuk menampilkan plot data
    plot_panel = uipanel(f,'Title','Data Plot','Position',[0.05,0.2,0.7,0.72]);
    axes_handle = axes('Parent', plot_panel);

    % Membuat tombol push untuk memulai prediksi
    hButton = uicontrol('Parent', f, 'Style', 'pushbutton', 'String', 'Mulai Prediksi', 'Units', 'normalized', 'Position', [0.7 0.0 0.2 0.2], 'Callback', @onButtonClick);
    
    importDataButton = uicontrol('Style', 'pushbutton', 'String', 'Import Data', ...
    'Position', [50, 50, 100, 30], 'Callback', @simpan_data_excel_to_mat);
tampilDataButton = uicontrol('Style', 'pushbutton', 'String', 'Tampilkan Data', ...
    'Position', [100, 50, 100, 30], 'Callback', @tampil_data);
    % Membuat tombol untuk mengambil data
    data_button = uicontrol(f,'Style','pushbutton','String','Ambil Data',...
        'Position',[315,220,100,25],'Callback',{@ambil_data_callback});

    % Membuat tombol untuk menyimpan dataset
    save_button = uicontrol(f,'Style','pushbutton','String','Simpan Dataset',...
        'Position',[315,170,100,25],'Callback',{@simpan_dataset_callback});

    % Membuat edit box untuk input label
    label_edit = uicontrol(f,'Style','edit','Position',[315,120,100,15]);
    label_edit2 = uicontrol(f,'Style','edit','Position',[315,100,100,15]);
    label_edit3 = uicontrol(f,'Style','edit','Position',[315,80,100,15]);

    % Membuat teks untuk label
    label_text = uicontrol(f,'Style','text','String','Label 1,2,3',...
        'Position',[325,150,80,15]);
data = zeros(1000, 3); % inisialisasi variabel data dengan ukuran 100 x 3
label = zeros(1000, 1); % inisialisasi variabel label dengan ukuran 100 x 1
    % Menampilkan GUI
    f.Visible = 'on';

    % Callback untuk tombol ambil data
    function ambil_data_callback(source, event)
        % Koneksi ke Arduino
        a = arduino('COM17', 'Uno');

        % Inisialisasi variabel
        jumlah_sampel = 120;
        jumlah_sensor = 3;
        data = zeros(jumlah_sampel, jumlah_sensor);
        label = zeros(jumlah_sampel, 1);

        % Pengambilan data dari sensor
        for i = 1:jumlah_sampel
            % Sensor MQ-5
            data(i, 1) = readVoltage(a, 'A1');

            % Sensor MQ-135
            data(i, 2) = readVoltage(a, 'A4');

            % Sensor MQ-2
            data(i, 3) = readVoltage(a, 'A5');

            % Input label dari edit box
%             label(i) = str2double(label_edit.String);
                if (i >= 0 && i<=39)
                label(i) = str2double(label_edit2.String);
                elseif (i>=40 && i<=80)
                    label(i) = str2double(label_edit3.String);
                else
                    label(i) = str2double(label_edit.String);
                end

            % Plot data
            plot(axes_handle, data(:,1), 'r');
            hold on
            plot(axes_handle, data(:,2), 'g');
            plot(axes_handle, data(:,3), 'b');
            xlim(axes_handle,[1 jumlah_sampel]);
            ylim(axes_handle,[0 5]);
            xlabel(axes_handle,'Sampel');
            ylabel(axes_handle,'Nilai Sensor');
            hold off

            % Jeda sebelum mengambil data berikutnya
            pause(0.1);
        end

        % Menutup koneksi dengan Arduino
        clear a;
    end

% menampilkan dataset
    function tampil_data(source,event)
        load('dataset2.mat');  % Mengambil dataset dari file dataset.mat
x = dataset(:, 1);  % Kolom pertama dataset sebagai data sumbu x
y = dataset(:, 2);  % Kolom kedua dataset sebagai data sumbu y
scatter(x, y);
title('Scatter Plot Dataset');
xlabel('X');
ylabel('Y');
    end
    % Callback untuk tombol simpan dataset
    function simpan_dataset_callback(source, event)
        % Simpan dataset ke dalam file .mat
        dataset = horzcat(data, label);
        save('dataset2.mat', 'dataset');
        msgbox('Dataset berhasil disimpan!');
    end
    
    function menampilkan_figur_baru(source,event)
        
    end


%     membuat inputan 
    function simpan_data_excel_to_mat(source,event)
        % Meminta pengguna untuk memilih file Excel
    [filename, path] = uigetfile('*.xlsx', 'Pilih file Excel');

    % Memeriksa jika pengguna membatalkan pemilihan file
    if isequal(filename,0) || isequal(path,0)
        disp('Pemilihan file dibatalkan.');
        return;
    end

    % Membaca dataset dari file Excel
    try
        data = xlsread(fullfile(path, filename));
    catch
        disp('Terjadi kesalahan saat membaca file Excel.');
        return;
    end

    % Menyimpan dataset dalam file .mat
    try
        save(fullfile(path, 'dataset.mat'), 'data');
        disp('Dataset berhasil diimpor dan disimpan sebagai file .mat.');
    catch
        disp('Terjadi kesalahan saat menyimpan file .mat.');
    end
    end
    
    function onButtonClick(~, ~)
        % Inisialisasi objek Arduino
      
            
           a = arduino('COM17', 'Uno');
net = feedforwardnet([10 20 5]);
net = init(net);
net.trainParam.epochs = 100;
net.trainParam.goal = 0.01;

load('dataset2.mat');
data = dataset(:, 1:3);
label = dataset(:, 4);
trainData = data(1:90,:);
trainLabel = label(1:90,:);
testData = data(91:end,:);
testLabel = label(91:end,:);

mseValues = zeros(1, net.trainParam.epochs);

for epoch = 1:net.trainParam.epochs
    [net, tr] = train(net, trainData', trainLabel');
    mseValues(epoch) = tr.best_perf;
    
    if tr.best_perf <= net.trainParam.goal
        break; % Berhenti jika telah mencapai goal
    end
end

% Menampilkan grafik MSE vs. Epoch
figure;
plot(1:epoch, mseValues(1:epoch), 'b', 'LineWidth', 2);
title('Grafik MSE vs. Epoch');
xlabel('Epoch');
ylabel('MSE');


mq5Value = readVoltage(a, 'A5');
mq135Value = readVoltage(a, 'A4');
mq2Value = readVoltage(a, 'A1');

sensorData = [mq5Value; mq135Value; mq2Value];
prediction = net(sensorData);

if prediction <= 3.2
    hasil = "beras dalam keadaan baik";
else
    hasil = "beras dalam keadaan buruk";
end
            hText = uicontrol('Parent', f, 'Style', 'text', 'String', prediction, 'Units', 'normalized', 'Position', [0.0 0.0 0.5 0.2]);
       % Analisis Data Pengujian
 % Analisis Data Pengujian
predictedLabels = net(testData'); % Melakukan prediksi pada data pengujian
mseValue = mse(predictedLabels', testLabel); % Menghitung Mean Squared Error
maeValue = mae(predictedLabels', testLabel); % Menghitung Mean Absolute Error
% Menghitung akurasi
acc = sum(predictedLabels' == testLabel) / length(testLabel);
disp("Hasil Analisis Data Pengujian:")
disp("Mean Squared Error: " + mseValue)
disp("Mean Absolute Error: " + maeValue)
disp("Akurasi: " + acc)


% Analisis Lainnya
% Misalnya, visualisasi perbandingan target dan hasil prediksi pada data pengujian
figure
plot(testLabel, 'b', 'LineWidth', 2);
hold on;
plot(predictedLabels', 'r--', 'LineWidth', 2);
title('Hasil Prediksi vs. Target Sebenarnya (Data Pengujian)')
xlabel('Data Uji')
ylabel('Nilai')
legend('Target', 'Prediksi')
     end
end
