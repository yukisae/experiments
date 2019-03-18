.PHONY: all

all:
	docker build -t cx/$(shell basename "$(realpath .)") .
	docker image prune -f
