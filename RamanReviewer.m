% Raman Review MATLAB Program %
% Author: Kenny Brown
% Version 1.1 (8/16/2021)
clc
clear all
close all

%% OVERVIEW

% == Overview == %
% This program is designed to use data exported from the Renishaw Raman
% available at the University of Virginia Nano Materials Characterization
% Facility.

% == Data Format == %
% File format: *.txt
% Column 1, Raman shift (cm-1) in descending order
% Column 2, Intensity (counts)

% == Notes to User == %
% Adjusting the find peaks settings may be required to indicate the
% characteristic peaks of Raman spectra of graphene. Peaks should at least
% be indicated at ~1350 cm-1 (D-peak), ~1580 cm-1 (G-Peak), and ~2720 cm-1
% (2D peak), without any peaks located in between.

%% SPECTRA IMPORT

% Select spectral data file
[file,path] = uigetfile('*.txt');
data = importdata([path file]);

% Shift data down y-axis so min intensity at zero
shift = min(data(:,2));
data(:,2) = data(:,2)-shift;

% Determine characteristic peaks in each typical range for thoes peaks

% D Peak
Dsearch = find(data(:,1)>1325 & data(:,1)<1375);
[Dpk,Dloc] = findpeaks(data(Dsearch,2),'NPeaks',1);
Dloc = Dsearch(Dloc);

% G Peak
Gsearch = find(data(:,1)>1550 & data(:,1)<1600);
[Gpk,Gloc] = findpeaks(data(Gsearch,2),'NPeaks',1);
Gloc = Gsearch(Gloc);

% 2D Peak
D2search = find(data(:,1)>2650 & data(:,1)<2750);
[D2pk,D2loc] = findpeaks(data(D2search,2),'MinPeakProminence',150);
D2loc = D2search(D2loc);

% D+G Peak
DGsearch = find(data(:,1)>2925 & data(:,1)<2975);
[DGpk,DGloc] = findpeaks(data(DGsearch,2),'NPeaks',1,'MinPeakProminence',25);
DGloc = DGsearch(DGloc);

% 2D prime Peak
D2psearch = find(data(:,1)>3225 & data(:,1)<3275);
[D2ppk,D2ploc] = findpeaks(data(D2psearch,2),'NPeaks',1,'MinPeakProminence',50);
D2ploc = D2psearch(D2ploc);

% Concatenate peak locations and intensities
locs=[Dloc,Gloc,D2loc,DGloc,D2ploc];
pks=[Dpk,Gpk,D2pk,DGpk,D2ppk];

%% PLOT SPECTRA w/ PEAKS
figure
plot(data(:,1),data(:,2),data(locs),pks,'o')
xlim([data(length(data),1) data(1,1)])
%set(gca,'XDir','reverse') %Some show the spectra in descending shift. You
%can uncomment this to reverse the plot x-axis
xlabel('Raman Shift (1/cm)')
ylabel('Intensity (rel.)')
title(file,'Interpreter','none')

%% GRAPHENE CHARACTERIZATIONS

% Raman Shift of Characteristic Peaks
Peak_D = data(Dloc);
Peak_G = data(Gloc);
Peak_2D = data(D2loc);

% Number of layers by G peak position
lyrbyG = ((7963-5*Peak_G-1))/(5*Peak_G-7908)^(5/8);
fprintf('Number of layers as indicated by G-peak: %f\n\n', lyrbyG)

% Number of layers by IG/I2D
IGI2D = Gpk/D2pk;
lyrbyG_2D = (IGI2D-0.14)*10;
fprintf('Number of layers as indicated by IG / I2D ratio: %f\n\n', lyrbyG_2D)

%% Changelog
% V1.1 - replaced full spectrum findpeaks with individual findpeaks for
% each target peak range (G,D,2D,DG, and 2D prim peaks) to make peak
% finding more reliable. added function to shift trace to y-axis to improve
% IG/I2D ratio calculation.