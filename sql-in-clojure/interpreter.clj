;by Haishi Qi


"tables"
(def persons
  #{{:id 1 :name "olle"}
    {:id 2 :name "anna"}
    {:id 3 :name "hash"}
    {:id 4 :name "heisenberg"}
    {:id 5 :name "ollie"}})

(def cars    #{{:id 1 :car "BMW"}
               {:id 2 :car "Toyota"}
               {:id 3 :car "Hyundai"}
               {:id 4 :car "Mustang"}
               {:id 5 :car "Tesla"}})


"like"
(defn like [target value]
  (cond (<= (count value) (count target))
        (= (subs target 0 (count value)) value)

        :else
        false))


"in"
;(filter (fn [x] (in (x :id) #{{:id 4} {:id 3}})) persons)
(defn in [elem coll]
  (let [column (first (keys (first coll)))]
    (boolean (some (fn [x] (= x elem)) (map (fn [x] (x (first (keys (first coll))))) coll)))))
;(in 3 '({:id 4} {:id 3}))

"select macro"
(defmacro select [ a & forms ]
  (cond (= 0 (count forms))
        a

        :else ; columns sql-from table sql-where cond-column (operator value) sql-orderby order-column
        (let [columns      a
              table        (second forms)
              cond-column  (nth forms 3)
              operator     (nth forms 4)
              value        (nth forms 5)
              order-column (last forms)]
          `(sort-by ~order-column
                    (set (map (fn [a#] (select-keys a# ~columns))
                         (filter (fn [x#] (~operator (x# ~cond-column) ~value)) ~table)))))))


"tests"
(select "a")

(select #{{:name "hash", :id 3} {:name "olle", :id 1}})

(select [:car] from cars
         where :id in (select [:id] from persons
                        where :name like "h"
                        orderby :id)
         orderby :id)

(select [:id :name] from persons
         where :id in (select [:id] from cars
                        where :car like "T"
                        orderby :id)
         orderby :name)

(select [:id :name] from persons
         where :id = 2
         orderby :name)

(select [:id :name] from persons
        where :id in #{{:id 1} {:id 3}}
        orderby :id)

(select [:name] from persons
        where :name like "o"
        orderby :name)
