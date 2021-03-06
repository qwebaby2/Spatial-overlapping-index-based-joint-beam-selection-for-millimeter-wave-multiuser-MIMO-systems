PP = zeros(K, Nbarr);
for nef = 1 : Nbarr
    WHF = zeros(Nr, Nr);
    Hqtn = zeros(Nr, Nb);
    Ftr = zeros(Nb, Nr);
    for kx = 1 : Nr
        Ftr(:,kx) = Ub(:, indexbklbs(kx, nef));
    end
    for n = 1 : N
        H = H_s(:, Nb*K*(n-1)+1:Nb*K*n);
        for kx = 1 : Nr
            kk = G_in(kx, nef);
            wtk = Um(:, indexbklus(kx, nef));
            Hkn = H(:, Nb*(kk-1)+1:Nb*kk);
            WHF(kx, :) = wtk' * Hkn * Ftr;
            Hqtn(kx, :) = wtk' * Hkn;
        end
        X = Hqtn * Ftr * (Ftr' * Ftr)^(-0.5);
        [~,Dtn,Utn] = svd(X);
        Gamatn = zeros(Nr, Nr);
        miu = P / Nr;
        Gamatnf2 = 0;
        while abs(Gamatnf2-P)>1e-2*P
            miu = miu + 1e-3*P;
            Gamatnf2 = 0;
            for jgama = 1 : Nr
                Gamatn(jgama, jgama) = sqrt(max(miu-1/Dtn(jgama, jgama)^2, 0));
                Gamatnf2 = Gamatnf2 + abs(Gamatn(jgama, jgama))^2;
            end
        end
        Ftn = (Ftr' * Ftr)^(-0.5) * Utn * Gamatn;
        for kx = 1 : Nr
            k = G_in(kx, nef);
            SNRt = abs(WHF(kx, :) * Ftn(:, kx))^2;
            interf = 0;
            for ktt = 1 : Nr
                if ktt == kx
                else
                    interf = interf + abs(WHF(kx, :) * Ftn(:, ktt))^2;
                end
            end
            SNRt = SNRt / (1 + interf);
            PP(k, nef) = PP(k, nef) + log2(1+SNRt);
        end
    end
end