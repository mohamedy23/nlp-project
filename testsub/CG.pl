:- consult('KB.pl').

% the width and height predicates are used to get the dimensions of the
% grid.
width(W) :- grid(_,W).
height(H) :- grid(H,_).

% the predicate that generates the final plan
goal(S) :-
         ids(state(_,_,0,[],S),1).

ids(X,L):-
   (call_with_depth_limit(X,L,R), number(R));
   (call_with_depth_limit(X,L,R), R=depth_limit_exceeded,
    L1 is L+1, ids(X,L1)).

state(GuardX,GuardY,0,Ships,s0) :-
    agent_loc(GuardX,GuardY),
    ships_loc(Ships).

state(GuardX,GuardY,CurrentCapacity,Ships,result(Action,S)) :-
    state(GuardX1,GuardY1,CurrentCapacity1,Ships1,S),
    (
     % First case : pick up action
     % preconditions : to be in the same cell of the ship & to have capacity
     % enables the guard to carry at least one passenger.
     % If the preconditions hold, then we can perform pick up action,
     % and make a copy of the current location to a new state,
     % and the action will be concatenated to the previous situation,
     % to be : result(pickup, S).
    (isShip(GuardX1,GuardY1,Ships1),
     haveCapacity(CurrentCapacity1),
     pickup(GuardX1,GuardY1,CurrentCapacity1,CurrentCapacity,Ships1,Ships),
     copy(GuardX1,GuardX),
     copy(GuardY1,GuardY),
     Action = pickup)
        ;
     % Second case : drop action
     % preconditions : to be in the same cell with the station & already carrying
     % at least one passenger.
     % If the preconditions hold, then we can perform drop action,
     % and make a copy of the location and list of ships to a new state,
     % and the action will be concatenated to the previous situation,
     % to be : result(drop, S).
    (isStation(GuardX1,GuardY1),
     havePassengers(CurrentCapacity1),
     drop(CurrentCapacity),
     copy(GuardX1,GuardX),
     copy(GuardY1,GuardY),
     copy(Ships1,Ships),
     Action = drop)
        ;
     % Third case : move right
     % preconditions : to be in a cell that is not an edge cell. In another words,     % your current y location should be less than the width of the grid.
     % If the preconditions hold, then we can perform moving right action,
     % and make a copy of all other things (capacity,ships) to a new state,
     % and the action will be concatenated to the previous situation,
     % to be : result(right, S).
    (validRight(GuardY1),
     moveRight(GuardX1,GuardY1,GuardX,GuardY),
     copy(CurrentCapacity1,CurrentCapacity),
     copy(Ships1,Ships),
     Action = right)
        ;
     % Fourth case : move left
     % preconditions :y location should be greater than zero.
     % If the preconditions hold, then we can perform moving left action,
     % and make a copy of all other things (capacity,ships) to a new state,
     % and the action will be concatenated to the previous situation,
     % to be : result(left, S).
    (validLeft(GuardY1),
     moveLeft(GuardX1,GuardY1,GuardX,GuardY),
     copy(CurrentCapacity1,CurrentCapacity),
     copy(Ships1,Ships),
     Action = left)
        ;
     % Fifth case : move down
     % preconditions :x location should be less than the height of the grid.
     % If the preconditions hold, then we can perform moving down action,
     % and make a copy of all other things (capacity,ships) to a new state,
     % and the action will be concatenated to the previous situation,
     % to be : result(down, S).
    (validDown(GuardX1),
     moveDown(GuardX1,GuardY1,GuardX,GuardY),
     copy(CurrentCapacity1,CurrentCapacity),
     copy(Ships1,Ships) ,
     Action = down)
        ;
     % Sixth case : move up
     % preconditions :x location should be greater than zero.
     % If the preconditions hold, then we can perform moving up action,
     % and make a copy of all other things (capacity,ships) to a new state,
     % and the action will be concatenated to the previous situation,
     % to be : result(up, S).
    (validUp(GuardX1),
     moveUp(GuardX1,GuardY1,GuardX,GuardY),
     copy(CurrentCapacity1,CurrentCapacity),
     copy(Ships1,Ships),
     Action = up)
    ).



% check if the current location contains a ship.
isShip(XLoc,YLoc,Ships):-
	member([XLoc,YLoc],Ships).

% check if the guard can carry more passengers.
haveCapacity(CurrentCapacity):-
          capacity(FullCapacity),
          CurrentCapacity < FullCapacity.

% perform pickup action, and this includes two things :
% - increase number of carried passengers by one
% - remove this ship from ships list
pickup(XLoc,YLoc,Capacity,NewCapacity,Ships,RemainingShips):-
         NewCapacity is Capacity +1,
         removeShip(XLoc,YLoc,Ships,RemainingShips).

% check if the current cell contains a station.
isStation(XLoc,YLoc):- station(XLoc,YLoc).

% check if the guard carries at least one passenger.
havePassengers(Capacity):-
         Capacity > 0.

% perform drop action by resetting the capacity to be zero.
drop(NewCapacity):-
         NewCapacity = 0.

% remove a ship from ships list, and this is done by giving the
% predicate the x,y locations and the list of ships.
removeShip(Sh1x,Sh1y,[[Sh1x,Sh1y]|T],T).
removeShip(Sh1x,Sh1y,[[Sh2x,Sh2y]|T1],[[Sh2x,Sh2y]|T2]):-
	removeShip(Sh1x,Sh1y,T1,T2).

% check if the guard can move to right.
validRight(GuardY1):-
         width(W),
         GuardY1 < W - 1.

% check if the guard can move to left.
validLeft(GuardY1):-
         GuardY1 > 0.

% check if the guard can move down.
validDown(GuardX1):-
         height(H),
         GuardX1 < H - 1.

% check if the guard can move up.
validUp(GuardX1):-
         GuardX1 > 0.

% copy value of In to be in Out.
copy(In,Out):- Out = In.

% perform moving to right action.
moveRight(GuardX1,GuardY1,GuardX,GuardY):-
         GuardY is GuardY1 + 1,
         GuardX = GuardX1.

% perform moving to left action.
moveLeft(GuardX1,GuardY1,GuardX,GuardY):-
         GuardY is GuardY1 - 1,
         GuardX = GuardX1.

% perform moving down action.
moveDown(GuardX1,GuardY1,GuardX,GuardY):-
         GuardX is GuardX1 + 1,
         GuardY = GuardY1.

% perform moving up action.
moveUp(GuardX1,GuardY1,GuardX,GuardY):-
         GuardX is GuardX1 - 1,
         GuardY = GuardY1.








