
clear; close all; clc
workspace

%% Patient Identification Name/Number

PIName='F001'; % <---- WRITE INDENTIFICATION NAME/NUMBER in quotation marks   

                % This name will be used for the new folder with the saved video frames that are important for processing

%% Video
[VideoName,VideoPath]=uigetfile('*.mp4','Select Video')
video=VideoReader(fullfile(VideoPath,VideoName));                       % Choose a video for precessing

%% Saving frames of the video

folderPath = uigetdir();                        % Select the folder in which the new folder corresponding to the PIName can be created. 
                                                % The video frames will be saved in the newly created folder. 
mkdir(fullfile(folderPath,PIName));             % Create new folder.
Tc=2;                                           % Sampling rate determining that every '2' frame will be saved.
nof=video.NumFrames;                            % Total number of video frames

f=waitbar(0,'Loading your data','Name','Saving Frames');                                                                    
            for ii=1:Tc:nof
                frames=read(video,ii);                                                      % Reading the video after every 
                                                                                            % second frame
                cesta = fullfile(folderPath, PIName,[[PIName,'_'], int2str(ii),'.jpg']);    % The path for saving frames
                imwrite(frames,cesta)                                                       % Save a frame

                waitbar(ii/nof, f, sprintf('Progress: %d %%', floor(ii/nof*100)));          % Progress bar
            end
 delete(f);

 %% Selection Region of Interest

%Forehead
I=imread(fullfile(folderPath, PIName,[PIName '_', int2str(1),'.jpg']));
uiwait(msgbox('To select the region of interest, press the left button and swipe over the image.Double-click in ROI to complete the selection.','Instruction','help'));
figure('Name','Coordinates for video heart rate processing','NumberTitle','off');
hold on; title('Selection of Region of Interest - Forehead')
[~,ROICelo] = imcrop(I);                                                    % save coordinates of upper left corner 
                                                                            % and lower right corner
close all

%Mouth
I=imread(fullfile(folderPath, PIName,[PIName '_', int2str(1),'.jpg']));
uiwait(msgbox('To select the region of interest, press the left button and swipe over the image.Double-click in ROI to complete the selection.','Instruction','help'));
figure('Name','Coordinates for video heart rate processing','NumberTitle','off');
hold on; title('Selection of Region of Interest - Mouth')
[~,ROIPusa] = imcrop(I);                                                    % save coordinates of upper left corner 
                                                                            % and lower right corner
close all

%Left Cheek
I=imread(fullfile(folderPath, PIName,[PIName '_', int2str(1),'.jpg']));
uiwait(msgbox('To select the region of interest, press the left button and swipe over the image.Double-click in ROI to complete the selection.','Instruction','help'));
figure('Name','Coordinates for video heart rate processing','NumberTitle','off');
hold on; title('Selection of Region of Interest - Left Cheek')
[~,ROITvarL] = imcrop(I);                                                   % save coordinates of upper left corner 
                                                                            % and lower right corner
close all

%Right Cheek
I=imread(fullfile(folderPath, PIName,[PIName '_', int2str(1),'.jpg']));
uiwait(msgbox('To select the region of interest, press the left button and swipe over the image.Double-click in ROI to complete the selection.','Instruction','help'));
figure('Name','Coordinates for video heart rate processing','NumberTitle','off');
hold on; title('Selection of Region of Interest - Right Cheek')
[~,ROITvarP] = imcrop(I);                                                   % save coordinates of upper left corner 
                                                                            % and lower right corner
close all
%Face
I=imread(fullfile(folderPath, PIName,[PIName '_', int2str(1),'.jpg']));
uiwait(msgbox('To select the region of interest, press the left button and swipe over the image.Double-click in ROI to complete the selection.','Instruction','help'));
figure('Name','Coordinates for video heart rate processing','NumberTitle','off');
hold on; title('Selection of Region of Interest - Face')
[~,ROIOblicej] = imcrop(I);                                                 % save coordinates of upper left corner 
                                                                            % and lower right corner
close all


