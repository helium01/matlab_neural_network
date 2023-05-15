function sensor_gui()
    % Membuat GUI
    f = figure('Visible','off','Position',[360,500,450,285]);

    % Membuat panel untuk menampilkan plot data
    plot_panel = uipanel(f,'Title','Data Plot','Position',[0.05,0.2,0.7,0.75]);
    axes_handle = axes('Parent', plot_panel);

    % Membuat tombol push untuk memulai prediksi
    hButton = uicontrol('Parent', f, 'Style', 'pushbutton', 'String', 'Mulai Prediksi', 'Units', 'normalized', 'Position', [0.7 0.2 0.2 0.2], 'Callback', @onButtonClick);
    
    
    % Membuat tombol untuk mengambil data
    data_button = uicontrol(f,'Style','pushbutton','String','Ambil Data',...
        'Position',[315,220,100,25],'Callback',{@ambil_data_callback});

    % Membuat tombol untuk menyimpan dataset
    save_button = uicontrol(f,'Style','pushbutton','String','Simpan Dataset',...
        'Position',[315,170,100,25],'Callback',{@simpan_dataset_callback});

    % Membuat edit box untuk input label
    label_edit = uicontrol(f,'Style','edit','Position',[315,120,100,25]);

    % Membuat teks untuk label
    label_text = uicontrol(f,'Style','text','String','Label',...
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
        jumlah_sampel = 1000;
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
            label(i) = str2double(label_edit.String);

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

    % Callback untuk tombol simpan dataset
    function simpan_dataset_callback(source, event)
        % Simpan dataset ke dalam file .mat
        dataset = horzcat(data, label);
        save('dataset2.mat', 'dataset');
        msgbox('Dataset berhasil disimpan!');
    end
    
    function onButtonClick(~, ~)
        % Inisialisasi objek Arduino
      
            
            a = arduino('COM17', 'Uno');
            % Persiapkan model neural network
            net = feedforwardnet([10 20 5]);

            % Inisialisasi bobot dan bias secara acak
            net = init(net);
            % Tentukan opsi pelatihan model
            net.trainParam.epochs = 100;
            net.trainParam.goal = 0.01;

            % Pisahkan dataset menjadi data pelatihan dan data pengujian
            load('dataset2.mat');
            data = dataset(:, 1:3);
            label = dataset(:, 4);
            trainData = data(1:80,:);
            trainLabel = label(1:80,:);
            testData = data(81:end,:);
            testLabel = label(81:end,:);

            % Mulai proses pelatihan
            [net,tr] = train(net,trainData',trainLabel');
            % Tampilkan hasil balasan
            disp(tr);

            % Baca data dari sensor
            mq5Value = readVoltage(a, 'A5');
            mq135Value = readVoltage(a, 'A4');
            mq2Value = readVoltage(a, 'A1');

            % Lakukan prediksi dengan menggunakan model
            sensorData = [mq5Value; mq135Value; mq2Value];
            prediction = net(sensorData);

            % Tampilkan hasil prediksi
            if(prediction<0.5)
                hasil="beras dalam keadaan baik";
            else
                hasil="beras dalam keadaan buruk";
            end
            hText = uicontrol('Parent', f, 'Style', 'text', 'String', hasil, 'Units', 'normalized', 'Position', [0.0 0.0 0.9 0.2]);
       
     end
end