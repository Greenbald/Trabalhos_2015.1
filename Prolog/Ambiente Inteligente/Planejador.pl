%------------------------------------------
%           Base de conhecimento
%------------------------------------------
sala(204).
sala(205).
sala(206).
horario(manha).
horario(tarde).
horario(noite).
forneceLuz(lampada).
professor(otton).
professor(javier).
professor(leandro).
professor(daniel).
professor(ricardo).
professor(adrian).
professor(aline).
professor(vanessa).
professor(alexandre).
equipamento(computador).
equipamento(projetor).
condicionador(ar).
janela(janela).
naoUsaEquip(otton).
naoUsaEquip(javier).
naoUsaEquip(ricardo).
naoUsaEquip(adrian).
da_aula(manha,204,otton).
da_aula(tarde,204,javier).
da_aula(noite,204,leandro).
da_aula(manha,205,daniel).
da_aula(tarde,205,ricardo).
da_aula(noite,205,adrian).
da_aula(manha,206,aline).
da_aula(tarde,206,vanessa).
da_aula(noite,206,alexandre).
usa(leandro,projetor).
usa(leandro,computador).
usa(daniel,projetor).
usa(daniel,computador).
usa(aline,projetor).
usa(aline,computador).
usa(vanessa,projetor).
usa(vanessa,computador).
usa(alexandre,projetor).
usa(alexandre,computador).
luminosidade(manha,alta).
luminosidade(tarde,alta).
luminosidade(noite,baixa).
clima(muitoQuente).
clima(quente).
clima(bom).
clima(frio).
potencia(muitoQuente,alta).
potencia(quente,baixa).

%------------------------------------------
%                 Ações
%------------------------------------------
%------------------------------------------
%            Preparo da aula
%------------------------------------------
%detectaProf(Horario,Sala,Professor)
can(detectaProf(Horario,Sala,Professor),[horario(Horario),sala(Sala),not(professor(Professor))],uff):-
	horario(Horario),
	sala(Sala),
	professor(Professor),
	da_aula(Horario,Sala,Professor).
adds(detectaProf(Horario,Sala,Professor),[professor(Professor)], _, uff):-
	horario(Horario),
	sala(Sala),
	professor(Professor).
deletes(detectaProf(_Horario,Sala,Professor),[sala(Sala),not(professor(Professor))], uff):-
	sala(Sala).

%detectaLuz(QtdLuz)
can(detectaLuz(QtdLuz),[horario(Horario),not(luminosidade(QtdLuz))],uff):-
	horario(Horario),
	luminosidade(Horario,QtdLuz).
adds(detectaLuz(QtdLuz),[luminosidade(QtdLuz)], _, uff).
deletes(detectaLuz(QtdLuz),[not(luminosidade(QtdLuz))], uff):-
	horario(Horario).
	
%acende(Lampada)
can(acende(Lampada),[not(ligado(Lampada)),luminosidade(baixa)],uff):-
	forneceLuz(Lampada).
adds(acende(Lampada),[ligado(Lampada),luminosidade(alta)], _, uff).
deletes(acende(Lampada),[not(ligado(Lampada)),luminosidade(baixa),not(luminosidade(alta))], uff).

%abre(Porta)
can(abre(Porta),[not(aberto(Porta))],uff).
adds(abre(Porta),[aberto(Porta)], _, uff).
deletes(abre(Porta),[not(aberto(Porta))], uff).

%ligaAC(Ar)
can(ligaAC(Ar),[not(ligado(Ar))],uff):-
	condicionador(Ar).
adds(ligaAC(Ar),[ligado(Ar)], _, uff).
deletes(ligaAC(Ar),[not(ligado(Ar))], uff).

%ajustaPotenciaAC(Pot)
can(ajustaPotenciaAC(Pot),[ligado(Ar),clima(Clima),not(potencia(Pot))],uff):-
	clima(Clima),
	potencia(Clima,Pot).
adds(ajustaPotenciaAC(Pot),[potencia(Pot),clima(bom)], _, uff).
deletes(ajustaPotenciaAC(Pot),[not(potencia(Pot)),clima(Clima)], uff):-
	clima(Clima).

