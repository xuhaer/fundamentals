;练习2.17 定义 last-pair,它返回只包含给定(非空)表里的最后一个元素
(define (last-pair lst)
    (cond ((null? (cdr lst))
            lst)
          (else
;(last-pair (list 1 2 3))
;Value 13: (3)


;练习2.18 定义一个 reverse 一个表的过程
(define (reverse lst)
    (iter lst '())); '()为一空 list

(define (iter remained-items result)
    (if (null? remained-items)
        result
        (iter (cdr remained-items)
              (cons (car remained-items) result))))
(reverse (list 1 2 3)) ;(3 2 1)


;练习2.21 定义一个返回一个表的平方的过程
(define (square-list items)
    (if (null? items)
        '()
        (cons (square (car items))
              (square-list (cdr items)))))

(square-list (list 1 2 3)) ;(1 4 9)