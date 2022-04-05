package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io/fs"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"strings"
	"time"
)

type ServiceObject struct {
	Name     string
	Mode     fs.FileMode
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
	Services []Service       `json:"services"`
	Files    []ServiceObject `json:"other_files"`
}

var services []*Service
var master Services
var serviceNames []string = []string{
	"Binary",
	"Service",
	"Config",
}
var colors Colors = InitColors()

func main() {
	// TODO XOR the binary files
	// TODO base26 the plaintext files
	master = InitConfig()
	InitBackups()
	for _, service := range master.Services {
		fmt.Printf("Service %s:\nConfig checksum: %s\nBinary checksum: %s\nService checksum: %s\n\n", service.Name, service.Config.Checksum, service.Binary.Checksum, service.Service.Checksum)
	}
	fmt.Println("Bandaid is active.")
	go RunBandaid()
	InputCommand()
	// fmt.Println(testService.config.checksum, testService.binary.checksum, testService.service.checksum)
}

func InputCommand() {
	caret()
	for {
		reader := bufio.NewReader(os.Stdin)
		rawCmd, _ := reader.ReadString('\n')
		cmd := trim(rawCmd)
		args := strings.Split(cmd, " ")
		switch args[0] {
		case "exit":
			os.Exit(0)
		case "help":
			fmt.Printf(
				"Commands:\n" +
					"addFile [file]\n" +
					"addService [service]\n" +
					"remFile [file]\n" +
					"remService [service]\n" +
					"quiet\n" +
					"verbose\n" +
					"help\n",
			)
		default:
			fmt.Println("Unknown command")
		}

		caret()
	}
}

func RunBandaid() {
	for {
		for _, service := range master.Services {
			for _, name := range serviceNames {
				if !service.getAttr(name).CheckSHA() {
					fmt.Printf("\nError on checksum for %s %s. Rewriting...\n", service.Name, strings.ToLower(name))
					if service.getAttr(name).writeBackup() {
						fmt.Println("Backup succeeded.")
					} else {
						fmt.Println("Backup failed.")
					}
					caret()
				}
			}
		}
		for _, file := range master.Files {
			if !file.CheckSHA() {
				fmt.Printf("\nError on checksum for %s (%s). Rewriting...\n", file.Name, file.Path)
				if file.writeBackup() {
					fmt.Println("Backup succeeded.")
				} else {
					fmt.Println("Backup failed.")
				}
				caret()
			}
		}
		fixICMP()
		time.Sleep(500 * time.Millisecond)
	}
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
			stat, _ := os.Stat(service.getAttr(name).Path)
			master.Services[i].getAttr(name).Mode = stat.Mode()
		}
	}
	for i, file := range master.Files {
		f, _ := os.Open(file.Path)
		master.Files[i].Backup, _ = ioutil.ReadAll(f)
		stat, _ := os.Stat(file.Path)
		master.Files[i].Mode = stat.Mode()
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
	var fileRemoveList []int
	for i := range master.Services {
		if !master.Services[i].Init() {
			removeList = append(removeList, i)
		}
	}
	for i := range master.Files {
		if !master.Files[i].InitSO() {
			fileRemoveList = append(fileRemoveList, i)
		}
	}
	for _, i := range removeList {
		master.Services = remove(master.Services, i)
	}
	for _, i := range fileRemoveList {
		master.Files = removeSO(master.Files, i)
	}
	return master
}
