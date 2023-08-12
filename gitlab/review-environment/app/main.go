// main.go
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"sync"
)

var (
	items      []Item
	nextItemID int
	mutex      sync.Mutex
)

func main() {
	http.HandleFunc("/items", listItems)
	http.HandleFunc("/items/create", createItem)
	http.HandleFunc("/items/update", updateItem)
	http.HandleFunc("/items/delete", deleteItem)

	fmt.Println("Server listening on :8080")
	http.ListenAndServe(":8080", nil)
}

func listItems(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(items)
}

func createItem(w http.ResponseWriter, r *http.Request) {
	var newItem Item
	if err := json.NewDecoder(r.Body).Decode(&newItem); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	mutex.Lock()
	newItem.ID = nextItemID
	nextItemID++
	items = append(items, newItem)
	mutex.Unlock()

	w.WriteHeader(http.StatusCreated)
}

func updateItem(w http.ResponseWriter, r *http.Request) {
	var updatedItem Item
	if err := json.NewDecoder(r.Body).Decode(&updatedItem); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	mutex.Lock()
	for i, item := range items {
		if item.ID == updatedItem.ID {
			items[i] = updatedItem
			break
		}
	}
	mutex.Unlock()

	w.WriteHeader(http.StatusOK)
}

func deleteItem(w http.ResponseWriter, r *http.Request) {
	itemIDStr := r.URL.Query().Get("id")
	itemID, err := strconv.Atoi(itemIDStr)
	if err != nil {
		http.Error(w, "Invalid item ID", http.StatusBadRequest)
		return
	}

	mutex.Lock()
	for i, item := range items {
		if item.ID == itemID {
			items = append(items[:i], items[i+1:]...)
			break
		}
	}
	mutex.Unlock()

	w.WriteHeader(http.StatusOK)
}
