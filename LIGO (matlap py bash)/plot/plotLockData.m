

transverse = 1:length(trans.power);

% figure('name', 'ETMX')
% pdPlot(itmx)
% mtit('ETMX')

% figure('name', 'ITMX')
% pdPlot(etmx)
% mtit('ITMX')

% figure('name', 'ETMY')
% pdPlot(itmy)
% mtit('ETMY')

% figure('name', 'ITMY')
% pdPlot(etmy)
% mtit('ITMY')

figure('name', 'Power')
hold all
plot(transverse, trans.power + trans.dP, 'g')
plot(transverse, trans.power - trans.dP, 'r')
plot(transverse, trans.power, 'b');
xlabel('Lock Number')
ylabel('Cavity Power (W)')
title('Cavity Power By Lock')
legend('+ Uncertainty', '- Uncertainty', 'Median During Full Lock')
grid on
hold off