tic

[i11,i12]=uigetfile('*.*');%XXXXXX Input Image XXXXXXXXXXX

i12=strcat(i12,i11);

im2=imread(i12);

% im12=imread('1.jpg');

im=imresize(im2,[400 400]);

im1=im(:,:,1);

z=input('Select the key for Image Encryption ') ;

z1=z;

% im1=rgb2gray(im);

% im1=medfilt2(im1,[3 3]);

% figure(1);

subplot(2,2,1);imshow(im);

title('Input Image');

im2=double(im1);

[M,N]=size(im2);

e=hundungen(M,N,0.1);

tt=0.001;

im3=mod(tt*im2+(1-tt)*e,256);

a1(:,:,1)=round(im3(:,:,1));a1(:,:,2)=im(:,:,2);a1(:,:,3)=im(:,:,3);

for i=1:400

for j=1:400

a1(i,j,1)=bitxor (a1(i,j,3),a1(i,j,1));

a1(i,j,2)=bitxor (a1(i,j,1),a1(i,j,2));

a1(i,j,3)=bitxor (a1(i,j,2),a1(i,j,3));

end

end

for i=1:400

for j=1:400

a1(i,j,1)=bitxor (a1(i,j,3),a1(i,j,2));

a1(i,j,2)=bitxor (a1(i,j,1),a1(i,j,3));

a1(i,j,3)=bitxor (a1(i,j,2),a1(i,j,1));

end

end

% for i=1:400

% for j=1:400

% a1(i,j,1)=mod((a1(i,j,3)+a1(i,j,1)),255);

% a1(i,j,2)=mod((a1(i,j,1)+a1(i,j,2)),255);

% a1(i,j,3)=mod((a1(i,j,2)+a1(i,j,3)),255);

% %

% end

% end

% for i=1:400

% for j=1:400

% a1(i,j,1)=mod((a1(i,j,2)+a1(i,j,3)),255);

% a1(i,j,2)=mod((a1(i,j,3)+a1(i,j,1)),255);

% a1(i,j,3)=mod((a1(i,j,1)+a1(i,j,2)),255);

% %

% end

% end

% figure(2);

subplot(2,2,2);imshow(uint8(a1),[]);

title('Encrypted Image');

toc