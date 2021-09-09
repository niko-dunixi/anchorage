package main

import (
	"bytes"
	"context"
	"io"
	"log"
	"os"
	"os/exec"
	"strings"
	"time"
)

func main() {
	log.Println("Starting QEMU...")
	ctx, cancelFunc := context.WithCancel(context.Background())
	defer cancelFunc()

	// baudRate := 9600
	// baudRate := 115200

	qemuOutput, pipeOutputWriter := io.Pipe()
	multiWriterOutput := io.MultiWriter(os.Stdout, pipeOutputWriter)

	pipeInputReader, qemuInput := io.Pipe()
	qemuCmd := exec.CommandContext(ctx,
		"qemu-system-x86_64",
		// "-display", "none",
		// "-display", "sdl",
		"-m", "8G",
		// "--machine", "accel=hvf",
		// "-serial", "stdio",

		"-drive", "file=./out/linux.iso,index=0,media=cdrom",
		"-drive", "file=./out/cloud-init.iso,index=1,media=cdrom",

		// "-cdrom", "./out/linux.iso",
		// "-cdrom", "./out/cloud-init.iso",
		"-drive", "file=./out/main.img,if=virtio",
		// "-netdev", "user,id=net0",
		// "-device", "e1000,netdev=net0",

		"-net", "user,hostfwd=tcp::10022-:22",
		"-net", "nic",
	)
	qemuCmd.Stdout = multiWriterOutput
	qemuCmd.Stderr = multiWriterOutput
	qemuCmd.Stdin = pipeInputReader
	qemuCmd.Start()

	go func() {
		buffer := make([]byte, 1024)
		for {
			_, _ = qemuOutput.Read(buffer)
		}
	}()

	go func() {
		// sleep(5)
		// send(qemuInput, "\t")
		// sleep(1)
		// send(qemuInput, fmt.Sprintf(` console=ttyS0,%d`, baudRate))
		// sleep(2)
		// send(qemuInput, "\n")
		// expect(qemuOutput, `archiso login: `)
		// splitSend(qemuInput, "root\n")
		// sleep(5)
		send(qemuInput, `clear`+"\n")
		send(qemuInput, `echo "Hello world!"`+"\n")
	}()

	if err := qemuCmd.Wait(); err != nil {
		panic(err)
	}
}

func splitSend(w io.Writer, s string) {
	for i := 0; i < len(s); i++ {
		w.Write([]byte{s[i]})
		sleep(1)
	}
}

func send(w io.Writer, s string) {
	w.Write([]byte(s))
}

func expect(r io.Reader, expectant string) {
	qemuOutputBuffer := make([]byte, 2048)
	valueBuffer := bytes.Buffer{}
	for {
		n, err := r.Read(qemuOutputBuffer)
		if err != nil {
			panic(err)
		} else if n == 0 {
			continue
		}
		if _, err := valueBuffer.Write(qemuOutputBuffer[:n]); err != nil {
			panic(err)
		}
		currentString := valueBuffer.String()
		if strings.Contains(currentString, expectant) {
			valueBuffer.Reset()
			sleep(2)
			return
		}
	}
}

func sleep(seconds int) {
	time.Sleep(time.Second * time.Duration(seconds))
}
