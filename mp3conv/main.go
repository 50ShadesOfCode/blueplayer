package main

import (
	"os/exec"
)

func main() {

	fileName := "berezy.mp3"
	cmdName := "ffmpeg"
	id := "1"
	args := []string{
		"-i",
		fileName,
		"-c:a",
		"libmp3lame",
		"-b:a",
		"320k",
		"-map",
		"0:0",
		"-f",
		"segment",
		"-segment_time",
		"10",
		"-segment_list",
		"m" + id + ".m3u8",
		"-segment_format",
		"mpegts",
		"seg%0d.ts",
	}

	cmd := exec.Command(cmdName, args...)
	cmd.Run()
}
