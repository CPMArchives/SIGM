
[EVALCOM.LSP]
[a compiler analogous to EVAL]
[compiles LISP into REC without ALIST]
[January 1, 1981]

[[
Type a LISP function - use round parentheses.
]]



[ASSOC]
(a ((lambda (0 1) (cond
    ((null 1) 0)
    ((eq 0 (car 1)) (cadr 1))
    ((and) (a 0 (cddr 1)))
    ))))

[EVALCOM]
(c ((lambda (1) (cond
    ((atom 1) (cons 1 (quote ($ryG))))
    ((eq (car 1) (quote quote)) (list (qu (cadr 1))))
    ((atom (car 1)) (d (car 1) (v (cdr 1))))
    ((eq (caar 1) (quote lambda))
        (m (v (cdr 1)) (cadr (car 1)) (c (cadr (cdar 1))) ))
        ))))

(d ((lambda (1 2) (cond
    ((eq 1 (quote if)) (p (list (car 2) (quote ('T'=))
        (cadr 2) (quote (;L)) (car (cddr 2)) (quote (;)) )))
    ((eq 1 (quote list)) (l 2))
    ((eq 1 (quote and)) (list (n 2)))
    ((eq 1 (quote or)) (list (o 2)))
    ((and) (e))
    ))))

[primitive atomic function forms]
(e ((lambda () (cond
    ((eq 1 (quote car)) (append (car 2) (quote (@1))))
    ((eq 1 (quote cdr)) (append (car 2) (quote (@2))))
    ((eq 1 (quote cons)) (append (car 2) (append (cadr 2)
        (quote (@3)))))
    ((eq 1 (quote atom)) (append (car 2) (quote (@4))))
    ((eq 1 (quote eq)) (append (car 2) (append (cadr 2)
        (quote (@5)))))
    ((and) (f))
    ))))

(f ((lambda () (cond
    ((eq 0 (quote not)) (not (e (car 1) 2)))
    ((eq 0 (quote append)) (append (e (car 1) 2) (e (cadr 1) 2)))
    ((eq 0 (quote cond)) (m 1))
    ((and) (h))
    ))))

[COMLIS - compile the function LIST]
(l ((lambda (1) (if (null 1) (quote ('()'))
     (p (list (car 1) (l (cdr 1)) (quote (@3)))) ))))

[COMLAM compile a LAMBDA]
(m ((lambda (0 1 2) (p (append 0 (list (s 1) 2 (r 1))) ))))

[COMAND]
(n ((lambda (1) (if (null 1) (quote ('T';;))
   (p (list (car 1) (quote ('T'=)) (n (cdr 1))))
   ))))

[EVOR - evaluate an OR]
(o ((lambda (1) (if (null 1) (quote ('F';))
    (p (list (car 1) (quote ('T'='T';L)) (o (cdr 1))))
    ))))

[multiple APPEND]
(p ((lambda (1) (if (null 1) 1 (append (car 1) (p (cdr 1))) ))))
[restore]
(r ((lambda (1) (if (null 1) 1 (append (quote (nLnn$S)) (r (cdr 1)))))))

[save]
(s ((lambda (1) (if (null 1) 1
    (append (list (car 1) (quote pGm$rmml) (car 1) (quote $S))
     (s (cdr 1)) ) ))))

[EVLIST - compile all the elements of a list]
(v ((lambda (1) (if (null 1) 1
    (cons (c (car 1)) (v (cdr 1))) ))))

[main program]
(* ((lambda (0) (c 0))))

[end]
