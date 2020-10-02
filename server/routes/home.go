package routes

import (
	"fmt"
	"net/http"
)

//Home :
func Home(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Ok Home")
}
