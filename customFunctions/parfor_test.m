%% Apply a function to each row of an input matrix, in a parallel loop

%% Boilerlplate
clear all; close all; clc; %#ok

%% Params
nrow = 100000;
ncol = 10000;
input = rand(nrow,ncol);

output_col = length(custFunc(input(1,:))); % get expected output length per row

%% Main
output = NaN(nrow,output_col);
parfor i = 1:nrow
    output(i,:) = custFunc(input(i,:));   
end

%% Plot
figure();
plot(1:nrow,output,'-b');
xlim([0 nrow+1]); ylim([0 1]);

%% End
disp('Done!');

%% Functions
function y = custFunc(x)
    %% Whatever the function to apply to each row of input x is.
    y = mean(mean(reshape(x,100,100)));
end