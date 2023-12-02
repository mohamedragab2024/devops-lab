package main

import (
	"fmt"
	"log"
	"net/http"
	"strconv"
)

func main() {

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if val, err := strconv.ParseBool(r.URL.Query().Get("error")); err != nil && val == true {
			http.Error(w, "An error occurred", 500)
			return
		}
		htmlContent := `
    <!DOCTYPE html>
    <html>
    <head>
        <title>Blue deployment</title>
    </head>
    <body style="background:blue">
        <h1>Simple Go web app!</h1>
        <p>Welcome to blue version</p>
        
    </body>
    </html>
`
		fmt.Fprintf(w, htmlContent)
	})
	log.Fatal(http.ListenAndServe(":3000", nil))
}
