function [Y, it] = ATTMVC(Xcell, m, opts)
    % (X^{(v)}: n x d_v, Z^{(v)}: n x m)%
    % Objective (1):
    %   min  beta * ||𝓖||_TTR + lambda * sum_v ||E^{(v)}||_{2,1}^{row} + mu0 * sum_v ||G^{(v)} - Y||_F^2
    % s.t. (2) X^{(v)} = Z^{(v)} (A^{(v)})^T + E^{(v)}
    %      (3) G^{(v)} = Z^{(v)} P^{(v)}
    %      (4) (A^{(v)})^T A^{(v)} = I_m, (P^{(v)})^T P^{(v)} = I_m
    %
    % Inputs:
    %   Xcell{v} : n x d_v   data matrix for view v, v=1..V  (samples in rows)
    %   m        : #anchors (common across views)

    % Outputs:
    %   Y     : n x m consensus matrix (cluster via kmeans on rows or use affinity)
    %   it : iteration times when return

    % -------------------- defaults --------------------


    if nargin < 3, opts = struct; end
    % getopt  = @(s,f,def) (isfield(s,f) && ~isempty(s.(f))) * s.(f) + ...
    %                      ~(isfield(s,f) && ~isempty(s.(f))) * def;
    lambda  = getopt(opts,'lambda',1e-1);
    beta    = getopt(opts,'beta',1.0); % the first parameter, set as 1
    mu0     = getopt(opts,'mu0',1.0);
    mu      = getopt(opts,'mu',10);
    rho     = getopt(opts,'rho',10);
    delta   = getopt(opts,'delta',0.1);
    maxIter = getopt(opts,'maxIter',200);
    tol     = getopt(opts,'tol',1e-5);
    cont_factor = getopt(opts,'cont_factor',1.5);
    max_mu = getopt(opts,'max_mu',10e10);
    max_rho = getopt(opts,'max_rho',10e10);
    hard_permutation = getopt(opts,'hard_permutation',false);
    bTTR = getopt(opts,'bTTR',false);
    rank_fun = getopt(opts,'rank_fun',1);

    % -------------------- init --------------------
    V = numel(Xcell);
    [n, ~] = size(Xcell{1});
    sX =[n ,m ,V ];

    A = cell(V,1); Z = cell(V,1); E = cell(V,1); P = cell(V,1);
    G = cell(V,1); Ymul = cell(V,1); Wmul = cell(V,1);

    for v=1:V
        Xv = Xcell{v};             % n x d_v
        dv = size(Xv,2);
        if dv < m
            warning('View %d: d_v < m; cannot satisfy A^T A = I_m exactly. Using QR on random to approximate.', v);
        end

        A{v} = zeros(dv, m);     % d_v x m    
        Z{v} = Xv * A{v};    
        E{v} = zeros(n, dv);
        P{v} = eye(m);
        G{v} = Z{v} * P{v};        
        Ymul{v} = zeros(n, dv);    % multiplier 
        Wmul{v} = zeros(n, m);     % multiplier 
    end
    Y = mean(cat(3, G{:}), 3);     

    % -------------------- main loop --------------------
    for it = 1:maxIter    
        % ----- Z-step: closed-form 
        for v=1:V
            Xtil = Xcell{v} - E{v} + (1/mu)*Ymul{v};             % n x d_v
            Z{v} = ( mu * (Xtil * A{v}) ...
                + rho * (G{v} * (P{v})') ...
                +       (Wmul{v} * (P{v})') ) / (mu + rho);   % n x m
        end
        % ----- E-step: row L21 shrink 
        for v=1:V
            Uv = Xcell{v} - Z{v} * (A{v})' + (1/mu)*Ymul{v};     % n x d_v
            E{v} = shrink_l21_rows(Uv, lambda/mu);
        end

        % ----- A-step: 
        for v=1:V
            Xtil = Xcell{v} - E{v} + (1/mu)*Ymul{v};             % n x d_v
            M = Xtil' * Z{v};                                    % d_v x m
            [U,~,Vsvd] = svd(M, 'econ');
            A{v} = U * Vsvd';                                    % d_v x m,
        end



        % ----- G/TTR-step
        Hstack = zeros(n, m, V);
        for v=1:V
            Hstack(:,:,v) = ( rho * (Z{v} * P{v}) - Wmul{v} + 2*mu0 * Y ) / (rho + 2*mu0); 
        end

        if bTTR
            [Gstack, ~] = optimize_tensor_ttr(Hstack, beta, rho, mu0, sX, delta);
        else
            [Gstack, ~] = optimize_tensor(Hstack, (rho+2*mu0)/beta, sX, delta, rank_fun); %other non-convex surrogate functions
        end

        for v=1:V
            G{v} = Gstack(:,:,v);
        end

        % ----- Y-step 
        Y = mean(Gstack, 3);

        % ----- P-step:
        for v=1:V
            M = (Z{v})' * (rho * G{v} + Wmul{v});   % m x m

            if hard_permutation
                [assign, ~] = munkres(-M);  % assign(j)=i or 0, hard permutation
                Pmat = full(sparse(assign(assign>0), find(assign>0), 1, m, m));            
                P{v} = Pmat;   % hard permutation update
            else
                [U,~,Vsvd] = svd(M, 'econ');
                P{v} = U * Vsvd';                       
            end
        end

        % ----- multipliers update and converge judgement   
        isconverge  = 1;
        ReconstructionError = zeros(V, 0);
        MatchError = zeros(V, 0);    
        for v=1:V
            resR = Xcell{v} - Z{v} * (A{v})' - E{v};
            resC = G{v} - Z{v} * P{v};
            Ymul{v} = Ymul{v} + mu  * resR;
            Wmul{v} = Wmul{v} + rho * resC;

            ReconstructionError(v) = norm(resR, inf);
            MatchError(v) = norm(resC, inf);
            if (ReconstructionError(v) > 0.0001)
                isconverge = 0;
            end
            if (MatchError(v) > 0.0001)
                isconverge = 0;
            end        
        end

        if (isconverge == 1)
            break;
        end

        mu  = min(mu  * cont_factor, max_mu);
        rho = min(rho * cont_factor, max_rho);

    end


    clear Z A E P G Ymul Wmul;
end % ================= end main ===================


function E = shrink_l21_rows(U, tau)
    % Row-wise l2 shrinkage (for ||E||_{2,1}^{row}); U: n x d
    n = size(U,1);
    E = zeros(size(U));
    nr = sqrt(sum(U.^2, 2));                  % n x 1
    idx = nr > 0;
    sc = max(0, 1 - tau ./ (nr + (~idx)));    % avoid divide-by-zero; (~idx) is 1 for zeros
    E(idx,:) = U(idx,:) .* sc(idx);
end


function v = getopt(s, name, def)
    if isfield(s,name) && ~isempty(s.(name)), v = s.(name); else, v = def; end
end

