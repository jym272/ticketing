package main

import (
	"context"
	"crypto/tls"
	"fmt"
	"github.com/ssgelm/cookiejarparser"
	"log"
	"net/http"
	"os"
	"strconv"
	"sync"
	"time"
)

var (
	BaseURL       = "https://ticketing.dev/api/tickets"
	Threads       = 2
	JobsPerThread = 10
)

var (
	client              *http.Client
	errorsUpdatingTks   = make(map[string]int)
	errorsCreatingTks   []int
	errorsCreatingTksMu sync.Mutex
	errorsUpdatingTksMu sync.Mutex
)

type TicketResponse struct {
	Message string `json:"message"`
	Ticket  struct {
		ID int `json:"id"`
	} `json:"ticket"`
}

func getEnvVars() {
	if os.Getenv("BASE_URL") != "" {
		BaseURL = os.Getenv("BASE_URL")
	}
	if os.Getenv("THREADS") != "" {
		threads, err := strconv.Atoi(os.Getenv("THREADS"))
		if err != nil {
			log.Fatal(err)
		}
		Threads = threads
	}
	if os.Getenv("JOBS_PER_THREAD") != "" {
		jobsPerThread, err := strconv.Atoi(os.Getenv("JOBS_PER_THREAD"))
		if err != nil {
			log.Fatal(err)
		}
		JobsPerThread = jobsPerThread
	}

}

func configureHTTPClient() {
	cookies, err := cookiejarparser.LoadCookieJarFile("cookie")
	if err != nil {
		log.Fatal(err)
	}
	transport := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	client = &http.Client{
		Jar:       cookies,
		Transport: transport,
		Timeout:   10 * time.Second,
	}
}

func main() {
	ctx := context.Background()
	configureHTTPClient()
	getEnvVars()

	var wg sync.WaitGroup

	wg.Add(Threads * JobsPerThread)

	for i := 0; i < Threads; i++ {
		go createThread(&ctx, i+1, &wg)
	}

	wg.Wait()
	createCSVFiles("update_errors.test.csv", "create_errors.test.csv")
}

func job(ctx *context.Context, wg *sync.WaitGroup, iteration int) {
	defer wg.Done()

	id, err := createTicket(ctx)

	if err != nil {
		errorsCreatingTksMu.Lock()
		errorsCreatingTks = append(errorsCreatingTks, iteration)
		errorsCreatingTksMu.Unlock()

		return
	}

	idNewTicket := fmt.Sprintf("%d", id)

	errorsUpdatingTksMu.Lock()
	errorsUpdatingTks[idNewTicket] = 0
	errorsUpdatingTksMu.Unlock()

	if err := updateTicket(ctx, "pineapple", "100.11", idNewTicket); err != nil {
		errorsUpdatingTksMu.Lock()
		errorsUpdatingTks[idNewTicket]++
		errorsUpdatingTksMu.Unlock()
	}

	if err := updateTicket(ctx, "grass", "200.22", idNewTicket); err != nil {
		errorsUpdatingTksMu.Lock()
		errorsUpdatingTks[idNewTicket]++
		errorsUpdatingTksMu.Unlock()
	}

	if err := updateTicket(ctx, "weed", "300.33", idNewTicket); err != nil {
		errorsUpdatingTksMu.Lock()
		errorsUpdatingTks[idNewTicket]++
		errorsUpdatingTksMu.Unlock()
	}
}

func createThread(ctx *context.Context, thread int, wg *sync.WaitGroup) {
	fmt.Printf("\033[32mTHREAD\t%d with jobs\t%d - %d\tstarted\033[0m\n", thread, (thread-1)*JobsPerThread+1, thread*JobsPerThread)

	for i := 0; i < JobsPerThread; i++ {
		iteration := (thread-1)*JobsPerThread + i + 1
		job(ctx, wg, iteration)
		fmt.Printf("\033[33mTHREAD\t%d\033[0m\t job   %d \tdone\n", thread, iteration)
	}
}
