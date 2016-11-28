package Adapter

import (
	"crypto/md5"
	"database/sql"
	"encoding/hex"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"math/rand"
)

type SQLConfig struct {
	username string
	password string
	host     string
	port     int
	db       string
}

type Authentification struct {
	Valid    	bool
	Username 	string
	Firstname	string
	Lastname	string
}

type SQLData struct {
	From string
	To string
	Date string
	Discount string
	Potjegy string
	Helyi string
	Atszallas string
	Kerekpar string
	Exits bool
}

func SQLFactory(username, password, host, db string, port int) SQLConfig {
	return SQLConfig{username, password, host, port, db}
}

func GetMD5Hash(text string) string {
	hasher := md5.New()
	hasher.Write([]byte(text))
	return hex.EncodeToString(hasher.Sum(nil))
}

func generateSalt() string {
	const letterBytes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	b := make([]byte, 10)
	for i := range b {
		b[i] = letterBytes[rand.Intn(len(letterBytes))]
	}
	return string(b)
}

func (this SQLConfig) MysqlAuthentificate(username, password string) Authentification {
	var usern, passw, salt1, salt2, fname, lname string
	var auth Authentification

	inf := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s", this.username, this.password, this.host, this.port, this.db)
	db, err := sql.Open("mysql", inf)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	rows, err := db.Query("SELECT NICKNAME, PASSWORD, SALT1, SALT2, FIRSTNAME, LASTNAME FROM USERS WHERE NICKNAME='" + username + "'")
	if err != nil {
		panic(err)
	}
	defer rows.Close()

	for rows.Next() {
		err := rows.Scan(&usern, &passw, &salt1, &salt2, &fname, &lname)
		if err != nil {
			panic(err)
		}
	}

	saltedPassword := fmt.Sprintf(salt1 + password + salt2)
	hashedPassword := GetMD5Hash(saltedPassword)
	if hashedPassword == passw {
		auth.Valid = true
		auth.Username = username
		auth.Firstname = fname
		auth.Lastname = lname
	} else {
		auth.Valid = false
		auth.Username = ""
	}

	return auth
}

func (this SQLConfig) MysqlRegistration(firstname, lastname, username, password, email string) int {
	var MySQLResultUser string

	inf := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s", this.username, this.password, this.host, this.port, this.db)
	db, err := sql.Open("mysql", inf)
	if err != nil {
		panic(err)
		return -2
	}
	defer db.Close()

	rows, err := db.Query("SELECT NICKNAME FROM USERS WHERE NICKNAME='" + username + "'")
	if err != nil {
		panic(err)
		return -2
	}
	defer rows.Close()

	for rows.Next() {
		err := rows.Scan(&MySQLResultUser)
		if err != nil {
			panic(err)
			return -2
		}
	}

	if MySQLResultUser != "" {
		return -1
	}

	salt1 := generateSalt()
	salt2 := generateSalt()
	saltedPassword := fmt.Sprintf(salt1 + password + salt2)
	hashedPassword := GetMD5Hash(saltedPassword)

	_, err = db.Exec("INSERT INTO USERS (FIRSTNAME, LASTNAME, NICKNAME, PASSWORD, SALT1, SALT2, TYPE, EMAIL) VALUES ('" + firstname + "', '" + lastname + "', '" + username + "', '" +
		hashedPassword + "', '" + salt1 + "', '" + salt2 + "', '" + "user" + "', '" + email + "')")

	if err != nil {
		panic(err)
		return -2
	}

	return 0
}

func (this SQLConfig) MysqlSearchTimetable(from, to, date, discount, potjegy, helyi, atszallas, kerekpar string) SQLData {
	var result SQLData

	inf := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s", this.username, this.password, this.host, this.port, this.db)
	db, err := sql.Open("mysql", inf)
	if err != nil {
		panic(err)
	}
	defer db.Close()

//TODO query megirasa a parameterek alapjan
	rows, err := db.Query("SELECT NICKNAME FROM USERS")
	if err != nil {
		panic(err)
	}
	defer rows.Close()

	for rows.Next() {
		err := rows.Scan()//TODO beolvasni a strukturaba
		if err != nil {
			panic(err)
		}
	}
	return result
}