%fecha(Janela)
can(fecha(Janela),[not(fechado(Janela)), clima(frio)],uff):-
	janela(Janela).
adds(fecha(Janela),[fechado(Janela),clima(bom)], _, uff).
deletes(fecha(Janela),[not(fechado(Janela)),clima(frio)], uff).

%liga(Equipamento)
can(liga(Equipamento),[professor(Professor),aberto(porta),not(ligado(Equipamento))],uff):-
	equipamento(Equipamento),
	usa(Professor,Equipamento).
adds(liga(Equipamento),[ligado(Equipamento)], _, uff):-
	equipamento(Equipamento).
deletes(liga(Equipamento),[not(ligado(Equipamento))], uff).

%conecta(EquipamentoX,EquipamentoY)
can(conecta(EquipamentoX,EquipamentoY),[professor(Professor),not(conectado(EquipamentoX,EquipamentoY)),ligado(EquipamentoX),ligado(EquipamentoY)],uff):-
	equipamento(EquipamentoX),
	equipamento(EquipamentoY),
	usa(Professor,EquipamentoY),
	usa(Professor,EquipamentoX).
adds(conecta(EquipamentoX,EquipamentoY),[conectado(EquipamentoX,EquipamentoY)], _, uff):-
	equipamento(Equipamento).
deletes(conecta(EquipamentoX,EquipamentoY),[not(conectado(EquipamentoX,EquipamentoY))], uff).

%sinalSalaPronta(Professor)
can(sinalSalaPronta(Professor),[aberto(porta),professor(Professor), luminosidade(alta), clima(bom),ligado(computador),ligado(projetor),conectado(computador,projetor)],uff):-
	usa(Professor,projetor).
adds(sinalSalaPronta(Professor),[status(pronto)], _, uff).
deletes(sinalSalaPronta(Professor),[not(status(pronto))], uff).

%sinalSalaPronta2(Professor)
can(sinalSalaPronta2(Professor),[aberto(porta),professor(Professor), luminosidade(alta), clima(bom)],uff):-
	naoUsaEquip(Professor).
adds(sinalSalaPronta2(Professor),[status(pronto)], _, uff).
deletes(sinalSalaPronta2(Professor),[not(status(pronto))], uff).

%------------------------------------------
%            Despreparo da aula
%------------------------------------------
%apaga(Lampada)
can(apaga(Lampada),[status(pronto),ligado(Lampada)],uff):-
	forneceLuz(Lampada).
adds(apaga(Lampada),[not(ligado(Lampada))], _, uff).
deletes(apaga(Lampada),[ligado(Lampada)], uff).

%fecha(Porta)
can(fecha(Porta),[status(pronto),aberto(Porta)],uff).
adds(fecha(Porta),[not(aberto(Porta))], _, uff).
deletes(fecha(Porta),[aberto(Porta)], uff).

%desligaAC(Ar)
can(desligaAC(Ar),[status(pronto),ligado(Ar)],uff):-
	condicionador(Ar).
adds(desligaAC(Ar),[not(ligado(Ar))], _, uff).
deletes(desligaAC(Ar),[ligado(Ar)], uff).

%abreJanela(Janela)
can(abreJanela(Janela),[status(pronto),fechado(Janela)],uff):-
	janela(Janela).
adds(abreJanela(Janela),[not(fechado(Janela))], _, uff).
deletes(abreJanela(Janela),[fechado(Janela)], uff).

%desliga(Equipamento)
can(desliga(Equipamento),[status(pronto),ligado(Equipamento)],uff):-
	equipamento(Equipamento).
adds(desliga(Equipamento),[not(ligado(Equipamento))], _, uff):-
	equipamento(Equipamento).
deletes(desliga(Equipamento),[ligado(Equipamento)], uff).

%desconecta(EquipamentoX,EquipamentoY)
can(desconecta(EquipamentoX,EquipamentoY),[status(pronto),not(ligado(EquipamentoX)),not(ligado(EquipamentoY)), conectado(EquipamentoX,EquipamentoY)],uff):-
	equipamento(EquipamentoX),
	equipamento(EquipamentoY).
