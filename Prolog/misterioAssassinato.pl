vitima(boddy).
caso(boddy, green).
caso(scarlett, boddy).
casado(plum, green).
rico(boddy).
/*rico(mustard). Adicionando esse fato, temos apenas um suspeito de crime. */
ambicioso(mustard).

odio(X) :- casado(X,Y) , caso(Z,Y).
dispostoAssassinar(X) :- ambicioso(X) , not(rico(X)) , vitima(Y) , rico(Y).
suspeito(X) :- dispostoAssassinar(X) ; odio(X).