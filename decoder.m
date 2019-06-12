function decoder(arquivo,duracao,silencio)
%% Detection returns the dialed numbers in an audio file, in addition to 
% displaying the graph in the time domain for checking, spectral analysis
% and the Fourier transform of the signal.

% Alunos: Igor Bonato Matricardi

% Function Call - Ex: Decoder('touchtone.wav',0.2,0.15);
% arquivo - Name of the file in the folder to be read;
% duracao - Time in seconds of each tone of the signal;
% silencio - Time in seconds of silence between each tone.

%% Reading the .wav file
[x,fs]=audioread(arquivo);

%% Time domain graph
tplot = (0:1/fs:(length(x)-1)/fs); % Tempo para a plotagem do gráfico
figure(1)
plot(tplot,x);
grid on
set(gca,'FontSize',10)
title('Sinal no domínio do Tempo')
xlabel('$t(s)$','Interpreter','LaTex','FontSize',12)
ylabel('$Amplitude$','Interpreter','LaTex','FontSize',12)
legend('Sinal DTMF')

%% DTMF signal 3D spectrogram
[S,F,T] = spectrogram(x, 1536, 64, 512, fs);

Fm = repmat(F, 1, length(T));
Tm = repmat(T, length(F), 1);
figure(2)
surf(Fm, Tm, abs(S))
grid on
title('Espectrograma do Sinal DTMF')
xlabel('Frequência')
ylabel('Tempo')
axis([0  2000    ylim    zlim])

Nfft = 2^nextpow2(length(x));
Fsinal = fft(x,Nfft);
f = fs/2*linspace(0,1,Nfft/2+1);
mag = 2*abs(Fsinal(1:Nfft/2+1));

%% Spectral Analysis

figure(3)
plot(f,mag);
grid on
set(gca,'FontSize',10)
title('Análise Espectral')
xlabel('$f(Hz)$','Interpreter','LaTex','FontSize',12)
ylabel('$|X(f)|$','Interpreter','LaTex','FontSize',12)
legend('Espectro de Frequência')
xlim([0 2000])

indice = (duracao/(1/fs)) + (silencio/(1/fs)); % Calculates the cutoff index according to the duration of each sound and silence

a = 1;                                      % First index for signal cut. Will be evaluated digit by digit
for b=indice:indice:length(x)               % Go through the signal. Second cutting index
    y = x(a:b);                             % Signal cut from the first index to the second
    
    freqHz = (0:1:length(abs(fft(y)))-1)*fs/length(y);  % Signal frequency axis.
    amp = abs(fft(y));                                  % Signal amplitude axis. Absolute values of the Fourier transform of the signal cut
    
    [p,l] = findpeaks(amp,freqHz,'MinPeakHeight',200,'MinPeakDistance',50);     % Find the peaks of the signal with minimum height of 200 and minimum distance of 50. Values were obtained in the previous plot
    
    fa = l(1);                                          % Fa is the frequency of the first peak found
    fb = l(2);                                          % Fb is the frequency of the second peak found
    
    if fa<=720 && fb<=1250
       disp('Tecla discada: 1')
       elseif fa<=720 && fb<=1400
          disp('Tecla discada: 2')
       elseif fa<=720 && fb<=1400
          disp('Tecla discada: 3')
       elseif fa<=810 && fb<=1250  
          disp('Tecla discada: 4')
       elseif fa<=810 && fb<=1400
          disp('Tecla discada: 5')
       elseif fa<=810 && fb<=1500
          disp('Tecla discada: 6')
       elseif fa<=900 && fb<=1250
          disp('Tecla discada: 7')
       elseif fa<=900 && fb<=1400
          disp('Tecla discada: 8')
       elseif fa<=900 && fb<=1500
          disp('Tecla discada: 9')
       elseif fa>900 && fb<=1250  
          disp('Tecla discada: *')
       elseif fa>900 && fb<=1400 
          disp('Tecla discada: 0')
       elseif fa>900 && fb<=1500 
          disp('Tecla discada: #')
    end                                                 % Check with the table the dialed key, from the frequencies found
                                        
    a = a + indice;                                     % Go to the next signal cut
end                                                     % END