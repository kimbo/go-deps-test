package main

import (
	"github.com/julienschmidt/httprouter"
	log "github.com/sirupsen/logrus"
)

func main() {
	log.Info("Hello world!")
	router := httprouter.New()
	_ = router
}
