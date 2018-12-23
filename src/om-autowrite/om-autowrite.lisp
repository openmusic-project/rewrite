
;;;Simple OM wrapper for loading Autowrite files

(defpackage :nautowrite-system
  (:use :common-lisp))

(in-package :nautowrite-system)

(defparameter *autowrite-directory* (om::om-make-pathname :directory (append (pathname-directory *load-truename*) 
                                                                             '("Autowrite"))))
-
;; (format t "load-truename: ~A ~%" *load-truename*)
;(format t "autowrite-directory is ~A ~%" *autowrite-directory*)

(print "Loading Autowrite 4.0. (c) Irene Durand (LabRI)")

(mapcar #'(lambda (filedesc)
            (om::compile&load (om::om-make-pathname :directory (append (pathname-directory *autowrite-directory*) 
                                                                       (car filedesc))
                                                    :name (cadr filedesc))))
        '((("General") "package")
          (("General") "general")
          (("General") "hashtable")
          (("General") "time")
          (("General") "annotation")
          
          (("Names") "package")
          (("Names") "names")
      
          (("Object") "package")
          (("Object") "object")
          (("Object") "named-object")
	    
          (("Symbols") "package")
          (("Symbols") "arity")
          (("Symbols") "symbols")
          (("Symbols") "aux-symbol")
          (("Symbols") "signature")
          (("Symbols") "signed-object")
          (("Symbols") "annotated-symbols")
        
          (("Term") "package")
          (("Term") "abstract-term")
          (("Term") "variables")
          (("Term") "aux-var")
          (("Term") "vars-subst")
          (("Term") "path")
          (("Term") "position")
          (("Term") "term")
          (("Term") "term-variable")
          (("Term") "term-pos")
          (("Term") "omega-terms")
          (("Term") "aterm")
        
          (nil "package")
          (nil "globals")
          (nil "arities")
          (nil "unify")
          (nil "terms")
          (nil "state-contents")
          (nil "abstract-state")
          (nil "state")
          (nil "symbol-state")
          (nil "rule")
          (nil "rules")
          (nil "flat-term-state")
          (nil "term-state")
          (nil "container")
          (nil "gstate")
          (nil "target")
          (nil "transition")
          (nil "simple-table")
          (nil "dag-table")
          (nil "states-table")
          (nil "abstract-transitions")
          (nil "transitions")
          (nil "sym-transitions")
          (nil "simple-transitions")
          (nil "fly-transitions")
          (nil "term-rules")
          (nil "trs")
          (nil "termset")
          (nil "generation")
          (nil "index-point")
          (nil "abstract-automaton")
          (nil "table-automaton")
          (nil "bvstate")
          (nil "determinize")
          (nil "states-mapping")
          (nil "duplicate-automaton")
          (nil "automata")
          (nil "tuple-state")
          (nil "intersection-emptyness")
          (nil "term-to-state")
          (nil "accessibilite")
          (nil "boolean-op-automaton")
          (nil "product")
          (nil "union")
          (nil "sstates")
          (nil "intersection")
          (nil "equivalence-classes")
          (nil "quotient")
          (nil "minimization")
          (nil "simplification")
          (nil "epsilon")
          (nil "tautomate")
          (nil "forward-branching")
          (nil "index-tree")
          (nil "salinier")
          (nil "lexer")
          (nil "parser")
          (nil "nfautomate")
          (nil "bprime-automate")
          (nil "dstate")
          (nil "specification")
          (nil "gsaturation")
          (nil "nlsaturation")
          (nil "gd-automate")
          (nil "det-dautomate")
          (nil "dautomate")
          (nil "approximation")
          (nil "integration")
          (nil "file-path")
          (nil "input")
          (nil "output")
          (nil "init-autowrite")
          (nil "context")
          (nil "lang-context")
          (nil "needed-redex")
          (nil "termination")
          (nil "com-term")
          (nil "com-termset")
          (nil "com-trs")
          (nil "com-automaton")
          (nil "com-reduction")
          (nil "com-approximation")
          (nil "signature-mapping")
          (nil "vmodification")
          (nil "hvmodification")
          (nil "vprojection")
          (nil "vcylindrification")
          (nil "vhomomorphisme")
          (nil "cprojection")
          (nil "fly-automaton")
          (nil "fly-to-table")
          (nil "vbits-homomorphisms")
          (nil "jeu-de-tests")
          )
        )

(pushnew :nautowrite *features*)