adds(desconecta(EquipamentoX,EquipamentoY),[not(conectado(EquipamentoX,EquipamentoY))], _, uff):-
	equipamento(Equipamento).
deletes(desconecta(EquipamentoX,EquipamentoY),[conectado(EquipamentoX,EquipamentoY)], uff).

%sinalSalaFechada(Professor)						                    
can(sinalSalaFechada(Professor),[status(pronto), professor(Professor), not(aberto(porta)), not(ligado(lampada)), not(ligado(computador)), not(ligado(projetor)), not(conectado(computador,projetor)), not(ligado(ar)), not(fechado(janela))],uff).
adds(sinalSalaFechada(Professor),[status(fechado)], _, uff).
deletes(sinalSalaFechada(Professor),[status(pronto)], uff).

%------------------------------------------
%                 Teste
%------------------------------------------
teste(P,Horario,Sala,Clima) :-
	plan([horario(Horario),sala(Sala),clima(Clima),not(status(pronto)),not(fechado(janela)),not(conectado(computador,projetor)),not(ligado(ar)),not(aberto(porta)),not(ligado(lampada)),not(luminosidade(alta)),not(luminosidade(baixa)),not(potencia(alta)),not(potencia(baixa)),not(ligado(computador)),not(ligado(projetor)),not(professor(aline)),not(professor(javier)),not(professor(otton)),not(professor(aline)),not(professor(leandro)),not(professor(daniel)),not(professor(ricardo)),not(professor(adrian)),not(professor(vanessa)),not(professor(alexandre))],
	     [status(fechado)], uff,
	     P), !.

%------------------------------------------
%               Planejador
%------------------------------------------
%    The Prolog Graplan project is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    The Prolog Graplan project is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with the Prolog Graplan project.  If not, see <http://www.gnu.org/licenses/>.

% (C) 2011 Suresh Manandhar, Pierre Andrews

% Graphplan Planner based on Blum & Furst 1997. Journal of AI, 90:281-300.
%  Pierre Andrews and Suresh Manandhar Nov 2006
%

:- dynamic no_op_count/1.
:- dynamic mutex_action/3.
:- dynamic mutex_condition/3.

:- dynamic plan_graph_del/3.
:- dynamic plan_graph_add/3.
:- dynamic plan_graph_pre/3.

plan(InitialState, FinalState, Domain, Plan):-
	retractall(no_op_count(_)),
	retractall(mutex_action(_, _, _)),
	retractall(mutex_condition(_, _, _)),

	retractall(plan_graph_del(_, _, _)),
	retractall(plan_graph_add(_, _, _)),
	retractall(plan_graph_pre(_, _, _)),

	assert(no_op_count(0)),
	add_initial_conditions(InitialState),
	generate_graph_nodes(1, FinalState, FinalLevel, Domain),
	find_plan(FinalLevel, FinalState, InitialState, [], PlanT),
	remove_no_ops(PlanT, Plan),
	nl, nl, write_plan(Plan), nl.


find_plan(0, CurrentState, InitialState, Plan, Plan):-
	subset(CurrentState, InitialState).

find_plan(N, CurrentState, InitialState, PrevActions, Plan):-
	N > 0,
	find_current_level_actions(N, CurrentState,  [], CurLevelNActions, []),
	
	findall(Cond,(member(Action,CurLevelNActions), plan_graph(N, pre, Cond, Action)), PreConds),
	list_to_set(PreConds, MidState),

%	nl, write(' Level  '), write(N),
%	nl, write('Actions : '), nl, write(CurLevelNActions),
%	nl, write('State   : '), nl, write(CurrentState), nl,nl,

	N1 is N-1,
	find_plan(N1, MidState, InitialState, [CurLevelNActions|PrevActions], Plan).


