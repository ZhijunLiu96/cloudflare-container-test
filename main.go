package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	port := getenv("PORT", "8080")
	message := getenv("MESSAGE", "cloudflare-container")
	instance := getenv("CLOUDFLARE_DEPLOYMENT_ID", "local")

	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ok"))
	})
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "container ok | msg=%s | instance=%s | path=%s\n",
			message, instance, r.URL.Path)
	})

	addr := ":" + port
	log.Printf("listen %s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatal(err)
	}
}

func getenv(k, fallback string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return fallback
}
