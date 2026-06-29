clc; clear; close all;

[X, Y] = meshgrid(-8:0.2:8, -8:0.2:8);
Z = sin(sqrt(X.^2 + Y.^2));

figure(1);
mesh(X, Y, Z);
title('mesh 绘图：z = sin(\surdx^2+y^2)');
xlabel('X'); ylabel('Y'); zlabel('Z');
colormap(jet);
colorbar;
view(40, 35);

figure(2);
surf(X, Y, Z);
shading interp; 
title('surf 绘图：z = sin(\surdx^2+y^2)');
xlabel('X'); ylabel('Y'); zlabel('Z');
colormap(parula); 
colorbar;
view(40, 35);

figure(3);
s = surf(X, Y, Z);
shading interp;
colormap(hsv);
colorbar;
title('三维曲面动态旋转视角');
xlabel('X'); ylabel('Y'); zlabel('Z');

for az = 0 : 3 : 357
    view(az, 30);   
    drawnow;        
    pause(0.04);      
end