%% Obtain the mean value of the green signal from the ROI.  

uiwait(msgbox('The heart rate evaluation will take some time, please wait.','Info','help'))

    wb = waitbar(0, 'Processing ...','WindowStyle', 'modal');
    wbch = allchild(wb);
    jp = wbch(1).JavaPeer;
    jp.setIndeterminate(1);


signalForehead=[];                                                                                  % Signal from ROI Forehead
 for m=1:Tc:nof
    I=imgaussfilt(imread(fullfile(folderPath, PIName,[PIName '_', int2str(m),'.jpg'])),2);      % This read '_m' saved frame and blur it with a filter.
    Iout = imcrop(I,ROICelo);                                                                   % Choose just a ROI from a frame 
    Gout=Iout(:,:,2);                                                                           % Choose just a green signal from a frame
    signalForehead =[signalForehead mean(Gout(:))];                                                     % Save mean values of green signal in ROI for '_m' frame 
 end 


signalMouth=[];                                                                                  % Signal from ROI Mouth
 for m=1:Tc:nof
    I=imgaussfilt(imread(fullfile(folderPath, PIName,[PIName '_', int2str(m),'.jpg'])),2);
    Iout = imcrop(I,ROIPusa); 
    Gout=Iout(:,:,2);    
    signalMouth=[signalMouth mean(Gout(:))]; 
 end 
signalLeftCheek=[];                                                                                 % Signal from ROI Left Cheek

 for m=1:Tc:nof
    I=imgaussfilt(imread(fullfile(folderPath, PIName,[PIName '_', int2str(m),'.jpg'])),2);
    Iout = imcrop(I,ROITvarL); 
    Gout=Iout(:,:,2);   
    signalLeftCheek =[signalLeftCheek mean(Gout(:))]; 
 end 
signalRightCheek=[];                                                                                 % Signal from ROI Right Cheek

 for m=1:Tc:nof
    I=imgaussfilt(imread(fullfile(folderPath, PIName,[PIName '_', int2str(m),'.jpg'])),2);
    Iout = imcrop(I,ROITvarP);
    Gout=Iout(:,:,2); 
    signalRightCheek =[signalRightCheek mean(Gout(:))];
 end 

signalFace=[];                                                                               % Signal from ROI Face
 for m=1:Tc:nof
    I=imgaussfilt(imread(fullfile(folderPath, PIName,[PIName '_', int2str(m),'.jpg'])),2);
    Iout = imcrop(I,ROIOblicej); 
    Gout=Iout(:,:,2); 
    signalFace =[signalFace mean(Gout(:))]; 
 end 
 
 close(wb)

%% High-pass filter
HPfreq=0.075;                                                               % Hz Equivalent to 45 BPM

HPForehead=highpass((signalForehead-mean(signalForehead)),HPfreq);                  % Forehead                   
HPMouth=highpass((signalMouth-mean(signalMouth)),HPfreq);                     % Mouth
HPLeftCheek=highpass((signalLeftCheek-mean(signalLeftCheek)),HPfreq);               % Left Cheek
HPRightCheek=highpass((signalRightCheek-mean(signalRightCheek)),HPfreq);              % Right Cheek
HPFace=highpass((signalFace-mean(signalFace)),HPfreq);                % Face

m=1:Tc:nof;
figure("Name",'High-pass filter','NumberTitle','off')
    hold on
        plot(m,HPForehead,'cyan','LineWidth',0.8);
        plot(m,HPMouth,'black','LineWidth',0.8); 
        plot(m,HPLeftCheek,'magenta','LineWidth',0.8);  
        plot(m,HPRightCheek,'blue','LineWidth',0.8); 
        plot(m,HPFace,'red','LineWidth',0.8); 
        grid on
        xlabel('frame number [-]','FontSize',15); ylabel('Green Signal [-]','FontSize',15); 
        legend({'Forehead','Mouth','Left Cheek','Right Cheek','Face'},'FontSize',15,'Location','eastoutside')
        title('HP filter','FontSize',15)
    hold off

