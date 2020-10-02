package routes

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
)

//UseRoutes :
func UseRoutes(r *mux.Router) {
	//r.HandleFunc("/media/{mId:[0-9]+}/stream", streamHandler).Methods("GET")
	//r.HandleFunc("/media/{mid:[0-9]+}/stream/{segName:seg[0-9]+.ts}", streamHandler).Methods("GET")
	s := http.StripPrefix("/songs/", addHeaders(http.FileServer(http.Dir("./songs/"))))
	r.PathPrefix("/songs/").Handler(s)
	r.HandleFunc("/upload", UploadFile)
	//r.Handle("/berezy", addHeaders(http.FileServer(http.Dir("songs"))))
}

func addHeaders(h http.Handler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Cache-Control", "no-cache")
		w.Header().Set("Content-Type", "application/x-mpegURL")
		h.ServeHTTP(w, r)
	}
}

//UploadFile :
func UploadFile(w http.ResponseWriter, r *http.Request) {
	fmt.Println("File upload hit")

	r.ParseMultipartForm(10 << 21)

	file, handler, err := r.FormFile("audio")

	if err != nil {
		fmt.Println("Error retrieving file")
		fmt.Println(err)
		return
	}

	defer file.Close()

	fmt.Println(handler.Filename)
	fmt.Println(handler.Size)
	fmt.Println(handler.Header)

	tmp, err := ioutil.TempFile("temp-files", "upload-*.png")
	if err != nil {
		fmt.Println(err)
	}

	defer tmp.Close()

	fileBytes, err := ioutil.ReadAll(file)
	if err != nil {
		fmt.Println(err)
	}

	tmp.Write(fileBytes)

	fmt.Fprintf(w, "Successful upload")
}

//Songs :
func Songs(w http.ResponseWriter, r *http.Request) {
	http.FileServer(http.Dir("./songs/"))
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Content-Type", "application/x-mpegURL")
}

func streamHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	mID, err := strconv.Atoi(vars["mId"])
	if err != nil {
		w.WriteHeader(http.StatusNotFound)
		return
	}
	segName, ok := vars["segName"]
	if !ok {
		mediaBase := getMediaBase(mID)
		m3u8Name := fmt.Sprintf("m%d.m3u8", mID)
		serveHlsM3U8(w, r, mediaBase, m3u8Name)
	} else {
		mediaBase := getMediaBase(mID)
		serveHlsTs(w, r, mediaBase, segName)
	}
}

func getMediaBase(mID int) string {
	mediaRoot := "songs"
	return fmt.Sprintf("%s/%d", mediaRoot, mID)
}

func serveHlsTs(w http.ResponseWriter, r *http.Request, mediaBase, segName string) {
	mediaFile := fmt.Sprintf("%s/hls/%s", mediaBase, segName)
	http.ServeFile(w, r, mediaFile)
	w.Header().Set("Content-Type", "video/MP2T")
}

func serveHlsM3U8(w http.ResponseWriter, r *http.Request, mediaBase, m3u8Name string) {
	mediaFile := fmt.Sprintf("%s/hls/%s", mediaBase, m3u8Name)
	http.ServeFile(w, r, mediaFile)
	w.Header().Set("Content-Type", "application/x-mpegURL")
}
