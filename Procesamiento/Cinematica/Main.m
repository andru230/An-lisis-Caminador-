%% speeding Up MATLAB Applications


clc 
close all

animation = 1;

a = load('Walking3Markers.mat');
DataWalking = a.Walking3Markers;
a = load('Walking3names.mat');
DataWalking_names = a.Walking3names;
a = load('Standing3Markers.mat');
DataStanding = a.Standing3Markers;
a = load('Standing3names.mat');
DataStanding_names = a.Standing3names;

%DataWalking = Walking3Markers;
%DataWalking_names = Walking3names;
%DataStanding = Standing3Markers;
%DataStanding_names = Standing3names;


%% Anthropometric measures(m) and weight (Kg)

R_mall_distance=0.09;
R_epy_distance=0.11;
R_pelvis_depth=0.11;
R_real_leg_length=0.89;

L_mall_distance=0.09;
L_epy_distance=0.11;
L_pelvis_depth=0.11;
L_real_leg_length=0.89;

Asis_distance=0.28;
DmidAB = 0.14;
height=1.79;

weight = 78;

%% Important Values to keep in mind

Rmarker = 0.01;

%% Lab reference system

Lab_ref_sys = [1 0 0; 0 1 0; 0 0 1];


% Standing -- Standing -- Standing -- Standing -- Standing -- Standing
% Standing -- Standing -- Standing -- Standing -- Standing -- Standing
% Standing -- Standing -- Standing -- Standing -- Standing -- Standing
% Standing -- Standing -- Standing -- Standing -- Standing -- Standing

%% Force plataforms use Detection 

[N_frames, N_points] = size(DataStanding) ;

End_Markers = Find_name(DataStanding_names,'r gr.X');
if isnan(End_Markers)
    End_Markers = N_points;
else
    End_Markers = End_Markers - 1;
end

%% Data Interpolation 

Inter_Data_S = [];
Inter_Data_S(:,1) = DataStanding(:,1);
Inter_Data_S(:,2) = DataStanding(:,2);
for x=3:End_Markers
    Inter_Data_S(:,x) = Iter_point(DataStanding(:,x),DataStanding(:,1),0);
end

%% Data Filter

Filtered_Data_S = [];
Filtered_Data_S(:,1) = DataStanding(:,1);
Filtered_Data_S(:,2) = DataStanding(:,2);

for x=3:End_Markers
    Filtered_Data_S(:,x) = Butterworth_LP_filter(Inter_Data_S(:,x),DataStanding_names{x},100,20,2,0);
end



%% Asis correction

[S_R_Asis2,S_L_Asis2] = Asis_correction(DataStanding_names,Filtered_Data_S,Asis_distance);

R_hip_CR_local = R_RC_LocalValue(Asis_distance, R_pelvis_depth, R_real_leg_length);
L_hip_CR_local = L_RC_LocalValue(Asis_distance, L_pelvis_depth, L_real_leg_length);

% Centers rotation estimation -- Centers rotation estimation -- Centers rotation estimation --Centers rotation estimation
% Centers rotation estimation -- Centers rotation estimation -- Centers rotation estimation --Centers rotation estimation


%% Knee center rotation estimation 

S_R_Knee_RC = BTS_Dav_Heel_R_Knee_RC(Filtered_Data_S,DataStanding_names,R_epy_distance,0);
S_L_Knee_RC = BTS_Dav_Heel_L_Knee_RC(Filtered_Data_S,DataStanding_names,R_epy_distance,0);

%% Ankle center rotation estimation

S_R_Ankle_RC = BTS_Dav_Heel_R_Ankle_RC(Filtered_Data_S,DataStanding_names,R_mall_distance,0);
S_L_Ankle_RC = BTS_Dav_Heel_L_Ankle_RC(Filtered_Data_S,DataStanding_names,L_mall_distance,0);

%% Mestatarsus center rotation estimation

