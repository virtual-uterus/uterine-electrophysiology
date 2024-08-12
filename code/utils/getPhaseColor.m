function color = getPhaseColor(phase)
%GETPHASECOLOR Returns the color associated with the estrus phase.
%   proestrus -> blue
%   estrus -> black
%   metestrus -> red
%   diestrus -> green
%
%   Input:
%    - phase, {'proestrus', 'estrus', 'metestrus', 'diestrus'},
%       phase of the cycle.
%   
%   Return: 
%    - color, plot color associated with the phase.
switch phase
    case "proestrus"
        color = [0 0.4470 0.7410];

    case "estrus"
        color = [0.4660 0.6740 0.1880];

    case "metestrus"
        color = [0.6350 0.0780 0.1840];

    case "diestrus"
        color = [0.4940 0.1840 0.5560];

    otherwise
        error("Error: selected phase is not valid.")
end
end