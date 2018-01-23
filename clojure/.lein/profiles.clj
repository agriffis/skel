{:user {:plugins [[cider/cider-nrepl "0.16.0"]
                   [lein-cljfmt "0.5.7"]
                   [jonase/eastwood "0.2.5"]]
        :dependencies [[cljfmt "0.5.7"]
                       [jonase/eastwood "0.2.5" :exclusions [org.clojure/clojure]]
                       [alembic "0.3.2"]]
        :repl-options {:init (require 'cljfmt.core)}}}

