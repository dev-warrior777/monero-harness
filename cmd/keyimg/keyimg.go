package main

import (
	"encoding/hex"
	"fmt"
	"os"
	"strings"
)

func main() {
	s, err := os.ReadFile("key_images")
	// s, err := io.ReadAll(os.Stdin)
	if err != nil {
		fmt.Printf("%v\n", err)
		os.Exit(1)
	}
	str := strings.TrimSuffix(string(s), "\r") // just 0x0d
	sb := []byte(str)
	b := make([]byte, len(s)*2)
	hex.Encode(b, sb)
	os.WriteFile("key_images_out", b, 0644)
	// os.WriteFile(os.Stdout.Name(), b, 0644)
}
