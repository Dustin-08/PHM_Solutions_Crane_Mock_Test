function plot3d(features,labels)
max_labels = max(labels);
for i=0:max_labels
    plot3(features(labels==i, 1), features(labels==i, 2),features(labels==i, 3), 'o');
    hold on;
end
grid on;
hold off;
