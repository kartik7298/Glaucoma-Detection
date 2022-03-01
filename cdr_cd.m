clc;
clear all;
%optic nerve image
for N=1:20
 %preprocessing
image=(sprintf('r%d.jpg',N));
I=imresize(imread(sprintf('r%d.jpg',N)),[576 720]); imtool(I);
%ROI Detection
Bgray=imadjust(I(:, :, 3)) %imtool(Bgray);
bw=im2bw(Bgray,0.5);
bw = bwareaopen(bw,500);
s1 = regionprops(bw, Bgray, {'WeightedCentroid'});
figure; [X,Y,I2,rect] = imcrop(I); 
imshow(I2)

%------------------------------------Disk----------------------------------
%Image preprocessing
Rgray=imadjust(I2(:,:,1)); %figure; imshow(Rgray); %red channel & processing
bwr=im2bw(Rgray,0.8); bwr = bwareaopen(bwr,1100);% imshow(bwr);
s2 = regionprops(bwr, Rgray, {'WeightedCentroid'});
se = strel('square',30);
closeop = imclose(Rgray,se); %closing operation
%imtool(closeop);
fil=medfilt2(closeop,[5 5]); %imtool(fil); %median filter
edg=edge(fil,'sobel'); %imtool(edg); %edge detection & procesing
se = strel('disk',16);
bww = imclose(edg,se); %imshow(bww);
bww = imfill(bww,'holes');
%figure; imshow(bww);
ns = bwareaopen(bww, 6000);
figure; imshow(ns); 

%K mean clustering
[idx,ctrs] = kmeans(ns,1);
plot(edg(idx==1,1),edg(idx==1,2),'r.','MarkerSize',20)
plot(edg(idx==2,1),edg(idx==2,2),'b.','MarkerSize',20)
plot(ctrs(:,1),ctrs(:,2),'kx','MarkerSize',12,'LineWidth',2)
plot(ctrs(:,1),ctrs(:,2),'ko','MarkerSize',12,'LineWidth',2)
legend('Cluster 1','Cluster 2','Centroids','Location','NW') 

%Ellipse fitting
s3 = regionprops      (ns, 'Orientation', 'MajorAxisLength','MinorAxisLength', 'Eccentricity', 'Centroid','Area');
figure; imshow(I2); hold on
    phi = linspace(0,2*pi,50);
    cosphi = cos(phi);
    sinphi = sin(phi);
    for k = 1:length(s3)
        xbar = s3(k).Centroid(1);
        ybar = s3(k).Centroid(2);
        A_disk(N)=s3(k).Area;
        fprintf('Area of Disk for %d image is %f\n',N,A_disk(N));
        a = s3(k).MajorAxisLength/2;
        b = s3(k).MinorAxisLength/2;
        theta = pi*s3(k).Orientation/360;
        R = [ cos(theta)   sin(theta)
            -sin(theta)   cos(theta)];
        xy = [a*cosphi; b*sinphi];
        xy = R*xy;
        x = xy(1,:) + xbar;
        y = xy(2,:) + ybar;
        plot(x,y,'g','LineWidth',1);
    end 
    hold off

 %-----------------------------------Cup------------------------------------

%Image preprocessing
Ggray=imadjust(I2(:,:,2)); imtool(Ggray); %Green channel
 bin_img=im2bw(Ggray,0.7); %imtool(bin_img); %binarized image 
 se = strel('disk',5);
 opn=imopen(bin_img,se); %imtool(opn); 
 bww = bwareaopen(opn,500); imtool(bww); %morphological opening operation
 edg_c=edge(opn,'sobel'); %imtool(edg_c); %edge detection & processing
 s2 = regionprops      (bww, 'Orientation', 'MajorAxisLength','MinorAxisLength', 'Eccentricity', 'Centroid','Area');

 %preprocessing for cup smoothing
 figure; imshow(I2); hold on
    phi = linspace(0,2*pi);
    cosphi = cos(phi);
    sinphi = sin(phi);
    for k = 1:length(s2)
        xbar = s2(k).Centroid(1);
        ybar = s2(k).Centroid(2);
        A_cup(N)=s2(k).Area;
        fprintf('Area of CUP for %d image is %f\n',N,A_cup(N));
        a = s2(k).MajorAxisLength/2;
        b = s2(k).MinorAxisLength/2;
        theta = pi*s2(k).Orientation/360;
        R = [ cos(theta)   sin(theta)
            -sin(theta)   cos(theta)];
        xy = [a*cosphi; b*sinphi];
        xy = R*xy;
        x = xy(1,:) + xbar;
        y = xy(2,:) + ybar;
        plot(x,y,'b','LineWidth',1);
        centroid = s2(k).Centroid;
        plot(centroid(1),centroid(2),'k*');

    end
    hold off

%Initial points of Cup region
Img=double(Ggray(:,:,1));
timestep=1;  
mu=0.2/timestep;
iter_inner=5;
iter_outer=70;
lambda=5; 
alfa=-3;  
epsilon=1.5;

sigma=.8;   
G=fspecial('gaussian',15,sigma);
Img_smooth=conv2(Img,G,'same');  % smooth image by Gaussiin convolution
[Ix,Iy]=gradient(Img_smooth);
f=Ix.^2+Iy.^2;
g=1./(1+f);  % edge indicator function.

% initialize LSF as binary step function
c0=2;
initialLSF = c0*ones(size(Img));
%for k=1:length(s)
%if(length(s)==1) 
    initialLSF(s2(1).Centroid:s2(1).Centroid+15,s2(1).Centroid:s2(1).Centroid+7)=-c0; 
phi=initialLSF;

%Initial cup counter
figure(2);
imagesc(Img,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
title('Initial zero level contour');
pause(0.5);

potential=2;  
if potential ==1
    potentialFunction = 'single-well';  
elseif potential == 2
    potentialFunction = 'double-well';  
else
    potentialFunction = 'double-well';  
end  

% start level set evolution
for n=1:iter_outer
    phi = variational(phi, g, lambda, mu, alfa, epsilon, timestep, iter_inner, potentialFunction);    
    if mod(n,2)==0
        figure(2);
        imagesc(Img,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
    end
end

% refine the zero level contour by further level set evolution with alfa=0
alfa=0;
iter_refine = 10;
phi = variational(phi, g, lambda, mu, alfa, epsilon, timestep, iter_inner, potentialFunction);

%Cup boiundary smoothing
finalLSF=phi;
figure(2);
imagesc(Img,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
hold on;  contour(phi, [0,0], 'r');
str=['Final zero level contour, ', num2str(iter_outer*iter_inner+iter_refine), ' iterations'];
title(str);

CDR(N)=(A_cup(N)/A_disk(N));
fprintf('CDR of %d image is %f\n',N,CDR(N));
Per_CDR(N)=CDR(N)*100;
fprintf('CDR(Percentage) of %d image is %f\n',N,Per_CDR(N));
end

 figure; hold on 
 plot(Per_CDR,'o-'); title('Cup to Disk ratio');
xlabel('Images');
ylabel('CDR(Percentage)');