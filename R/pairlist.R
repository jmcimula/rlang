#' Helpers for pairlist and language nodes.
#'
#' @description
#'
#' Like any [parse tree](https://en.wikipedia.org/wiki/Parse_tree), R
#' expressions are structured as trees of nodes. Each node has two
#' components: the head and the tail (though technically there is
#' actually a third component for argument names, see details). Due to
#' R's [lisp roots](https://en.wikipedia.org/wiki/CAR_and_CDR), the
#' head of a node (or cons cell) is called the CAR and the tail is
#' called the CDR (pronounced _car_ and _cou-der_). While R's ordinary
#' subsetting operators have builtin support for indexing into these
#' trees and replacing elements, it is sometimes useful to manipulate
#' the nodes more directly. This is the purpose of functions like
#' `node_car()` and `set_node_car()`. They are particularly useful to
#' prototype algorithms for your C-level functions.
#'
#' * `node_car()` and `set_node_car()` access or change the head of a node.
#'
#' * `node_cdr()` and `set_node_cdr()` access or change the tail of a node.
#'
#' * Variants like `node_caar()` or `set_node_cdar()` deal with the
#'   CAR of the CAR of a node or the CDR of the CAR of a node
#'   respectively. The letters in the middle indicate the type (CAR or
#'   CDR) and order of access.
#'
#' * `node_tag()` and `set_node_tag()` access or change the tag of a
#'   node. This is meant for argument names and should only contain
#'   symbols (not strings).
#'
#' * `node()` creates a new node from two components.
#'
#' @details
#'
#' R has two types of nodes to represent parse trees: language nodes,
#' which represent function calls, and pairlist nodes, which represent
#' arguments in a function call. These are the exact same data
#' structures with a different name. This distinction is helpful for
#' parsing the tree: the top-level node of a function call always has
#' _language_ type while its arguments have _pairlist_ type.
#'
#' Note that it is risky to manipulate calls at the node level. First,
#' the calls are changed inplace. This is unlike base R operators
#' which create a new copy of the language tree for each modification.
#' To make sure modifying a language object does not produce
#' side-effects, rlang exports the `duplicate()` function to create
#' deep copy (or optionally a shallow copy, i.e. only the top-level
#' node is copied). The second danger is that R expects language trees
#' to be structured as a `NULL`-terminated list. The CAR of a node is
#' a data slot and can contain anything, including another node (which
#' is how you form trees, as opposed to mere linked lists). On the
#' other hand, the CDR has to be either another node, or `NULL`. If it
#' is terminated by anything other than the `NULL` object, many R
#' commands will crash, including functions like `str()`. It is up to
#' you to ensure that the language list you have modified is
#' `NULL`-terminated.
#'
#' Finally, all nodes can contain metadata in the TAG slot. This is
#' meant for argument names and R expects tags to contain a symbol
#' (not a string).
#'
#' @param x A language or pairlist node. Note that these functions are
#'   barebones and do not perform any type checking.
#' @param newcar,newcdr The new CAR or CDR for the node. These can be
#'   any R objects.
#' @param newtag The new tag for the node. This should be a symbol.
#' @seealso [duplicate()] for creating copy-safe objects,
#'   [lang_head()] and [lang_tail()] as slightly higher level
#'   alternatives that check their input, and [base::pairlist()] for
#'   an easier way of creating a linked list of nodes.
#' @examples
#' # Changing a node component happens in place and can have side
#' # effects. Let's create a language object and a copy of it:
#' lang <- quote(foo(bar))
#' copy <- lang
#'
#' # Using R's builtin operators to change the language tree does not
#' # create side effects:
#' copy[[2]] <- quote(baz)
#' copy
#' lang
#'
#' # On the other hand, the CAR and CDR operators operate in-place. Let's
#' # create new objects since the previous examples triggered a copy:
#' lang <- quote(foo(bar))
#' copy <- lang
#'
#' # Now we change the argument pairlist of `copy`, making sure the new
#' # arguments are NULL-terminated:
#' set_node_cdr(copy, node(quote(BAZ), NULL))
#'
#' # Or equivalently:
#' set_node_cdr(copy, pairlist(quote(BAZ)))
#' copy
#'
#' # The original object has been changed in place:
#' lang
#' @md
#' @name pairlist
NULL

#' @rdname pairlist
#' @useDynLib rlang rlang_cons
#' @export
node <- function(newcar, newcdr) {
  .Call(rlang_cons, newcar, newcdr)
}

