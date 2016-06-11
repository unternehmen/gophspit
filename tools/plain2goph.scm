#!/bin/sh
# -*- scheme -*-
exec /usr/bin/env guile-2.0 -e main -s "$0" "$@"

This script takes a file from standard input and outputs a Gopherized
version, with every line being an info line.  It also strips off any
trailing whitespace on the right side all lines.

!#

(use-modules (ice-9 rdelim)
             (ice-9 streams))

(define (make-line-stream port)
  (make-stream
    (lambda (port)
      (let ((line (read-line port)))
        (if (eof-object? line)
          #f
          (cons line port))))
    port))

(define (main . args)
  (stream-for-each
    (lambda (line)
      (begin
        (display
          (string-append
            "i"
            (string-trim-right line char-set:whitespace)
            "	fake	(NULL)	0"))
        (newline)))
    (make-line-stream (current-input-port))))
