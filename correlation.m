% Objective: normalized cross-correlation between a segment and the entire
% array.
% Author: Yuchao Ma (yuchao.ma@wsu.edu)

function cor = correlation(window, ary)
lw = length(window);
la = length(ary);
raw_cor = zeros(1,la-lw+1);
lastP = la-lw+1;

for i = 1:lastP
    aryInWindow = ary(i:(i+lw-1));
    score = sum(times(window,aryInWindow));
    raw_cor(i) = score;
end
cor = raw_cor/(max(abs(raw_cor)));