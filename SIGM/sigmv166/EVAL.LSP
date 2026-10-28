
[EVAL.LSP]
[the LISP function EVAL]
[January 1, 1981]



[ASSOC]
(a ((lambda (0 1)
    (if (eq 0 (car 1)) (cadr 1) (a 0 (cddr 1))))))

[EVAL]
(e ((lambda (0 2) (cond
    ((atom 0) (a 0 2))
    ((atom (car 0)) (f (car 0) (cdr 0)))
    ((eq (caar 0) (quote lambda))
        (e (cadr (cdar 0)) (v (cadr (car 0)) (cdr 0))))
        ))))

[the most primitive atomic function forms]
(f ((lambda (0 1) (cond
    ((eq 0 (quote car)) (car (e (car 1) 2)))
    ((eq 0 (quote cdr)) (cdr (e (car 1) 2)))
    ((eq 0 (quote cons)) (cons (e (car 1) 2) (e (cadr 1) 2)))
    ((eq 0 (quote atom)) (atom (e (car 1) 2)))
    ((eq 0 (quote eq)) (eq (e (car 1) 2) (e (cadr 1) 2)))
    ((eq 0 (quote quote)) (car 1))
    ((eq 0 (quote if)) (if (e (car 1) 2) (e (cadr 1) 2)
				(e (car (cddr 1)) 2) ))
    ((and) (g))
    ))))

[convenient atomic function forms]
(g ((lambda () (cond
    ((eq 0 (quote and)) (n 1))
    ((eq 0 (quote or)) (o 1))
    ((eq 0 (quote not)) (not (e (car 1) 2)))
    ((eq 0 (quote list)) (l 1))
    ((eq 0 (quote append)) (append (e (car 1) 2) (e (cadr 1) 2)))
    ((eq 0 (quote cond)) (m 1))
    ((and) (h))
    ))))

[CAR and CDR composites]
(h ((lambda () (cond
    ((eq 0 (quote caar)) (car (car (e (car 1) 2))))
    ((eq 0 (quote cadr)) (car (cdr (e (car 1) 2))))
    ((eq 0 (quote cdar)) (cdr (car (e (car 1) 2))))
    ((eq 0 (quote cddr)) (cdr (cdr (e (car 1) 2))))
    ((and) (i))
    ))))

[service functions]
(i ((lambda () (cond
    ((eq 0 (quote print)) (print (e (car 1) 2)))
    ((eq 0 (quote read)) (read))
    ))))

[EVLIS - evaluate a LIST]
(l ((lambda (1)
    (if (null 1) 1 (cons (e (car 1) 2) (l (cdr 1)))) )))

[EVCON - evaluate COND]
(m ((lambda (1)
    (if (e (caar 1) 2) (e (car (cdar 1)) 2) (m (cdr 1))) )))

[EVAND - evaluate an AND]
(n ((lambda (1)
    (or (null 1) (and (e (car 1) 2) (n (cdr 1)))) )))

[EVOR - evaluate an OR]
(o ((lambda (1)
    (and (not (null 1)) (or (e (car 1) 2) (o (cdr 1)))) )))

[EVARGS - augment ALIST for LAMBDA]
(v ((lambda (0 1) (if (null 0) 2
    (cons (car 0) (cons (e (car 1) 2) (v (cdr 0) (cdr 1))))
    ))))

[main program]
(* (print (e (read) (quote ()))))

[end]
