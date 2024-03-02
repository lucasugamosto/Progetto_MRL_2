%Assignment 2 "Model gambler's problem":
%- Un giocatore d'azzardo ha la possibilità di scommettere sui risultati di
%una sequenza di lanci di moneta.

%- Se la moneta esce testa, lui vince tanti dollari quanti ne ha scommessi
%in quel lancio; se esce croce, lui perde la puntata.

%- Il gioco termina quando il giocatore d'azzardo vince raggiungendo il suo
%obiettivo di 100$ o perde rimanendo senza soldi.

%- Il reward è +1 in caso di vittoria e -1 in caso di sconfitta.

clc
clear
close all

%Caricamento della matrice di transizione di probabilità P e dei rewards R
load gamblerProblem_data.mat
%Assegnazione del valore alla variabile "Gamma" (variabile tra 0 ed 1)
gamma = 0;
%Inizializzazione della classe per il calcolo della policy ottima,
%comprende l'inizializzazione di tutte le variabili utili al calcolo di pi*
Policy_algorithm = policyAlgorithm(P, R, gamma);

%--------------------------------------------------------------------------
%CALCOLO CON POLICY ITERATION

%Aggiornamento e calcolo della policy pi e della stima della funzione
%valore Vpi
Policy_algorithm = Policy_algorithm.policyIteration(P, R);

%Graficazione della policy pi e della stima della funzione valore Vpi
Policy_algorithm = Policy_algorithm.createPlots(0);

%--------------------------------------------------------------------------
%CALCOLO CON VALUE ITERATION
%Questo risolve lo svantaggio del policy iteration, dovuto alle molteplici
%scansioni attraverso lo stato durante la fase di policy evaluation

%Aggiornamento e calcolo della policy pi e della stima della funzione
%valore Vpi
Policy_algorithm = Policy_algorithm.valueIteration(P, R);

%Graficazione della policy pi e della stima della funzione valore Vpi
Policy_algorithm = Policy_algorithm.createPlots(1);