S_R_metatarsus_RC = BTS_Dav_Heel_R_metatarsus_RC(Filtered_Data_S,DataStanding_names,R_mall_distance,0);
S_L_metatarsus_RC = BTS_Dav_Heel_L_metatarsus_RC(Filtered_Data_S,DataStanding_names,R_mall_distance,0);

%% Hip center rotation estimation

[S_R_hip_RC , S_L_hip_RC] = BTS_Dav_Heel_R_hip_RC(Filtered_Data_S,DataStanding_names,S_R_Asis2,S_L_Asis2,R_hip_CR_local,L_hip_CR_local,0);


% Gravity centers estimation -- Gravity centers estimation -- Gravity centers estimation
% Gravity centers estimation -- Gravity centers estimation -- Gravity centers estimation

%% Calf gravity center estimation 

S_R_Calf_CG = BTS_Dav_Heel_R_calf_CG(S_R_Knee_RC, S_R_Ankle_RC,Filtered_Data_S(:,2),0);
S_L_Calf_CG = BTS_Dav_Heel_L_calf_CG(S_L_Knee_RC, S_L_Ankle_RC,Filtered_Data_S(:,2),0);

%% Thigh gravity center estimation 

S_R_Thigh_CG = BTS_Dav_Heel_R_thigh_CG(S_R_hip_RC, S_R_Knee_RC ,Filtered_Data_S(:,2),0);
S_L_Thigh_CG = BTS_Dav_Heel_L_thigh_CG(S_L_hip_RC, S_L_Knee_RC, Filtered_Data_S(:,2),0);

%% Foot gravity center estimation 

S_R_Foot_CG = BTS_Dav_Heel_R_standing_foot_CG(Filtered_Data_S, DataStanding_names ,S_R_metatarsus_RC,0);
S_L_Foot_CG = BTS_Dav_Heel_L_standing_foot_CG(Filtered_Data_S, DataStanding_names ,S_L_metatarsus_RC,0);

% Anatomical Reference systems estimation -- Anatomical Reference systems estimation 
% Anatomical Reference systems estimation -- Anatomical Reference systems estimation

%% Calf anatomical reference system estimation -- Calf anatomical reference system estimation

S_R_Calf_Anat_RefSys = BTS_Dav_Heel_R_calf_RefSys(Filtered_Data_S, DataStanding_names ,S_R_Calf_CG,S_R_Knee_RC,S_R_Ankle_RC,0);
S_L_Calf_Anat_RefSys = BTS_Dav_Heel_L_calf_RefSys(Filtered_Data_S, DataStanding_names ,S_L_Calf_CG,S_L_Knee_RC,S_L_Ankle_RC,0);

%% Thigh anatomical reference system estimation -- Calf anatomical reference system estimation

S_R_Thigh_Anat_RefSys = BTS_Dav_Heel_R_thigh_RefSys(Filtered_Data_S, DataStanding_names ,S_R_Thigh_CG,S_R_hip_RC,S_R_Knee_RC,0);
S_L_Thigh_Anat_RefSys = BTS_Dav_Heel_L_thigh_RefSys(Filtered_Data_S, DataStanding_names ,S_L_Thigh_CG,S_L_hip_RC,S_L_Knee_RC,0);

%% Foot anatomical reference system estimation -- Calf anatomical reference system estimation

S_R_Foot_Anat_RefSys = BTS_Dav_Heel_R_foot_RefSys(Filtered_Data_S, DataStanding_names ,S_R_Foot_CG,S_R_Ankle_RC,S_R_metatarsus_RC,0);
S_L_Foot_Anat_RefSys = BTS_Dav_Heel_L_foot_RefSys(Filtered_Data_S, DataStanding_names ,S_L_Foot_CG,S_L_Ankle_RC,S_L_metatarsus_RC,0);

%% Pelvis anatomical reference system estimation -- Calf anatomical reference system estimation

S_Pelvis_Anat_RefSys = BTS_Dav_Heel_R_pelvis_RefSys(Filtered_Data_S, DataStanding_names, S_R_Asis2, S_L_Asis2 ,0);

