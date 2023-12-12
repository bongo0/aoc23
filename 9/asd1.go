// go build asd1.go && ./asd1
package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func is_zeroes(h []int) bool {
	for _, a := range h {
		if a != 0 {
			return false
		}
	}
	return true
}

func get_diffs(h []int) []int {
	var diffs []int
	if len(h) == 1 {
		diffs = append(diffs, 0)
		return diffs
	}

	for i := 0; i < len(h)-1; i++ {
		diffs = append(diffs, h[i+1]-h[i])
	}
	return diffs
}

func main() {
	fname := "input"
	fmt.Printf("input file: `%s`\n", fname)

	file, err := os.Open(fname)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	var histories [][]int // slice of slices

	scn := bufio.NewScanner(file)
	// reads file line by line
	for scn.Scan() {
		var d []int
		line := scn.Text()
		for _, el := range strings.Split(line, " ") {
			a, err := strconv.Atoi(el)
			if err != nil {
				fmt.Printf("Atoi could not convert to int: `%s` -> %d\n", el, a)
			}
			d = append(d, a)
		}
		histories = append(histories, d)
	}

	// for i, d := range histories {
	// 	for j, a := range d {
	// 		fmt.Printf(" (%d,%d):%d ", i, j, a)
	// 	}
	// 	fmt.Printf("\n")
	// }
	forecasts_sum := 0

	for i := 0; i < len(histories); i++ {
		dif0 := histories[i]
		forecast := 0
		for !is_zeroes(dif0) {
			last := dif0[len(dif0)-1]
			forecast += last
			fmt.Printf(" last dif: %d\n", last)
			dif0 = get_diffs(dif0)
		}
		for _, d := range dif0 {
			fmt.Printf("%d ", d)
		}
		fmt.Printf("\n")
		fmt.Printf(" forecast: %d\n", forecast)
		forecasts_sum += forecast
	}
	fmt.Printf(" forecasts_sum: %d\n", forecasts_sum)

}
