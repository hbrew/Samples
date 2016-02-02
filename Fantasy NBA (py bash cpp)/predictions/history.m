addpath('export_fig/')

data = csvread('history.csv');
data = [[1:length(data)]', data];
wins = data(find(data(:,end) == 1), 1:3);
losses = data(find(data(:,end) == 0), 1:3);

figure
stem(wins(:,1), wins(:,2) - wins(:,3), 'b')
hold all
stem(losses(:,1), losses(:,2) - losses(:,3), 'r')
ylabel('Score Differential (Actual - Projected)')
xlabel('Contest')
title('Fanduel History')
legend('Wins', 'Losses')
export_fig('history.png')