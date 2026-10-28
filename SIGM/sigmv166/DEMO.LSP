
[DEMO.LSP]
[collection of LISP demonstration programs]
[December 31, 1980]
[December 28, 1983]

[[
A collection of LISP demonstration programs:
     (merge (1 2 3) (a b c)) produces (1 a 2 b 3 c)
     (reverse (1 2 3 4 5)) produces (5 4 3 2 1)
     (split (1 a 2 b 3 c)) produces ((1 2 3) (a b c))
     (split* (1 a 2 b 3 c)) produces the same result
     (binsum (1 1 1 0) (1 1)) produces (1 0 0 0 1)
To execute one of these programs, type its name, then
a carriage return. Then type its arguments, in response
to the prompts.
]]



[calculate a binary sum - use reversed digits]
(b ((lambda (0 1) (r (c (r 0 (list)) (r 1 (list))) (list)) )))

[binary sum - sum low order bits, then rest]
(c ((lambda (0 1) (cond
    ((null 0) 1)
    ((null 1) 0)
    ((and) (cons (d (car 0) (car 1))
		 (c (list (e (car 0) (car 1))) (c (cdr 0) (cdr 1))) ))
    ))))

[sum of two bits]
(d ((lambda (0 1) (cond
    ((eq 0 (quote 0)) 1)
    ((eq 1 (quote 0)) 0)
    ((and) (quote 0))
    ))))

[carry bit]
(e ((lambda (0 1) (cond
    ((eq 0 (quote 0)) (quote 0))
    ((eq 1 (quote 0)) (quote 0))
    ((and) (quote 1))
    ))))

[make a list of two elements]
(l ((lambda (0 1) (cons 0 (cons 1 (quote ()))))))

[merge two lists]
(m ((lambda (0 1) (if (null 0) 1
		  (if (null 1) 0
		  (cons (car 0) (cons (car 1) (m (cdr 0) (cdr 1))))
		  )))))

[reverse a list]
(r ((lambda(0 1)(if(eq 0 (quote ()))1(r(cdr 0)(cons(car 0)1)))) ))

[split a list into odds and evens]
(s ((lambda (0 1 2) (if (null 0) (l 1 2)
		    (if (null (cdr 0)) (l (cons (car 0) 1) 2)
		    	(s (cddr 0) (cons (car 0) 1)
			   (cons (cadr 0) 2))
		    )))))

[split a list into odds and evens - variant]
(t ((lambda (0) (if (null 0) (l 0 0)
		 (if (null (cdr 0)) (l 0 (quote ()))
		 ((lambda (1) (l (cons (car 0) (car 1))
				 (cons (cadr 0) (cadr 1))
				 )) (t (cddr 0)))
		 )))))

[main program]
(* ((lambda(0)
	(if (eq 0 (quote merge)) (m (read) (read))
	(if (eq 0 (quote reverse)) (r (read) (quote()))
	(if (eq 0 (quote split)) (s (read) (quote ()) (quote ()))
	(if (eq 0 (quote split*)) (t (read))
	(if (eq 0 (quote binsum)) (b (read) (read))
	(quote (wrong option))
	)))))
	)))

[end]
