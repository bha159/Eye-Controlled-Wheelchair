function [a]=corner(a)
%Make Corners White.
%Input a binary image and make it corner white.
[l,w]=size(a);
if l>10 && w>10
    a(:,1:8)=255;
    a(:,end-8:end)=255;
    a(1:8,:)=255;
    a(end-8:end,:)=255;
else
    disp('Closed Eye Detected/Flickered Image Captured');
end