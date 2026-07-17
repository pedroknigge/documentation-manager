package main

import (
	"fmt"

	"example.com/hello/internal/greet"
)

func main() {
	fmt.Println(greet.Hello("world"))
}
