{:user {:plugins [[cider/cider-nrepl "0.14.0"]
                   [lein-cljfmt "0.5.6"]
                   [jonase/eastwood "0.2.4"]]
        :dependencies [[cljfmt "0.5.1"]
                       [jonase/eastwood "0.2.1" :exclusions [org.clojure/clojure]]
                       [alembic "0.3.2"]]
        :repl-options {:init (require 'cljfmt.core)}}}

