% Supplementary Material to Hasselman (2014) "Classifying Acoustic Signals into Speech Categories"

%%%%%%%%%%%%%% MARKDOWN CODE %%%%%%%%%%%%%%
%
% ### Introduction
% This is a demonstration script accompanying the article "Classifying Acoustic Signals into Speech Categories". Its purpose is to
% provide an example of how to use various freely available MATLAB sources on the web to extract variables from speech
% stimuli. This script should thus be used as an example to build your own scripts only. It is not a function or toolbox, not
% optimized for speed or functionality! Evaluate the code per Cell (using MATLAB's Cell Mode) and inspect the workspace to
% see what is going on.
%
% This OSF project page contains links to all the files: https://osf.io/a8g32
%
% ### Data / Toolboxes / Scripts, etc. that need to be on the MATLAB PATH
%
% * [Fred's toolbox](https://github.com/FredHasselman/toolboxML) on GitHub
% * Scripts are available in a [GithHub repository](https://github.com/FredHasselman/Acoustic-Complexity-Matching)
% * Data Files are available at the [Open Science Framework](https://osf.io/a8g32/files)
%
% ### Author / Version / License
%
% Created by: [Fred Hasselman 2011-2014](http://www.fredhasselman.com)
% Affiliations: [School of Pedagogical and Educational Science](http://www.ru.nl/pwo) and [Behavioural Science Institute (Learning & Plasticity)](http://www.ru.nl/bsi) at the [Radboud University Nijmegen, the Netherlands](http://www.ru.nl)
%
%%%%%%%%%%%%%% MARKDOWN CODE %%%%%%%%%%%%%%

%%  PREP

% Uncomment next line to clear and close everything... detergent grade!
%omo

%Change ... to the path on your machine where you stored the files
%If you copied the dropbox folder from the OSF, current path should be Ok (on machines that allow tilde expansion)
source='~/Dropbox/Hasselman2014-PeerJ-Classifying_Acoustic_Signals/';
datPath=[source,'DATA/'];

%This datafile: Hasselman2014_stimfeatures_ORI.mat contains the values that were used in the article. 
%Running the script Hasselman2014_extractmeasures should give you the same results. 
%Note that bootstrapping CIs uses randomisation, which can give slightly different results.

%% Figure 1 - Summary Figure
load([datPath,'Hasselman2014_stimfeatures_ORI.mat']);

h0=figure;
maximize(h0);

cm  = (gray);
v   = [-200:10:0];
icm = 1:floor(length(cm)/length(v)):length(cm-20);
cmp = cm(icm,:);
colormap(cmp);
lvl   = .1;

subplot(4,6,[2 11])
plot(stimuli(1).y,'-k')
axis off

% Get the Formant Tracks
cnt=1;
[t,m,n] = unique(Formants(1,cnt).tracks{1,1});

IN = Formants(1,cnt).tracks{1,2};
F1 = Formants(1,cnt).tracks{1,4};
F2 = Formants(1,cnt).tracks{1,5};
F3 = Formants(1,cnt).tracks{1,6};

IN = IN(m); F1 = F1(m); F2 = F2(m); F3 = F3(m);

Sweep(cnt).TI =  t(IN>=lvl);
Sweep(cnt).F1 = F1(IN>=lvl);
Sweep(cnt).F2 = F2(IN>=lvl);
Sweep(cnt).F3 = F3(IN>=lvl);

dsF1 = smooth(Sweep(cnt).F1,.6,'rloess');
dsF2 = smooth(Sweep(cnt).F2,.6,'rloess');
dsF3 = smooth(Sweep(cnt).F3,.6,'rloess');

subplot(4,6,13);

% Plot the spectrogram
[~, h_spec] = contourf(STIM(cnt).T,STIM(cnt).F,20*log10(abs(STIM(cnt).S)+eps),v,'LineColor','none');hold on;
axf = gca;

h_F1 = plot(axf,Sweep(cnt).TI,dsF1,'-','Color',[.5 .5 .5],'LineWidth',3); hold on;
h_F2 = plot(axf,Sweep(cnt).TI,dsF2,'-','Color',[.5 .5 .5],'LineWidth',3); hold on;
h_F3 = plot(axf,Sweep(cnt).TI,dsF3,'-','Color',[.5 .5 .5],'LineWidth',3); hold on;

set(axf,'Ylim',[1 3000],'Ytick',[],'YtickLabel','','Xlim',[0.1 .6],'Xtick',[],'XtickLabel','');

[mxF2 In] = max(dsF2);
Sweep(cnt).F2mx = mxF2; Sweep(cnt).tF2mx = Sweep(cnt).TI(In);
[mnF2 mIn] = min(dsF2);
Sweep(cnt).F2mn = mnF2; Sweep(cnt).F2mn = Sweep(cnt).TI(mIn); Sweep(cnt).swpF2 = (mxF2-mnF2)/(Sweep(cnt).TI(In)-Sweep(cnt).TI(mIn));

ylabel('Frequency (kHz)');
xlabel('Time (s)');

h_t = text(.45,180,['\Delta F2 = ',deblank(num2str(Sweep(cnt).swpF2/1000,'%#1.2f'))],'Margin',0.01); %[.8 .8 .8] ,'EdgeColor','k'

title('F2 Slope')

clear IN F1 F2 F3 t m n c h_spec h_s h_t h_F1 h_F2 h_F3 dsF1 dsF2 dsF3 In mIn mnF2 mxF2

subplot(4,6,14);
axh=gca;

[hnrp(cnt).S hnrp(cnt).F hnrp(cnt).T, hnrp(cnt).P] = spectrogram(rpTS(cnt).ts(:,2),SPEC.window,SPEC.noverlap,SPEC.f,SPEC.fs);
[~, h_spec] = contourf(hnrp(cnt).T,hnrp(cnt).F,20*log10(abs(hnrp(cnt).S)+eps),v,'LineColor','none');hold on;

set(axh,'Ytick',[],'YtickLabel','','Xtick',[],'XtickLabel','');
hnr_t = text(.065,200,['HNR = ',deblank(num2str(HNR(cnt).HNR,'%#1.2f'))],'Margin',0.01); %[.8 .8 .8] ,'EdgeColor','k'

if cnt==1
 Opos(1,:)=get(axh,'Position');
 ylabel('Frequency (kHz)');
 xlabel('Time (s)');
end

title('HNR')

% Figure 2: maxENVELOPE Slope
%
% Slope till max formant amplitude from stimulus onset and formant onset

subplot(4,6,15);
ax1 = gca;

plot(STIM(cnt).IAT,  (stimuli(cnt).y./5),'LineWidth',.1,'Color',[.7 .7 .7]);hold on;
axis tight;
plot(STIM(cnt).IAT,[STIM(cnt).IAsm],'LineWidth',2,'Color',[.3 .3 .3]);hold on;
axis tight;
plot(STIM(cnt).IAT,-[STIM(cnt).IAsm],'LineWidth',2,'Color',[.3 .3 .3]);hold on;
axis tight;

%Plot min to max AMP line
IAS = plot([STIM(cnt).IAT(1) STIM(cnt).IATmx],[STIM(cnt).IA(1) STIM(cnt).IAmx],'Color','k');hold on
plot([STIM(cnt).IAT(1) STIM(cnt).IATmx],[STIM(cnt).IA(1) STIM(cnt).IAmx],'o','MarkerSize',4,'MarkerEdgeColor',[.3 .3 .3],'MarkerFaceColor',[.8 .8 .8]);

axis tight;

set(ax1,'Ylim',[-5 .5],'Ytick',[],'YtickLabel','','Xlim',[0 .6],'Xtick',[],'XtickLabel','');

%Print slope in figure
text(.35,-.42,['\Delta maxENV = ',num2str(STIM(cnt).IASmxO,'%1.2f')]);


if cnt==1
 Opos(1,:)=get(ax1,'Position');
 ylabel('Amplitude (a.u.)');
 xlabel('Time (s)');
end

title('maxENV')
axis tight;

clear IAS IASmx0


% RFTe
subplot(4,6,16);
axr = gca;

%Scale up the derivative of the smoothed envelope
%Derivative is available here: http://www.mathworks.com/matlabcentral/fileexchange/28920-derivative
dsENV = derivative(STIM(cnt).IAsm).*600;

plot(STIM(cnt).IAT, (stimuli(cnt).y./5),'LineWidth',.1,'Color',[.7 .7 .7]);hold on;
axis tight;

plot(STIM(cnt).IAT , dsENV,'LineWidth',2,'Color',[.3 .3 .3]);hold on;
axis tight;

% Plot the crossings
[~,t0,s0] = crossing(dsENV,STIM(cnt).IAT);
plot(t0,s0+.25,'x','MarkerSize',7,'MarkerEdgeColor','k');

% Print entropy in figure
text(.4,-.26,['RFTe = ',num2str(RTent(cnt),'%1.2f')]);

set(axr,'Ylim',[-.3 ,.3],'Ytick',[],'YtickLabel','','Xlim',[0 .6],'Xtick',[],'XtickLabel','');

ylabel('Amplitude change (a.u.)');
xlabel('Time (s)');

title('RFTe')

% RP plots
ds = 2;

subplot(4,6,17)
tssz=length(rpTS(cnt).ts(:,1));

rr = downsample(rpMTRX(cnt).rp,ds); cc = downsample(transpose(rr),ds);
[r c] = size(cc);
spy(cc,'.k',1);
ax6 = gca;
axis square; axis xy;title('DET / LAM');
xlabel(''); ylabel('');
xlim([0 r(end)]);ylim([0 c(end)]);

set(ax6,'XTick',[],...
 'YTick',[],...
 'ZTick',[],...
 'XTickLabel','',...
 'YTickLabel','',...
 'ZTickLabel','');

% Plot TS
TSpos = get(ax6,'Position');
ax_TS = axes('Position',[TSpos(1)+.01,TSpos(2)-.035,TSpos(3)-.02,TSpos(4)/6]);
h_TSH = line(rpTS(cnt).ts(1:end,1),rpTS(cnt).ts(1:end,2),'Color',[.5 .5 .5]); axis tight
set(ax_TS,'Visible','off');

ax_TSV = axes('Position',[TSpos(1)-.01,TSpos(2),TSpos(4)/9,TSpos(3)+.055]);
h_TSV = line(rpTS(cnt).ts(1:end,2),rpTS(cnt).ts(1:end,1),'Color',[.5 .5 .5]); axis tight
set(ax_TSV,'Visible','off');


% Multifractal Detrended Fluctuation Analysis
qmin=-10;
qmax=10;
qres=101;

qq = linspace(qmin,qmax,qres);

scmin=6;
scmax=12;
ressc=40;

scale=round(2.^[scmin:((scmax-scmin)/ressc):scmax]);

left = [1 4 7 10];
st   = [0 10 20 30];
stc  = [10 20 30 40 50 60 70 80 90 100];

cm  = gray(130);
i = 1;s=1;
subplot(4,6,18);
ax0 = gca;
ax2 = gca;

h(s)=plot(mf(cnt).hq,mf(cnt).Dq,'Color',cm(stc(s),:),'LineWidth',2); hold on;
title('Multifractal Spectrum');
xlabel('h(q)')
ylabel('D(q)')
ylim([-.05 1.05]);
xlim([.45 2.55]);

qzero=mf(i).Hq(qq==0);
qp2=mf(i).Hq(qq==2);
qm2=mf(i).Hq(qq==-2);
qp5=mf(i).Hq(qq==5);
qm5=mf(i).Hq(qq==-5);
plot(ax2,[qzero qzero],[-.05 2.55],':k');
plot(ax2,[qp2 qp2],[-.05 2.55],'--k');
plot(ax2,[qm2 qm2],[-.05 2.55],'--k');

set(ax2,'XTick',[qp2 qzero qm2],'XTickLabel',{'q=2','q=0','q=-2'});

title('CVhq+ / CVhq-')

subplot(4,6,[19 20]);
plot([0 0 1 1],[0 1 0 1],'.w');
text(0.5,0.5,'RTPDH','FontSize',30,'HorizontalAlignment','center')
axis off

subplot(4,6,[21 22]);
plot([0 0 1 1],[0 1 0 1],'.w');
text(0.5,0.5,'ATPDH','FontSize',30,'HorizontalAlignment','center')
axis off


subplot(4,6,[23 24]);
plot([0 0 1 1],[0 1 0 1],'.w');
text(0.5,0.5,'CMH','FontSize',30,'HorizontalAlignment','center')
axis off


h_4=annotation('textbox',[.52 .08 0 0],'String','Causal Ontology','EdgeColor','none','FontSize',18,'HorizontalAlignment','center');
set(h_4,'FitBoxToText','on');

h_5=annotation('textbox',[.08 .065 0 0],'String','Component Dominant','EdgeColor','none','FontSize',18);
set(h_5,'FitBoxToText','on');
h_6=annotation('textbox',[.862 .065 0 0],'String','Interaction Dominant','EdgeColor','none','FontSize',18);
set(h_6,'FitBoxToText','on');
h_7 = annotation('doublearrow',[.2 .84],[.05 .05],'HeadStyle','cback2','Head2Style','cback2','LineWidth',1.5);

% Uncomment if you want to save a figure
% grab('Hasselman2014_Figure1',0)

%% Figure 2: F2 Slope
%load([datPath,'Hasselman2014_stimfeatures_ORI.mat']);

h0=figure;
maximize(h0);

cm  = (gray);
v   = [-200:10:0];
icm = 1:floor(length(cm)/length(v)):length(cm-20);
cmp = cm(icm,:);
colormap(cmp);
lvl   = .1;


for cnt=1:40
 
 % Get the Formant Tracks
 [t,m,n] = unique(Formants(1,cnt).tracks{1,1});
 
 IN = Formants(1,cnt).tracks{1,2};
 F1 = Formants(1,cnt).tracks{1,4};
 F2 = Formants(1,cnt).tracks{1,5};
 F3 = Formants(1,cnt).tracks{1,6};
 
 IN = IN(m); F1 = F1(m); F2 = F2(m); F3 = F3(m);
 
 Sweep(cnt).TI =  t(IN>=lvl);
 Sweep(cnt).F1 = F1(IN>=lvl);
 Sweep(cnt).F2 = F2(IN>=lvl);
 Sweep(cnt).F3 = F3(IN>=lvl);
 
 dsF1 = smooth(Sweep(cnt).F1,.6,'rloess');
 dsF2 = smooth(Sweep(cnt).F2,.6,'rloess');
 dsF3 = smooth(Sweep(cnt).F3,.6,'rloess');
 
 subplot(4,10,cnt);
 
 % Plot the spectrogram
 [~, h_spec] = contourf(STIM(cnt).T,STIM(cnt).F,20*log10(abs(STIM(cnt).S)+eps),v,'LineColor','none');hold on;
 ax0 = gca;
 
 h_F1 = plot(ax0,Sweep(cnt).TI,dsF1,'-','Color',[.5 .5 .5],'LineWidth',3); hold on;
 h_F2 = plot(ax0,Sweep(cnt).TI,dsF2,'-','Color',[.5 .5 .5],'LineWidth',3); hold on;
 h_F3 = plot(ax0,Sweep(cnt).TI,dsF3,'-','Color',[.5 .5 .5],'LineWidth',3); hold on;
 
 set(ax0,'Ytick',[0:1000:3000],'YtickLabel',{'','1','2',''});
 
 ylim([1 3000]);
 
 grid on;
 
 [mxF2 In] = max(dsF2);
 Sweep(cnt).F2mx = mxF2; Sweep(cnt).tF2mx = Sweep(cnt).TI(In);
 [mnF2 mIn] = min(dsF2);
 Sweep(cnt).F2mn = mnF2; Sweep(cnt).F2mn = Sweep(cnt).TI(mIn); Sweep(cnt).swpF2 = (mxF2-mnF2)/(Sweep(cnt).TI(In)-Sweep(cnt).TI(mIn));
 
 % Note that the stimuli are not of equal length!
 % Obviously "Slowed Down" stimuli are longer
 if ismember(cnt,[1:10])
  title(num2str(cnt));
  xlim([0.01 .6]);
 end
 if ismember(cnt,[11:20])
  title(num2str(cnt-10));
  xlim([0.01 .9]);
 end
 if ismember(cnt,[21:30])
  title(num2str(cnt-20));
  xlim([0.01 .6]);
 end
 if ismember(cnt,[31:40])
  title(num2str(cnt-30));
  xlim([0.01 .9]);
 end
 
 if cnt==1
  Opos(1,:)=get(ax0,'Position');
  ylabel('Frequency (kHz)');
  xlabel('Time (s)');
 end
 if cnt==11
  Opos(2,:)=get(ax0,'Position');
  ylabel('Frequency (kHz)');
  xlabel('Time (s)');
 end
 if cnt==21
  Opos(3,:)=get(ax0,'Position');
  ylabel('Frequency (kHz)');
  xlabel('Time (s)');
 end
 if cnt==31
  Opos(4,:)=get(ax0,'Position');
  ylabel('Frequency (kHz)');
  xlabel('Time (s)');
 end
 
 h_t = text(.2,150,['\DeltaF2 = ',deblank(num2str(Sweep(cnt).swpF2/1000,'%#1.2f'))],'Margin',0.01); %[.8 .8 .8] ,'EdgeColor','k'
 
 clear IN F1 F2 F3 t m n c h_spec h_s h_t h_F1 h_F2 h_F3 dsF1 dsF2 dsF3 In mIn mnF2 mxF2
 
end

Tpos = [-.1 -0.06 0 0];

h_1= annotation('textbox',[Opos(1,:)+Tpos],'String','None','EdgeColor','none','FontSize',16);
set(h_1,'FitBoxToText','on');
h_2= annotation('textbox',[Opos(2,:)+Tpos],'String','Slowed Down','EdgeColor','none','FontSize',16);
set(h_2,'FitBoxToText','on');
h_3= annotation('textbox',[Opos(3,:)+Tpos],'String','Amplified','EdgeColor','none','FontSize',16);
set(h_3,'FitBoxToText','on');
h_4=annotation('textbox',[Opos(4,:)+Tpos],'String','Both','EdgeColor','none','FontSize',16);
set(h_4,'FitBoxToText','on');
h_5=annotation('textbox',[.146 .065 0 0],'String','/bAk/','EdgeColor','none','FontSize',16);
set(h_5,'FitBoxToText','on');
h_6=annotation('textbox',[.862 .065 0 0],'String','/dAk/','EdgeColor','none','FontSize',16);
set(h_6,'FitBoxToText','on');
h_7 = annotation('arrow',[.2 .84],[.05 .05],'HeadStyle','cback2','LineWidth',1.5);

keep Formants HNR RTent SPEC STIM rpSTATS rpTS stimuli rpMTRX stimuliMF mf

% Uncomment if you want to save a figure
%grab('Hasselman2014_Figure2',0)


%% Figure 3: maxENVELOPE Slope
% Slope till max formant amplitude from stimulus onset and formant onset

%load([datPath,'Hasselman2014_stimfeatures_ORI.mat']);

h0=figure;
maximize(h0);

cnt=0;
for cnt=1:40
 
 subplot(4,10,cnt);
 ax1 = gca;
 
 plot(STIM(cnt).IAT,  (stimuli(cnt).y./5),'LineWidth',.1,'Color',[.7 .7 .7]);hold on;
 axis tight;
 plot(STIM(cnt).IAT,[STIM(cnt).IAsm],'LineWidth',2,'Color',[.3 .3 .3]);hold on;
 axis tight;
 plot(STIM(cnt).IAT,-[STIM(cnt).IAsm],'LineWidth',2,'Color',[.3 .3 .3]);hold on;
 axis tight;
 
 %Plot min to max AMP line
 IAS = plot([STIM(cnt).IAT(1) STIM(cnt).IATmx],[STIM(cnt).IA(1) STIM(cnt).IAmx],'Color','k');hold on
 plot([STIM(cnt).IAT(1) STIM(cnt).IATmx],[STIM(cnt).IA(1) STIM(cnt).IAmx],'o','MarkerSize',4,'MarkerEdgeColor',[.3 .3 .3],'MarkerFaceColor',[.8 .8 .8]);
 
 axis tight;
 set(ax1,'Ytick',[-.5:.1:.5],'YtickLabel',{'','','','','','0','','','','',''});
 
 ylim([-.5 .5]);
 xlim([0 .9]);
 %grid on;
 
 %Print slope in figure
 text(.55,-.45,['\Delta = ',num2str(STIM(cnt).IASmxO,'%1.2f')]);
 
 %Garnish
 if ismember(cnt,[1:10])
  title(num2str(cnt));
 end
 if ismember(cnt,[11:20])
  title(num2str(cnt-10));
 end
 if ismember(cnt,[21:30])
  title(num2str(cnt-20));
 end
 if ismember(cnt,[31:40])
  title(num2str(cnt-30));
 end
 
 if cnt==1
  Opos(1,:)=get(ax1,'Position');
  ylabel('Amplitude (a.u.)');
  xlabel('Time (s)');
 end
 if cnt==11
  Opos(2,:)=get(ax1,'Position');
  ylabel('Amplitude (a.u.)');
  xlabel('Time (s)');
 end
 if cnt==21
  Opos(3,:)=get(ax1,'Position');
  ylabel('Amplitude (a.u.)');
  xlabel('Time (s)');
 end
 if cnt==31
  Opos(4,:)=get(ax1,'Position');
  ylabel('Amplitude (a.u.)');
  xlabel('Time (s)');
 end
 
 clear IAS IASmx0
 
end

Tpos = [-.1 -0.06 0 0];

h_1= annotation('textbox',[Opos(1,:)+Tpos],'String','None','EdgeColor','none','FontSize',16);
set(h_1,'FitBoxToText','on');
h_2= annotation('textbox',[Opos(2,:)+Tpos],'String','Slowed Down','EdgeColor','none','FontSize',16);
set(h_2,'FitBoxToText','on');
h_3= annotation('textbox',[Opos(3,:)+Tpos],'String','Amplified','EdgeColor','none','FontSize',16);
set(h_3,'FitBoxToText','on');
h_4=annotation('textbox',[Opos(4,:)+Tpos],'String','Both','EdgeColor','none','FontSize',16);
set(h_4,'FitBoxToText','on');
h_5=annotation('textbox',[.146 .065 0 0],'String','/bAk/','EdgeColor','none','FontSize',16);
set(h_5,'FitBoxToText','on');
h_6=annotation('textbox',[.862 .065 0 0],'String','/dAk/','EdgeColor','none','FontSize',16);
set(h_6,'FitBoxToText','on');
h_7 = annotation('arrow',[.2 .84],[.05 .05],'HeadStyle','cback2','LineWidth',1.5);

keep Formants HNR RTent SPEC STIM rpSTATS rpTS stimuli rpMTRX stimuliMF mf

% Uncomment if you want to save a figure
% grab('Hasselman2014_Figure3',0);

%% Figure 4: Rise and Fall Time Entropy

%load([datPath,'Hasselman2014_stimfeatures_ORI.mat']);

h0=figure;
maximize(h0);

for cnt=1:40
 
 subplot(4,10,cnt);
 ax1 = gca;
 
 %Scale up the derivative of the smoothed envelope
 dsENV = derivative(STIM(cnt).IAsm).*600;
 
 plot(STIM(cnt).IAT, (stimuli(cnt).y./5),'LineWidth',.1,'Color',[.7 .7 .7]);hold on;
 axis tight;
 
 plot(STIM(cnt).IAT , dsENV,'LineWidth',2,'Color',[.3 .3 .3]);hold on;
 axis tight;
 
 % Plot the crossings
 [~,t0,s0] = crossing(dsENV,STIM(cnt).IAT);
 plot(t0,s0+.25,'x','MarkerSize',7,'MarkerEdgeColor','k');
 
 % Print entropy in figure
 text(.05,-.26,['RFTe = ',num2str(RTent(cnt),'%1.2f')]);
 
 
 set(ax1,'Ytick',[-.3:.1:.3],'YtickLabel',{'','','','0','','',''});
 
 ylim([-.3 .3]);
 xlim([0 .9]);
 %grid on;
 
 % Garnish
 if ismember(cnt,[1:10])
  title(num2str(cnt));
 end
 if ismember(cnt,[11:20])
  title(num2str(cnt-10));
 end
 if ismember(cnt,[21:30])
  title(num2str(cnt-20));
 end
 if ismember(cnt,[31:40])
  title(num2str(cnt-30));
 end
 
 if cnt==1
  Opos(1,:)=get(ax1,'Position');
  ylabel('Amplitude change (a.u.)');
  xlabel('Time (s)');
 end
 if cnt==11
  Opos(2,:)=get(ax1,'Position');
  ylabel('Amplitude change (a.u.)');
  xlabel('Time (s)');
 end
 if cnt==21
  Opos(3,:)=get(ax1,'Position');
  ylabel('Amplitude change (a.u.)');
  xlabel('Time (s)');
 end
 if cnt==31
  Opos(4,:)=get(ax1,'Position');
  ylabel('Amplitude change (a.u.)');
  xlabel('Time (s)');
 end
 
 clear dsENV s0 t0
 
end

Tpos = [-.1 -0.06 0 0];

h_1= annotation('textbox',[Opos(1,:)+Tpos],'String','None','EdgeColor','none','FontSize',16);
set(h_1,'FitBoxToText','on');
h_2= annotation('textbox',[Opos(2,:)+Tpos],'String','Slowed Down','EdgeColor','none','FontSize',16);
set(h_2,'FitBoxToText','on');
h_3= annotation('textbox',[Opos(3,:)+Tpos],'String','Amplified','EdgeColor','none','FontSize',16);
set(h_3,'FitBoxToText','on');
h_4=annotation('textbox',[Opos(4,:)+Tpos],'String','Both','EdgeColor','none','FontSize',16);
set(h_4,'FitBoxToText','on');
h_5=annotation('textbox',[.146 .065 0 0],'String','/bAk/','EdgeColor','none','FontSize',16);
set(h_5,'FitBoxToText','on');
h_6=annotation('textbox',[.862 .065 0 0],'String','/dAk/','EdgeColor','none','FontSize',16);
set(h_6,'FitBoxToText','on');
h_7 = annotation('arrow',[.2 .84],[.05 .05],'HeadStyle','cback2','LineWidth',1.5);

keep Formants HNR RTent SPEC STIM rpSTATS rpTS stimuli rpMTRX stimuliMF mf

% Uncomment if you want to save a figure
% grab('Hasselman2014_Figure4',0);


%% Figure 5: Phase Space Reconstruction Example

%load([datPath,'Hasselman2014_stimfeatures_ORI.mat']);

cnt=10; ds=1;
x = rpTS(cnt).ts(1:1024,2);
t = rpTS(cnt).ts(1:1024,1);
tau=6; m=3;

x=minplus1(x);

x1=x(1+(m-3)*tau:end-((m-1)*tau)+1); ts1=t(1+(m-3)*tau:end-((m-1)*tau)+1); %  t1=minplus1(t1);
x2=x(0+(m-2)*tau:end-((m-2)*tau));   ts2=t(0+(m-2)*tau:end-((m-2)*tau));   %  t2=minplus1(t2);
x3=x(0+(m-1)*tau:end-((m-3)*tau));   ts3=t(0+(m-1)*tau:end-((m-3)*tau));   %  t3=minplus1(t3);

t = -1:2/(length(x1)-1):1;

t1=t;
t2=t;
t3=t;

z1=-1+zeros(length(t1),1);
z2= 1+zeros(length(t2),1);
z3= 1+zeros(length(t3),1);

h0=figure;
maximize(h0);

ax_PS =axes('NextPlot','add');

h_ts1=plot3(x1(:),x2(:),z1,'-k');axis square;
xlim([-1 1]),ylim([-1 1]);zlim([-1 1]); view(3);
h_ts2=plot3(z2,x2(:),x3(:),'-k');axis square;
h_ts3=plot3(x1(:),z3,x3(:),'-k');axis square;

set(ax_PS,'XTick',[-1 0 1],'YTick',[-1 0 1],'ZTick',[-1 0 1]);
set([h_ts1 h_ts2 h_ts3],'Color',[.7 .7 .7]);

h_ps=plot3(x1(:), x2(:), x3(:),'-ko'); grid on; axis square;
set(h_ps,'MarkerFaceColor',[.5 .5 .5]);
xlabel('X_m_=_1'); ylabel('X_m_=_2'); zlabel('X_m_=_3');
title({'Reconstructed Phase Space of Stimulus 10 (first 1024 samples)', ['Delay Embedding with m = 3, \tau = 6, \epsilon = ',num2str(rpSTATS(cnt,1),1),' of maximum norm distance']});

s=.18;
point=525;
xc=[0 1 1 0 0 0;1 1 0 0 1 1;1 1 0 0 1 1;0 1 1 0 0 0]*s;xc=xc+x1(point)-(s/2);
yc=[0 0 1 1 0 0;0 1 1 0 0 0;0 1 1 0 1 1;0 0 1 1 1 1]*s;yc=yc+x2(point)-(s/2);
zc=[0 0 0 0 0 1;0 0 0 0 0 1;1 1 1 1 0 1;1 1 1 1 0 1]*s;zc=zc+x3(point)-(s/2);

axes(ax_PS);
for i=1:6
 h=patch(xc(:,i),yc(:,i),zc(:,i),[.8 .8 .8]);
 set(h,'edgecolor','k','FaceAlpha',.5,'LineWidth',1)
end

xc1 = xc(:,1); yc1 = yc(:,1); zc1 = zc(:,1);
xc2 = xc(:,2); yc2 = yc(:,2); zc2 = zc(:,2);
xc3 = xc(:,3); yc3 = yc(:,3); zc3 = zc(:,3);
xc4 = xc(:,4); yc4 = yc(:,4); zc4 = zc(:,4);
xc5 = xc(:,5); yc5 = yc(:,5); zc5 = zc(:,5);
xc6 = xc(:,6); yc6 = yc(:,6); zc6 = zc(:,6);

axes(ax_PS);
h1=patch(xc5(:),yc5(:),[-1 -1 -1 -1]',[.8 .8 .8]);
h2=patch(xc6(:),[1 1 1 1]',zc1(:),[.8 .8 .8]);
h3=patch([1 1 1 1]',yc2(:),zc1(:),[.8 .8 .8]);

set([h1 h2 h3],'edgecolor','k','FaceAlpha',.5,'LineWidth',1)

text(xc(1,1)-(s/3),yc(1,1)+(s/3),zc(1,1)+.15,'\epsilon','FontSize',20);

axes(ax_PS);
hc1 = plot3(x1(point),x2(point),-1,'ok');
hc2 = plot3(1,x2(point),x3(point),'ok');
hc3 = plot3(x1(point),1,x3(point),'ok');
set([hc1 hc2 hc3],'MarkerFaceColor',[.2 .2 .2],'MarkerSize',8);

point3=795;
hc7 = plot3(x1(point3),x2(point3),-1,'sk');
hc8 = plot3(1,x2(point3),x3(point3),'sk');
hc9 = plot3(x1(point3),1,x3(point3),'sk');
set([hc7 hc8 hc9],'MarkerFaceColor',[.7 .7 .7],'MarkerSize',8);

keep Formants HNR RTent SPEC STIM rpSTATS rpTS stimuli rpMTRX stimuliMF mf

% Uncomment if you want to save a figure
% grab('Hasselman2014_Figure5',0);

%% Figure 6 (LEFT): RP example

%load([datPath,'Hasselman2014_stimfeatures_ORI.mat']);

cnt=10; tau=6; m=3; e=.01; thr= 'rr';
% Uncomment to calculate rahter than load this RP matrix
% 
%[MTRX] = crp(rpTS(cnt).ts,m,tau,e,thr,'nonormalize','silent');

[MTRX] = rpMTRX(cnt).rp;
[r c]  = size(MTRX);

scrsz = get(0,'ScreenSize');
h0    = figure('Position',[scrsz(3)/4 0 scrsz(3)/2 scrsz(3)/2],'NextPlot','add');

RPdims  =[.35 .35 .6 .6];

TSHdims1=[.35 .06 .6 .06];
TSHdims2=[.35 .15 .6 .06];
TSHdims3=[.35 .24 .6 .06];

TSVdims1=[.06 .35 .06 .6];
TSVdims2=[.15 .35 .06 .6];
TSVdims3=[.24 .35 .06 .6];

%Recurrence Plot
ax_RP =axes('Position',RPdims);
spy(MTRX,'.k',1);
axis square; axis xy;
xlabel('Recurrent values in m-dimensional phase space');
title({'(Auto) Recurrence Plot of Stimulus 10:',['\tau = 6, m = 3, \epsilon = ',num2str(rpSTATS(cnt,1),1)]});
loi=line([0 r],[0 c],'Color','k','LineWidth',3);

x1=rpTS(cnt).ts(1+(m-3)*tau:end-((m-1)*tau),2); y1=rpTS(cnt).ts(1+(m-3)*tau:end-((m-1)*tau),1);
x2=rpTS(cnt).ts(0+(m-2)*tau:end-((m-2)*tau),2); y2=rpTS(cnt).ts(0+(m-2)*tau:end-((m-2)*tau),1);
x3=rpTS(cnt).ts(0+(m-1)*tau:end-((m-3)*tau),2); y3=rpTS(cnt).ts(0+(m-1)*tau:end-((m-3)*tau),1);

%Horizontal TS
ax_TSH1=axes('Position',TSHdims1);%drawnow
h_TSH1=line(y1,x1); axis tight
xlabel('Surrogate Dimensions: m Time Series Delayed by m*\tau');
ylabel('X_m_=_1');

ax_TSH2=axes('Position',TSHdims2);%drawnow
h_TSH2=line(y2,x2); axis tight
ylabel('X_m_=_2');

ax_TSH3=axes('Position',TSHdims3);%drawnow
h_TSH3=line(y3,x3); axis tight
ylabel('X_m_=_3');

%Vertical TS
ax_TSV1=axes('Position',TSVdims1);%drawnow
h_TSV1=line(x1,y1); axis tight
ylabel('Surrogate Dimensions: m Time Series Delayed by m*\tau');
xlabel('X_m_=_1');

ax_TSV2=axes('Position',TSVdims2);%drawnow
h_TSV2=line(x2,y2); axis tight
xlabel('X_m_=_2');

ax_TSV3=axes('Position',TSVdims3);%drawnow
h_TSV3=line(x3,y3); axis tight
xlabel('X_m_=_3');

set([h_TSH1,h_TSH2,h_TSH3,h_TSV1,h_TSV2,h_TSV3],'Color',[.5 .5 .5]);

set([ax_RP],...
 'FontSize',14,...
 'XTick',[1 round(r/2) r],...
 'YTick',[1 round(c/2) c],...
 'XTickLabel',{'1' num2str(round(r/2)) num2str(r)},...
 'YTickLabel',{'1' num2str(round(r/2)) num2str(r)});

set([ax_TSH1],...
 'FontSize',14,...
 'XTick',[y1(1) y1(round(length(y1)/2)) y1(end)],...
 'YTick',[-1 0 1],...
 'XTickLabel',{num2str(y1(1),4) num2str(y1(round(length(y1)/2)),4) num2str(y1(end),4)},...
 'YTickLabel',{'' '' ''},'Box','on');

set([ax_TSH2],...
 'FontSize',14,...
 'XTick',[y2(1) y2(round(length(y2)/2)) y2(end)],...
 'YTick',[-1 0 1],...
 'XTickLabel',{num2str(y2(1),4) num2str(y2(round(length(y2)/2)),4) num2str(y2(end),4)},...
 'YTickLabel',{'' '' ''},'Box','on');

set([ax_TSH3],...
 'FontSize',14,...
 'XTick',[y3(1) y3(round(length(y3)/2)) y3(end)],...
 'YTick',[-1 0 1],...
 'XTickLabel',{num2str(y3(1),4) num2str(y3(round(length(y1)/2)),4) num2str(y3(end),4)},...
 'YTickLabel',{'' '' ''},'Box','on');

set([ax_TSV1],...
 'FontSize',14,...
 'YTick',[y1(1) y1(round(length(y1)/2)) y1(end)],...
 'XTick',[-1 0 1],...
 'YTickLabel',{'' '' ''},...
 'XTickLabel',{'-1' '0' '1'},'Box','on');

set([ax_TSV2],...
 'FontSize',14,...
 'YTick',[y2(1) y2(round(length(y2)/2)) y2(end)],...
 'XTick',[-1 0 1],...
 'YTickLabel',{'' '' ''},...
 'XTickLabel',{'-1' 0'' '1'},'Box','on');

set([ax_TSV3],...
 'FontSize',14,...
 'YTick',[y3(1) y3(round(length(y3)/2)) y3(end)],...
 'XTick',[-1 0 1],...
 'YTickLabel',{'' '' ''},...
 'XTickLabel',{'-1' '0' '1'},'Box','on');

rpST = {['RQA measures:'],...
 [' '],...
 ['REC = ',num2str(rpSTATS(cnt,2),2)],...
 ['DET = ',num2str(rpSTATS(cnt,3),2)],...
 ['Lmn = ',num2str(rpSTATS(cnt,4),3)],...
 ['ENT = ',num2str(rpSTATS(cnt,6),3)],...
 ['LAM = ',num2str(rpSTATS(cnt,7),2)],...
 ['Vmn = ',num2str(rpSTATS(cnt,8),3)]};

h_s = annotation('textbox',[.06 .3 0 0],'String',rpST,'EdgeColor','none','FontName','Courier','FontSize',24);
set(h_s,'FitBoxToText','on');

keep Formants HNR RTent SPEC STIM rpSTATS rpTS stimuli rpMTRX stimuliMF mf

% Uncomment if you want to save a figure
% grab('Hasselman2014_Figure5',0);

%% Figure 6 (RIGHT): RP RANDOM example

%load([datPath,'Hasselman2014_stimfeatures_ORI.mat']);

cnt=10; tau=6; m=3; e=.01; thr= 'rr';

% Create a shuffled version
Y = shuffle(rpTS(cnt).ts(:,2));
[STATS]= crqa(Y, m,tau,e,thr,'nonormalize','silent');
[MTRX] = crp([rpTS(cnt).ts(:,1) Y],m,tau,e,thr,'nonormalize','silent');

[r c] = size(MTRX);

scrsz = get(0,'ScreenSize');
h0 = figure('Position',[scrsz(3)/4 0 scrsz(3)/2 scrsz(3)/2],'NextPlot','add');

RPdims  =[.35 .35 .6 .6];

TSHdims1=[.35 .06 .6 .06];
TSHdims2=[.35 .15 .6 .06];
TSHdims3=[.35 .24 .6 .06];

TSVdims1=[.06 .35 .06 .6];
TSVdims2=[.15 .35 .06 .6];
TSVdims3=[.24 .35 .06 .6];

%Recurrence Plot
ax_RP =axes('Position',RPdims);
spy(MTRX,'.k',1);
axis square; axis xy;
xlabel('Recurrent values in m-dimensional phase space');
title({'(Auto) Recurrence Plot of Stimulus 10 (RANDOMISED):',['\tau = 6, m = 3, \epsilon = ',num2str(STATS(1),1)]});
loi=line([0 r],[0 c],'Color','k','LineWidth',3);

x1=Y(1+(m-3)*tau:end-((m-1)*tau)); y1=rpTS(cnt).ts(1+(m-3)*tau:end-((m-1)*tau),1);
x2=Y(0+(m-2)*tau:end-((m-2)*tau)); y2=rpTS(cnt).ts(0+(m-2)*tau:end-((m-2)*tau),1);
x3=Y(0+(m-1)*tau:end-((m-3)*tau)); y3=rpTS(cnt).ts(0+(m-1)*tau:end-((m-3)*tau),1);

%Horizontal TS
ax_TSH1=axes('Position',TSHdims1);%drawnow
h_TSH1=line(y1,x1); axis tight
xlabel('Surrogate Dimensions: m Time Series Delayed by m*\tau');
ylabel('X_m_=_1');

ax_TSH2=axes('Position',TSHdims2);%drawnow
h_TSH2=line(y2,x2); axis tight
ylabel('X_m_=_2');

ax_TSH3=axes('Position',TSHdims3);%drawnow
h_TSH3=line(y3,x3); axis tight
ylabel('X_m_=_3');

%Vertical TS
ax_TSV1=axes('Position',TSVdims1);%drawnow
h_TSV1=line(x1,y1); axis tight
ylabel('Surrogate Dimensions: m Time Series Delayed by m*\tau');
xlabel('X_m_=_1');

ax_TSV2=axes('Position',TSVdims2);%drawnow
h_TSV2=line(x2,y2); axis tight
xlabel('X_m_=_2');

ax_TSV3=axes('Position',TSVdims3);%drawnow
h_TSV3=line(x3,y3); axis tight
xlabel('X_m_=_3');

set([h_TSH1,h_TSH2,h_TSH3,h_TSV1,h_TSV2,h_TSV3],'Color',[.5 .5 .5]);

set([ax_RP],...
 'FontSize',14,...
 'XTick',[1 round(r/2) r],...
 'YTick',[1 round(c/2) c],...
 'XTickLabel',{'1' num2str(round(r/2)) num2str(r)},...
 'YTickLabel',{'1' num2str(round(r/2)) num2str(r)});

set([ax_TSH1],...
 'FontSize',14,...
 'XTick',[y1(1) y1(round(length(y1)/2)) y1(end)],...
 'YTick',[-1 0 1],...
 'XTickLabel',{num2str(y1(1),4) num2str(y1(round(length(y1)/2)),4) num2str(y1(end),4)},...
 'YTickLabel',{'' '' ''},'Box','on');

set([ax_TSH2],...
 'FontSize',14,...
 'XTick',[y2(1) y2(round(length(y2)/2)) y2(end)],...
 'YTick',[-1 0 1],...
 'XTickLabel',{num2str(y2(1),4) num2str(y2(round(length(y2)/2)),4) num2str(y2(end),4)},...
 'YTickLabel',{'' '' ''},'Box','on');

set([ax_TSH3],...
 'FontSize',14,...
 'XTick',[y3(1) y3(round(length(y3)/2)) y3(end)],...
 'YTick',[-1 0 1],...
 'XTickLabel',{num2str(y3(1),4) num2str(y3(round(length(y1)/2)),4) num2str(y3(end),4)},...
 'YTickLabel',{'' '' ''},'Box','on');

set([ax_TSV1],...
 'FontSize',14,...
 'YTick',[y1(1) y1(round(length(y1)/2)) y1(end)],...
 'XTick',[-1 0 1],...
 'YTickLabel',{'' '' ''},...
 'XTickLabel',{'-1' '0' '1'},'Box','on');

set([ax_TSV2],...
 'FontSize',14,...
 'YTick',[y2(1) y2(round(length(y2)/2)) y2(end)],...
 'XTick',[-1 0 1],...
 'YTickLabel',{'' '' ''},...
 'XTickLabel',{'-1' 0'' '1'},'Box','on');

set([ax_TSV3],...
 'FontSize',14,...
 'YTick',[y3(1) y3(round(length(y3)/2)) y3(end)],...
 'XTick',[-1 0 1],...
 'YTickLabel',{'' '' ''},...
 'XTickLabel',{'-1' '0' '1'},'Box','on');

rpST = {['RQA measures:'],...
 [' '],...
 ['REC = ',num2str(STATS(2),2)],...
 ['DET = ',num2str(STATS(3),1)],...
 ['Lmn = ',num2str(STATS(4),3)],...
 ['ENT = ',num2str(STATS(6),1)],...
 ['LAM = ',num2str(STATS(7),1)],...
 ['Vmn = ',num2str(STATS(8),3)]};

h_s = annotation('textbox',[.06 .30 0 0],'String',rpST,'EdgeColor','none','FontName','Courier','FontSize',24);
set(h_s,'FitBoxToText','on');

keep Formants HNR RTent SPEC STIM rpSTATS rpTS stimuli rpMTRX stimuliMF mf

% Uncomment if you want to save a figure
% grab('Hasselman2014_Figure6r',0);


%% Figure 7: RP plots

%load([datPath,'Hasselman2014_stimfeatures_ORI.mat']);

ds = 2;
h0=figure;
maximize(h0);

for cnt=1:40
 
 subplot(4,10,cnt)
 tssz=length(rpTS(cnt).ts(:,1));
 
 rr = downsample(rpMTRX(cnt).rp,ds); cc = downsample(transpose(rr),ds);
 [r c] = size(cc);
 spy(cc,'.k',1);
 ax0 = gca;
 axis square; axis xy;
 xlabel(''); ylabel('');title(num2str(cnt));
 xlim([0 r(end)]);ylim([0 c(end)]);
 
 set(ax0,'XTick',[0 (round(r(end)/2)) r(end)],...
  'YTick',[0 (round(c(end)/2)) c(end)],...
  'XTickLabel',{'','',''},...
  'YTickLabel',{'','',''});
 
 if ismember(cnt,[1:10])
  title([num2str(cnt),'- \epsilon =',num2str(rpSTATS(cnt,1),1)]);
 end
 if ismember(cnt,[11:20])
  title([num2str(cnt-10),'- \epsilon =',num2str(rpSTATS(cnt,1),1)]);
 end
 if ismember(cnt,[21:30])
  title([num2str(cnt-20),'- \epsilon =',num2str(rpSTATS(cnt,1),1)]);
 end
 if ismember(cnt,[31:40])
  title([num2str(cnt-30),'- \epsilon =',num2str(rpSTATS(cnt,1),1)]);
 end
 
 if cnt==1
  Opos(1,:)=get(ax0,'Position');
 end
 if cnt==11
  Opos(2,:)=get(ax0,'Position');
 end
 if cnt==21
  Opos(3,:)=get(ax0,'Position');
 end
 if cnt==31
  Opos(4,:)=get(ax0,'Position');
 end
 
 % Plot TS
 TSpos = get(ax0,'Position');
 ax_TS = axes('Position',[TSpos(1),TSpos(2)-.03,TSpos(3),TSpos(4)/4]);
 h_TSH = line(rpTS(cnt).ts(1:end,1),rpTS(cnt).ts(1:end,2),'Color',[.5 .5 .5]); axis tight
 set(ax_TS,'Visible','off');
 
end

Tpos = [-.1 -0.06 0 0];

h_1= annotation('textbox',[Opos(1,:)+Tpos],'String','None','EdgeColor','none','FontSize',16);
set(h_1,'FitBoxToText','on');
h_2= annotation('textbox',[Opos(2,:)+Tpos],'String','Slowed Down','EdgeColor','none','FontSize',16);
set(h_2,'FitBoxToText','on');
h_3= annotation('textbox',[Opos(3,:)+Tpos],'String','Amplified','EdgeColor','none','FontSize',16);
set(h_3,'FitBoxToText','on');
h_4=annotation('textbox',[Opos(4,:)+Tpos],'String','Both','EdgeColor','none','FontSize',16);
set(h_4,'FitBoxToText','on');
h_5=annotation('textbox',[.146 .065 0 0],'String','/bAk/','EdgeColor','none','FontSize',16);
set(h_5,'FitBoxToText','on');
h_6=annotation('textbox',[.862 .065 0 0],'String','/dAk/','EdgeColor','none','FontSize',16);
set(h_6,'FitBoxToText','on');
h_7 = annotation('arrow',[.2 .84],[.05 .05],'HeadStyle','cback2','LineWidth',1.5);
h_8 = annotation('textbox',[.39 .99 0 0],'String','(Auto) Recurrence Plots for all Stimuli','EdgeColor','none','FontSize',16);
set(h_8,'FitBoxToText','on');

keep Formants HNR RTent SPEC STIM rpSTATS rpTS stimuli rpMTRX stimuliMF mf

% Uncomment if you want to save a figure
% grab('Hasselman2014_Figure6',0);

%% Figure 8 - Explaining DFA

%load([datPath,'Hasselman2014_stimfeatures_ORI.mat']);

scmin=6;
scmax=12;
ressc=60;

scale=round(2.^[scmin:((scmax-scmin)/ressc):scmax]);

y=cumsum(stimuliMF(1).IA-mean(stimuliMF(1).IA))';
m=1;

% This is the DFA algorithm!
% Nothing more, nothing less... (adapted from Ihlen, 2012)
for ns=1:length(scale),
 segments(ns)=floor(length(y)/scale(ns));
 for v=1:segments(ns),
  Index=((((v-1)*scale(ns))+1):(v*scale(ns)));
  C=polyfit(Index,y(Index),m);
  fit1=polyval(C,Index);
  RMS_scale{ns}(v)=sqrt(mean((y(Index)-fit1).^2));
 end
 F(ns)=sqrt(mean(RMS_scale{ns}.^2));
end
Ch = polyfit(log2(scale),log2(F),1);
H = Ch(1);
RegLine = polyval(Ch,log2(scale));


% Plot the Figure
h0=figure;
maximize(h0);

ns  = [21 31 51 61];
col = [9 10 11 12] ;
ids = [53 27 7 4];

subplot(8,4,[2 7])
plot(stimuliMF(1).IA,'-k'); hold on
plot(1:length(stimuliMF(1).IA),cumsum(stimuliMF(1).IA-mean(stimuliMF(1).IA))./2000,'-','Color',[.5 .5 .5],'LineWidth',1); hold on

axis off
grid off

for s = 1:length(ns)
 
 subplot(8,4,col(s))
 
 sc = [1:scale(ns(s)):length(y)]';
 x  = (sc(1:end-1)+sc(2:end))./2;
 yv = unit(RMS_scale{ns(s)});
 
 plot(y,'-','Color',[.5 .5 .5]); hold on
 plot([sc(ids(s)):sc(ids(s)+1)],y([sc(ids(s)):sc(ids(s)+1)]),'-k','LineWidth',2); hold on
 set(gca,'XTick',[1:scale(ns(s)):length(y)],'YTick',[],'XTickLabel','','XGrid','on','YGrid','off');
 axis tight
 
 ylabel('Profile');
 xlabel('');
 title(['s = ',num2str(scale(ns(s))),' (scale)  |  N_s = ',num2str(length(sc)),' (segments v)']);
 
 subplot(8,4,col(s)+4)
 plot([sc(ids(s)):sc(ids(s)+1)],detrend(y(sc(ids(s)):sc(ids(s)+1))),'-k'); hold on
 set(gca,'XTick',[sc(ids(s)) sc(ids(s)+1)],'XTickLabel',{num2str(sc(ids(s)).*(1/stimuli(1).fs),2),num2str(sc(ids(s)+1).*(1/stimuli(1).fs),2)},'YTick',0,'YGrid','on');
 
 ylabel('');
 title(['Detrended Segment (v = ',num2str(ids(s)),')'])
 axis tight
 
 
 subplot(8,4,col(s)+8)
 plot(x,yv,'ok'); hold on
 plot(x(ids(s)),yv(ids(s)),'ok','MarkerFaceColor',[.4 .4 .4],'MarkerSize',8); hold on
 set(gca,'XTick',[1:scale(ns(s)):length(y)],'YTick',[],'XTickLabel','','XGrid','on','YGrid','off');
 ylabel('F^2(s,v)');
 xlabel(['RMS variation of F^2 (s = ',num2str(scale(ns(s))),', N_s = ',num2str(length(sc)),') = ',num2str(F(ns(s)),2)]);
 
 axis tight
 
end

subplot(8,4,[22 31])
plot(log2(scale),log2(F),'sk'); hold on;
plot(log2(scale(ns)),log2(F(ns)),'sk','MarkerFaceColor',[.4 .4 .4],'MarkerSize',8); hold on;
plot(log2(scale),RegLine,'-k','LineWidth',2); hold on;
xlim([scmin-.5 scmax+.5]);
ylim([min(log2(F))-.5 max(log2(F))+.5]);

set(gca,'XTick',[scmin:scmax],'XTickLabel',[2.^[scmin:scmax]],'YTick',floor(min(log2(F))):ceil(max(log2(F))),'YTickLabel',2.^[floor(min(log2(F))):ceil(max(log2(F)))]);
ylabel('RMS variation of [F^2(s,v)]')
xlabel('Scale (s)')
axis square

% Uncomment to save for further processing in Vector Graphics Software
% (e.g., Adobe Illustrator to add arrows and lines)
%grab('Hasselman2014_Figure8',0)

%% Figure 9 Multifractal Detrended Fluctuation Analysis

%load([datPath,'Hasselman2014_stimfeatures_ORI.mat']);

h0=figure;
maximize(h0);
cnt=0;

qmin=-10;
qmax=10;
qres=101;

qq = linspace(qmin,qmax,qres);

scmin=6;
scmax=12;
ressc=40;

scale=round(2.^[scmin:((scmax-scmin)/ressc):scmax]);

left = [1 4 7 10];
st   = [0 10 20 30];
stc  = [10 20 30 40 50 60 70 80 90 100];

cm  = gray(130);

for i = 1:4
 
 for s=1:10
  cnt=cnt+1;
  
  subplot(4,3,left(i));
  ax0 = gca;
  
  hf(s)=loglog(scale,(mf(cnt).Fq(find(qq==-5),:)),'.','Color',cm(stc(s),:),'LineWidth',2,'MarkerSize',15); hold on;
  hf(s)=loglog(scale,(mf(cnt).Fq(find(qq==-2),:)),'.','Color',cm(stc(s),:),'LineWidth',2,'MarkerSize',15); hold on;
  hf(s)=loglog(scale,(mf(cnt).Fq(find(qq==0),:)),'.','Color',cm(stc(s),:),'LineWidth',2,'MarkerSize',15); hold on;
  hf(s)=loglog(scale,(mf(cnt).Fq(find(qq==2),:)),'.','Color',cm(stc(s),:),'LineWidth',2,'MarkerSize',15); hold on;
  hf(s)=loglog(scale,(mf(cnt).Fq(find(qq==5),:)),'.','Color',cm(stc(s),:),'LineWidth',2,'MarkerSize',15); hold on;
  
  
  if s==10
   text(scale(1)-20,mf(cnt).Fq(find(qq==-5),1),'q=-5');
   text(scale(1)-20,mf(cnt).Fq(find(qq==-2),1),'q=-2');
   text(scale(1)-20,mf(cnt).Fq(find(qq==0),1),'q=0');
   text(scale(1)-20,mf(cnt).Fq(find(qq==2),1),'q=2');
   text(scale(1)-20,mf(cnt).Fq(find(qq==5),1),'q=5');
   loglog(scale(20:30),10.^[-3.5:.1:-2.5],'-k','LineWidth',2);
   text(scale(25),10^-3.5,'Slope = H(q)');
   
  end
  
  title('Scale dependency of q-order fluctuations F_q(s)');
  xlabel('Scale (Samples in Segment)')
  ylabel('F_q(s)')
  xlim([(min(scale)-25) (max(scale)+25)]);
  ylim([10^-4.5 10^2.5]);
  
  subplot(4,3,left(i)+1);
  ax1 = gca;
  
  hq(s)=plot(qq,mf(cnt).Hq,'Color',cm(stc(s),:),'LineWidth',2); hold on;
  title('q-order of scaling exponent H');
  xlabel('q')
  ylabel('H(q)')
  xlim([min(qq) max(qq)]);
  ylim([.45 2.55]);
  
  subplot(4,3,left(i)+2);
  ax2=gca;
  
  h(s)=plot(mf(cnt).hq,mf(cnt).Dq,'Color',cm(stc(s),:),'LineWidth',2); hold on;
  title('Multifractal Spectrum');
  xlabel('h(q)')
  ylabel('D(q)')
  ylim([-.05 1.05]);
  xlim([.45 2.55]);
  
 end
 
 Opos(i,:)=get(ax0,'Position');
 
 legend(h,...
  {['/bAk/'],...
  ['  2  '],... 
  ['  3  '],... 
  ['  4  '],... 
  ['  5  '],... 
  ['  6  '],... 
  ['  7  '],... 
  ['  8  '],... 
  ['  9  '],... 
  ['/dAk/']},... 
  'FontSize',10,...
  'FontName','Arial',...
  'Location','BestOutside')
 
 set(ax0,'XTick',2.^[scmin:scmax],'YTick',10.^[-4:2:2],'YTickLabel',num2cell(10.^[-4:2:2]));
 
 plot(ax1,[0 0],[0 2.55],':k');
 plot(ax1,[-5 -5],[-.05 2.55],':k');
 plot(ax1,[5 5],[-.05 2.55],':k');
 plot(ax1,[-2 -2],[-.05 2.55],':k');
 plot(ax1,[2 2],[-.05 2.55],':k');
 
 set(ax1,'XTick',[-10 -5:1:5 10]);
 
 qzero=mf(i).Hq(qq==0);
 qp2=mf(i).Hq(qq==2);
 qm2=mf(i).Hq(qq==-2);
 qp5=mf(i).Hq(qq==5);
 qm5=mf(i).Hq(qq==-5);
 plot(ax2,[qzero qzero],[-.05 2.55],':k');
 plot(ax2,[qp2 qp2],[-.05 2.55],'--k');
 plot(ax2,[qm2 qm2],[-.05 2.55],'--k');
 plot(ax2,[qp5 qp5],[-.05 2.55],'--k');
 plot(ax2,[qm5 qm5],[-.05 2.55],'--k');
 set(ax2,'XTick',[qp5 qp2 qzero qm2 qm5],'XTickLabel',{'','','q=0','q=-2','q=-5'});
 text((qp5-.1),-.1,'q=5');
 text(qp2-.01, -.1,'q=2');
 
 clear qzero qp2 qm2 qp5 qm5
 
end

Tpos = [-.1 -0.07 0 0];

h_1= annotation('textbox',[Opos(1,:)+Tpos],'String','None','EdgeColor','none','FontSize',16);
set(h_1,'FitBoxToText','on');
h_2= annotation('textbox',[Opos(2,:)+Tpos],'String','Slowed Down','EdgeColor','none','FontSize',16);
set(h_2,'FitBoxToText','on');
h_3= annotation('textbox',[Opos(3,:)+Tpos],'String','Amplified','EdgeColor','none','FontSize',16);
set(h_3,'FitBoxToText','on');
h_4=annotation('textbox',[Opos(4,:)+Tpos],'String','Both','EdgeColor','none','FontSize',16);
set(h_4,'FitBoxToText','on');

% Uncomment if you want to save a figure
%grab('Hasselman2014_Figure9',0)

%% Figure 10: LOGIT predictions
%load([datPath,'Hasselman2014_predictedLOGIT.mat']);

f0=figure;
maximize(f0);
subplot(2,2,1)
ax0=gca; pos=get(ax0,'Position');

% The order of colums is MEDIAN CI95.lower CI95.upper, for each manipulation None, Slowed Down Amplified Both
none  = errorbar([1:10]-0.1,LogitPredictAverage(:,1),[LogitPredictAverage(:,1)-LogitPredictAverage(:,2)],[LogitPredictAverage(:,3)-LogitPredictAverage(:,1)],'-');
hold on;

% The order of colums is MEDIAN CI95.lower CI95.upper, for each manipulation None, Slowed Down Amplified Both
noned = errorbar([1:10]+0.1,LogitPredictDyslexic(:,1),[LogitPredictDyslexic(:,1)-LogitPredictDyslexic(:,2)],[LogitPredictDyslexic(:,3)-LogitPredictDyslexic(:,1)],'-.');
hold on;
xlim([0.7 10.3]);
ylim([-0.05 1.05]);
threshold = line(xlim,[0.5 0.5],'Color',[0.5 0.5 0.5],'LineStyle','--');

set([none, noned], ...
 'Marker'          , 'o'        , ...
 'MarkerSize'      , 7          , ...
 'MarkerEdgeColor' , 'k'     , ...
 'MarkerFaceColor' , [.5 .5 .5] , ...
 'Color'       , 'k');

set(none, ...
 'MarkerFaceColor' , [0 0 0]);

set(gca, ...
 'TickDir'     , 'out'     , ...
 'TickLength'  , [.01 .01] , ...
 'YTick'       , 0:.1:1, ...
 'XTickLabel'  , {'/bAk/','2','3','4','5','6','7','8','9','/dAk/'},...
 'Box','off', ...
 'LineWidth'   , 1         );

legend('Average reader','Dyslexic reader','Location','SouthEast');
title('A. None');
xlabel('Stimulus');
ylabel('\fontsize{14}\it\pi\fontsize{12}\rm with \itCI\fontsize{10}_{.95}\fontsize{10}\rm  for Perceiving /dAk/');


subplot(2,2,2)
none=errorbar([1:10]-0.1,LogitPredictAverage(:,4),[LogitPredictAverage(:,4)-LogitPredictAverage(:,5)],[LogitPredictAverage(:,6)-LogitPredictAverage(:,4)],'-');
hold on;
noned=errorbar([1:10]+0.1,LogitPredictDyslexic(:,4),[LogitPredictDyslexic(:,4)-LogitPredictDyslexic(:,5)],[LogitPredictDyslexic(:,6)-LogitPredictDyslexic(:,4)],'-.');
hold on;
xlim([0.7 10.3]);
ylim([-0.05 1.05]);
threshold = line(xlim,[0.5 0.5],'Color',[0.5 0.5 0.5],'LineStyle','--');

set([none, noned], ...
 'Marker'          , 'v'        , ...
 'MarkerSize'      , 7          , ...
 'MarkerEdgeColor' , 'k'     , ...
 'MarkerFaceColor' , [.5 .5 .5] , ...
 'Color'       , 'k');

set(none, ...
 'MarkerFaceColor' , [0 0 0]);

set(gca, ...
 'TickDir'     , 'out'     , ...
 'TickLength'  , [.01 .01] , ...
 'YTick'       , 0:.1:1, ...
 'XTickLabel'  , {'/bAk/','2','3','4','5','6','7','8','9','/dAk/'},...
 'Box','off', ...
 'LineWidth'   , 1         );


legend('Average reader','Dyslexic reader','Location','SouthEast');
title('B. Slowed down');
xlabel('Stimulus');
ylabel('\fontsize{14}\it\pi\fontsize{12}\rm with \itCI\fontsize{10}_{.95}\fontsize{10}\rm  for Perceiving /dAk/');


subplot(2,2,3)
none=errorbar([1:10]-0.1,LogitPredictAverage(:,7),[LogitPredictAverage(:,7)-LogitPredictAverage(:,8)],[LogitPredictAverage(:,9)-LogitPredictAverage(:,7)],'-');
hold on;
noned=errorbar([1:10]+0.1,LogitPredictDyslexic(:,7),[LogitPredictDyslexic(:,7)-LogitPredictDyslexic(:,8)],[LogitPredictDyslexic(:,9)-LogitPredictDyslexic(:,7)],'-.');
hold on;
xlim([0.7 10.3]);
ylim([-0.05 1.05]);
threshold = line(xlim,[0.5 0.5],'Color',[0.5 0.5 0.5],'LineStyle','--');

set([none, noned], ...
 'Marker'          , '^'        , ...
 'MarkerSize'      , 7          , ...
 'MarkerEdgeColor' , 'k'     , ...
 'MarkerFaceColor' , [.5 .5 .5] , ...
 'Color'       , 'k');

set(none, ...
 'MarkerFaceColor' , [0 0 0]);

set(gca, ...
 'TickDir'     , 'out'     , ...
 'TickLength'  , [.01 .01] , ...
 'YTick'       , 0:.1:1, ...
 'XTickLabel'  , {'/bAk/','2','3','4','5','6','7','8','9','/dAk/'},...
 'Box','off', ...
 'LineWidth'   , 1         );

legend('Average reader','Dyslexic reader','Location','SouthEast');
title('C. Amplified');
xlabel('Stimulus');
ylabel('\fontsize{14}\it\pi\fontsize{12}\rm with \itCI\fontsize{10}_{.95}\fontsize{10}\rm  for Perceiving /dAk/');


subplot(2,2,4)
none=errorbar([1:10]-0.1,LogitPredictAverage(:,10),[LogitPredictAverage(:,10)-LogitPredictAverage(:,11)],[LogitPredictAverage(:,12)-LogitPredictAverage(:,10)],'-');
hold on;
noned=errorbar([1:10]+0.1,LogitPredictDyslexic(:,10),[LogitPredictDyslexic(:,10)-LogitPredictDyslexic(:,11)],[LogitPredictDyslexic(:,12)-LogitPredictDyslexic(:,10)],'-.');
hold on;
xlim([0.7 10.3]);
ylim([-0.05 1.05]);
threshold = line(xlim,[0.5 0.5],'Color',[0.5 0.5 0.5],'LineStyle','--');

set([none, noned], ...
 'Marker'          , 'd'        , ...
 'MarkerSize'      , 7          , ...
 'MarkerEdgeColor' , 'k'     , ...
 'MarkerFaceColor' , [.5 .5 .5] , ...
 'Color'       , 'k');

set(none, ...
 'MarkerFaceColor' , [0 0 0]);

set(gca, ...
 'TickDir'     , 'out'     , ...
 'TickLength'  , [.01 .01] , ...
 'YTick'       , 0:.1:1, ...
 'XTickLabel'  , {'/bAk/','2','3','4','5','6','7','8','9','/dAk/'},...
 'Box','off', ...
 'LineWidth'   , 1         );

legend('Average reader','Dyslexic reader','Location','SouthEast');
title('D. Both');
xlabel('Stimulus');
ylabel('\fontsize{14}\it\pi\fontsize{12}\rm with \itCI\fontsize{10}_{.95}\fontsize{10}\rm  for Perceiving /dAk/');


%keep Formants HNR RTent SPEC STIM rpSTATS rpTS stimuli rpMTRX LogitPredictAverage LogitPredictDyslexic mf stimuliMF datPath dource

% Uncomment if you want to save a figure
% grab('Hasselman2014_Figure10',0);

