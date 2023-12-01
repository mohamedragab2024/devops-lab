package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		htmlContent := `
    <!DOCTYPE html>
    <html>
    <head>
        <title>Green deployment</title>
    </head>
    <body style="background:blue">
        <h1>Simple Go web app!</h1>
        <p>Welcome to green version</p>
        
    </body>
    </html>
`
		fmt.Fprintf(w, htmlContent)
	})
	log.Fatal(http.ListenAndServe(":3000", nil))
}
