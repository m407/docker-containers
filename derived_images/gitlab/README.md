To run container exec next command:

`
docker run -d --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/run/docker.sock:/var/run/docker.sock -p 8080:80 --name gitlab m407/gitlab
`