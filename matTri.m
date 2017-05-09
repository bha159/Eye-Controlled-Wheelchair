function [img]=matTri(img1)
%Trims Dark corners from a binary image.
%For images with illumination.
[H,L]=size(img1);
n=2.7;
l=floor(L/n);
r=floor(2*L/n);
%For Upper Part
for i=1:(ceil(H/n)+1)
    img1(i,1:l)=255;
    img1(i,r:end)=255;
    if r<L
        r=r+1;
    end
    if l>1
        l=l-1;
    end
end

r=L;
l=1;
%For Lower Part
for i=(ceil(2*H/n)-1):H
    img1(i,1:l)=255;
    img1(i,r:end)=255;
    if r>1
        r=r-1;
    end
    if l<=L
        l=l+1;
    end
end
img=img1;