% Anatomical Angles -- Anatomical Angles -- Anatomical Angles -- Anatomical Angles
% Anatomical Angles -- Anatomical Angles -- Anatomical Angles -- Anatomical Angles

%% Ankle anatomical angles estimation -- Ankle anatomical angles estimation

S_R_Ankle_Ant_Angles = BTS_Dav_Heel_R_ankle_angles(Filtered_Data_S,S_R_Calf_Anat_RefSys, S_R_Foot_Anat_RefSys,0);
S_L_Ankle_Ant_Angles = BTS_Dav_Heel_L_ankle_angles(Filtered_Data_S,S_L_Calf_Anat_RefSys, S_L_Foot_Anat_RefSys,0);

%% Knee anatomical angles estimation -- Knee anatomical angles estimation

S_R_Knee_Ant_Angles = BTS_Dav_Knee_R_knee_angles(Filtered_Data_S,S_R_Thigh_Anat_RefSys, S_R_Calf_Anat_RefSys,0);
S_L_Knee_Ant_Angles = BTS_Dav_Knee_L_knee_angles(Filtered_Data_S,S_L_Thigh_Anat_RefSys, S_L_Calf_Anat_RefSys,0);


% Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking
% Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking
% Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking
% Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking -- Walking

Walking_Final_Data = {};

Walking_Final_Data{1,1} = 'DataWalking';
Walking_Final_Data{2,1} =  DataWalking_names;
Walking_Final_Data{3,1} = DataWalking;

%% Force plataforms use Detection 

[N_frames, N_points] = size(DataWalking) ;

End_Markers = Find_name(DataWalking_names,'r gr.X');
if isnan(End_Markers)
    End_Markers = N_points;
else
    End_Markers = End_Markers - 1;
end

%% Data Interpolation 

Inter_Data_W = [];
Inter_Data_W(:,1) = DataWalking(:,1);
Inter_Data_W(:,2) = DataWalking(:,2);
for x=3:End_Markers
    Inter_Data_W(:,x) = Iter_point(DataWalking(:,x),DataWalking(:,1),0);
end

Walking_Final_Data{1,2} = 'Data Interpolated';
Walking_Final_Data{2,2} =  DataWalking_names;
Walking_Final_Data{3,2} = Inter_Data_W;

%% Data Filter

Filtered_Data_W = [];
Filtered_Data_W(:,1) = DataWalking(:,1);
Filtered_Data_W(:,2) = DataWalking(:,2);

for x=3:End_Markers
    Filtered_Data_W(:,x) = Butterworth_LP_filter(Inter_Data_W(:,x),DataWalking_names{x},100,20,2,0);
end

Walking_Final_Data{1,3} = 'Data Filtered';
Walking_Final_Data{2,3} =  DataWalking_names;
Walking_Final_Data{3,3} = Filtered_Data_W;

%% Asis correction

[W_R_Asis2,W_L_Asis2] = Asis_correction(DataWalking_names,Filtered_Data_W,Asis_distance);

% Centers rotation estimation -- Centers rotation estimation -- Centers rotation estimation --Centers rotation estimation
% Centers rotation estimation -- Centers rotation estimation -- Centers rotation estimation --Centers rotation estimation

Centers_rotation_names = {};
Centers_rotation_data = [];
Indi = 1;

%% Knee center rotation estimation 

W_R_Knee_RC = BTS_Dav_Heel_R_Knee_RC(Filtered_Data_W,DataWalking_names,R_epy_distance,0);
Centers_rotation_names{Indi}   = 'W_R_Knee_RC.X';
Centers_rotation_names{Indi+1} = 'W_R_Knee_RC.Y';
Centers_rotation_names{Indi+2} = 'W_R_Knee_RC.Z';
Centers_rotation_data(:,Indi:Indi+2) = W_R_Knee_RC;
Indi = Indi + 3;

