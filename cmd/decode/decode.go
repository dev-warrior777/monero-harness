package main

import (
	"encoding/hex"
	"fmt"
	"io"
	"os"
	"strings"
)

func main() {
	s, err := io.ReadAll(os.Stdin)
	if err != nil {
		fmt.Printf("%v\n", err)
		os.Exit(1)
	}
	str := strings.TrimSuffix(string(s), "\n")
	sb := []byte(str)
	b := make([]byte, len(s)/2)
	_, err = hex.Decode(b, sb)
	if err != nil {
		fmt.Printf("error: %v - Usage: hex-enc-string | ./decode\n", err)
		os.Exit(1)
	}
	os.WriteFile(os.Stdout.Name(), b, 0644)
}
