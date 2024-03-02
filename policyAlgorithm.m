classdef policyAlgorithm
    %Classe contenente tutte le variabili e tutte le funzioni utili al
    %calcolo della policy ottima per mezzo dell'algoritmo di "policy
    %iteration"

    properties
        S                         %dimensione dello spazio degli stati del modello
        A                         %dimensione dello spazio delle azioni del modello
        gamma                     %fattore di scarto che indica indica la lungimiranza dell'algoritmo
        pi                        %vettore contenente i valori dell'azione da prendere se vi si trova in un determinato stato
        piForValueIteration       %vettore in cui viene salvata la stessa policy "pi" e che viene utilizzato per richiamare questa nel value iteration 
        V0                        %stima iniziale della funzione valore associata ad ogni stato del modello
        thresholdValue            %valore di soglia che permette di determinare la condizione di uscita dal ciclo
        Vpi                       %stima della funzione valore associata ad ogni stato del modello data la policy pi
        next_pi                   %nuova policy calcolata per mezzo del teorema di "policy improvement"
        prev_pi                   %policy precedente a quella calcolata con policyImprovement utilizzata per determinare la condizione di uscita
        next_Vpi                  %nuova stima della funzione valore calcolata nell'algoritmo di "value iteration"
    end

    methods
        function obj = policyAlgorithm(matrix1, matrix2, value3)
            %funzione eseguita nello stesso istante in cui si va a definire
            %la classe. Utilizzata per inizializzare i parametri interni
            obj.S = size(matrix1, 1);
            obj.A = size(matrix2, 2);

            %"randi()" genera un vettore di dimensione Sx1 popolato da
            %numeri interi compresi nell'intervallo [1, A]
            obj.pi = randi(obj.A, [obj.S 1]);
            obj.piForValueIteration = obj.pi;

            %"randn()" genera un vettore di  dimensione Sx1 popolato da
            %numeri casuali presi da una distribuzione normale
            obj.V0 = randn(obj.S, 1);
            %la stima della funzione valore associata agli stati terminali
            %deve essere pari a 0
            obj.V0(1) = 0;
            obj.V0(obj.S) = 0;

            obj.thresholdValue = 1 * 10^(-5);
            obj.gamma = value3;
            
        end

        function obj = iterativePolicyEvaluation(obj, matrixP, matrixR, Case)
            %funzione per il calcolo della stima della funzione valore Vpi
            %dati in ingresso la policy "pi" e il valore di soglia "theta"
            Ppi = zeros(obj.S, obj.S);           %matrice P associata alla policy in ingresso
            Rpi = zeros(obj.S, 1);               %vettore R associatao alla policy in ingresso

            %inserimento di nuovi valori all'interno sia di Ppi sia di Rpi
            for s = 1:obj.S                 %per ogni stato dell'insieme S
                a = obj.pi(s);              %azione dettata dalla policy "pi" se ci si trova nello stato "s"  

                %"squeeze()" seleziona il vettore riga di P associato alla
                %riga s-esima e all'azione a-esima
                Ppi(s, :) = squeeze(matrixP(s, :, a));
                Rpi(s) = matrixR(s, a);
            end

            %calcolo della stima della funzione valore Vpi associata a "pi"
            if (Case == 0)
                %caso in cui si utilizza il "iterativePolicyEvaluation"
                %prima del loop e quindi considero la funzione iniziale V0
                %come la stima della funzione valore da usare e migliorare
                value = obj.V0;
            elseif (Case == 1)
                %caso in cui si utilizza il "iterativePolicyEvaluatio"
                %all'interno del loop e quindi considero la funzione Vpi
                %calcolata precedentemente come la stima della funzione
                %valore da usare e migliorare
                value = obj.Vpi;
            end

            while true
                nextValue = Rpi + ((obj.gamma .* Ppi) * value);
                if (norm((nextValue - value), "inf") < obj.thresholdValue)
                    %condizione di uscita dal loop poichè la funzione
                    %valore non varia rispetto a quella calcolata prima
                    obj.Vpi = nextValue;
                    break                   %uscita dal loop
                else
                    %si rimane nel loop
                    value = nextValue;      %aggiornamento "in-place" poichè si memorizza una sola variabile
                end
            end
            %salvataggio della policy usata per il calcolo della stima
            %della funzione valore Vpi per confrontarla in seguito con
            %la futura nuova policy calcolata con policyImprovement
            obj.prev_pi = obj.pi;
        end

        function obj = policyImprovement(obj, matrixP, matrixR)
            %funzione per il calcolo della policy "pi*" migliore rispetto a
            %quella precedente, valutando la stima della funzione valore
            %associata alla policy "pi" passata in ingresso
            Q = zeros(obj.S, obj.A);             %inizializzazione della stima della funzione qualità associata ad ogni coppia (stato, azione)
            obj.next_pi = zeros(obj.S, 1);       %inizializzazione della nuova policy "pi*"

            for s = 1:obj.S                 %per ogni stato appartenente ad S
                for a = 1:obj.A             %per ogni azione appartenente ad A
                    Q(s, a) = matrixR(s, a) + ((obj.gamma .* matrixP(s, :, a)) * obj.Vpi);
                end
                %calcolo della nuova azione da prendere se ci si trova
                %nello stato s e inserimento di questa nel vettore della
                %policy pi
                if (s == 1 || s == obj.S)
                    obj.next_pi(s) = 1;
                else
                    obj.next_pi(s) = find(Q(s, :) == max(Q(s, :)), 1, "first");
                end
            end
            obj.pi = obj.next_pi;                %salvataggio della nuova policy calcolata
        end

        function obj = policyEvaluation(obj, matrixP, matrixR)
            %funzione che calcola la stima della funzione valore "Vpi" dato
            %in ingresso la policy "pi"
            Ppi = zeros(obj.S, obj.S);           %matrice P associata alla policy in ingresso
            Rpi = zeros(obj.S, 1);               %vettore R associatao alla policy in ingresso

            for s = 1:obj.S
                a = obj.pi(s);                   %azione dettata dalla policy "pi" se ci si trova nello stato "s"
                
                %"squeeze()" seleziona il vettore riga di P associato alla
                %riga s-esima e all'azione a-esima
                Ppi(s, :) = squeeze(matrixP(s, :, a));
                Rpi(s) = matrixR(s, a);
            end
            I = eye(obj.S);                      %matrice identità quadrata di dimensionr SxS
            obj.Vpi = (I - (obj.gamma .* Ppi)) \ Rpi;
            
            %salvataggio della policy usata per il calcolo della stima
            %della funzione valore Vpi per confrontarla successivamente con
            %la futura nuova policy calcolata con policyImprovement
            obj.prev_pi = obj.pi;
        end

        function obj = policyIteration(obj, matrixP, matrixR)
            %funzione per il calcolo della policy ottima eseguendo in modo
            %alternato le funzioni policy evaluation, policy improvement
            obj = iterativePolicyEvaluation(obj, matrixP, matrixR, 0);      %primo passo di policy evaluation
            obj = policyImprovement(obj, matrixP, matrixR);                 %primo passo di policy improvement

            counter = 0;
            while true
                counter = counter + 1;
                fprintf("PI - iterazione n°: ");
                disp(counter)

                %passo di POLICY EVALUATION
                if (obj.gamma < 1)
                    obj = policyEvaluation(obj, matrixP, matrixR);
                else
                    %poichè per gamma = 1 si hanno problemi con la
                    %divisione seguente: Ppi \ Rpi
                    obj = iterativePolicyEvaluation(obj, matrixP, matrixR, 1);
                end
                %passo di POLICY IMPROVEMENT
                obj = policyImprovement(obj, matrixP, matrixR);
                if (norm((obj.pi - obj.prev_pi), 2) == 0)
                    %caso in cui la policy trovata non è cambiata rispetto
                    %alla precedente e quindi si è trovata una policy
                    %stabile
                    break                        %uscita dal loop
                end
            end
        end

        %------------------------------------------------------------------

        function obj = valueIterationStep(obj, matrixP, matrixR)
            %funzione che calcola una stimma della funzione valore dopo
            %aver applicato un singolo passo di policy evaluation
            Ppi = zeros(obj.S, obj.S);           %matrice P associata alla policy in ingresso
            Rpi = zeros(obj.S, 1);               %vettore R associatao alla policy in ingresso

            for s = 1:obj.S
                a = obj.pi(s);                   %azione dettata dalla policy "pi" se ci si trova nello stato "s"

                %"squeeze()" seleziona il vettore riga di P associato alla
                %riga s-esima e all'azione a-esima
                Ppi(s, :) = squeeze(matrixP(s, :, a));
                Rpi(s) = matrixR(s, a);
            end

            %singolo passo di policy evaluation
            nextVpi = Rpi + ((obj.gamma .* Ppi) * obj.Vpi);
            %aggiornamento della stima della funzione valore  utilizzando
            %la stima della funzione qualità
            obj.next_Vpi = zeros(obj.S, 1);
            Q = zeros(obj.S, obj.A);             %stima della funzione qualità
            for s = 1:obj.S
                for a = 1:obj.A
                    Q(s, a) = matrixR(s, a) + ((obj.gamma .* matrixP(s, :, a)) * nextVpi);
                end
                obj.next_Vpi(s) = max(Q(s, :));
            end
        end

        function obj = valueIteration(obj, matrixP, matrixR)
            %funzione che calcola la policy ottima usando un singolo passo
            %di policy evaluation e il policy improvement
            obj.pi = obj.piForValueIteration;
            obj.Vpi = obj.V0;

            counter = 0;
            while true
                counter = counter + 1;
                fprintf("VI - iterazione n°: ");
                disp(counter)

                %esecuzione dell'algoritmo di value iteration step
                obj = valueIterationStep(obj, matrixP, matrixR);
                %confronto tra la nuova stima della funzione valore
                %calcolata tramite "valueIterationStep" e della vecchia
                %stima della funzione valore "Vpi"
                if (norm((obj.next_Vpi - obj.Vpi), "inf") < obj.thresholdValue)
                    obj.Vpi = obj.next_Vpi;
                    break
                else
                    obj.Vpi = obj.next_Vpi;
                end
            end
            %calcolo della policy ottima per mezzo di policy improvement
            obj = policyImprovement(obj, matrixP, matrixR);
        end

        %------------------------------------------------------------------
        
        function obj = createPlots(obj, parameter)
            %funzione usata per graficare le soluzioni ottenute riguardo la
            %policy ottima e la stima della funzione valore associatagli
            if (parameter == 0)
                %grafici relativi al policy iteration
                figure(1)
                plot(obj.pi, "r*");
                grid on
                title("Policy ottima");
                legend("Policy iteration");
                xlabel("States of MDP")
                ylabel("Policy pi*")
             
                figure(2)
                plot(obj.Vpi, LineWidth = 1, Color = "red");
                grid on
                title("Stima della funzione valore ottima");
                legend("Policy iteration");
                xlabel("States of MDP")
                ylabel("Value function Vpi*")

            elseif (parameter == 1)
                figure(3)
                plot(obj.pi, "b*");
                grid on
                title("Policy ottima");
                legend("Value iteration");
                xlabel("States of MDP")
                ylabel("Actions")

                figure(4)
                plot(obj.Vpi, LineWidth = 1, Color = "blue");
                grid on
                title("Stima della funzione valore ottima");
                legend("Value iteration");
                xlabel("States of MDP")
                ylabel("Value function")
            end
        end
    end
end