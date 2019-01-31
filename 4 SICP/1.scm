;练习1.3 返回给定3个数中较大的两个数的和
(define (sum_max_2_of_3 x y z)
        (cond 
            ((and (< x y) (< x z)) (+ y z))
            ((and (< y x) (< y z)) (+ x z))
            (else (+ x y))
        )
)
(sum_max_2_of_3 1 2 3)


;练习1.6 一种检测解释器究竟采用应用序还是正则序求值的2个过程:
(define (p) (p))
(define (test x y)
    (if (= x 0) 0 y)
    ;很简单，在正则序求值中，调用 (p) 从始到终都没有被执行，所以也就不会产生无限循环，因此，如果返回 0 ，那么这个解释器使用的是正则序求值模式。
)
(test 0 (p));无结果，可证明 Lisp 采用应用序求值。


;练习1.8 求立方根的牛顿法基于如下事实：如果 y 是 x 的立方根的一个近似值，那么下式将给出一个更好的近似值：
;   ((x/y^2) + 2y)/3
(define (newton_guess x y)
    (/
        (+ (/ x (* y y )) (* 2 y))
        3
    ))


;练习1.9 下面2个过程各定义了一种将2个正整数相加的方法，它们都基于过程 inc(+1)和dec(-1):
(define (plus a b)
    (if (= a 0)
        b
        (inc (plus dec a) b)))

(define (plus_2 a b)
    (if (= a 0)
        b
        (plus_2 (dec a) (inc b))))

;对 (plus 2 3) 进行求值，表达式的展开过程为
; (plus 2 3)
; (inc (plus 1 3))
; (inc (inc (plus 0 3)))
; (inc (inc 3))
; (inc 4)
; 5
; 很明显: 该过程有伸展和收缩两个阶段，伸展阶段所需的额外存储量和计算所需的步数都正比于参数 n ，说明这是一个线性递归计算过程。

;对 (plus_2 2 3) 进行求值，表达式的展开过程为
; (plus_2 1 4)
; (plus_2 0 5)
; 5
; plus_2 函数只使用常量存储大小，且计算所需的步骤正比于参数 n ，说明这是一个线性迭代计算过程。


;练习1.11 如果 n < 3,f(n) = n;如果 n >= 3,f(n) = f(n-1) + 2f(n-2) + 3f(n-3)
;递归计算过程:
(define (f n)
    (cond 
        ((< n 3) n)
        ((>= n 3) 
            ( + (f (- n 1))
                (* 2 (f (- n 2)))
                (* 3 (f (- n 3)))
            ))
        ))
;迭代计算过程:从f(0)开始一步步计算出f(n): 
(define (f n)
    (f-iter 0 1 2 0 n)); f(0)、f(1)、f(2), i, n

(define (f_iter a b c i n)
    (if (< i n)
        (f_iter b                       ; new a
                c                       ; new b
                (+ c (* 2 b) (* 3 a))   ; new c
                (+ i 1)
                n)
        a))
(f_iter 0 1 2 0 3) ;Value: 4

#| Python版:(f_iter 0 1 2 0 3)
def f_iter(n, i=0):
    a, b, c = 0, 1, 2 # 初始值
    while i < n:
        a, b, c = b, c, c + 2 * b + 3 * a
        i += 1
    return a
|#

;练习1.12 帕斯卡三角形; x,y 为其坐标,从1开始，如(2, 3)值为2
(define (pascal x y)
    (if (or (= x 1) (= x y))
        1
        (+ (pascal (- x 1) (- y 1))
            (pascal x (- y 1))
        )))


;练习1.20 欧几里得算法求最大公约数
(define (gcd a b)
    (if (= b 0)
        a
        (gcd b (remainder a b))))
;(gcd 6 9) ;Value: 3

