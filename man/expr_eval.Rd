% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lang-expr.R
\name{expr_eval}
\alias{expr_eval}
\title{Evaluate an expression in an environment.}
\usage{
expr_eval(expr, env = parent.frame())
}
\arguments{
\item{expr}{An expression to evaluate.}

\item{env}{The environment in which to evaluate the expression.}
}
\description{
\code{expr_eval()} is a lightweight version of the base function
\code{\link[base]{eval}()}. It does not accept supplementary data,
but it is more efficient and does not clutter the evaluation stack.
Technically, \code{expr_eval()} is a simple wrapper around the C
function \code{Rf_eval()}.
}
\details{
\code{base::eval()} inserts two call frames in the stack, the
second of which features the \code{envir} parameter as frame
environment. This may unnecessarily clutter the evaluation stack
and it can change evaluation semantics with stack sensitive
functions in the case where \code{env} is an evaluation environment
of a stack frame (see \code{\link{eval_stack}()}). Since the base
function \code{eval()} creates a new evaluation context with
\code{env} as frame environment there are actually two contexts
with the same evaluation environment on the stack when \code{expr}
is evaluated. Thus, any command that looks up frames on the stack
(stack sensitive functions) may find the parasite frame set up by
\code{eval()} rather than the original frame targetted by
\code{env}. As a result, code evaluated with \code{base::eval()}
does not have the property of stack consistency, and stack
sensitive functions like \code{\link[base]{return}()},
\code{\link[base]{parent.frame}()} may return misleading results.
}
\examples{
# expr_eval() works just like base::eval():
env <- new_env(data = list(foo = "bar"))
expr <- quote(foo)
expr_eval(expr, env)

# To explore the consequences of stack inconsistent semantics, let's
# create a function that evaluates `parent.frame()` deep in the call
# stack, in an environment corresponding to a frame in the middle of
# the stack. For consistency we R's lazy evaluation semantics, we'd
# expect to get the caller of that frame as result:
fn <- function(eval_fn) {
  list(
    returned_env = middle(eval_fn),
    actual_env = env()
  )
}
middle <- function(eval_fn) {
  deep(eval_fn, env())
}
deep <- function(eval_fn, eval_env) {
  expr <- quote(parent.frame())
  eval_fn(expr, eval_env)
}

# With expr_eval(), we do get the expected environment:
fn(rlang::expr_eval)

# But that's not the case with base::eval():
fn(base::eval)

# Another difference of expr_eval() compared to base::eval() is
# that it does not insert parasite frames in the evaluation stack:
get_stack <- quote(identity(eval_stack()))
expr_eval(get_stack)
eval(get_stack)
}
\seealso{
with_env
}