W_L_Knee_RC = BTS_Dav_Heel_L_Knee_RC(Filtered_Data_W,DataWalking_names,R_epy_distance,0);
Centers_rotation_names{Indi}   = 'W_L_Knee_RC.X';
Centers_rotation_names{Indi+1} = 'W_L_Knee_RC.Y';
Centers_rotation_names{Indi+2} = 'W_L_Knee_RC.Z';
Centers_rotation_data(:,Indi:Indi+2) = W_L_Knee_RC;
Indi = Indi + 3;

%% Ankle center rotation estimation

W_R_Ankle_RC = BTS_Dav_Heel_R_Ankle_RC(Filtered_Data_W,DataWalking_names,R_mall_distance,0);
Centers_rotation_names{Indi}   = 'W_R_Ankle_RC.X';
Centers_rotation_names{Indi+1} = 'W_R_Ankle_RC.Y';
Centers_rotation_names{Indi+2} = 'W_R_Ankle_RC.Z';
Centers_rotation_data(:,Indi:Indi+2) = W_R_Ankle_RC;
Indi = Indi + 3;

W_L_Ankle_RC = BTS_Dav_Heel_L_Ankle_RC(Filtered_Data_W,DataWalking_names,L_mall_distance,0);
Centers_rotation_names{Indi}   = 'W_L_Ankle_RC.X';
Centers_rotation_names{Indi+1} = 'W_L_Ankle_RC.Y';
Centers_rotation_names{Indi+2} = 'W_L_Ankle_RC.Z';
Centers_rotation_data(:,Indi:Indi+2) = W_L_Ankle_RC;
Indi = Indi + 3;

%% Mestatarsus center rotation estimation

W_R_metatarsus_RC = BTS_Dav_Heel_R_metatarsus_RC(Filtered_Data_W,DataWalking_names,R_mall_distance,0);
Centers_rotation_names{Indi}   = 'W_R_metatarsus_RC.X';
Centers_rotation_names{Indi+1} = 'W_R_metatarsus_RC.Y';
Centers_rotation_names{Indi+2} = 'W_R_metatarsus_RC.Z';
Centers_rotation_data(:,Indi:Indi+2) = W_R_metatarsus_RC;
Indi = Indi + 3;

W_L_metatarsus_RC = BTS_Dav_Heel_L_metatarsus_RC(Filtered_Data_W,DataWalking_names,R_mall_distance,0);
Centers_rotation_names{Indi}   = 'W_L_metatarsus_RC.X';
Centers_rotation_names{Indi+1} = 'W_L_metatarsus_RC.Y';
Centers_rotation_names{Indi+2} = 'W_L_metatarsus_RC.Z';
Centers_rotation_data(:,Indi:Indi+2) = W_L_metatarsus_RC;
Indi = Indi + 3;

%% Hip center rotation estimation

[W_R_hip_RC , W_L_hip_RC] = BTS_Dav_Heel_R_hip_RC(Filtered_Data_W,DataWalking_names,W_R_Asis2,W_L_Asis2,R_hip_CR_local,L_hip_CR_local,0);

Centers_rotation_names{Indi}   = 'W_R_hip_RC.X';
Centers_rotation_names{Indi+1} = 'W_R_hip_RC.Y';
Centers_rotation_names{Indi+2} = 'W_R_hip_RC.Z';
Centers_rotation_data(:,Indi:Indi+2) = W_R_hip_RC;
Indi = Indi + 3;

Centers_rotation_names{Indi}   = 'W_L_hip_RC.X';
Centers_rotation_names{Indi+1} = 'W_L_hip_RC.Y';
Centers_rotation_names{Indi+2} = 'W_L_hip_RC.Z';
Centers_rotation_data(:,Indi:Indi+2) = W_L_hip_RC;
Indi = Indi + 3;


Walking_Final_Data{1,4} = 'Centers Rotation';
Walking_Final_Data{2,4} =  Centers_rotation_names;
Walking_Final_Data{3,4} = Centers_rotation_data;


% Gravity centers estimation -- Gravity centers estimation -- Gravity centers estimation
% Gravity centers estimation -- Gravity centers estimation -- Gravity centers estimation

