clc;
clear all;
%optic nerve image
for N=1:2
 %preprocessing
% image=(sprintf('r%d.jpg',N));
I=imresize(imread(sprintf('kj.jpg',N)),[576 720]); imtool(I);
%ROI Detection
Bgray=imadjust(I(:, :, 3)) %imtool(Bgray);
bw=im2bw(Bgray,0.5);
bw = bwareaopen(bw,500);
s1 = regionprops(bw, Bgray, {'WeightedCentroid'});
figure; [X,Y,I2,rect] = imcrop(I); 
imshow(I2)

%------------------------------------Disk----------------------------------
%Image preprocessing
Rgray=imadjust(I2(:,:,1)); 
figure; imshow(Rgray); %red channel & processing
bwr=im2bw(Rgray,0.8); bwr = bwareaopen(bwr,1100);% imshow(bwr);
s2 = regionprops(bwr, Rgray, {'WeightedCentroid'});
se = strel('square',30);
closeop = imclose(Rgray,se); %closing operation
%imtool(closeop);
fil=medfilt2(closeop,[5 5]);
figure,imshow(fil);%imtool(fil); %median filter
edg=edge(fil,'sobel');
figure,imshow(edg);%imtool(edg); %edge detection & procesing
se = strel('disk',16);
bww = imclose(edg,se); %imshow(bww);
bww = imfill(bww,'holes');
figure; imshow(bww);
ns = bwareaopen(bww, 6000);
figure; imshow(ns); 
Ggray=I2(:,:,2); imtool(Ggray); %Green channel
 bin_img=im2bw(Ggray,0.7); imtool(bin_img);





end