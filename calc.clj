(use 'clojure.test) ; Single quote takes everything to the right and treat it as data. Pass it to the function
; use and require are functions, not macros.


; require:  link but do not copy
; use: copy into the current namespace (mutates the current namespace)

(def numeric
 (conj
  (map  str
   (range 0 10)) "."))


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

(deftest my-test
 (doseq [example parse-token-examples]
  (is (= (:expect example) (parse-token (:given example))))))

(run-tests 'user)
