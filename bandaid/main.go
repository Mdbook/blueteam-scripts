package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"strings"
	"time"
)

type ServiceObject struct {
	Path     string
	Checksum string
	Backup   []byte
}

type Service struct {
	Name      string `json:"name"`
	locations []*ServiceObject
	Binary    *ServiceObject `json:"binary"`
	Service   *ServiceObject `json:"service"`
	Config    *ServiceObject `json:"config"`
}
type Services struct {
	Services []Service `json:"services"`
}

var services []*Service
var master Services
var serviceNames []string = []string{
	"Binary",
	"Service",
	"Config",
}

func main() {
	master = InitConfig()
	InitBackups()
	for _, service := range master.Services {
		fmt.Printf("Service %s:\nConfig checksum: %s\nBinary checksum: %s\nService checksum: %s\n\n", service.Name, service.Config.Checksum, service.Binary.Checksum, service.Service.Checksum)
	}
	fmt.Println("Bandaid is active.")
	for {
		for _, service := range master.Services {
			for _, name := range serviceNames {
				if !service.getAttr(name).CheckSHA() {
					fmt.Printf("Error on checksum for %s %s. Rewriting...\n", service.Name, strings.ToLower(name))
					if service.getAttr(name).writeBackup() {
						fmt.Println("Backup succeeded.")
					} else {
						fmt.Println("Backup failed.")
					}
				}
			}
		}
		fixICMP()
		time.Sleep(500 * time.Millisecond)
	}
	// fmt.Println(testService.config.checksum, testService.binary.checksum, testService.service.checksum)
}

func fixICMP() {
	if trim(readFile("/proc/sys/net/ipv4/icmp_echo_ignore_all")) != "0" {
		cmd := exec.Command("/bin/sh", "-c", "echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_all")
		cmd.Run()
		fmt.Println("ICMP change detected; Re-enabled ICMP")
	}
}

func InitBackups() {
	// os.Mkdir(".config", os.ModePerm)
	// os.Mkdir(".config/backups", os.ModePerm)
	for i, service := range master.Services {
		for _, name := range serviceNames {
			f, _ := os.Open(service.getAttr(name).Path)
			master.Services[i].getAttr(name).Backup, _ = ioutil.ReadAll(f)
		}
	}
}

func InitConfig() Services {
	configFile, err := os.Open("config.json")
	if err != nil {
		log.Fatal(err)
	}
	defer configFile.Close()
	configBytes, _ := ioutil.ReadAll(configFile)

	var master Services
	json.Unmarshal(configBytes, &master)
	var removeList []int
	for i := range master.Services {
		if !master.Services[i].Init() {
			removeList = append(removeList, i)
		}
	}
	for _, i := range removeList {
		master.Services = remove(master.Services, i)
	}
	return master
}
