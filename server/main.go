package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/kakty/blue_player/routes"

	"github.com/gorilla/mux"

	"github.com/joho/godotenv"
)

var (
	err  error
	port string
)

func init() {
	err = godotenv.Load()
	if err != nil {
		log.Fatal(err)
	}
	port = os.Getenv("PORT")
}

func main() {
	r := mux.NewRouter()
	routes.UseRoutes(r)
	fmt.Println("Listening on port: " + port)
	log.Fatal(http.ListenAndServe(":"+port, r))
}
