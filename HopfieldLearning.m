close all
clear all
clc

%% Read image
% Define image location
digitDatasetPath = fullfile(pwd);

% Read inidividual file from a folder
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');

%% 
W = 0;
d = 120;
N = 8;

%% Read memory images and weight matrix
for i = 1:1:8
input = readimage(imds,i);
for j = 1:1:12
    for k = 1:1:10
        s(j+(k-1)*12,1) = double(input (j,k));
    end
end
    for j = 1:1:120
       if s(j) == 255
           s(j) = 1;
       else
           s(j) = -1;
       end
    end
    W = W + s*transpose(s);
end
for i = 1:1:120
   W (i,i) = 0; 
end

W = (1/d)*W - (N/d)*(eye(120));

%% Initial pattern
initial = readimage(imds,15);
for j = 1:1:12
    for k = 1:1:10
        x(j+(k-1)*12,1) = double(initial(j,k));
    end
end

for j = 1:1:120
    if x(j) == 255
        x(j) = 1;
    else
        x(j) = -1;
    end
end
    
o = x;

%% Iterations
iterations = 16;
for i = 1:1:iterations
    product = W*o;
    for j = 1:1:120
        if product (j) >= 0
            o(j) = 1;
        else
            o(j) = -1;
        end
    end
    for j = 1:1:120
        iterationstore (j,i) = o(j);
    end
end

for j = 1:1:12
    for k = 1:1:10
        output (j,k) = o(j+(k-1)*12,1);
    end
end

for i = 1:1:iterations
for j = 1:1:12
    for k = 1:1:10
        outputstore (j,k,i) = iterationstore(j+(k-1)*12,i);
    end
end
end


%% Plotting of figures
% Training data
figure (1)
for i = 1:1:8
        subplot (2,4,i), imshow (readimage(imds,i));
end
% Training precevied
figure (2)
for i = 1:1:8
        subplot (2,4,i), imshow (readimage(imds,i+8));
end
% Restoration
figure (3)
subplot (2,4,1), imshow (initial)
title ("Input image")
for i = 1:1:7
        subplot (2,4,i+1), imshow (outputstore(:,:,i));
        title (["After", num2str(i), "iterations"])
end

