package models

//Song :
type Song struct {
	ID     uint64 `json:"id"`
	Name   string `json:"name"`
	Author string `json:"author"`
	Path   string `json:"path"`
}
