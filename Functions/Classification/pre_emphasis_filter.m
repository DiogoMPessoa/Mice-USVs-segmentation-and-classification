function y_filt=pre_emphasis_filter(y,emphasis_factor)
pre = [0 emphasis_factor];
y_filt = filter(pre,1,y);