Gravity_centers_names = {};
Gravity_centers_data = [];
Indi = 1;

%% Calf gravity center estimation 

W_R_Calf_CG = BTS_Dav_Heel_R_calf_CG(W_R_Knee_RC, W_R_Ankle_RC,Filtered_Data_W(:,2),0);
Gravity_centers_names{Indi}   = 'W_R_Calf_CG.X';
Gravity_centers_names{Indi+1} = 'W_R_Calf_CG.Y';
Gravity_centers_names{Indi+2} = 'W_R_Calf_CG.Z';
Gravity_centers_data(:,Indi:Indi+2) = W_R_Calf_CG;
Indi = Indi + 3;

W_L_Calf_CG = BTS_Dav_Heel_L_calf_CG(W_L_Knee_RC, W_L_Ankle_RC,Filtered_Data_W(:,2),0);
Gravity_centers_names{Indi}   = 'W_L_Calf_CG.X';
Gravity_centers_names{Indi+1} = 'W_L_Calf_CG.Y';
Gravity_centers_names{Indi+2} = 'W_L_Calf_CG.Z';
Gravity_centers_data(:,Indi:Indi+2) = W_L_Calf_CG;
Indi = Indi + 3;


%% Thigh gravity center estimation 

W_R_Thigh_CG = BTS_Dav_Heel_R_thigh_CG(W_R_hip_RC, W_R_Knee_RC ,Filtered_Data_W(:,2),0);
Gravity_centers_names{Indi}   = 'W_R_Thigh_CG.X';
Gravity_centers_names{Indi+1} = 'W_R_Thigh_CG.Y';
Gravity_centers_names{Indi+2} = 'W_R_Thigh_CG.Z';
Gravity_centers_data(:,Indi:Indi+2) = W_R_Thigh_CG;
Indi = Indi + 3;

W_L_Thigh_CG = BTS_Dav_Heel_L_thigh_CG(W_L_hip_RC, W_L_Knee_RC, Filtered_Data_W(:,2),0);
Gravity_centers_names{Indi}   = 'W_L_Thigh_CG.X';
Gravity_centers_names{Indi+1} = 'W_L_Thigh_CG.Y';
Gravity_centers_names{Indi+2} = 'W_L_Thigh_CG.Z';
Gravity_centers_data(:,Indi:Indi+2) = W_L_Thigh_CG;
Indi = Indi + 3;


%% Foot gravity center estimation 

W_R_Foot_CG = BTS_Dav_Heel_R_standing_foot_CG(Filtered_Data_W, DataWalking_names ,W_R_metatarsus_RC,0);
Gravity_centers_names{Indi}   = 'W_R_Foot_CG.X';
Gravity_centers_names{Indi+1} = 'W_R_Foot_CG.Y';
Gravity_centers_names{Indi+2} = 'W_R_Foot_CG.Z';
Gravity_centers_data(:,Indi:Indi+2) = W_R_Foot_CG;
Indi = Indi + 3;

W_L_Foot_CG = BTS_Dav_Heel_L_standing_foot_CG(Filtered_Data_W, DataWalking_names ,W_L_metatarsus_RC,0);
Gravity_centers_names{Indi}   = 'W_L_Foot_CG.X';
Gravity_centers_names{Indi+1} = 'W_L_Foot_CG.Y';
Gravity_centers_names{Indi+2} = 'W_L_Foot_CG.Z';
Gravity_centers_data(:,Indi:Indi+2) = W_L_Foot_CG;
Indi = Indi + 3;

Walking_Final_Data{1,5} = 'Centers gravity';
Walking_Final_Data{2,5} =  Gravity_centers_names;
Walking_Final_Data{3,5} = Gravity_centers_data;


% Anatomical Reference systems estimation -- Anatomical Reference systems estimation 
% Anatomical Reference systems estimation -- Anatomical Reference systems estimation