figure("Name",'High-pass filter of ROI - Forehead','NumberTitle','off')
highpass((signalForehead-mean(signalForehead)),HPfreq);


%% Low-pass filter 
LPfreq=0.1667;                                              % Hz Equivalent to 100 BPM

LPForehead=lowpass(HPForehead,LPfreq);                      % Forehead
LPMouth=lowpass(HPMouth,LPfreq);                            % Mouth
LPLeftCheek=lowpass(HPLeftCheek,LPfreq);                    % Left Cheek
LPRightCheek=lowpass(HPRightCheek,LPfreq);                  % Right Cheek
LPFace=lowpass(HPFace,LPfreq);                              % Face

m=1:Tc:nof;
figure("Name",'Low-pass filter','NumberTitle','off')
    hold on
        plot(m,LPForehead,'cyan','LineWidth',0.8);
        plot(m,LPMouth,'black','LineWidth',0.8); 
        plot(m,LPLeftCheek,'magenta','LineWidth',0.8);  
        plot(m,LPRightCheek,'blue','LineWidth',0.8); 
        plot(m,LPFace,'red','LineWidth',0.8); 
        grid on
        xlabel('frame number [-]','FontSize',15); ylabel('Green Signal [-]','FontSize',15); 
        legend({'Forehead','Mouth','Left Cheek','Right Cheek','Face'},'FontSize',15,'Location','eastoutside')
        title('LP filter','FontSize',15)
    hold off

figure("Name",'Low-pass filter of ROI - Forehead','NumberTitle','off')
lowpass(HPForehead,LPfreq);


%% Calculating peaks

PeakDistance=8;                       % Minimum distance of peaks

m=1:Tc:nof;
figure("Name",'Detection of Peaks','NumberTitle','off')
    hold on
        findpeaks(LPForehead,'MinPeakDistance',PeakDistance)%,'MinPeakHeight',PeaksHigh);             % Forehead
        findpeaks(LPMouth,'MinPeakDistance',PeakDistance)%,'MinPeakHeight',PeaksHigh);                % Mouth
        findpeaks(LPLeftCheek,'MinPeakDistance',PeakDistance)%,'MinPeakHeight',PeaksHigh);            % Left Cheek
        findpeaks(LPRightCheek,'MinPeakDistance',PeakDistance)%,'MinPeakHeight',PeaksHigh);           % Right Cheek   
        findpeaks(LPFace,'MinPeakDistance',PeakDistance)%,'MinPeakHeight',PeaksHigh);                 % Face
        grid on
        xlabel('Frame Number [-]','FontSize',15); 
        ylabel('Green Signal [-]','FontSize',15); 
        legend({'Forehead','Peaks of Forehead ROI','Mouth','Peaks of Mouth ROI','Left Cheek', ...
            'Peaks of Left Cheek ROI','Right Cheek','Peakst of Right Cheek ROI','Face','Peaks of Face ROI'},'FontSize',15,'Location','eastoutside')
        title('Detection of Peaks','FontSize',15)
    hold off

%Calculation of number of peaks in each ROI
PeakForehead=numel(findpeaks(LPForehead,'MinPeakDistance',PeakDistance));         
PeakMouth=numel(findpeaks(LPMouth,'MinPeakDistance',PeakDistance));            
PeakLeftCheek=numel(findpeaks(LPLeftCheek,'MinPeakDistance',PeakDistance));          
PeakRightCheek=numel(findpeaks(LPRightCheek,'MinPeakDistance',PeakDistance));              
PeakFace=numel(findpeaks(LPFace,'MinPeakDistance',PeakDistance));      

PeakData=[PeakFace; PeakForehead; PeakLeftCheek; PeakRightCheek; PeakMouth;];

PeaksBPM=mean(PeakData)                                                       % Mean value of number of peaks
STD=round(std(PeakData),1)                                                    % Deviation from the mean value

BPM= round(PeaksBPM/(nof/30)*60,1)                                            % [number of peaks / (second of video)] * 60 s                     

