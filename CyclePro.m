% Platform-agnostic Gait Cycle Detection
% Author: Yuchao Ma (yuchao.ma@wsu.edu)

function numCycle = CyclePro(fname, freq)

%INPUT: load sensor signals from the given file "fname"
data = csvread(fname);

%STEP 1: compute signal vector magnitude (SVM) from uni-axial signals
svm = data(:,1) .^ 2;
for i = 2:size(data,2)
    svm = svm + data(:,i).^2;
end
svm = sqrt(svm);
L = length(svm);

%STEP 2: construct salience vector from SVM signal
salient = zeros(1,L);
for i = 1:L-1
    mi = 0;
    for j = i+1:L
        if svm(j) > svm(i)
            mi = mi+1;
        else
            break
        end
    end
    salient(i) = mi;
end

%STEP 3: find salient points based on consecutive distance
minPeak = [];
inxPeak = [];
for i = 1:L
    if salient(i) > floor((60 .* freq)/100)
        minPeak = [minPeak, salient(i)];
        inxPeak = [inxPeak, i];
    end
end
n = length(minPeak);

for i = 2:n
    if inxPeak(i) - inxPeak(i-1) < floor((60 .* freq)/100)
        inxPeak(i) = inxPeak(i-1);
        minPeak(i) = 0;
    end
end
minFinal = minPeak(minPeak > 0);
inxFinal = inxPeak(minPeak > 0);
minFinal(1) = [];
inxFinal(1) = [];

figure;
subplot(2,1,1);
plot(svm);
ylabel('input magnitude');
hold on
plot(inxFinal, svm(inxFinal), 'ro');
hold off
legend('SVM signal', 'salient points');

subplot(2,1,2);
plot(salient);
ylabel('salient value');
hold on
plot(inxFinal, minFinal, 'o');
hold off

%STEP 4: choose three templates of gait cycle from SVM signal
x = length(minFinal);
numList = 1:1:x;
if x > 4
    numList = numList(2:end-2);
    m = inxFinal(1)+1;
else
    numList = numList(1:end-1);
    m = 1;
end
diff = zeros(length(numList),3);

for i=1:length(numList)
    k = numList(i);
    if inxFinal(k) < 0 || inxFinal(k) > length(svm)
        break;
    end
    a = svm(m:inxFinal(k));
    minD = abs(min(a(1:3))) - abs(min(a(end-3:end)));
    diff(i,1) = (std(svm) - std(a))^2 + minD^2;
    diff(i,2) = m;
    diff(i,3) = inxFinal(k);
    m = inxFinal(k) + 1;
end
[value, index] = sort(diff(:,1),'ascend');
answer = floor(diff(index(1:3),2:3));

%STEP 5: compute the number of gait cycles and segmentation index on SVM
ps = [];
for i = 1:length(answer)
    temp = svm(answer(i,1):answer(i,2));
    corResult = correlation(temp, svm);
    [numOfPeak, Index] = newPeak(corResult, freq, svm);
    ps = [ps, numOfPeak];
    
end

numCycle = mode(ps);





