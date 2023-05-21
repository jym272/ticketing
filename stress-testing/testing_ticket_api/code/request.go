package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

func createTicket(ctx *context.Context) (int, error) {
	body := []byte(`{"title": "apple", "price": "69.69"}`)

	req, err := http.NewRequestWithContext(*ctx, "POST", BaseURL, bytes.NewBuffer(body))
	if err != nil {
		return 0, err
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return 0, err
	}

	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		return 0, fmt.Errorf("ticket creation failed with status code: %d", resp.StatusCode)
	}

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return 0, err
	}

	var ticketResp TicketResponse
	err = json.Unmarshal(respBody, &ticketResp)

	if err != nil {
		return 0, err
	}

	return ticketResp.Ticket.ID, nil
}

func updateTicket(ctx *context.Context, title, price, id string) error {
	body := []byte(fmt.Sprintf(`{"title": "%s", "price": "%s"}`, title, price))

	req, err := http.NewRequestWithContext(*ctx, "PUT", BaseURL+"/"+id, bytes.NewBuffer(body))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("ticket update failed with status code: %d", resp.StatusCode)
	}

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	var ticketResp TicketResponse
	err = json.Unmarshal(respBody, &ticketResp)

	if err != nil {
		return err
	}

	if ticketResp.Message != "Ticket updated." {
		return fmt.Errorf("ticket update failed")
	}

	return nil
}
