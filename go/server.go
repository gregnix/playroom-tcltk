package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"

	"github.com/xuri/excelize/v2"
)

func main() {
	fmt.Println("Server started")
	reader := bufio.NewReader(os.Stdin)
	var f *excelize.File

	for {
		fmt.Print("Enter command: ")
		cmdStr, err := reader.ReadString('\n')
		if err != nil {
			fmt.Println("Error reading command:", err)
			continue
		}
		cmdStr = strings.TrimSpace(cmdStr)
		parts := strings.SplitN(cmdStr, " ", 2)

		if len(parts) < 1 {
			fmt.Println("Invalid command")
			continue
		}

		command := parts[0]
		var args string
		if len(parts) > 1 {
			args = parts[1]
		}

		switch command {
		case "set":
			argsParts := strings.SplitN(args, " ", 2)
			if len(argsParts) != 2 {
				fmt.Println("Invalid arguments for set")
				continue
			}
			cell := argsParts[0]
			value := argsParts[1]

			if f == nil {
				f = excelize.NewFile()
			}

			f.SetCellValue("Sheet1", cell, value)
			fmt.Println("Setting cell", cell, "to", value)
			fmt.Println("ok")

		case "get":
			if f == nil {
				fmt.Println("No file created")
				continue
			}
			value, err := f.GetCellValue("Sheet1", args)
			if err != nil {
				fmt.Println("Error getting cell value:", err)
				continue
			}
			fmt.Println(value)
			fmt.Println("ok")

		case "save":
			if f == nil {
				fmt.Println("No file to save")
				continue
			}
			err := f.SaveAs(args)
			if err != nil {
				fmt.Println("Error saving file:", err)
				continue
			}
			fmt.Println("Saving file as", args)
			fmt.Println("ok")

		case "close":
			fmt.Println("closing server")
			fmt.Println("ok")
			return

		default:
			fmt.Println("unknown command")
		}
	}
}