Anatomical_Ref_Sys_names = {};
Anatomical_Ref_Sys_data = {};
Indi = 1;

%% Calf anatomical reference system estimation -- Calf anatomical reference system estimation

W_R_Calf_Anat_RefSys = BTS_Dav_Heel_R_calf_RefSys(Filtered_Data_W, DataWalking_names ,W_R_Calf_CG,S_R_Knee_RC,S_R_Ankle_RC,0);
Anatomical_Ref_Sys_names{Indi}   = 'W_R_Calf_Anat_RefSys';
Anatomical_Ref_Sys_data{Indi} =  W_R_Calf_Anat_RefSys;
Indi = Indi + 1;

W_L_Calf_Anat_RefSys = BTS_Dav_Heel_L_calf_RefSys(Filtered_Data_W, DataWalking_names ,W_L_Calf_CG,S_L_Knee_RC,S_L_Ankle_RC,0);
Anatomical_Ref_Sys_names{Indi}   = 'W_L_Calf_Anat_RefSys';
Anatomical_Ref_Sys_data{Indi} =  W_L_Calf_Anat_RefSys;
Indi = Indi + 1;

%% Thigh anatomical reference system estimation -- Calf anatomical reference system estimation

W_R_Thigh_Anat_RefSys = BTS_Dav_Heel_R_thigh_RefSys(Filtered_Data_W, DataWalking_names ,W_R_Thigh_CG,S_R_hip_RC,S_R_Knee_RC,0);
Anatomical_Ref_Sys_names{Indi}   = 'W_R_Thigh_Anat_RefSys';
Anatomical_Ref_Sys_data{Indi} =  W_R_Thigh_Anat_RefSys;
Indi = Indi + 1;

W_L_Thigh_Anat_RefSys = BTS_Dav_Heel_L_thigh_RefSys(Filtered_Data_W, DataWalking_names ,W_L_Thigh_CG,S_L_hip_RC,S_L_Knee_RC,0);
Anatomical_Ref_Sys_names{Indi}   = 'W_L_Thigh_Anat_RefSys';
Anatomical_Ref_Sys_data{Indi} =  W_L_Thigh_Anat_RefSys;
Indi = Indi + 1;

%% Foot anatomical reference system estimation -- Calf anatomical reference system estimation

W_R_Foot_Anat_RefSys = BTS_Dav_Heel_R_foot_RefSys(Filtered_Data_W, DataWalking_names ,W_R_Foot_CG,S_R_Ankle_RC,S_R_metatarsus_RC,0);
Anatomical_Ref_Sys_names{Indi}   = 'W_R_Foot_Anat_RefSys';
Anatomical_Ref_Sys_data{Indi} =  W_R_Foot_Anat_RefSys;
Indi = Indi + 1;

W_L_Foot_Anat_RefSys = BTS_Dav_Heel_L_foot_RefSys(Filtered_Data_W, DataWalking_names ,W_L_Foot_CG,S_L_Ankle_RC,S_L_metatarsus_RC,0);
Anatomical_Ref_Sys_names{Indi}   = 'W_L_Foot_Anat_RefSys';
Anatomical_Ref_Sys_data{Indi} =  W_L_Foot_Anat_RefSys;
Indi = Indi + 1;

%% Pelvis anatomical reference system estimation -- Calf anatomical reference system estimation

W_Pelvis_Anat_RefSys = BTS_Dav_Heel_R_pelvis_RefSys(Filtered_Data_W, DataWalking_names, W_R_Asis2, W_L_Asis2 ,0);
Anatomical_Ref_Sys_names{Indi}   = 'W_Pelvis_Anat_RefSys';
Anatomical_Ref_Sys_data{Indi} =  W_Pelvis_Anat_RefSys;
Indi = Indi + 1;


Walking_Final_Data{1,6} = 'Anatomical Ref Sys';
Walking_Final_Data{2,6} =  Anatomical_Ref_Sys_names;
Walking_Final_Data{3,6} = Anatomical_Ref_Sys_data;

