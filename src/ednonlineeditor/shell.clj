(ns ednonlineeditor.shell
  (:require [ring.util.response :as resp]
            [figwheel-sidecar.repl-api :as ra]
            [com.stuartsierra.component :as component]
            [system.components.jetty :refer [new-web-server]]
            [compojure.core :refer :all]
            [compojure.route :as route]))

(def figwheel-config
  {:figwheel-options {} ;; <-- figwheel server config goes here
    :build-ids ["dev"]   ;; <-- a vector of build ids to start autobuilding
    :all-builds          ;; <-- supply your build configs here
    [{:id "dev"
      :figwheel true
      :source-paths ["src"]
      :compiler {:main "ednonlineeditor.core"
                 :asset-path "js"
                 :output-to "resources/public/js/compiled/ednonlineeditor.js"
                 :output-dir "resources/public/js"
                 :verbose true}}]})


(defrecord Figwheel []
  component/Lifecycle
  (start [config]
    (ra/start-figwheel! config)
    config)
  (stop [config]
    ;; you may want to restart other components but not Figwheel
    ;; consider commenting out this next line if that is the case
    (ra/stop-figwheel!)
    config))

(defn index-handler [request]
  (resp/resource-response "index.html" {:root "public"}))

(defn handler [request]
  (index-handler request))

(defroutes shell-routes
  (GET "/" req (index-handler req))
  (route/resources "/")
  (route/not-found "Page not found"))


(def system
  (atom
   (component/system-map
    :app-server (new-web-server 8080 shell-routes)
    :figwheel   (map->Figwheel figwheel-config))))

(def system-main
  (atom
   (component/system-map
    :app-server (new-web-server 80 shell-routes))))

(defn start []
  (swap! system component/start))

(defn stop []
  (swap! system component/stop))

(defn reload []
  (stop)
  (start))

(defn repl []
    (ra/cljs-repl))

(defn -main [& args]
  (swap! system-main component/start))

(comment

  (start)
  (stop)

  (reload)

  (repl))
