package main

import (
	"encoding/csv"
	"os"
	"strconv"
)

func createCSVFiles(updateErrorsFile, createErrorsFile string) {
	updateErrors := [][]string{{"id", "errors"}}
	for key, value := range errorsUpdatingTks {
		updateErrors = append(updateErrors, []string{key, strconv.Itoa(value)})
	}
	writeCSVFile(updateErrorsFile, updateErrors)

	createErrors := [][]string{{"iteration"}}
	for _, value := range errorsCreatingTks {
		createErrors = append(createErrors, []string{strconv.Itoa(value)})
	}
	writeCSVFile(createErrorsFile, createErrors)
}

func writeCSVFile(filename string, data [][]string) {
	file, err := os.Create(filename)
	if err != nil {
		panic(err)
	}
	defer func(file *os.File) {
		err := file.Close()
		if err != nil {
			panic(err)
		}
	}(file)

	writer := csv.NewWriter(file)
	defer writer.Flush()

	for _, row := range data {
		if err := writer.Write(row); err != nil {
			panic(err)
		}
	}
}
