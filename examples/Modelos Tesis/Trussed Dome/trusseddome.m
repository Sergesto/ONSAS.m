%md# Plasticity | shallow trussed dome
close all; clear;
addpath( genpath( [ pwd '/../../src'] ) );

% scalar parameters (N/cm2)
E = 206e3 ;
Kplas = 1545.1 ;
sigma_Y_0 = 258.3 ;
Fu = 1 ;

materials = struct();
materials.hyperElasModel  = 'isotropicHardening_logstrain' ;

materials.hyperElasParams = [ E Kplas sigma_Y_0 ] ;

elements = struct();
elements(1).elemType = 'node' ;
elements(2).elemType = 'truss';
elements(2).elemCrossSecParams = { 'circle' , sqrt(1*4/pi)} ;

boundaryConds = struct();
boundaryConds(1).imposDispDofs = [ 1 3 5 ] ;
boundaryConds(1).imposDispVals = [ 0 0 0 ] ;
boundaryConds(2).loadsCoordSys = 'global' ;
boundaryConds(2).loadsTimeFact = @(t) (Fu)*t ;
boundaryConds(2).loadsBaseVals = [ 0 0 0 0 1 0 ] ;

% MEBI [Material Element Boundary_Conditions Initial_Conditions]

base_msh='' ;

mesh = struct() ;
[ mesh.nodesCoords, mesh.conecCell ] = meshFileReader( [ base_msh 'TrussedDome.msh'] ) ;

initialConds                = struct() ;

analysisSettings = struct();

analysisSettings.stopTolDeltau =   1e-8 ;
analysisSettings.stopTolForces =   1e-8 ;
analysisSettings.stopTolIts    =   15   ;

analysisSettings.posVariableLoadBC = 2 ;

otherParams = struct();
otherParams.plots_format = 'vtk' ;
otherParams.plots_deltaTs_separation = 2 ; 

otherParams.problemName       = 'Shallow Trussed Dome' ;
analysisSettings.methodName   = 'arcLength' ;
analysisSettings.finalTime    = 600 ;
analysisSettings.incremArcLen = [-26/100*ones(1,100) -74/500*ones(1,500)] ;
analysisSettings.iniDeltaLamb = boundaryConds(2).loadsTimeFact(1)/600 ;
analysisSettings.posVariableLoadBC = 2 ;

global arcLengthFlag
arcLengthFlag = 2 ;

global dominantDofs
dominantDofs = 6*12+5 ;

global scalingProjection
scalingProjection = 1 ;

[matUs, loadFactorsMat] = ONSAS( materials, elements, boundaryConds, initialConds, mesh, analysisSettings, otherParams ) ;
controlDispsNRAL_Jirasek_logarithmic_strain =  -matUs(6*12+5,:) ;
loadFactorsNRAL_Jirasek_logarithmic_strain  =  -loadFactorsMat(:,2) ;

figure(1)
plot( controlDispsNRAL_Jirasek_logarithmic_strain, loadFactorsNRAL_Jirasek_logarithmic_strain, 'linewidth', 1.5)
labx = xlabel('Displacement w(t)');
laby = ylabel('\lambda(t)') ;
legend('\fontsize{12} Arc Length / Logarithmic Strain','Location','northeast');
hold on;