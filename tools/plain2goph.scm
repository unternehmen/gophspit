#!/bin/sh
# -*- scheme -*-
exec /usr/bin/env guile-2.0 -e main -s "$0" "$@"

This script takes a file from standard input and outputs a Gopherized
version, with every line being an info line.  It also strips off any
trailing whitespace on the right side all lines.

!#

(use-modules (ice-9 rdelim)
             (ice-9 streams))

(define (convert-line line)
  (let ((trimmed (string-trim-right line char-set:whitespace)))
    (string-append "i" trimmed "	fake	(NULL)	0")))

(define (display-line obj . args)
  (begin
    (apply display obj args)
    (apply newline args)))

(define (main . args)
  (stream-for-each
    display-line
    (let ((line-stream (port->stream (current-input-port) read-line)))
      (stream-map convert-line line-stream))))
