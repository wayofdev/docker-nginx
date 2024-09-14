## Documentation:
## https://docs.docker.com/build/ci/github-actions/multi-platform/#with-bake

variable "DEFAULT_TAG" { default = "wayofdev/nginx:local" }

## Special target: https://github.com/docker/metadata-action#bake-definition
target "docker-metadata-action" {
    tags = ["${DEFAULT_TAG}"]
}

###########################
##    Nginx Dev
###########################
target "nginx-dev-alpine" {
    inherits = ["docker-metadata-action"]
    context = "dist/dev-alpine"
    dockerfile = "./Dockerfile"
}

###########################
##    Nginx K8s
###########################
target "nginx-k8s-alpine" {
    inherits = ["docker-metadata-action"]
    context = "dist/k8s-alpine"
    dockerfile = "./Dockerfile"
}

###########################
##    Groups
###########################
group "all" {
    targets = [
        "nginx-dev-alpine",
        "nginx-k8s-alpine",
    ]
}

group "dev" {
    targets = [
        "nginx-dev-alpine",
    ]
}

group "k8s" {
    targets = [
        "nginx-k8s-alpine",
    ]
}
