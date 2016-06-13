#!/bin/sh
# -*- scheme -*-
exec /usr/bin/env guile-2.0 -e main -s "$0" "$@"
!#

(use-modules
  (ice-9 regex)
  (ice-9 rdelim)
  (srfi srfi-41)
  (sxml simple))

(define (compose f g)
  (lambda (x) (f (g x))))

(define* (port->line-stream #:optional (port (current-input-port)))
  (stream-let recurse ()
    (let ((c (read-line port)))
      (if (eof-object? c)
        stream-null
        (stream-cons c (recurse))))))

(define type-pattern ".")
(define text-pattern "[^\t]*")
(define selector-pattern "[^\t]*")
(define hostname-pattern "[^\t]*")
(define port-pattern "[^\t]*")

(define line-regexp
  (make-regexp
    (string-append
      "^(" type-pattern     ")"
      "("  text-pattern     ")\t"
      "("  selector-pattern ")\t"
      "("  hostname-pattern ")\t"
      "("  port-pattern     ").*")
    regexp/extended))

(define url-regexp (make-regexp "URL:(.*)" regexp/extended))

(define (linkize text selector hostname port)
  (let ((match (regexp-exec url-regexp selector)))
    (if (eq? match #f)
      `(a (@ (href ,(string-append
                      "gopher://"
                      hostname ":" port
                      selector)))
         ,text)
      `(a (@ (href ,(match:substring match 1))) ,text))))

(define line-type-infos
  '(("i" "      " "info"      #f)
    ("I" "[IMG] " "image"     #t)
    ("g" "[GIF] " "gif"       #t)
    ("7" "[SEA] " "search"    #t)
    ("0" "[TXT] " "text"      #t)
    ("1" "[DIR] " "directory" #t)
    ("h" "[HTM] " "html"      #t)
    ("s" "[AUD] " "audio"     #t)
    (""  "[???] " "unknown"   #f)))

(define (render-line-data type text selector hostname port)
  (let ((info (assoc-ref line-type-infos type)))
    (if (not (eq? info #f))
      (let ((prefix (car info))
            (class (cadr info))
            (link? (caddr info)))
        `(span (@ (class ,class))
           ,prefix
           ,(if link?
              (linkize text selector hostname port)
              text)))
      (let ((info (assoc-ref line-type-infos "")))
        (let ((prefix (car info))
              (class (cadr info))
              (link? (caddr info)))
          `(span (@ (class ,class))
             ,prefix
             ,(if link?
                (linkize text selector hostname port)
                text)))))))

(define (transform-line line)
  (let ((match (regexp-exec line-regexp line)))
    (if (not (eq? match #f))
      (let ((type     (match:substring match 1))
            (text     (string-append (match:substring match 2) "\n"))
            (selector (match:substring match 3))
            (hostname (match:substring match 4))
            (port     (match:substring match 5)))
        (render-line-data type text selector hostname port))
      "")))

(define (is-terminating-line? str)
  (string=? str "."))

(define (string-strip-right str)
  (string-trim-right str char-set:whitespace))

(define (main . args)
  (sxml->xml
    `(html
       (head
         (meta (@ (name "viewport")
                  (content "width=device-width, initial-scale=1")))
         (link (@ (rel "stylesheet")
                  (type "text/css")
                  (href "style.css"))))
       (body
         (pre
           ,@(stream->list
               (stream-map
                 transform-line
                 (stream-take-while
                   (compose not is-terminating-line?)
                   (stream-map
                     string-strip-right
                     (port->line-stream))))))))))
