// main.go
package main

import (
	"io"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"os/exec"
	"time"
)

func setupIptables(proxyPort, appPort string) {
	cmdCheck := exec.Command("iptables", "-t", "nat", "-C", "OUTPUT", "-p", "tcp", "--dport", appPort, "-j", "REDIRECT", "--to-port", proxyPort)
    err := cmdCheck.Run()
    if err == nil {
        log.Println("iptables rule already exists, skipping...")
        return
    }

	cmd := exec.Command("iptables", "-t", "nat", "-A", "OUTPUT",
		"-p", "tcp", "--dport", appPort,
		"-j", "REDIRECT", "--to-port", proxyPort)

	out, err := cmd.CombinedOutput()
	if err != nil {
		log.Fatalf("Failed to set iptables rule: %v\n%s", err, out)
	}
	log.Println("iptables rule added: redirect", appPort, "→", proxyPort)
}

func main() {
	setupIptables("15000", "8080")

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("[Proxy] %s %s", r.Method, r.URL.Path)

		target := "http://" + r.Host
		log.Printf("[Proxy] %s %s --> Target: %s", r.Method, r.URL.Path, target)

		targetURL, err := url.Parse(target)
		if err != nil {
			http.Error(w, "Invalid target URL", http.StatusInternalServerError)
			return
		}

		proxy := httputil.NewSingleHostReverseProxy(targetURL)

		proxy.ModifyResponse = func(resp *http.Response) error {
			if resp.StatusCode >= 400 {
				log.Printf("[Proxy] Error: Received %d from target", resp.StatusCode)
			}
			return nil
		}

		time.Sleep(50 * time.Millisecond)

		proxy.ServeHTTP(w, r)
	})

	log.Println("Proxy listening on :15000")
	log.Fatal(http.ListenAndServe(":15000", nil))
}
