function [detect,stopint,direction]=detener(t,y)
% Determina el instante cuando pasa por la altura cero y detiene la integraci�n
    detect=y(3); % Detecta cuando llega al suelo
    stopint=1; % Detiene la integraci�n
    direction=0; % No tiene inter�s
end