% Anatomical Angles -- Anatomical Angles -- Anatomical Angles -- Anatomical Angles
% Anatomical Angles -- Anatomical Angles -- Anatomical Angles -- Anatomical Angles

Anatomical_angles_names = {};
Anatomical_angles_data = [];
Indi = 1;

%% Ankle anatomical angles estimation -- Ankle anatomical angles estimation

W_R_Ankle_Ant_Angles = BTS_Dav_Heel_R_ankle_angles(Filtered_Data_W,W_R_Calf_Anat_RefSys, W_R_Foot_Anat_RefSys,0);
Anatomical_angles_names{Indi}   = 'W_R_Ankle_Ant_Angles.X';
Anatomical_angles_names{Indi+1} = 'W_R_Ankle_Ant_Angles.Y';
Anatomical_angles_names{Indi+2} = 'W_R_Ankle_Ant_Angles.Z';
Anatomical_angles_data(:,Indi:Indi+2) = W_R_Ankle_Ant_Angles;
Indi = Indi + 3;

W_L_Ankle_Ant_Angles = BTS_Dav_Heel_L_ankle_angles(Filtered_Data_W,W_L_Calf_Anat_RefSys, W_L_Foot_Anat_RefSys,0);
Anatomical_angles_names{Indi}   = 'W_L_Ankle_Ant_Angles.X';
Anatomical_angles_names{Indi+1} = 'W_L_Ankle_Ant_Angles.Y';
Anatomical_angles_names{Indi+2} = 'W_L_Ankle_Ant_Angles.Z';
Anatomical_angles_data(:,Indi:Indi+2) = W_L_Ankle_Ant_Angles;
Indi = Indi + 3;


%% Knee anatomical angles estimation -- Knee anatomical angles estimation

W_R_Knee_Ant_Angles = BTS_Dav_Knee_R_knee_angles(Filtered_Data_W,W_R_Thigh_Anat_RefSys, W_R_Calf_Anat_RefSys,0);
Anatomical_angles_names{Indi}   = 'W_R_Knee_Ant_Angles.X';
Anatomical_angles_names{Indi+1} = 'W_R_Knee_Ant_Angles.Y';
Anatomical_angles_names{Indi+2} = 'W_R_Knee_Ant_Angles.Z';
Anatomical_angles_data(:,Indi:Indi+2) = W_R_Knee_Ant_Angles;
Indi = Indi + 3;


W_L_Knee_Ant_Angles = BTS_Dav_Knee_L_knee_angles(Filtered_Data_W,W_L_Thigh_Anat_RefSys, W_L_Calf_Anat_RefSys,0);
Anatomical_angles_names{Indi}   = 'W_L_Knee_Ant_Angles.X';
Anatomical_angles_names{Indi+1} = 'W_L_Knee_Ant_Angles.Y';
Anatomical_angles_names{Indi+2} = 'W_L_Knee_Ant_Angles.Z';
Anatomical_angles_data(:,Indi:Indi+2) = W_L_Knee_Ant_Angles;
Indi = Indi + 3;



Walking_Final_Data{1,7} = 'Anatomical Angles';
Walking_Final_Data{2,7} =  Anatomical_angles_names;
Walking_Final_Data{3,7} = Anatomical_angles_data;

% Animation -- Animation -- Animation -- Animation -- Animation 
% Animation -- Animation -- Animation -- Animation -- Animation 
% Animation -- Animation -- Animation -- Animation -- Animation 
% Animation -- Animation -- Animation -- Animation -- Animation 

%%

