% Objective: filter out invalid peaks to finalize the repetition of gait
% cycles according to the result of cross-correlation
% Author: Yuchao Ma (yuchao.ma@wsu.edu)

function [minNum, finalI] = newPeak(signal, s, svm)
L = length(signal);

tempPeak = [];
tempIndex = [];
for i = 2:L-1
    if signal(i) > signal(i-1) && signal(i) > signal(i+1)
        tempPeak = [tempPeak, signal(i)];
        tempIndex = [tempIndex, i];
    end
end
n = length(tempPeak);
eliminateP = 0;
i = 1;
n = n-1;
while i < n
    j = i+1;
    maxT = tempPeak(i);
    maxI = i;
    while ( j <= n && tempIndex(j) - tempIndex(i) < floor((60.*s)/100))
        if maxT <= tempPeak(j)
            maxT = tempPeak(j);
            tempPeak(maxI) = 0;
            eliminateP = eliminateP+1;
            maxI = j;
        else
            tempPeak(j) = 0;
            eliminateP = eliminateP + 1;
        end 
        j = j+1;
    end
    i = j;
end

tPeak = [];
tIndex = [];
for i = 1:n
    if tempPeak(i) > 0
        tPeak = [tPeak, tempPeak(i)];
        tIndex = [tIndex, tempIndex(i)];
    end
end
k = length(tPeak);

value = tPeak(1);
in = tIndex(1);
for i = 2:k
    if tIndex(i) - in < floor((60.*s)/70)
        if tPeak(i) > value
            value = tPeak(i);
            in = tIndex(i);
            tPeak(i-1) = 0;
        else
            value = tPeak(i-1);
            in = tIndex(i-1);
            tPeak(i) = 0;
        end
    else
        in = tIndex(i);
        value = tPeak(i);
    end
end
          
Peak = [];
Index = [];
for i = 1:k
    if tPeak(i) > 0
        Peak = [Peak, tPeak(i)];
        Index = [Index, tIndex(i)];
    end
end
p = length(Peak);
L = length(Index);
valInd = zeros(1,L-1);
valVal = zeros(1,L-1);
for i=1:L-1
    valVal(i) = min(signal(Index(i):Index(i+1)));
    valInd(i) = find(signal(Index(i):Index(i+1)) == valVal(i),1)+Index(i)-1;
end

valueBar = min(valVal);
[value,index] = sort(Peak,'descend');
valueTemp = [value,valueBar];
indexTemp = [index,p+1];
minV = var(valueTemp);
minNum = 1;

for i=1:p
    if var(valueTemp(1:i))+var(valueTemp(i+1:end)) <= minV
        minV = var(valueTemp(1:i))+var(valueTemp(i+1:end));
        minNum = i;
    end
end

finalP = zeros(minNum,1);
finalI = zeros(minNum,1);
for j = 1:minNum
    finalP(j) = Peak(indexTemp(j));
    finalI(j) = Index(indexTemp(j));
end

if minNum < p
    deNum = p-minNum;
    deleteP = zeros(deNum,1);
    deleteI = zeros(deNum,1);
    for j=minNum+1:p
        deleteP(j-minNum) = Peak(indexTemp(j));
        deleteI(j-minNum) = Index(indexTemp(j));
    end
else
    deleteP = [];
    deleteI = [];
end

figure;
subplot(2,1,1);
plot(svm);
title('Signal Vector Magnitude of Input');
ylabel('magnitude');
hold on
plot(finalI, svm(finalI), 'o','MarkerSize',8);
hold off
legend('SVM signal', 'segment point');

subplot(2,1,2);
plot(signal);
title('Peak Detection Using Template');
ylabel('cross-correlation');
hold on
plot(finalI,finalP,'ro','MarkerSize',8);
plot(deleteI,deleteP,'m*','MarkerSize',10);
plot(valInd,valVal,'ko','MarkerSize',8);
hold off
if ~isempty(deleteI)
    legend('sequence', 'peak', 'removed', 'valley');
else
    legend('sequence', 'peak', 'valley');
end

