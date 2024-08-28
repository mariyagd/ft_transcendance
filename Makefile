# Variables
COMPOSE_FILE = ./srcs/docker-compose.yml

GREEN = \033[0;32m
NC = \033[0m

create-directories:
	@if [ ! -d "/home/postgres/data" ]; then \
		echo "${GREEN}\nCREATING DIRECTORY \"/home/postgres/data\" FOR DATABASE ${NC}"; \
		sudo mkdir -p /home/postgres/data; \
	fi

set-permissions:
	@if [ "$$(stat -c %U /home/postgres/data)" != "$$(whoami)" ]; then \
		echo "${GREEN}\nSETTING PERMISSIONS FOR \"/home/postgres/data\" DATA DIRECTORY ${NC}"; \
		sudo chown -R $$(whoami):$$(whoami) /home/postgres/data; \
		sudo chmod -R 755 /home/postgres/data; \
	fi

dangling-images:
	@echo "${GREEN}\nCLEANING DANGLING IMAGES ${NC}"
	-@docker image prune -f > /dev/null 2>&1

dangling-networks:
	@echo "${GREEN}\nCLEANING DANGLING NETWORKS ${NC}"
	-@docker network prune -f > /dev/null 2>&1

dangling-volumes:
	@echo "${GREEN}\nCLEANING DANGLING VOLUMES ${NC}"
	-@docker volume prune -f > /dev/null 2>&1

dangling: dangling-images dangling-networks dangling-volumes

# Target to start all services
up:
	@echo "${GREEN}\nBUILDING IMAGES, (RE)CREATING, STARTING AND ATTACHING CONTAINERS FOR SERVICES ${NC}"
	@docker-compose -f $(COMPOSE_FILE) up --build -d

all: create-directories set-permissions up

# Target to stop and remove containers and networks
down:
	@echo "${GREEN}\nSTOPPING CONTAINERS AND REMOVING CONTAINERS AND NETWORKS ${NC}"
	@docker-compose -f $(COMPOSE_FILE) down

# Target to stop and remove containers, networks, images, and volumes
down-rmi:
	@echo "${GREEN}\nSTOPPING CONTAINERS AND REMOVING CONTAINERS, NETWORKS, IMAGES, AND VOLUMES USED BY SERVICES ${NC}"
	@docker-compose -f $(COMPOSE_FILE) down --rmi all --volumes

clean: down

# Target to remove all resources and data
fclean: down-rmi
	@$(MAKE) dangling
	@if [ -d "/home/postgres/data" ]; then \
  		echo "${GREEN}\nREMOVING SAVED DATA IN HOST MACHINE ${NC}"; \
  		echo "${GREEN}NEEDS SUDO LOGIN ${NC}"; \
  		sudo rm -rf /home/postgres/data*; \
		sudo rmdir /home/postgres/data; \
		sudo rmdir /home/postgres/; \
		sudo chown -R $$(whoami):$$(whoami) ./srcs/site/media; \
		sudo chown -R $$(whoami):$$(whoami) ./srcs/site/static; \
	fi


re: clean all

ref: fclean all

# Secondary Commands

# Build images without starting containers
build:
	@echo "${GREEN}\nBUILDING IMAGES WITHOUT STARTING THE CONTAINERS ${NC}"
	@docker-compose -f $(COMPOSE_FILE) build
	@$(MAKE) dangling

# Start containers for services
start:
	@echo "${GREEN}\nSTARTS CONTAINERS FOR SERVICES ${NC}"
	@docker-compose -f $(COMPOSE_FILE) start

# Target to stop running containers without removing them
stop:
	@echo "${GREEN}\nSTOPPING RUNNING CONTAINERS WITHOUT REMOVING THEM ${NC}"
	@docker-compose -f $(COMPOSE_FILE) stop

logs:
	@echo "${GREEN}\nDISPLAYS LOG OUTPUT FROM SERVICES ${NC}"
	@docker-compose -f $(COMPOSE_FILE) logs

ps:
	@docker ps -a

image:
	@docker image -a

network:
	@docker network ls

.PHONY: build up down start stop logs clean fclean all ref down-rmi ps
