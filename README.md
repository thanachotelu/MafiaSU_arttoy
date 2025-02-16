# Project Backend-Frontend

### e-commerce web-application with React and Golang

## Setup
### install docker desktop

``` bash
$ git clone https://github.com/thanachotelu/MafiaSU_arttoy.git

# import package
$ go get "github.com/gin-contrib/cors"
$ go get "github.com/gin-gonic/gin"
$ go get "github.com/spf13/viper"
$ go get "github.com/jmoiron/sqlx"
$ go get "github.com/lib/pq"
$ go get "github.com/golang-jwt/jwt"

# run docker
$ docker-compose up

# install dependencies
$ npm install

# run server
$ npm start
```

### อย่าลืมเข้าไปสร้าง database server ใน pgadmin
### ต้องเปลี่ยน port ในไฟล์ **env** ด้วย
