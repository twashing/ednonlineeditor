(ns ednonlineeditor.core
  (:require [goog.dom :as gdom]
            [om.next :as om :refer-macros [defui]]
            [om.dom :as dom]))

(enable-console-print!)


;; define your app data so that it doesn't get over-written on reload

#_(defonce app-state (atom {:text "Hello world!"}))
#_(defn on-js-reload []
  ;; optionally touch your app-state to force rerendering depending on
  ;; your application
  ;; (swap! app-state update-in [:__figwheel_counter] inc)
)


(def app-state (atom {:count 0}))

(defui Counter
  Object
  (render [this]
          (let [{:keys [count]} (om/props this)]
            (dom/div nil
                     (dom/span nil (str "Count: " count))
                     (dom/button
                      #js {:onClick
                           (fn [e]
                             (swap! app-state update-in [:count] inc))}
                      "Click me!")))))

(def reconciler
  (om/reconciler {:state app-state}))

(om/add-root! reconciler
              Counter(gdom/getElement "app"))


(comment

  ;; 1. pretty print data to string
  (def data {:hello "world", :things {:vegetables #{"cauliflower" "sprouts" "cucumber"}, :primes [2 3 5 7 11 13 17 19 23], :fruits #{"apple" "banana" "strawberry" "kiwi"}}})

  (require '[cljs.pprint :as pp])
  (with-out-str (pp/pprint data))

  ;; 2. template lang to pull in HTML (kioo vs. hiccups)
  ;; 3. HTML header with nice font
  ;; 4. Layout
  ;;   1 box
  ;;   2 buttons (pretty & unpretty)
  ;; 5. stitch it into AWS
  ;; 6. DNS direct to AWS
  
  
 )
