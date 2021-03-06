function GenerateSubGeonetData(path_g_mask, path_r_line, path_b_gray, path_result, path_result_png)
%path_g_mask ='D:\Desktop\test\mask\*.png';
%path_r_line ='D:\Desktop\test\line';
%path_b_/gray ='D:\Desktop\test\gray';

%path_result = 'D:\Desktop\test\test\';

imageDir_mask = dir([path_g_mask '*.png']);
imageDir_gray = dir(path_b_gray);

errorList = [];
% if length(imageDir_mask) ~= length(imageDir_gray)
%     disp('error Image number!')
% end

parfor i = 1:length(imageDir_mask)
    i
    img_result = uint8([]);
    img_g_mask = imread(fullfile(imageDir_mask(i).folder, imageDir_mask(i).name));
    if (~exist(fullfile(path_r_line, [imageDir_mask(i).name(1:end-4) '.png']), 'file'))
        errorList = [errorList; imageDir_mask(i).name];
    end
    
    img_r_line = imread(fullfile(path_r_line, [imageDir_mask(i).name(1:end-4) '.png']));
    img_b_gray = imread(fullfile(path_b_gray, [imageDir_mask(i).name(1:end-4) '.png']));
    sizeMask = size(img_g_mask);
    if(~all(size(img_r_line)==sizeMask(1:2)))
        disp('error !!!');
    end
    [labels, label_maps] = getAllInstance(img_g_mask);
    for j = 1:size(labels,1)
        img_result(:,:,1) = img_r_line;
        img_result(:,:,2) = label_maps(:,:,j);
        img_result(:,:,3) = img_b_gray;
        imwrite(img_result,[path_result imageDir_mask(i).name(1:end-4) '_' num2str(labels(j,1)) '_' num2str(labels(j,2)) '_' num2str(labels(j,3)) '.jpg']); 
        img_result(:,:,1) = label_maps(:,:,j);
        img_result(:,:,2) = label_maps(:,:,j);
        img_result(:,:,3) = label_maps(:,:,j);
        imwrite(img_result,[path_result_png imageDir_mask(i).name(1:end-4) '_' num2str(labels(j,1)) '_' num2str(labels(j,2)) '_' num2str(labels(j,3)) '.png']);
    end
end
end

function saveImg(img,path, name, ext, count)
if(count ~= 0)
    imwrite(img,[path '\' [name(1:end-4) ext '.png']]);
end
end

function color = getNewColor(label)
if label(2)==0 && label(3)==255   % cubo
    color = 50;
elseif label(2)~=0 && label(3)==255   % cufa
    color = 100;
elseif label(2)==0 && label(3)==200   % cybo
    color = 150;
elseif label(2)~=0 && label(3)==200   % cyfa
    color = 200;
elseif label(2)==0 && label(3)==150   % grip
    color = 250;
end
end

function [labels, label_maps] = getAllInstance(seg)
labels = [];
label_maps = uint8(zeros(size(seg,1), size(seg,2)));
for r = 1:size(seg,1)
    for c = 1:size(seg,2)
        if ~all([seg(r,c,1) seg(r,c,2) seg(r,c,3)]==[0 0 0])
            if isempty(labels) || ~m_ismember(labels,[seg(r,c,1) seg(r,c,2) seg(r,c,3)])
                labels =[labels; seg(r,c,1) seg(r,c,2) seg(r,c,3)];
                RowCols = FindIndexOfColor(seg, labels(end,:));
                label_map = uint8(zeros(size(seg,1), size(seg,2)));
                label_map(RowCols) = getNewColor(labels(end,:));
                label_maps(:,:,size(labels,1)) = label_map;
            end
        end
    end
end
end

function RowCols = FindIndexOfColor(seg, color)
RowCols = [];
for r = 1:size(seg,1)
    for c = 1:size(seg,2)
        if all([seg(r,c,1) seg(r,c,2) seg(r,c,3)]==color)
            RowCols = [RowCols, (c-1)*size(seg,1) + r];
        end
    end
end
end

function m_flag = m_ismember(labels, color)
for i = 1:size(labels, 1)
    if all(labels(i,:)==color)
        m_flag = true;
        return
    end    
end
m_flag = false;
end