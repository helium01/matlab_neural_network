function sensor_gui()
    % Membuat GUI
    f = figure('Visible','off','Position',[360,500,500,285]);

    % Membuat panel untuk menampilkan plot data
    plot_panel = uipanel(f,'Title','Data Plot','Position',[0.1,0.1,0.7,0.72]);

    % Membuat teks untuk menampilkan label "Tanggal:"
    labelText = uicontrol(f, 'Style', 'text', 'String', 'Tanggal:', ...
        'Units', 'normalized', 'Position', [0.1, 0.9, 0.15, 0.05]);
     % Menambahkan teks untuk menampilkan tanggal bulan tahun
    dateText = uicontrol(f,'Style', 'text', 'Units', 'normalized', 'Position', [0.1, 0.8, 0.15, 0.1]);

    % Mengatur tanggal bulan tahun awal
    currentDate = date;
    dateString = datestr(currentDate, 'dd/mm/yyyy');
    set(dateText, 'String', dateString);

    % Membuat timer untuk mengupdate tanggal bulan tahun
    t = timer('ExecutionMode', 'fixedRate', 'Period', 1, 'TimerFcn', @updateDate);
    start(t);

    % Fungsi untuk mengupdate tanggal bulan tahun
    function updateDate(~, ~)
        currentDate = date;
        dateString = datestr(currentDate, 'dd/mm/yyyy');
        set(dateText, 'String', dateString);
    end

    % Menambahkan axes untuk menampilkan gambar logo di atas plot_panel
    logo_axes = axes('Parent', f, 'Units', 'normalized', 'Position', [0, 0.80, 0.1, 0.20]);
    logo_img = imread('Lambang.png'); % Ganti 'Lambang.png' dengan nama file logo yang sesuai
    desired_width = 200;
    desired_height = round(size(logo_img, 1) * desired_width / size(logo_img, 2));
    logo_img_resized = imresize(logo_img, [desired_height, desired_width]);
    imshow(logo_img_resized, 'Parent', logo_axes);

    % Menambahkan axes untuk menampilkan plot data di dalam plot_panel
    axes_handle = axes('Parent', plot_panel);

    % Membuat tombol push untuk memulai prediksi
    hButton = uicontrol('Parent', f, 'Style', 'pushbutton', 'String', 'Mulai Prediksi', 'Units', 'normalized', 'Position', [0.8 0.0 0.2 0.2], 'Callback', @onButtonClick);
    analisis = uicontrol('Parent', f, 'Style', 'pushbutton', 'String', 'analisis data', 'Units', 'normalized', 'Position', [0.5 0.0 0.2 0.1], 'Callback', @analisis_data);
    
    importDataButton = uicontrol('Style', 'pushbutton', 'String', 'Import Data', ...
        'Units', 'normalized', 'Position', [0.1, 0.0, 0.2, 0.1], 'Callback', @simpan_data_excel_to_mat);
    tampilDataButton = uicontrol('Style', 'pushbutton', 'String', 'Tampilkan Data', ...
        'Units', 'normalized', 'Position', [0.3, 0.0, 0.2, 0.1], 'Callback', @tampil_data);

    % Membuat tombol untuk mengambil data
    data_button = uicontrol(f,'Style','pushbutton','String','Ambil Data',...
        'Units', 'normalized', 'Position',[0.8, 0.7, 0.2, 0.1],'Callback',{@ambil_data_callback});

    % Membuat tombol untuk menyimpan dataset
    save_button = uicontrol(f,'Style','pushbutton','String','Simpan Dataset',...
        'Units', 'normalized', 'Position',[0.8, 0.6, 0.2, 0.1],'Callback',{@simpan_dataset_callback});

    % Membuat edit box untuk input label
    label_edit = uicontrol(f,'Style','edit', 'Units', 'normalized','Position',[0.8, 0.5, 0.2, 0.05]);
    label_edit2 = uicontrol(f,'Style','edit', 'Units', 'normalized','Position',[0.8, 0.45, 0.2, 0.05]);
    label_edit3 = uicontrol(f,'Style','edit', 'Units', 'normalized','Position',[0.8, 0.4, 0.2, 0.05]);

    % Membuat teks untuk label
    label_text = uicontrol(f,'Style','text', 'Units', 'normalized','String','Label 1,2,3',...
        'Position',[0.8, 0.55, 0.2, 0.05]);
    data = zeros(1000, 3); % inisialisasi variabel data dengan ukuran 100 x 3
    label = zeros(1000, 1); % inisialisasi variabel label dengan ukuran 100 x 1
        % Menampilkan GUI
        f.Visible = 'on';
    drawnow;
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

        % Menampilkan hasil prediksi dalam sebuah figur baru
        figure;
         text(0.5, 0.8, ['Prediksi: ' hasil], 'FontSize', 12, 'HorizontalAlignment', 'center');
        text(0.5, 0.4, ['MSE: ' num2str(mseValue)], 'FontSize', 12, 'HorizontalAlignment', 'center');
        text(0.5, 0.2, ['MAE: ' num2str(maeValue)], 'FontSize', 12, 'HorizontalAlignment', 'center');
        axis off;

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
 
    % analisis data
    function analisis_data(source,event)
        % Memuat dataset
        load('dataset2.mat'); % Ganti 'dataset.mat' dengan nama file dataset yang sesuai

        % Memisahkan fitur dan label dari dataset
        X = dataset(:, 1:end-1); % Kolom fitur dari dataset
        y = dataset(:, end); % Kolom label dari dataset

        % Memisahkan data menjadi data pelatihan dan data pengujian
        trainRatio = 0.8; % Rasio data pelatihan
        validationRatio = 0.1; % Rasio data validasi
        testRatio = 0.1; % Rasio data pengujian
        [trainInd, valInd, testInd] = dividerand(size(X, 1), trainRatio, validationRatio, testRatio);
        X_train = X(trainInd, :); % Data pelatihan
        y_train = y(trainInd, :); % Label pelatihan
        X_val = X(valInd, :); % Data validasi
        y_val = y(valInd, :); % Label validasi
        X_test = X(testInd, :); % Data pengujian
        y_test = y(testInd, :); % Label pengujian

        % Analisis dataset
        % Contoh analisis yang dapat dilakukan:
        numSamples = size(X, 1); % Jumlah total sampel
        numFeatures = size(X, 2); % Jumlah fitur
        numClasses = numel(unique(y)); % Jumlah kelas

        disp('Analisis Dataset:');
        disp(['Jumlah total sampel: ' num2str(numSamples)]);
        disp(['Jumlah fitur: ' num2str(numFeatures)]);
        disp(['Jumlah kelas: ' num2str(numClasses)]);

        % Pemilihan model untuk neural network
        % Contoh pemilihan model:
        hiddenLayerSizes = [10 20 5]; % Jumlah neuron dalam setiap lapisan tersembunyi
        net = feedforwardnet(hiddenLayerSizes); % Membuat model neural network
        net = init(net); % Inisialisasi bobot dan bias
        net.trainParam.epochs = 100; % Jumlah epoch pelatihan
        net.trainParam.goal = 0.01; % Target MSE (Mean Squared Error) pelatihan

        disp('Model Neural Network:');
        disp(['Jumlah neuron dalam setiap lapisan tersembunyi: ' num2str(hiddenLayerSizes)]);
        disp(['Jumlah epoch pelatihan: ' num2str(net.trainParam.epochs)]);
        disp(['Target MSE: ' num2str(net.trainParam.goal)]);

        % Pelatihan neural network menggunakan data pelatihan
        [net, tr] = train(net, X_train', y_train');

        % Evaluasi model menggunakan data validasi
        y_val_predicted = net(X_val');
        mse_val = mse(y_val_predicted', y_val);
        mae_val = mae(y_val_predicted', y_val);


        % Prediksi menggunakan data pengujian
        y_test_predicted = net(X_test');
        mse_test = mse(y_test_predicted', y_test);
        mae_test = mae(y_test_predicted', y_test);

     % Menampilkan hasil evaluasi pada figure baru dengan plot
        figure;
        subplot(2, 1, 1);
        plot(y_val, 'b', 'LineWidth', 2);
        hold on;
        plot(y_val_predicted', 'r--', 'LineWidth', 2);
        title('Hasil Prediksi vs. Target Sebenarnya (Data Validasi)');
        xlabel('Data Validasi');
        ylabel('Nilai');
        legend('Target', 'Prediksi');

        subplot(2, 1, 2);
        plot(y_test, 'b', 'LineWidth', 2);
        hold on;
        plot(y_test_predicted', 'r--', 'LineWidth', 2);
        title('Hasil Prediksi vs. Target Sebenarnya (Data Pengujian)');
        xlabel('Data Pengujian');
        ylabel('Nilai');
        legend('Target', 'Prediksi');
        % Buat figur baru
        figure;

        % Tampilkan analisis dataset
        subplot(2, 1, 1);
        bar([numSamples, numFeatures, numClasses]);
        xticks(1:3);
        xticklabels({'Total Sampel', 'Jumlah Fitur', 'Jumlah Kelas'});
        ylabel('Jumlah');
        title('Analisis Dataset');

        % Tampilkan evaluasi model
        subplot(2, 1, 2);
        bar([mse_val, mae_val; mse_test, mae_test]);
        xticks(1:2);
        xticklabels({'Data Validasi', 'Data Pengujian'});
        ylabel('Nilai');
        title('Evaluasi Model');

        % Tampilkan nilai di atas batang
        for i = 1:length(mse_val)
            text(i, mse_val(i), num2str(mse_val(i), '%0.5f'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Position', [i mse_val(i)+0.05]);
        end

        for i = 1:length(mae_val)
            text(i, mae_val(i), num2str(mae_val(i), '%0.5f'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Position', [i mae_val(i)+0.05]);
        end

        for i = 2:length(mse_test)+1
            text(i, mse_test(i-1), num2str(mse_test(i-1), '%0.5f'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Position', [i mse_test(i-1)+0.05]);
        end

        for i = 2:length(mae_test)+1
            text(i, mae_test(i-1), num2str(mae_test(i-1), '%0.5f'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Position', [i mae_test(i-1)+0.05]);
        end
        % Atur tata letak subplot
        suptitle('Analisis Dataset dan Evaluasi Model');
    end
end
