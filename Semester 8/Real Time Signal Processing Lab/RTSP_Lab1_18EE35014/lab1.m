
% using inbuilt functions

clear all;
G=[255 255 255 255 255 255 255 255;
   255 255 255 100 100 100 255 255;
   255 255 100 150 150 150 100 255;
   255 255 100 150 200 150 100 255;
   255 255 100 150 150 150 100 255;
   255 255 255 100 100 100 255 255;
   255 255 255 255 50 255 255 255;
   50 50 50 50 255 255 255 255;];

[U,S,V]=svd(G);
[U1,S1,V1]=svd(G.');
eig1=U(:,1)*S(1,1)*V(:,1)';
eig2=U(:,1:2)*S(1:2,1:2)*V(:,1:2)';
eig3=U(:,1:3)*S(1:3,1:3)*V(:,1:3)';
eig4=U(:,1:4)*S(1:4,1:4)*V(:,1:4)';
eig5=U(:,1:5)*S(1:5,1:5)*V(:,1:5)';
eig6=U(:,1:6)*S(1:6,1:6)*V(:,1:6)';

subplot(2,3,1);
image(G);
title("Original");
colormap(gray);

subplot(2,3,2);
image(eig1);
title("Top 1");
colormap(gray);

subplot(2,3,3);
image(eig2);
title("Top 2");
colormap(gray);

subplot(2,3,4);
image(eig3);
title("Top 3");
colormap(gray);

subplot(2,3,5);
image(eig4);
title("Top 4");
colormap(gray);

subplot(2,3,6);
image(eig5);
title("Top 5");
colormap(gray);

dist1=norm(G-eig1);
dist2=norm(G-eig2);
dist3=norm(G-eig3);
dist4=norm(G-eig4);
dist5=norm(G-eig5);
dist6=norm(G-eig6);
diffeigenrotate=norm(S-S1) % difference after rotating