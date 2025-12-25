function y = rank_fun_derivative(x,delta,rank_fun)
    switch rank_fun
        case 1 %Geman function
            y  = delta^2./(delta+x).^2;
        case 2 %Laplace function
            y = exp(-x./delta)/delta;
        case 3 %l_delta function
            y= (delta+delta^2)./(delta+x).^2;
        case 4 %ETR function
            y=delta*exp(delta^2)./((x+delta).^2+eps);
    end
end

