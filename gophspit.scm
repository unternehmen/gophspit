#!/bin/sh
# -*- scheme -*-
exec /usr/bin/env guile-2.0 -e main -s "$0" "$@"
!#

(use-modules (ice-9 regex)
             (ice-9 rdelim)
             (sxml simple))

(define (map-lines-of-port func port)
  (letrec ((iter
             (lambda (acc)
               (let ((line (read-line port)))
                 (if (eof-object? line)
                   acc
                   (iter (cons (func line) acc)))))))
    (reverse (iter '()))))

(define line-regexp
  (make-regexp
    "^([0-9iI])([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*).*"
    regexp/extended))

(define (translate-line line)
  (let ((match (regexp-exec line-regexp line)))
    (let ((type     (match:substring match 1))
          (text     `(pre ,(match:substring match 2)))
          (selector (match:substring match 3))
          (addr     (match:substring match 4))
          (port     (match:substring match 5)))
      `(div (@ (class ,(string-append "line type-"
                                      (if (char-upper-case?
                                            (string-ref type 0))
                                        (string-append "cap-" type)
                                        type))))
         ,@(cond
             ((string=? type "i")
               `(,text))
             ((or (string=? type "0")
                  (string=? type "1")
                  (string=? type "I"))
                `((a (@ (href ,(cond
                                 ((and (string=? addr "(ROOT)")
                                       (string=? port "(ROOT)"))
                                   selector)
                                 ((and (string=? addr "(HERE)")
                                       (string=? port "(HERE)"))
                                   (string-append "." selector))
                                 (else (string-append
                                         "http://"
                                         addr ":" port selector)))))
                    ,text)))
             (else
               `(,text)))))))

(define (translate port)
  (with-output-to-string
    (lambda ()
      (begin
        (display "<!DOCTYPE html>")
        (newline)
        (sxml->xml
          `(html
             (head
               (link (@ (rel "stylesheet")
                        (type "text/css")
                        (href "style.css")))
               (title ""))
             (body
               ,@(map-lines-of-port translate-line port))))))))

(define (main . args)
  (cond ((not (provided? 'regex))
         (with-output-to-port (current-error-port)
           (lambda ()
             (begin
               (display "Need regular expression support.")
               (newline)))))
        (else
          (begin
            (display (translate (current-input-port)))
            (newline)))))
