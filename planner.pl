
%%%%%%%%% Two Room Planner %%%%%%%%
%%%
%%% Cullen Bair
%%% UCF
%%% COP4630
%%% Spring 2018
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- module( planner,
	   [
	       plan/4,change_state/3,conditions_met/2,member_state/2,
	       move/3,go/2,test/0,test2/0
	   ]).

:- [utils].

plan(State, Goal, _, Moves) :-	equal_set(State, Goal),
				write('moves are'), nl,
				reverse_print_stack(Moves).
plan(State, Goal, Been_list, Moves) :-
				move(Name, Preconditions, Actions),
				conditions_met(Preconditions, State),
				change_state(State, Actions, Child_state),
				not(member_state(Child_state, Been_list)),
				enqueue(Child_state, Been_list, New_been_list),
				stack(Name, Moves, New_moves),
			plan(Child_state, Goal, New_been_list, New_moves),!.

change_state(S, [], S).
change_state(S, [add(P)|T], S_new) :-	change_state(S, T, S2),
					add_to_set(P, S2, S_new), !.
change_state(S, [del(P)|T], S_new) :-	change_state(S, T, S2),
					remove_from_set(P, S2, S_new), !.
conditions_met(P, S) :- subset(P, S).

member_state(S, [H|_]) :-	equal_set(S, H).
member_state(S, [_|T]) :-	member_state(S, T).

/* move types */

move(pickup(X), [handempty, clear(X), on(X, Y), inroom1(X), room1],
		[del(handempty), del(clear(X)), del(on(X, Y)), add(clear(Y)), add(holding(X))]).

move(pickup(X), [handempty, clear(X), on(X, Y), inroom2(X), room2],
		[del(handempty), del(clear(X)), del(on(X, Y)), add(clear(Y)), add(holding(X))]).

move(pickup(X), [handempty, clear(X), ontable1(X), room1],
		[del(handempty), del(clear(X)), del(ontable1(X)), add(holding(X))]).

move(pickup(X), [handempty, clear(X), ontable2(X), room2],
		[del(handempty), del(clear(X)), del(ontable2(X)), add(holding(X))]).

move(putdown(X), [holding(X), room1],
		 [del(holding(X)), add(ontable1(X)), add(clear(X)), add(handempty)]).

move(putdown(X), [holding(X), room2],
		 [del(holding(X)), add(ontable2(X)), add(clear(X)), add(handempty)]).

move(stack(X, Y), [holding(X), clear(Y), room1, inroom1(Y)],
		  [del(holding(X)), del(clear(Y)), add(handempty), add(on(X, Y)), add(clear(X))]).

move(stack(X, Y), [holding(X), clear(Y), room2, inroom2(Y)],
		  [del(holding(X)), del(clear(Y)), add(handempty), add(on(X, Y)), add(clear(X))]).

move(goroom1, [handempty, room2], [del(room2), add(room1)]).

move(goroom2, [handempty, room1], [del(room1), add(room2)]).

move(goroom1, [holding(X), room2],
              [del(room2), del(inroom2(X)), add(room1), add(inroom1(X))]).

move(goroom2, [holding(X), room1],
              [del(room1), del(inroom1(X)), add(room2), add(inroom2(X))]).

/* run commands */

go(S, G) :- plan(S, G, [S], []).

test :- go([handempty, room1, ontable1(b), ontable1(c), on(a, b), clear(c), clear(a), inroom1(a), inroom1(b), inroom1(c)],
	          [handempty, room1, ontable1(c), on(a,b), on(b,c), clear(a), inroom1(a), inroom1(b), inroom1(c)]).

test2 :- go([handempty, room1, ontable1(b), ontable1(c), on(a,b), clear(c), clear(a), inroom1(a), inroom1(b), inroom1(c)],
		  [handempty, room1, ontable2(b), on(a,c), on(c,b), clear(a), inroom2(a), inroom2(b), inroom2(c)]).