if animation == 1
    
    X_postions = Find_all_names(DataWalking_names,'.X');
    Y_postions = Find_all_names(DataWalking_names,'.Y');
    Z_postions = Find_all_names(DataWalking_names,'.Z');

    for x=1:length(X_postions)
        X_data(:,x) = Filtered_Data_W(:,X_postions(x));
        Y_data(:,x) = Filtered_Data_W(:,Y_postions(x));
        Z_data(:,x) = Filtered_Data_W(:,Z_postions(x));
    end
    
    max_X = max(max(X_data));
    min_X = min(min(X_data));

    max_Y = max(max(Y_data));
    min_Y = min(min(Y_data));

    max_Z = max(max(Z_data));
    min_Z = min(min(Z_data));

    figure()
    ax = axes('XLim',[min_X-0.1*abs(min_X) max_X*1.1],'YLim'...
        ,[min_Z-0.1*abs(min_Z) max_Z*1.1],'ZLim',[min_Y-0.1*abs(min_Y) max_Y*1.1]);
    
    view(3)
    grid on
    axis equal;
    
    hold on
    xlabel('X')
    ylabel('Z')
    zlabel('Y')
    
    [x,y,z] = sphere(10);
  
    % Rotation points -- Rotation points -- Rotation points
    
    rad_RC = 0.025;
    Rot_cent_sphere = {};
    Rot_cent_t = {};
    
    [n_RotCen,m_RotCen] = size(Walking_Final_Data{3,4});
   
    for p=1:m_RotCen/3
        Rot_cent_sphere{p} = surface(x*rad_RC,y*rad_RC,z*rad_RC,'FaceColor','red');
        Rot_cent_t{p} = hgtransform('Parent',ax);
        set(Rot_cent_sphere{p},'Parent',Rot_cent_t{p})
    end
    
    
    % Markes points -- Markes points -- Markes points
    
    rad_Mar = 0.01;
    Markers_sphere = {};
    Markers_t = {};
    
    [n_Mark,m_Mark] = size(Walking_Final_Data{3,3});
   
    for p=1:m_Mark/3
        Markers_sphere{p} = surface(x*rad_Mar,y*rad_Mar,z*rad_Mar,'FaceColor','green');
        Markers_t{p} = hgtransform('Parent',ax);
        set(Markers_sphere{p},'Parent',Markers_t{p})
    end
    
    
    % Centers gravity points -- Centers gravity points -- Centers gravity points
    
    rad_CG = 0.025;
    CG_sphere = {};
    CG_t = {};
    
    [n_CG,m_CG] = size(Walking_Final_Data{3,5});
   
    for p=1:m_CG/3
        CG_sphere{p} = surface(x*rad_CG,y*rad_CG,z*rad_CG,'FaceColor','blue');
        CG_t{p} = hgtransform('Parent',ax);
        set(CG_sphere{p},'Parent',CG_t{p})
    end
    
    % Animation -- Animation -- Animation
 
    hTxt = text(min_X,min_Z,max_Y,'\fontsize{1}\color{blue}0\rightarrow');
    t = hgtransform('Parent',ax);
    set(hTxt,'Parent',t)
    
    [n,m] = size(Filtered_Data_W);
    for i = 1:n
        
          translation = [];
          l=1;
          for p=1:3:m_RotCen 
              translation = makehgtform('translate',Walking_Final_Data{3,4}(i,p)...
                                 ,Walking_Final_Data{3,4}(i,p+2),Walking_Final_Data{3,4}(i,p+1));
              set(Rot_cent_t{l},'Matrix',translation) 
              l=l+1;
          end
          
          l=1;
          for p=3:3:m_Mark
              translation = makehgtform('translate',Walking_Final_Data{3,3}(i,p)...
                                 ,Walking_Final_Data{3,3}(i,p+2),Walking_Final_Data{3,3}(i,p+1));
              set(Markers_t{l},'Matrix',translation) 
              l=l+1;
          end
          
          l=1;
          for p=1:3:m_CG
              translation = makehgtform('translate',Walking_Final_Data{3,5}(i,p)...
                                 ,Walking_Final_Data{3,5}(i,p+2),Walking_Final_Data{3,5}(i,p+1));
              set(CG_t{l},'Matrix',translation) 
              %set(t,'Matrix',translation)
             
              l=l+1;
          end
        
        set(hTxt,'String',num2str(i))
        
        drawnow 
        %pause(1/100)
      
    end
    
 
end