find_current_level_actions(_, [], Actions, Actions, _).
find_current_level_actions(N, CurrentState, CurActions, Actions, CurAdds):-
	member(Pred, CurrentState),
	choose_action_to_achieve_pred(N, Pred, Action),

	not( (member(OtherAction,CurActions), mutex_action(N, Action, OtherAction)) ),

	findall(Cond, plan_graph(N, add, Cond, Action), AddCondsL),
	list_to_set(AddCondsL, AddConds),

	%% Plan minimality (as described in the paper) is equivalent to redundancy check
	%% There is no other action which has the same effect i.e. same add conditions
	not( (member(OtherAdds,CurAdds), subset(AddConds,OtherAdds), subset(OtherAdds,AddConds)) ),

	subtract(CurrentState, AddConds, CurrentStateMod),
	find_current_level_actions(N, CurrentStateMod, [Action|CurActions], Actions, [AddConds|CurAdds]).



choose_action_to_achieve_pred(N, Pred, no_op(X)):-  %% Generate shorter plans using the following strategy
	plan_graph(N, add, Pred, no_op(X)).                   %% Be lazy: prefer no ops

choose_action_to_achieve_pred(N, Pred, OtherAction):-    %% Choose real actions only if no ops fail
	plan_graph(N, add, Pred, OtherAction),
	OtherAction \= no_op(_).





add_initial_conditions([]).
add_initial_conditions([Pred|Conditions]):-
	add_plan_graph(0, add, Pred, start),
	add_initial_conditions(Conditions).


generate_graph_nodes( N, _, _, _Domain):-
	N > 30,   %% The program is probably too slow beyond this point
	!,
	nl, nl, write('Bound reached'),
	nl, write('Terminating.....'),
	fail.

generate_graph_nodes( N, FinalState, N1, _Domain):-
	N1 is N-1,
	%% Check if FinalState Conditions have been satisfied 
        %%    and no mutual exclusion conditions have been violated
	get_nonmutex_addconds(FinalState, N1, []),
	nl, write('Feasible Plan found at level '), write(N1),
	!.

generate_graph_nodes(N, _, _, _Domain):-

	% Add no-ops
	add_no_op_nodes(N),

	fail.


generate_graph_nodes(N, _, _, Domain):-
	can(Action, PreConditions, Domain),
	NPrev is N-1,
	get_nonmutex_addconds(PreConditions, NPrev, []),	
	
	deletes(Action, DelPreConditions, Domain),
	%% Instantiation Check
	( ground(DelPreConditions) 
           -> true
            ; ( 
	        nl, 
		write('Action not fully instantiated '), write(Action),
		nl,
		write('Del Conditions: '), write(DelPreConditions), nl
	    )
	),

	
	adds(Action, AddConditions, _, Domain),
	%% Instantiation Check
	( ground(AddConditions) 
           -> true
            ; ( 
	        nl, 
		write('Action not fully instantiated '), write(Action),
		nl,
		write('Add Conditions: '), write(AddConditions), nl
	    )
	),


	add_graph_nodes(PreConditions, Action, N, pre),

	add_graph_nodes(DelPreConditions, Action, N, del),
	add_graph_nodes(AddConditions, Action, N, add),

%	nl, write("Added Action: "), write(Action),
%	nl,

	fail.

generate_graph_nodes(N, FinalState, FinalLevel, Domain):-

	% Propagate mutual exclusions
	mutex(N),

	N1 is N+1,
	!,
	generate_graph_nodes(N1, FinalState, FinalLevel, Domain),
	!.


get_nonmutex_addconds([], _, _).
get_nonmutex_addconds([Pred|Conditions], N, PrePreds):-
	plan_graph(N, add, Pred, _),
	check_mutex(PrePreds, Pred, N),
	get_nonmutex_addconds(Conditions, N, [Pred|PrePreds]).
	
check_mutex([], _, _).
check_mutex([OtherPred|Others], Pred, N):-
	not(mutex_condition(N, Pred, OtherPred)),
	check_mutex(Others, Pred, N).




mutex(N):-
	mutex_add_del_conflict(N),
	mutex_precond_conflict(N),
	mutex_add_add_conflict(N).


mutex_add_del_conflict(N):-
	plan_graph(N, del, Pred, Action2),
	( plan_graph(N, add, Pred, Action1); plan_graph(N, pre, Pred, Action1) ),
	Action1 \= Action2,
	insert_action_conflict(N, Action1, Action2),
	fail.
