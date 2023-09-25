function [sensi,variation] = NLSD(net,input,output)
%% brief explanation
% NLSD takes the neural network, input data, and output data and derives the sensitivity of each input to output and variation of output caused by each input.
%% input
% net, data: row denotes each dimension, and column denotes each sample.
% num_segment: the number of segments between the origin and the data for reflecting nonlinearity of the model.
%% output
% variation: the variation of the output caused by each input in a sample.
% sensi: the sensitivity of each input to the output in each segment between the origin and the sample.
%% code
if varargin<4
    num_segment = 5;
end

input_interval = cell(1,size(input,2));
for i = 1:size(input,2)
    space = [];
    for j = 1:size(input,1)
        space(j,:) = 0:input(j,i)/num_segment:input(j,i);
    end
    input_interval{i} = space;
end

if varargout<2
    variation = cell(size(output,1),1);
    for o = 1:size(output,1)
        variation{o} = zeros(size(input));
        for i = 1:size(input,2)
            for j = 1:size(input,1)
                space2 = 0;
                for k = 1:num_segment
                    space = [input_interval{i}(:,k) input_interval{i}(:,k) input_interval{i}(:,k+1) input_interval{i}(:,k+1)];
                    space(j,2) = space(j,3); space(j,3) = space(j,1);
                    space2 = space2 + (net(space(:,2)) - net(space(:,1)) + net(space(:,4)) - net(space(:,3)))/2;
                end
                variation{o}(j,i) = space2;
            end
        end
    end
else
    variation = cell(size(output,1),1); sensi = cell(size(output,1),1);
    for o = 1:size(output,1)
        variation{o} = zeros(size(input)); sensi{o} = cell(1,size(input,2));
        for i = 1:size(input,2)
            for j = 1:size(input,1)
                space2 = 0;
                for k = 1:num_segment
                    space = [input_interval{i}(:,k) input_interval{i}(:,k) input_interval{i}(:,k+1) input_interval{i}(:,k+1)];
                    space(j,2) = space(j,3); space(j,3) = space(j,1);
                    sensi{o}{i}(j,k) = (net(space(:,2)) - net(space(:,1)) + net(space(:,4)) - net(space(:,3)))/2;
                    space2 = space2 + sensi{o}{i}(j,k);
                end
                variation{o}(j,i) = space2;
            end
        end
    end
end

end
