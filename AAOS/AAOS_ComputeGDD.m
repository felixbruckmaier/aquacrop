%% Computes cumulated sum of GDD's within growing season (only for 1 crop)
% - code snippet from 'AOS_ComputeCropCalendar.m'
function GDDcumsum = AAOS_ComputeGDD()

%% Declare global variables %%
global AOS_ClockStruct
global AOS_InitialiseStruct

Weather = AOS_InitialiseStruct.Weather;
tSto = AOS_ClockStruct.HarvestDate;
tSta = AOS_ClockStruct.PlantingDate;
Dates = Weather(:,1);

StaRow = find(Dates==tSta);
StoRow = find(Dates==tSto);
Tmin = Weather(StaRow:StoRow,2);
Tmax = Weather(StaRow:StoRow,3);


% Calculate GDD's
Crops = AOS_InitialiseStruct.Parameter.Crop;
CropName =  string(fieldnames(Crops(1)));
Crop = Crops.(CropName);

if Crop.GDDmethod == 1
    Tmean = (Tmax+Tmin)/2;
    Tmean(Tmean>Crop.Tupp) = Crop.Tupp;
    Tmean(Tmean<Crop.Tbase) = Crop.Tbase;
    GDD = Tmean-Crop.Tbase;
elseif Crop.GDDmethod == 2
    Tmax(Tmax>Crop.Tupp) = Crop.Tupp;
    Tmax(Tmax<Crop.Tbase) = Crop.Tbase;
    Tmin(Tmin>Crop.Tupp) = Crop.Tupp;
    Tmin(Tmin<Crop.Tbase) = Crop.Tbase;
    Tmean = (Tmax+Tmin)/2;
    GDD = Tmean-Crop.Tbase;
elseif Crop.GDDmethod == 3
    Tmax(Tmax>Crop.Tupp) = Crop.Tupp;
    Tmax(Tmax<Crop.Tbase) = Crop.Tbase;
    Tmin(Tmin>Crop.Tupp) = Crop.Tupp;
    Tmean = (Tmax+Tmin)/2;
    Tmean(Tmean<Crop.Tbase) = Crop.Tbase;
    GDD = Tmean-Crop.Tbase;
end
% Store computed cumulated sum of GDD's within simulation period:
GDDcumsum = cumsum(GDD);
end