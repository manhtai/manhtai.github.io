---
title: "Dockerize Django Vue web app"
date: 2018-08-24T22:42:47+07:00
tags: ["django", "docker", "drone.io"]
draft: false
---

Recently I've fired up multiple Django projects for my company. Most of them
follow a typical setup with Nginx + Gunicorn + Supervisord in a big Ubuntu
virtual machine. I must say that the setup works quite well, but sometimes,
when having not much more work to do, I strike for better by trying to
dockerize them.


## 1) Dockerize Django-Vue app with Nginx & Gunicorn

I want to start with an app that has Vue as frontend. This method works with
all frontend frameworks, it just happens that we use Vue. The Vue part has a
separate repo so backend and frontend developers can work simultaneously. But
to build the docker image in the easiest way I put them into one by using git
submodule.

To build frontend part, I use `node:8` image:


```
FROM node:8 as frontend

RUN mkdir /code
WORKDIR /code
ADD ./frontend /code/
RUN npm install yarn && yarn && yarn run build
```


I use `python:3.7-slim-stretch` to build backend, install `nginx`,
`supervisord` to the same image. Note that Nginx and Supervisord
configuration must be customized to run inside a Docker container.
You can refer to [uwsgi-nginx-docker][1] repo for more insights.

In case you still wonder, I use Supervisord to run Gunicorn and Nginx.

```
FROM python:3.7-slim-stretch

# Install wget, gnupg to get nginx
RUN apt-get update && apt-get install -y wget gnupg

RUN echo "deb http://nginx.org/packages/mainline/debian/ stretch nginx" >> /etc/apt/sources.list
RUN wget https://nginx.org/keys/nginx_signing.key -O - | apt-key add - && \
  apt-get update && \
  apt-get install -y nginx supervisor && \
  rm -rf /var/lib/apt/lists/*

# Remove wget, gnupg
RUN apt-get purge -y --auto-remove wget gnupg

# Add code folder
RUN mkdir /code
WORKDIR /code
ADD . /code/

# Nginx configuration
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/conf.d/default.conf
COPY deploy/nginx_docker.conf /etc/nginx/conf.d/nginx_docker.conf

# Supervisor configuration
COPY deploy/supervisor_docker.conf /etc/supervisor/conf.d/supervisor_docker.conf
```

I use [pipenv][2] instead of requirements file to manage dependencies:

```
# Install python lib dep
RUN pip install pipenv
RUN pipenv install --system --deploy
```

After that, collect staticfiles and expose them:

```
# Set env to production
ENV DJANGO_SETTINGS_MODULE myapp.settings.production

# Collect static files
RUN (cd myapp; python manage.py collectstatic --noinput)

VOLUME ["/code/myapp/public"]
```

Then copy frontend code from frontend build image to our main image:

```
COPY --from=frontend /code/dist/ /code/dist/
```

And lastly, expose port for running:

```
EXPOSE 80 443

CMD ["/usr/bin/supervisord"]
```

That's it. We've had a Dockerfile that contains all frontend, backend and
a web server ready to use.

The reality that we can't build our Docker images by hands takes us to a CD
tool, and which tool should it be?

## 2) CD pipeline using Drone.io

I've had some experience in writting Jenkinsfile for CD pipeline. It works
most of the time when I already had a Jenkins server running. But it costs me
hours and hours trying to set up a working Jenkins server in AWS, and then
I just quit. Some googling around, I found [Drone.io][3].

The setup is dead simple, just one `docker-compose.yml` file and you got
a https CD server ready in minutes. I just fall in love with it immediately.

My config file is this:

```
version: '2'

services:
  drone-server:
    image: drone/drone:0.8

    ports:
      - 80:80
      - 443:443
      - 9000:9000
    volumes:
      - ${HOME}/drone-data:/var/lib/drone/
    restart: always
    environment:
      - DRONE_OPEN=true
      - DRONE_ORGS=myteam
      - DRONE_ADMIN=myusername
      - DRONE_HOST=${DRONE_HOST}
      - DRONE_BITBUCKET=true
      - DRONE_BITBUCKET_CLIENT=${DRONE_BITBUCKET_CLIENT}
      - DRONE_BITBUCKET_SECRET=${DRONE_BITBUCKET_SECRET}
      - DRONE_SECRET=${DRONE_SECRET}
      - DRONE_LETS_ENCRYPT=true

  drone-agent:
    image: drone/agent:0.8

    command: agent
    restart: always
    depends_on:
      - drone-server
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - DRONE_SERVER=drone-server:9000
      - DRONE_SECRET=${DRONE_SECRET}
```

You don't need nginx or something like just, just `docker-compose up -d` and
it's set. I wish all web applications are just simple as that!

Now you must define a `.drone.yml` file in your web server project, and it is
dead simple, too.

Here is the script for building the Docker image and then push it to AWS ECR:

```
clone:
  git:
    image: plugins/git
    recursive: true
    # Override here so you don't have to edit it in your repo
    submodule_override:
      frontend: https://bitbucket.org/myteam/myapp.git

pipeline:
  ecr:
    image: plugins/ecr
    repo: <account-id>.dkr.ecr.ap-southeast-1.amazonaws.com/myapp
    registry: <account-id>.dkr.ecr.ap-southeast-1.amazonaws.com
    secrets: [ ecr_access_key, ecr_secret_key ]
    region: ap-southeast-1

  slack:
    image: plugins/slack
    channel: drone
    secrets: [ slack_webhook ]
    when:
      status: [ success, failure ]
```

And now in our server, `docker-compose.yml` file is now very simple:

```
version: '2'

services:
  myapp:
    image: <account-id>.dkr.ecr.ap-southeast-1.amazonaws.com/myapp:latest

    ports:
      - 80:80
      - 443:443
    restart: always
    environment:
      - DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE}
```

Note that to pull images from ECR, you may need an [ECR credential helper][4].

## 3) Conclusion

Now to start your server, you just need to run `docker-compose up -d` and it's
set! Our Django app is just like a typical Golang app: one Docker image and
nothing more.

I've crossed out some things here so you can find out for yourself:

  * \- Add test step to Drone pipeline (if you had some!).

  * \- Add deploy step to Drone pipeline so it can be complete.

  * \- Use another container scheduling and management system like [Kubernetes][5]
    instead of Docker compose.


[1]: https://github.com/tiangolo/uwsgi-nginx-docker/blob/master/python3.6-alpine3.7/Dockerfile
[2]: https://pipenv.readthedocs.io/
[3]: https://drone.io
[4]: https://github.com/awslabs/amazon-ecr-credential-helper
[5]: https://kubernetes.io/
