
- hi

- likely you've heard a little about how these sessions work from the others

- we'll start with some ruby code that is basically anti-clojure. redesign and implement it in a functional style, then port it to Clojure

- our task during this session will be to *break the program apart* into smaller pieces with single responsibilities that can be easily tested. then *compose* those pieces back into a better ruby solution that works like the original program but supports decimal (not float) numbers.

- specific topics we'll touch upon in this session:

- design and testing
- reduce
- stack algorithms
- pure functions
- function arity
- lazy evaluation

----

"At runtime, our data scope is any data we can see from within our thread. It encompasses data which is within lexical scope, and any accessible vars. Functions can do three things: pull data into scope, transform data, or push data into another scope. When we take from a queue, we bring data into scope. When put onto a queue, we push data out of scope. HTTP GET and POST requests can be seen as pulling and pushing, respectively.

...

Most functions should only push, pull, or transform data. At least one function in every process must do all three, but these combined functions are difficult to reuse. Separate actions should be defined separately, and then composed."

- Zachary Tellman (http://elementsofclojure.com)
