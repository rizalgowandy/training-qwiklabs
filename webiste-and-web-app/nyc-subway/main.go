package main

import (
	"io/ioutil"
	"log"
	"net/http"
    "path/filepath"
    "os"
)

// GeoJSON is a cache of the NYC Subway Station and Line data.
var GeoJSON = make(map[string][]byte)

// cacheGeoJSON loads files under data into `GeoJSON`.
func cacheGeoJSON() {
	filenames, err := filepath.Glob("data/*")
	if err != nil {
		// Note: this will take down the GAE instance by exiting this process.
		log.Fatal(err)
	}
	for _, f := range filenames {
		name := filepath.Base(f)
		dat, err := ioutil.ReadFile(f)
		if err != nil {
			log.Fatal(err)
		}
		GeoJSON[name] = dat
	}
}

func main() {
    cacheGeoJSON()
	loadStations()
	http.HandleFunc("/data/subway-stations", subwayStationsHandler)
    http.HandleFunc("/data/subway-lines", subwayLinesHandler)
    http.HandleFunc("/", indexHandler)

    port := os.Getenv("PORT")
    if port == "" {
            port = "8080"
            log.Printf("Defaulting to port %s", port)
    }

    log.Printf("Listening on port %s", port)
    if err := http.ListenAndServe(":"+port, nil); err != nil {
            log.Fatal(err)
    }
}

func subwayLinesHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-type", "application/json")
	w.Write(GeoJSON["subway-lines.geojson"])
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
    if r.URL.Path != "/" {
            http.NotFound(w, r)
            return
    }
}
