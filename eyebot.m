function []=eyebot(url,varargin)
% eyebot Function detect eyes movement and passes that data via Bluetooth.
% eyebot(URL) takes URL of IP-Cam in http,sttp or other protocols.
% Only URL is required, if given more than one argument, function exits
% with error.
%
% Copyright 2016-"Until World Ends" 

if(nargin > 1)
    error('Too many arguments, Only URL required.');
end
%To make sure just one input is given as url.
url=[url '/video'];
%Picks ipcam url to live stream video
webcam=ipcam(url);  %webcam named object created
savepath = 'D:\Minor';  %save path
imageNum = 0;        %starting image number
%Intializing Bluetooth
b=instrhwinfo('Bluetooth');
b.RemoteNames
bt=Bluetooth('HC-05',1);
fopen(bt);
%Calibration Code
disp('Clabirating threshold for face');
thr_temp=0;
thl_temp=0;
    
for i=1:1:5
    %Reading Image 
    img=snapshot(webcam);
    img=rgb2gray(img);
    img=imadjust(img);
    img=adapthisteq(img);
    thl=6;
    thr=6;
    th_flag=0;
    while(th_flag~=1)
        %Creating Object Using Voila-Jones Algorithm for detecting Eyes
        leye=vision.CascadeObjectDetector('LeftEyeCART','MergeThreshold',thl);
        lbox=step(leye,img);
        reye=vision.CascadeObjectDetector('RightEyeCART','MergeThreshold',thr);
        rbox=step(reye,img);
        %Checking for set Threshold
        if( isequal(size(lbox),[1 4]) && isequal(size(rbox),[1 4]) )
            th_flag=1;
        else
            if( isequal(size(lbox),[1 4]) && ~isequal(size(rbox),[1 4]) )
                thr=thr+2;
            else
                if( ~isequal(size(lbox),[1 4]) && isequal(size(rbox),[1 4]) )
                    thl=thl+2;
                else
                    if( ~isequal(size(lbox),[1 4]) && ~isequal(size(rbox),[1 4]) )
                        thl=thl+2;
                        thr=thr+2;
                    end
                end
            end
        end
    end
    t=i*20;
    temp=num2str(t);
    str=[temp '% Completed'];
    disp(str);
    thr_temp=thr_temp+thr;
    thl_temp=thl_temp+thl;
end
disp('Face Calibrated, Dont move camera now');
thr=ceil(thr_temp/5);
thl=ceil(thl_temp/5);
stop=0;

