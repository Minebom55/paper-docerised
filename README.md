# By using this image you agree the the minecraft [eula](https://www.minecraft.net/en-us/eula)

## Paper docerised


Edit the docker-compose.yaml for settings
start the server by using **docker compose up**

Add a comma and the id of the plugins you want in the compose file to change what plugins are installed


## The two branches
There are two available branches that either you can host multiple servers as seperate servers or using a proxy. In this case velocity

### The main branch
Main branch starts the selected amount of paper servers and hosts them seperatly on diffrent ports. They don't interact with eatchother and you need to expose seperate ports for each server but is relible and hould just work. You can additionaly chose to only turn on some servers if you have a limited amount of avalible ram or open ports.

### Velocity branch
[Velocity](https://papermc.io/software/velocity/) is a opensource minecraft proxy devloped by paperMC. The back end servers need to be paper but only one port needs to be open and the proxy distributes the trafic between the back end servers. This means that your players only need to join one server and can switch between them. This branch combines the back end paper servers and the proxy so you can host more servers. This branch is located here: [github.com/Minebom55/paper-docerised/tree/velocity](https://github.com/Minebom55/paper-docerised/tree/velocity)