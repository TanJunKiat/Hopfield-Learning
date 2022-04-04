close all
clear all
clc

%% Read image
% Define image location
digitDatasetPath = fullfile(pwd);

% Read inidividual file from a folder
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');

[h, w, d] = size(readimage(imds,1));

%% Initialisation
W = 0;              % Weight matrix
d = h*w;            % Effective pixel ( H x W )
N = 8;              % Number of training images

%% Read memory images and weight matrix
for i = 1:N
input = readimage(imds,i);          % Reading image

s = reshape(double(input(:,:,1)),[],1);         % Reshaping into a vector
s = s./127.5 - 1;                               % Normalisation
W = W + s*transpose(s);                         % Self-addition of weight matrix
end

W = W - diag(diag(W));
W = (1/d)*W - (N/d)*(eye(d));

%% Corrupted pattern for testing
initial = readimage(imds,14);                   % Reads corrupted image
x = reshape(double(initial(:,:,1)),[],1);       % Reshaping into a vector
x = x./127.5 - 1;                               % Normalisation

%% Iterations
o = x;                                          % Initialising output
iterations = 16;                                % Number of iterations
for i = 1:iterations
    product = W*o;                              % Calculating neuron outputs
    o(find(product>=0)) = 1;                    % Digitizing output
    o(find(product<0)) = -1;                    % Digitizing output
    iterationstore(:,i) = o;                    % Storing output
end

outputstore = reshape(iterationstore(:,:,1),h,w,iterations);    % Restoring output vector as 2D image

%% Plotting of figures
% Plotting of training data
figure (1)
for i = 1:8
        subplot (2,4,i), imshow (readimage(imds,i));
end

% Plotting of network's interpretation of training data
figure (2)
for i = 1:8
        subplot (2,4,i), imshow (readimage(imds,i+8));
end

% Plotting of image restoration iterations
figure (3)
subplot (2,4,1), imshow (initial)
title ("Input image")
for i = 1:7
        subplot (2,4,i+1), imshow (outputstore(:,:,i));
        title (["After", num2str(i), "iterations"])
end



