(ns ednonlineeditor.core
  (:require [cljs.reader :refer [read-string]]
            [cljs.pprint :as pp]
            [goog.dom :as gdom]
            [om.next :as om :refer-macros [defui]]
            [om.dom :as dom]))


(enable-console-print!)


(def app-state (atom {:edn-string ""}))

(def data {:hello "world", :things {:vegetables #{"cauliflower" "sprouts" "cucumber"}, :primes [2 3 5 7 11 13 17 19 23], :fruits #{"apple" "banana" "strawberry" "kiwi"}}})

(def new-data {:foo "bar" :things {:alist [1 2 3 4 "five" true] :aset #{"qwerty" "asdf" "zxcv"}}})

(defui EdnInput
  Object
  (render [this]
          (let [{:keys [edn-string]} (om/props this)
                _ (println (str "EdnInput/render CALLED: " (om/props this)))
                edn-edn (read-string edn-string)]
            (dom/div nil
                     (dom/div nil
                              (dom/button
                               #js {:onClick
                                    (fn [e]
                                      (swap! app-state update-in
                                             [:edn-string]
                                             (fn [ee]
                                               (let [edn-pretty (with-out-str (pp/pprint edn-edn))]
                                                 (println (str "onClick CALLED: " edn-pretty))
                                                 edn-pretty))))}
                               ">>"))
                     (dom/div nil
                              (dom/textarea
                               #js {:id "edn-pane"
                                    :value edn-string #_(with-out-str (pp/pprint edn-edn))
                                    :onChange #(println (str "onChange CALLED: " (with-out-str (pp/pprint %))))
                                    :onBlur
                                    (fn [e]
                                      (println "onBlur CALLED: " (.-value (.-currentTarget e)))
                                      (swap! app-state update-in
                                             [:edn-string]
                                             (fn [ee]
                                               (.-value (.-currentTarget e)))))}))
                     ))))

(def reconciler
  (om/reconciler {:state app-state}))

(om/add-root! reconciler
              EdnInput (gdom/getElement "app"))



(comment

  ;; 1. pretty print data to string
  (def data {:hello "world", :things {:vegetables #{"cauliflower" "sprouts" "cucumber"}, :primes [2 3 5 7 11 13 17 19 23], :fruits #{"apple" "banana" "strawberry" "kiwi"}}})

  (def one {:foo "bar" :baz "quux"})
  
  (require '[cljs.pprint :as pp])
  (with-out-str (pp/pprint data))

  ;; 2. template lang to pull in HTML (kioo vs. hiccups)
  ;; 3. HTML header with nice font
  ;; 4. Layout
  ;;   1 box
  ;;   2 buttons (pretty & unpretty)
  ;; 5. stitch it into AWS
  ;; 6. DNS direct to AWS
  

  ;; lein run -m ednonlineeditor.shell/-main
  
 )
