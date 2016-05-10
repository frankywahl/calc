(use 'clojure.test) ; Single quote takes everything to the right and treat it as data. Pass it to the function
; use and require are functions, not macros.


; require:  link but do not copy
; use: copy into the current namespace (mutates the current namespace)

(def numeric
 (set (conj (map str (range 0 10)) ".")))

(def operators #{"+" "-"})
(def parens {"(" :open, ")" :closed})
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
  {:given [[], "1"] :expect [[1M] ""]}
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
 ([[token-list buffer]]))

(deftest tokenize-step-test
 (doseq [example tokenize-step-examples]
  (is (= (:expect example) (apply tokenize-step (:given example))))))

(run-tests 'user)
