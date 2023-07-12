function dockerps {
	echo -e "${GREEN}Running: docker container ls ${RESET}"
	echo -e "${BLUE}"
	docker container ls
	echo -e "\n"

	echo -e "${GREEN}Running: docker container ls -a"
	echo -e "${BLUE}"
	docker container ls -a
	echo -e "\n"

	echo -e "${GREEN}Running: docker volume ls"
	echo -e "${BLUE}"
	docker volume ls
	echo -e "\n"

	echo -e "${GREEN}Running: docker network ls"
	echo -e "${BLUE}"
	docker network ls
	echo -e "\n"

	echo -e "${GREEN}Running: docker images"
	echo -e "${BLUE}"
	docker images
}
