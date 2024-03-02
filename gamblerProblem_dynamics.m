%Studenti: Luca Sugamosto, matricola 0324613
%          Mattia Quadrini, matricola 0334381
clear
close all
clc

maxWin = 100;       %massimo denaro che può essere in deposito

S = maxWin + 1;     %numero di stati del processo markoviano
A = maxWin - 1;     %numero di azioni possibili

probability = 0.5;          %probabilità che esca una delle facce della moneta (Assumendo la moneta non truccata)

%NOTA:
%In questa struttura del gioco si usano matrici di probabilità di
%transizione P non troncate, questo significa che se mi trovo nello stato
%"s" e considero l'azione "a", con a > s, allora considero l'azione di
%giocare tutto il denaro posseduto nello stato "s".

%Inizializzazione della matrice delle probabilità di transizione P
%-----------------------------------------------------------------
P = zeros(S, S, A);

for s = 1:S                 %per ogni stato appartenente ad S
    [numRow,numCol] = ind2sub([S S], s);          %numRow indica lo stato s-esimo
    numRow = numRow - 1;                          %denaro effettivo in deposito

    for a = 1:A             %per ogni azione appartenente ad A
        %La giocata effettuata sarà l'azione 'a' se questa è minore o
        %uguale al denaro posseduto, mentre sarà il massimo denaro nello
        %stato 's' se si considera un'azione maggiore del denaro posseduto.

        if (numRow == 0 || numRow == maxWin)
            %Caso in cui mi trovo in uno stato terminale.
            %Indipendentemente dall'azione scelta torno sempre in esso
            newNumRow = numRow + 1;
            next_s = sub2ind([S S], newNumRow, numCol);    %calcolo dello stato successivo

            %Essendo l'unica transazione possibile quella di tornare nello
            %stesso stato, questa ha probabilità 1 di verificarsi
            P(s, next_s, a) = 1;                           %lo stato attuale si trova sull'indice di riga mentre lo stato successivo sull'indice di colonna
        else
            %Caso in cui mi trovo in uno stato non terminale e quindi con
            %probabilità 50% vado in uno stato, mentre con il 50% vado in 
            %un altro

            %la giocata effettiva è il valore minimo tra l'azione scelta
            %'a' ed il denaro effettivamente in deposito
            bet = min(a, numRow);

            newNumRow1 = min((numRow + 1) + bet, S);       %calcolo del nuovo stato in caso di vittoria
            newNumRow2 = max((numRow + 1) - bet, 1);       %calcolo del nuovo stato in caso di sconfitta

            next_s1 = sub2ind([S S], newNumRow1, numCol);  %nuova coordinata dello stato in caso di vittoria
            next_s2 = sub2ind([S S], newNumRow2, numCol);  %nuova coordinata dello stato in caso di sconfitta

            P(s, next_s1, a) = probability;                %lo stato attuale si trova sull'indice di riga mentre lo stato successivo sull'indice di colonna 
            P(s, next_s2, a) = probability;                %lo stato attuale si trova sull'indice di riga mentre lo stato successivo sull'indice di colonna
        end
    end
end

%Inizializzazione della matrice dei rewards R
%--------------------------------------------
earning = zeros(S,1);       %vettore dei guadagni istantanei che non dipendono dall'azione

for s = 1:S                 %per ogni stato appartenente ad S
    if (s == 1)             %stato che corrisponde ad avere 0$ nel deposito
        earning(s, 1) = -1;
    elseif (s == S)         %stato che corrisponde ad avere 100$ nel deposito
        earning(s, 1) = 1;
    %per tutti gli altri stati intermedi il guadagno istantaneo è pari a 0
    end
end

R = zeros(S, A);
for a = 1:A                 %per ogni azione appartenente ad A
    R(:, a) = P(:, :, a) * earning;
end
%siccome lo stato 1 ed S sono terminali allora il reward assegnato ad essi
%quando viene presa una qualsiasi azione è pari a 0
R(1, :) = 0;          
R(S, :) = 0;

save gamblerProblem_data.mat P R        %salvataggio delle matrici che determinano il modello