mutex_add_del_conflict(_).


insert_action_conflict(N, Action1, Action2):-
	add_to_db(mutex_action(N, Action1, Action2)),
	add_to_db(mutex_action(N, Action2, Action1)).



mutex_add_add_conflict(N):-
	mutex_action(N, Action1, Action2),
	plan_graph(N, add, Pred1, Action1),
	plan_graph(N, add, Pred2, Action2),

	Action1 \= Action2,
	Pred1 \= Pred2,
	not(mutex_condition(N, Pred1, Pred2)),
	not( (
	       plan_graph(N, add, Pred1, Action11),
	       plan_graph(N, add, Pred2, Action22),
	       Action11 \= Action22,
	       not(mutex_action(N, Action11, Action22))
	      )
           ),
	add_to_db(mutex_condition(N, Pred1, Pred2)),
	add_to_db(mutex_condition(N, Pred2, Pred1)),
	fail.
mutex_add_add_conflict(_).


mutex_precond_conflict(N):-
	N1 is N-1,
	mutex_condition(N1, Pred1, Pred2),
	plan_graph(N, pre, Pred1, Action1),
	plan_graph(N, pre, Pred2, Action2),
	Action1 \= Action2,
	insert_action_conflict(N, Action1, Action2),
	fail.
mutex_precond_conflict(_).
	

plan_graph(N, del, Pred, Action):-
	plan_graph_del(N, Pred, Action).
	
plan_graph(N, pre, Pred, Action):-
	plan_graph_pre(N, Pred, Action).
	
plan_graph(N, add, Pred, Action):-
	plan_graph_add(N, Pred, Action).


add_plan_graph(N, del, Pred, Action):-
	plan_graph_del(N, Pred, Action),
	!.
add_plan_graph(N, del, Pred, Action):-
	assert(plan_graph_del(N, Pred, Action)).
add_plan_graph(N, pre, Pred, Action):-
	plan_graph_pre(N, Pred, Action),
	!.
add_plan_graph(N, pre, Pred, Action):-
	assert(plan_graph_pre(N, Pred, Action)).
add_plan_graph(N, add, Pred, Action):-
	plan_graph_add(N, Pred, Action),
	!.
add_plan_graph(N, add, Pred, Action):-
	assert(plan_graph_add(N, Pred, Action)).




add_graph_nodes([], _, _, _).
add_graph_nodes([Pred|Conditions], Action, N, Type):-
	add_plan_graph(N, Type, Pred, Action),
	add_graph_nodes(Conditions, Action, N, Type).

add_no_op_nodes(N):-
	NPrev is N-1,
	plan_graph(NPrev, add, Pred, _),
	add_no_op_node(Pred, N),
	fail.
add_no_op_nodes(_).


add_no_op_node(Pred, N):-
	not((plan_graph(N, add, Pred, no_op(C)), plan_graph(N, pre, Pred, no_op(C)))),
	new_no_op_count(Count),
	add_plan_graph(N, add, Pred, no_op(Count)),
	add_plan_graph(N, pre, Pred, no_op(Count)).



new_no_op_count(N):-
	retract(no_op_count(N)),
	N1 is N+1,
	assert(no_op_count(N1)).



add_to_db(Clause):-
	call(Clause),
	!.
add_to_db(Clause):-
	assert(Clause).


write_plan(Plan):- write_plan(Plan,1). 

write_plan([], _):- nl.
write_plan([Actions|Rest], N):-
	nl, write('Step '), write(N), write(:), nl,
	write_list(Actions),
	N1 is N+1,
	write_plan(Rest, N1).
	
write_list([]).
write_list([no_op(_)|L]):- !, write_list(L).
write_list([X|L]):-  write('        '), write(X), nl, write_list(L).

remove_no_ops([],[]).
remove_no_ops([no_op(_)|L],R):-
	!,
	remove_no_ops(L,R).
remove_no_ops([X|L],[X1|R]):-
	!,
	remove_no_ops(X,X1),
	remove_no_ops(L,R).
remove_no_ops(X,X).
