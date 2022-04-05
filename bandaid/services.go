package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io/ioutil"
	"os"
)

func (a *ServiceObject) CheckSHA() bool {
	sha, err := a.GetSHA()
	if err {
		return false
	}
	if sha != a.Checksum {
		return false
	}
	return true
}

func (a *Service) Init() bool {
	var err bool
	a.locations = []*ServiceObject{
		a.Binary,
		a.Service,
		a.Config,
	}
	for _, location := range a.locations {
		location.Checksum, err = location.GetSHA()
	}
	if err {
		fmt.Printf("Filepath error while importing %s. Skipping...\n", a.Name)
		return false
	}
	return true
}
func (a *ServiceObject) InitSO() bool {
	var err bool
	a.Checksum, err = a.GetSHA()
	if err {
		fmt.Printf("Filepath error while importing %s. Skipping...\n", a.Name)
		return false
	}
	return true
}

func (a *ServiceObject) GetSHA() (string, bool) {
	f, err := os.Open(a.Path)
	if err != nil {
		return "ERR", true
	}
	defer f.Close()
	read, err := ioutil.ReadAll(f)
	sha := sha256.Sum256(read)
	ret := hex.EncodeToString(sha[:])
	return ret, false
}
