package main

import (
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"strings"
)

func CopyFile(src, dst string) (int64, error) {
	sourceFileStat, err := os.Stat(src)
	if err != nil {
		return 0, err
	}

	if !sourceFileStat.Mode().IsRegular() {
		return 0, fmt.Errorf("%s is not a regular file", src)
	}

	source, err := os.Open(src)
	if err != nil {
		return 0, err
	}
	defer source.Close()

	destination, err := os.Create(dst)
	if err != nil {
		return 0, err
	}
	defer destination.Close()
	nBytes, err := io.Copy(destination, source)
	return nBytes, err
}
func remove(slice []Service, s int) []Service {
	return append(slice[:s], slice[s+1:]...)
}

func (e *Service) getAttr(field string) *ServiceObject {
	return e.locations[find(serviceNames, field)]
}

func find(arr []string, s string) int {
	for i, str := range arr {
		if str == s {
			return i
		}
	}
	return -1
}

func (e *ServiceObject) writeBackup() bool {
	if IsImmutable(e.Path) {
		fmt.Printf("File %s is immutable. Removing immutable flag...\n", e.Path)
		RemoveImmutable(e.Path)
	}
	return writeFile(e.Path, e.Backup)
}

func writeFile(file string, contents []byte) bool {
	f, err := os.Create(file)
	if err != nil {
		return false
	}
	defer f.Close()
	_, err = f.Write(contents)
	if err != nil {
		return false
	}
	return true
}

func readFile(path string) string {
	dat, _ := ioutil.ReadFile(path)
	str := string(dat)
	return str
}

func trim(str string) string {
	return strings.TrimSuffix(strings.TrimSuffix(str, "\n"), "\r")
}
