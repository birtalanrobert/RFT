package Service

import (
  "Adapter"
)

func Authentificate(username, password string) bool {
  sqlAdapter := Adapter.SQLFactory("username", "password", "host", "db", 1) //port
  valid := sqlAdapter.MysqlAuthentificate(username, password)
  return valid
}