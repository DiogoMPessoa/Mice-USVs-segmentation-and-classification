function y_filt=filter_signal(y,Fs,cut_freq)

order = 20;
wc = cut_freq; %cut-off frequency
fc = wc / (0.5 * Fs);
[b, a]=butter(order, fc,'high');
y_filt = filter (b, a, y);