#' @rdname pairlist
#' @useDynLib rlang rlang_car
#' @export
node_car <- function(x) {
  .Call(rlang_car, x)
}
#' @rdname pairlist
#' @useDynLib rlang rlang_cdr
#' @export
node_cdr <- function(x) {
  .Call(rlang_cdr, x)
}
#' @rdname pairlist
#' @useDynLib rlang rlang_caar
#' @export
node_caar <- function(x) {
  .Call(rlang_caar, x)
}
#' @rdname pairlist
#' @useDynLib rlang rlang_cadr
#' @export
node_cadr <- function(x) {
  .Call(rlang_cadr, x)
}
#' @rdname pairlist
#' @useDynLib rlang rlang_cdar
#' @export
node_cdar <- function(x) {
  .Call(rlang_cdar, x)
}
#' @rdname pairlist
#' @useDynLib rlang rlang_cddr
#' @export
node_cddr <- function(x) {
  .Call(rlang_cddr, x)
}

#' @rdname pairlist
#' @useDynLib rlang rlang_set_car
#' @export
set_node_car <- function(x, newcar) {
  .Call(rlang_set_car, x, newcar)
}
#' @rdname pairlist
#' @useDynLib rlang rlang_set_cdr
#' @export
set_node_cdr <- function(x, newcdr) {
  .Call(rlang_set_cdr, x, newcdr)
}
#' @rdname pairlist
#' @useDynLib rlang rlang_set_caar
#' @export
set_node_caar <- function(x) {
  .Call(rlang_set_caar, x)
}
#' @rdname pairlist
#' @useDynLib rlang rlang_set_cadr
#' @export
set_node_cadr <- function(x, newcar) {
  .Call(rlang_set_cadr, x, newcar)
}
#' @rdname pairlist
#' @useDynLib rlang rlang_set_cdar
#' @export
set_node_cdar <- function(x) {
  .Call(rlang_set_cdar, x)
}
#' @rdname pairlist
#' @useDynLib rlang rlang_set_cddr
#' @export
set_node_cddr <- function(x, newcdr) {
  .Call(rlang_set_cddr, x, newcdr)
}

#' @rdname pairlist
#' @useDynLib rlang rlang_tag
#' @export
node_tag <- function(x) {
  .Call(rlang_tag, x)
}
#' @rdname pairlist
#' @useDynLib rlang rlang_set_tag
#' @export
set_node_tag <- function(x, newtag) {
  .Call(rlang_set_tag, x, newtag)
}

#' Duplicate an R object.
#'
#' In R semantics, objects are copied by value. This means that
#' modifying the copy leaves the original object intact. Since,
#' copying data in memory is an expensive operation, copies in R are
#' as lazy as possible. They only happen when the new object is
#' actually modified. However, some operations (like [set_node_car()]
#' or [set_node_cdr()]) do not support copy-on-write. In those cases,
#' it is necessary to duplicate the object manually in order to
#' preserve copy-by-value semantics.
#'
#' Some objects are not duplicable, like symbols and environments.
#' `duplicate()` returns its input for these unique objects.
#'
#' @param x Any R object. However, uncopyable types like symbols and
#'   environments are returned as is (just like with `<-`).
#' @param shallow This is relevant for recursive data structures like
#'   lists, calls and pairlists. A shallow copy only duplicates the
#'   top-level data structure. The objects contained in the list are
#'   still the same.
#' @seealso pairlist
#' @export
#' @useDynLib rlang rlang_duplicate
#' @useDynLib rlang rlang_shallow_duplicate
#' @md
duplicate <- function(x, shallow = FALSE) {
  if (shallow) {
    .Call(rlang_shallow_duplicate, x)
  } else {
    .Call(rlang_duplicate, x)
  }
}


node_walk <- function(.x, .f, ...) {
  cur <- .x
  while(!is.null(cur)) {
    .f(cur, ...)
    cur <- node_cdr(cur)
  }
  NULL
}
node_walk_nonnull <- function(.x, .f, ...) {
  cur <- .x
  out <- NULL
  while(!is.null(cur) && is.null(out)) {
    out <- .f(cur, ...)
    cur <- node_cdr(cur)
  }
  out
}
node_walk_last <- function(.x, .f, ...) {
  cur <- .x
  while(!is.null(node_cdr(cur))) {
    cur <- node_cdr(cur)
  }
  .f(cur, ...)
}

node_append <- function(.x, .y) {
  node_walk_last(.x, function(l) set_node_cdr(l, .y))
  .x
}
