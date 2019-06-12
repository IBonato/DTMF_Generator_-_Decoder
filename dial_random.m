function dial_random(teclas,fs)
%% Dial generates a vector containing the signal of the specified tones plus a white noise, 
% in addition to the time domain graph for assessment, spectral analysis and
% playback of the sound along with its output file 'seqDTMF.wav'.

% Author: Igor Bonato Matricardi

% Function Call - Ex: dial_random('1234567890',20000);
% teclas - character vector containing the keys used in the DTMF tone table;
% fs - Sampling frequency.
 
sinal = 0; % Declaration of the variable "GLOBAL"
d = 0.2; % 200ms tone length
s = (d/(1/fs))/4; % Duration of silence always being 1/4 of 'd' or 50ms
n = 0:(d/(1/fs)); % Vector n - pulse length
%% DTMF tone table

tom.tecla = ['1','2','3','A';
             '4','5','6','B';
             '7','8','9','C';
             '*','0','#','D'];

%% Matrices of correspondence: Frequency - Digits

DTMF.colunaTom = ones(4,1)*[1209,1336,1477,1633];
DTMF.linhaTom = [697;770;852;941]*ones(1,4);

% Time specification between each tone (zeros vector)
silencio = zeros(1, s);

for i = 1:length(teclas) % For que percorre cada uma das teclas inseridas
  
    sinal = [sinal silencio]; % Sinal recebe o tempo silêncio entre cada tecla

    if(any(any(teclas(i) == tom.tecla))) % Se a tecla inserida for encontrada

        [jlinha,jcoluna] = find(teclas(i) == tom.tecla); % jlinha e jcoluna 
        % recebem a posição da tecla na matriz tom,tecla
    else
        error('Essa tecla não existe!') % If the user enters a key that does not exist
    end % Fim do IF

    onda = sin((2*pi*DTMF.linhaTom(jlinha,jcoluna)*n)/fs) + cos((2*pi*DTMF.colunaTom(jlinha,jcoluna)*n)/fs); % Equação do DTMF
    
    sinal = [sinal onda]; % The previous signal receives the sum of itself with the current tone

end % Fim do FOR

sinal = [sinal silencio]; % The signal again receives silence after the sequence
sinal = sinal/max(abs(sinal(:))); % Normalizes the signal so that its maximum value is 1

s_random = sinal + randn(1, length(sinal))*0.03; % Adding a Gaussian (white) noise to the signal

soundsc(s_random, fs); % Função que reproduz o sinal gerado de acordo com fs

%% Time Domain

tplot = (0:1/fs:(length(s_random)-1)/fs); % Tempo para a plotagem do gráfico
figure(1)
plot(tplot,s_random);
grid on
set(gca,'FontSize',10)
title('Sinal no domínio do Tempo')
xlabel('$t(s)$','Interpreter','LaTex','FontSize',12)
ylabel('$Amplitude$','Interpreter','LaTex','FontSize',12)
legend('Sinal DTMF')

%% Spectral Analysis

Nfft = 2^nextpow2(length(s_random));
Fsinal = fft(s_random,Nfft);
f = fs/2*linspace(0,1,Nfft/2+1);
mag = 2*abs(Fsinal(1:Nfft/2+1));

figure(2)
plot(f,mag);
grid on
set(gca,'FontSize',10)
title('Análise Espectral')
xlabel('$f(Hz)$','Interpreter','LaTex','FontSize',12)
ylabel('$|X(f)|$','Interpreter','LaTex','FontSize',12)
legend('Espectro de Frequência')
xlim([0 2000])

audiowrite('seqrDTMF.wav',s_random, fs); % Function that creates an audio file with the generated signal