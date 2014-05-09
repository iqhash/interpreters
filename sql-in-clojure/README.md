Simple SQL interpreter in Clojure
=================================

#How to use
Just drag the interpreter into LightTable  
cmd + a --> cmd + enter  
That’s it.  

#Example
(select [:id :name] from persons  
        where :id in #{{:id 1} {:id 3}}  
        orderby :id)  
