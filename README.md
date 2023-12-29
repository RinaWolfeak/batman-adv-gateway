To run a container: docker run -d --restart=always --privileged --net=host --pid=host --ipc=host -v /etc:/etc -e MESH_NAME='' -e BAT_IP='' container name or ID
