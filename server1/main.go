package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
)

type User struct {
	ID       int    `json:"id"`
	Username string `json:"username"`
	Email    string `json:"email"`
}

var db *sql.DB

func main() {
	var err error
	// Connectionni environment variablelardan olish yaxshi amaliyot hisoblanadi
	db, err = sql.Open("postgres", "host=localhost port=5432 user=postgres password=your_password dbname=server1_db sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// Database connection test qilish
	if err = db.Ping(); err != nil {
		log.Fatal(err)
	}

	r := gin.Default()

	r.POST("/user/register", registerUser)
	r.GET("/user/list", listUsers)

	fmt.Println("Server 1 is running on :8081")
	if err := r.Run(":8081"); err != nil {
		log.Fatal(err)
	}
}

func registerUser(c *gin.Context) {
	var user User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Prepared statementni o'zgartirdim, chunki server1 schemasi bo'lmasligi mumkin
	stmt, err := db.Prepare("INSERT INTO users(username, email) VALUES($1, $2) RETURNING id")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		log.Printf("Prepare error: %v", err)
		return
	}
	defer stmt.Close()

	err = stmt.QueryRow(user.Username, user.Email).Scan(&user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		log.Printf("QueryRow error: %v", err)
		return
	}

	c.JSON(http.StatusCreated, user)
}

func listUsers(c *gin.Context) {
	// Query o'zgartirildi, chunki server1 schemasi bo'lmasligi mumkin
	rows, err := db.Query(`
		SELECT id, username, email FROM users
		UNION ALL
		SELECT id, username, email FROM users_server2
		UNION ALL
		SELECT id, username, email FROM users_server3
	`)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		log.Printf("Query error: %v", err)
		return
	}
	defer rows.Close()

	var users []User
	for rows.Next() {
		var user User
		if err := rows.Scan(&user.ID, &user.Username, &user.Email); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			log.Printf("Scan error: %v", err)
			return
		}
		users = append(users, user)
	}

	// rows.Err() ni tekshirish
	if err := rows.Err(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		log.Printf("Rows error: %v", err)
		return
	}

	c.JSON(http.StatusOK, users)
}
