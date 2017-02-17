# php-apache
Old school enviroment: PHP 5.4 + MySQL 5  
only for testing pourpose  
https://hub.docker.com/r/athenagroup/php-apache/

Sample *docker-compose.yml* file:

```yaml
web:
  container_name: athena_amd
  image: athenagroup/php-apache
  links:
    - db
    - mailcatcher
  ports:
    - "8080:80"
  volumes:
    - "./:/var/www"
  environment:
    DOCUMENT_ROOT: "/var/www"
    ENVIRONMENT: dev

db:
  image: tutum/mysql:5.5
  ports:
    - "3306:3306"
  volumes:
    - "./.db_data:/var/lib/mysql"
  environment:
    MYSQL_PASS: admin
    MYSQL_USER: admin
    ON_CREATE_DB: athena_amd

mailcatcher:
  image: helder/mailcatcher
  ports:
    - "1080:80"
```   
