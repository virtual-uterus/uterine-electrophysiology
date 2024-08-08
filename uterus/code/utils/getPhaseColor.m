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
        color = "b";

    case "estrus"
        color = "k";

    case "metestrus"
        color = "r";

    case "diestrus"
        color = "g";

    otherwise
        error("Error: selected phase is not valid.")
end
end