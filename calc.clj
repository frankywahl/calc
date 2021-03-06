(use 'clojure.test) ; Single quote takes everything to the right and treat it as data. Pass it to the function
; use and require are functions, not macros.


; require:  link but do not copy
; use: copy into the current namespace (mutates the current namespace)

(def numeric
 (set (conj (map str (range 0 10)) ".")))

(def operators #{"+" "-"})
(def parens {"(" :open, ")" :close})
;(defn parse_token)


(def parse-token-examples
 [{:given "1" :expect 1M}
  {:given "1.5" :expect 1.5M}
  { :given "+" :expect :+}
  { :given "(" :expect :open}])

(defn parse-token [s]
 (cond
  (contains? operators s) (keyword s)
  (contains? parens s) (get parens s)
  :else (bigdec s)))

(deftest parse-token-test
 (doseq [example parse-token-examples]
  (is (= (:expect example) (parse-token (:given example))))))

(def tokenize-step-examples
 [
  {:given [] :expect [[], ""]}
  {:given [[[], "1"]] :expect [[1M] ""],}
  {:given [[[], ""]], :expect [[], ""],}
  {:given [[[], ""], "1"], :expect [[], "1"] },
  {:given [[[], "1"], "1"], :expect [[], "11"] },
  {:given [[[], "1"], "+"], :expect [[1M, :+], ""] },
  {:given [[[], "1"], "-"], :expect [[1M, :-], ""] },
  {:given [[[], "1"], "."], :expect [[], "1."] },
  {:given [[[], "1"], "."], :expect [[], "1."] },
  {:given [[[], "1."], "5"], :expect [[],"1.5"] },
  {:given [[[3], "1."], "5"], :expect [[3],"1.5"] },])

(defn tokenize-step
 ([]
  [[], ""])
 ([[token-list buffer] c]
  (cond
   (contains? numeric c) [token-list (str buffer c)]
   (empty? buffer) [(conj token-list (parse-token c)) ""]
   :else
   [(conj token-list (parse-token buffer) (parse-token c)) ""]))
 ([[token-list buffer]]
  (if (empty? buffer)
   [token-list ""]
   [(conj token-list (parse-token buffer)) ""])))

(def tokenize-examples
 [
   { :given "0", :expect [0M] },
   { :given "1 + 1", :expect [1M, :+, 1M] },
   ; todo: negative number tokens
   ; { given: "1+-1", expect: [1, :+, -1] },
   { :given "1 - 1", :expect [1M, :-, 1M] },
   { :given "1 + (1 + 1)", :expect [1M, :+, :open, 1M, :+, 1M, :close]}])

(defn chars-without-spaces
 [s]
 (as->
   s val ; assign s to val
   (seq val) ; val is now a seq of chars
   (filter #(not= \space %1) val) ; val has no spaces
   (map str val))) ; val is now a seq of 1 char strings

(defn tokenize
 "returns a seq of tokens from a given string"
 [s]
 (let
  [initial (tokenize-step)
   chrs (chars-without-spaces s)
   penultimate (red uce tokenize-step initial-memo chrs)
   final (tokenize-step last-memo)]
  (first final)))

(deftest tokenize-test
 (doseq [example tokenize-examples]
  (is (= (:expect example) (tokenize (:given example))))))

(deftest tokenize-step-test
 (doseq [example tokenize-step-examples]
  (is (= (:expect example) (apply tokenize-step (:given example))))))

(run-tests 'user)