while(1)
    %Reading Image 
    img=snapshot(webcam);
    img=rgb2gray(img);
    img=imadjust(img);
    img=adapthisteq(img);
    %Creating Object Using Voila-Jones Algorithm for detecting Eyes
    leye=vision.CascadeObjectDetector('LeftEyeCART','MergeThreshold',thl);
    lbox=step(leye,img);
    reye=vision.CascadeObjectDetector('RightEyeCART','MergeThreshold',thr);
    rbox=step(reye,img);
    %Checking If Eyes Detected
    lcheck=isempty(lbox);
    rcheck=isempty(rbox);
    if(lcheck==1 && rcheck==1)
        disp('================No Eyes Detected======================');
        disp('================Postion Camera Correctly==============');
		stop=stop+1;
		%Stopping
		if stop==3
			disp('Stoping Since No Activity for more than 3 seconds');
			break;
		end
		
        continue;
    end
	
    %Cropping only correct eye
    if( isequal(size(lbox),[1 4]) && isequal(size(rbox),[1 4]) )
		lI=img(lbox(2)+ceil(lbox(4)/2.7):lbox(2)+lbox(4)-10,lbox(1)+ceil(lbox(3)/8):lbox(1)+lbox(3)-ceil(lbox(3)/7));
        lI=imbinarize(lI,0.15);
        imageNum = imageNum + 1;
        savename = 'image_%04dl.jpeg';  %name pattern
        fileName = sprintf(savename, imageNum);  %create filename
        path = [savepath '/' fileName];  %folder and all
        if(~isempty(lI))
            imwrite(lI, path);  %write the original binary image
        end
        lI=corner(lI);
        lI=matTri(lI);
        lI=imcomplement(lI);
        lI=erode(lI);
        savename = 'image_%04d.jpeg';  %name pattern
        fileName = sprintf(savename, imageNum);  %create filename
        path = [savepath '/' fileName];  %folder and all
        imwrite(lI, path);  %write the complemented binary image
        rI=img(rbox(2)+ceil(lbox(4)/2.4):rbox(2)+rbox(4)-10,rbox(1)+ceil(lbox(3)/8):rbox(1)+rbox(3)-ceil(lbox(3)/7));
        rI=imbinarize(rI,0.15);
        imageNum = imageNum + 1;
        savename = 'image_%04dr.jpeg';  %name pattern
        fileName = sprintf(savename, imageNum);  %create filename
        path = [savepath '/' fileName];  %folder and all
        if(~isempty(rI))
            imwrite(rI,path); %Write original binary image
        end
        rI=corner(rI);
        rI=matTri(rI);
        rI=imcomplement(rI);
        rI=erode(rI);
        savename = 'image_%04d.jpeg';  %name pattern
        fileName = sprintf(savename, imageNum);  %create filename
        path = [savepath '/' fileName];  %folder and all
        imwrite(rI,path); %Write complemented binary image
        %Movement Detection
        [~,wl]=size(lI);
        [~,wr]=size(rI);
        l=min(wl,wr);
        lsumm=zeros([1 l]);
        rsumm=zeros([1 l]);
        for i=1:l
            lsumm(i)=sum(lI(:,i));
            rsumm(i)=sum(rI(:,i));
        end

        [~,lindex]=max(lsumm);
        [~,rindex]=max(rsumm);
        %Left Or Right
        index=ceil((1.3*lindex+0.7*rindex)/2);
        if isempty(index)
            fwrite(bt,uint8(2));
            fwrite(bt,120);
            continue;
        end

        if index<(l/2.7)
            disp(['Left=' num2str(index)])
            fwrite(bt,uint8(1));
            fwrite(bt,index);
        else
            if (index>ceil((l/2.7)) && index<ceil((2*l/3)))
                disp(['Straight=' num2str(index)])
                fwrite(bt,uint8(2));
                fwrite(bt,index);
            else
                if index>floor((2*l/3))
                    disp(['Right=' num2str(index)])
                    fwrite(bt,uint8(3));
                    fwrite(bt,index);
                else
                    disp('Closed Eye detected');
                end
            end
        end
    %Checking just right eye       
	else
        if( isequal(size(rbox),[1 4]) )
            rI=img(rbox(2)+ceil(lbox(4)/2.4):rbox(2)+rbox(4)-10,rbox(1)+ceil(lbox(3)/8):rbox(1)+rbox(3)-ceil(lbox(3)/7));
            rI=imbinarize(rI,0.15);
            imageNum = imageNum + 1;
            savename = 'image_%04dr.jpeg';  %name pattern
            fileName = sprintf(savename, imageNum);  %create filename
            path = [savepath '/' fileName];  %folder and all
            if(~isempty(rI))
                imwrite(rI,path);
            end
            rI=corner(rI);
            rI=matTri(rI);
            rI=imcomplement(rI);
            rI=erode(rI);
            savename = 'image_%04d.jpeg';  %name pattern
            fileName = sprintf(savename, imageNum);  %create filename
            path = [savepath '/' fileName];  %folder and all
            if(~isempty(rI))
                imwrite(rI,path);
            end
            %Movement Detection
            [~,l]=size(rI);
            summ=zeros([1 l]);
            for i=1:l
                summ(i)=sum(rI(:,i));
            end
            %Left Or Right
            [~,index]=max(summ);
            if isempty(index)
                fwrite(bt,uint8(2));
                fwrite(bt,120);
                continue;
            end
            if index<ceil((l/2.7))
                disp(['Left=' num2str(index)])
                fwrite(bt,uint8(1));
                fwrite(bt,index);
            else
                if (index>ceil((l/2.7)) && index<ceil((2*l/3)))
                    disp(['Straight=' num2str(index)])
                    fwrite(bt,uint8(2));
                    fwrite(bt,index);
                else
                    if index>ceil((2*l/3))
                        disp(['Right=' num2str(index)])
                        fwrite(bt,uint8(3));
                        fwrite(bt,index);
                    else
                        disp('Closed Eye Detected');
                    end
                end
            end
        else
            %Detecting only left eye
			if( isequal(size(lbox),[1 4]) )
				lI=img(lbox(2)+ceil(lbox(4)/2.7):lbox(2)+lbox(4)-10,lbox(1)+ceil(lbox(3)/8):lbox(1)+lbox(3)-ceil(lbox(3)/7));
				lI=imbinarize(lI,0.15);
				savename = 'image_%04dl.jpeg';  %name pattern
				imageNum = imageNum + 1;
				fileName = sprintf(savename, imageNum);  %create filename
				path = [savepath '/' fileName];  %folder and all
                if(~isempty(lI))
                    imwrite(lI, path);  %write the image there as jpeg
                end
				lI=corner(lI);
                lI=matTri(lI);
				lI=imcomplement(lI);
				lI=erode(lI);
				savename = 'image_%04d.jpeg';  %name pattern
				fileName = sprintf(savename, imageNum);  %create filename
				path = [savepath '/' fileName];  %folder and all
                if(~isempty(lI))
                    imwrite(lI, path);  %write the image there as jpeg
                end
				%Movement Detection
				[~,l]=size(lI);
				summ=zeros([1 l]);
				for i=1:l
					summ(i)=sum(lI(:,i));
				end
				[~,index]=max(summ);
                if isempty(index)
                    fwrite(bt,uint8(2));
                    fwrite(bt,120);
                    continue;
                end
				%Left Or Right
				if index<ceil((l/2.7))
					disp(['Left=' num2str(index)])
					fwrite(bt,uint8(1));
					fwrite(bt,index);
				else
					if (index>ceil((l/2.7)) && index<ceil((2*l/3)))
						disp(['Straight=' num2str(index)])
						fwrite(bt,uint8(2));
						fwrite(bt,index);
					else
						if index>floor(2*l/3)
							disp(['Right=' num2str(index)])
							fwrite(bt,uint8(3));
							fwrite(bt,index);
						else
							disp('Closed Eye Detected');
						end
					end
				end
			else
				disp('Closed Eye Detected');
            end
        end
    end %Cropping and detecting if ended
end %while ended
%Function ended
end