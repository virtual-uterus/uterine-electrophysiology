%Function to calculate velocity. the activation times and the electrode
%spacing distance are the inputs. Velocity is calculated using gradients
%and a filter is used to smooth the signal. 
% Input - timeI - Activation time
%         elecSpacing - distace between electrode
% Outpur - Vx - Normalised velocity vector in the x direction 
%          Vy - Normalised velocity vector in the y direction 
%          VZI - Magnitude of the velocity component
% Nira (Date Modified:24th March 2010)
%
%Modified code so that all of the redundancies are removed. there were 
%variables being defined but not being used and the flow of the code was 
%not legible. So comments were added and a brief description of the algo 
%given below to supplement the code.
% 
%1. Create finite differnce grid
%2. Padding the array and interpolating (function incl below 'fillnans')
%3. Smoothing the gradients using a gaussian smoothing filter
%4. Normalising the vectors 
%3. Find the velocity vectors
%6. Unpadding the array  
% Nira (Date Modified:10th June 2011)

function [Vx,Vy,VZI]= calcVelocity(timeI,elecSpacing)

%% Creating the gradient 

[dx,dy]=gradient(timeI,elecSpacing,elecSpacing);

%% Padding the array

[m,n]=size(dx);
dx1=ones(m+4,n+4).*NaN;dy1=dx1;
dx1(3:size(dx,1)+2,3:size(dx,2)+2)=dx;
dy1(3:size(dy,1)+2,3:size(dy,2)+2)=dy;

dx1=fillnans(dx1,'power',2); %dx1=fillnans(dx1,'radius',5.01);
dy1=fillnans(dy1,'power',2); %dy1=fillnans(dy1,'radius',5.01); 

dx=dx1; %renaming for better reading of code
dy=dy1;

%% Finding Velocity vec

QQ=(dy.^2 + dx.^2);

QQ(QQ<1e-3)=NaN;
QQ=fillnans(QQ); 

VX=dx./QQ; 
VY=dy./QQ;

%% Smoothing

% H= fspecial('gaussian',[5 5],.75);% H= fspecial('gaussian',[3 3],.5);

H=[ 0.0002    0.0033    0.0081    0.0033    0.0002
    0.0033    0.0479    0.1164    0.0479    0.0033
    0.0081    0.1164    0.2831    0.1164    0.0081
    0.0033    0.0479    0.1164    0.0479    0.0033
    0.0002    0.0033    0.0081    0.0033    0.0002];

VX = conv2(VX, H, 'same');
VY = conv2(VY, H, 'same');

%% Normalising

VZI= sqrt(VX.^2 + VY.^2); % The magnitude of each arrow.
Vx=VX./VZI;
Vy=VY./VZI;

%% Unpadding the array

VZI=VZI(3:size(VZI,1)-2,3:size(VZI,2)-2);
Vx=Vx(3:size(Vx,1)-2,3:size(Vx,2)-2);
Vy=Vy(3:size(Vy,1)-2,3:size(Vy,2)-2);

Angle=atan2(Vy,Vx).*(180/pi);

return 



function Y = fillnans(varargin)
% FILLNANS replaces all NaNs in array using inverse-distance weighting.
%
% Y = FILLNANS(X) replaces all NaNs in the vector or array X by
% inverse-distance weighted interpolation:
%                       Y = sum(X/D^3)/sum(1/D^3)
% where D is the distance (in pixels) from the NaN node to all non-NaN
% values X. Values farther from a known non-NaN value will tend toward the
% average of all the values.
%
% Y = FILLNANS(...,'power',p) uses a power of p in the weighting
% function. The higer the value of p, the stronger the weighting.
%
% Y = FILLNANS(...,'radius',d) only used pixels < d pixels away in
% for weighted averaging.
%
% NOTE: Use in conjunction with INVDISTGRID to grid and interpolate x,y,z
% data.
%
% See also INPAINT_NANS
%
% Ian M. Howat, Applied Physics Lab, University of Washington
% ihowat@apl.washington.edu Ian M. Howat
% Version 1: 05-Jul-2007 17:28:57
%   Revision 1: 16-Jul-2007 17:47:43
%       Added increment expression to waitbar to reduce number of times its
%       called. Provided by John D'Errico.
%   Revision 2: 16-Jul-2007 18:40:34
%       Added radius option and 'option',value varargin parser.
%   Revision 3: 18-Jul-2007 10:25:23
%       Adopted several code efficiency revisions made by Urs, including
%       removing the waitbar.

%parse input and set defualts:
X = varargin{1}; %input array
Y = X; %output array
n = 2; %weighting power
d = 0; %distance cut-off radius (0= all pixels, no cut-off)
if nargin > 1 && nargin < 6
    for k=2:2:length(varargin)
        if isnumeric(varargin{k}) || ~isnumeric(varargin{k+1})
            error('Input arguments must be in ''option'',value form.')
        end
        switch lower(varargin{k})	% (Urs:less error prone)
            case 'power'
                n = varargin{k+1};
            case 'radius'
                d = varargin{k+1};
            otherwise
                error(['Unrecognized input argument: ',varargin{k}])
        end
    end
elseif nargin >= 6
    error('Too many input arguments')
end

%(Urs:use ISNAN()/NOT() once only)
ix=isnan(X);
[rn,cn]=find(ix);   %row,col of nans
ix=~ix;
[r,c]=find(ix);     %row,col of non-nans
ind=find(ix);       %index of non-nans

%Break distance-finding loops into with cut-off and without cut-off
%versions. The cutoff conditional statement adds time
%if cut-off values near the max pixel distance are used.

if d %distance cut-off loop
    d=d.^2;				% (Urs:allows first step without SQRT())
    for k = 1:length(rn)
        D = (rn(k)-r).^2+(cn(k)-c).^2;	% (Urs:no SQRT() here)
        Dd = D < d;
        if sum(Dd) ~= 0
            D=1./sqrt(D(Dd)).^n; %(Urs: Compute once only for valid <D>s)
            Y(rn(k),cn(k)) = sum(X(ind(Dd)).*D)./ sum(D);
        end
    end
else %no distance cut-off loop
    for k = 1:length(rn)
        D = 1./(sqrt((rn(k)-r).^2+(cn(k)-c).^2)).^n;% (Urs:compute once only)
        Y(rn(k),cn(k)) = sum(X(ind).*D)./sum(D);
    end
end
