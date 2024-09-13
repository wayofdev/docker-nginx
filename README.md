<p align="center">
    <br>
    <a href="https://wayof.dev" target="_blank">
        <picture>
            <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/wayofdev/.github/master/assets/logo.gh-dark-mode-only.png">
            <img width="400" src="https://raw.githubusercontent.com/wayofdev/.github/master/assets/logo.gh-light-mode-only.png" alt="WayOfDev Logo">
        </picture>
    </a>
    <br>
</p>

<div align="center">
<a href="https://actions-badge.atrox.dev/wayofdev/docker-nginx/goto"><img alt="Build Status" src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fwayofdev%2Fdocker-nginx%2Fbadge&style=flat-square"/></a>
<a href="https://github.com/wayofdev/docker-nginx/tags"><img src="https://img.shields.io/github/v/tag/wayofdev/docker-nginx?sort=semver&style=flat-square" alt="Latest Version"></a>
<a href="https://hub.docker.com/repository/docker/wayofdev/nginx"><img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/wayofdev/nginx?style=flat-square"></a>
<a href="LICENSE.md"><img src="https://img.shields.io/github/license/wayofdev/docker-nginx.svg?style=flat-square&color=blue" alt="Software License"/></a>
<a href="#"><img alt="Commits since latest release" src="https://img.shields.io/github/commits-since/wayofdev/docker-nginx/latest?style=flat-square"></a>
</div>

<br>

# Docker Image: Nginx

This **Docker image** provides a streamlined **Nginx** setup optimized for **local PHP development environments**.

It's designed to seamlessly integrate with [wayofdev/docker-php-dev](https://github.com/wayofdev/docker-php-dev) and other (WOD) images, creating an efficient local development ecosystem for web projects.

<br>

## 🌟 Why Choose This Image for Local Development?

- **Ansible-based Configuration:** Easily customizable through Ansible templates
- **PHP-FPM Optimized:** Pre-configured to work with PHP-FPM for fast local testing and development
- **SSL Ready:** Includes built-in support for HTTPS using self-signed certificates, mimicking production environments locally
- **Developer Friendly:** Packed with tools and configurations to enhance local development workflows
- **Flexible Deployment:** Includes a `k8s-alpine` variant for testing Kubernetes setups locally
- **Lightweight:** Based on **Alpine Linux** for minimal footprint and faster local builds
- **Multi-arch Support:** Works on both **x86 (AMD64)** and **ARM64** architectures, supporting various development machines
- **Regular Updates:** Maintained and updated frequently to align with the latest development practices

Perfect for developing **Laravel** applications, **Symfony** projects, or any **PHP-based web services** in a local environment that closely mirrors production setups.

Provides foundation for creating, testing, and debugging your web applications locally.

<br>

If you **like/use** this package, please consider ⭐️ **starring** it. Thanks!

<br>

## 📦 Image Variants

| Variant    | Description                                                                   |
|------------|-------------------------------------------------------------------------------|
| dev-alpine | For local development environments, uses 80 and 443 ports.                    |
| k8s-alpine | Optimized for k8s and local environments, uses 8880 and 8443 ports, rootless. |

<br>

## 🚀 Usage

### → Pulling the Image

```bash
docker pull wayofdev/nginx:k8s-alpine-latest
```

Replace `k8s-alpine-latest` with your desired type, and tag.

### → Available Image Variants

- **Types:** k8s, dev
- **Architectures:** amd64, arm64

### → Using in Docker Compose

Here's an example `docker-compose.yml` for a typical setup:

```yaml
services:
  app:
    image: wayofdev/php-dev:8.3-fpm-alpine-latest
    container_name: ${COMPOSE_PROJECT_NAME}-app
    restart: on-failure
    networks:
        - default
        - shared
    depends_on:
        - database
    links:
        - database
    volumes:
        - ./.github/assets:/assets:rw,cached
        - ./app:/app:rw,cached
        - ./.env:/app/.env
        - ~/.composer:/.composer
        - ~/.ssh:/home/www-data/.ssh
    environment:
      FAKETIME: '+2h'
      XDEBUG_MODE: '${XDEBUG_MODE:-off}'
      PHIVE_HOME: /app/.phive
    dns:
      - 8.8.8.8
    extra_hosts:
      - 'host.docker.internal:host-gateway'

  web:
    image: wayofdev/nginx:k8s-alpine-latest
    container_name: ${COMPOSE_PROJECT_NAME}-web
    restart: on-failure
    networks:
      - default
      - shared
    depends_on:
      - app
    links:
      - app
    volumes:
      - ./app:/app:rw,cached
      - ./.env:/app/.env
    labels:
      - traefik.enable=true
      - traefik.http.routers.api-${COMPOSE_PROJECT_NAME}-secure.rule=Host(`api.${COMPOSE_PROJECT_NAME}.docker`)
      - traefik.http.routers.api-${COMPOSE_PROJECT_NAME}-secure.entrypoints=websecure
      - traefik.http.routers.api-${COMPOSE_PROJECT_NAME}-secure.tls=true
      - traefik.http.services.api-${COMPOSE_PROJECT_NAME}-secure.loadbalancer.server.port=8880
      - traefik.docker.network=network.${SHARED_SERVICES_NAMESPACE}
```

#### This configuration includes

- An `app` service using the `wayofdev/php-dev` image for PHP processing.
- A `web` service using a [custom Nginx image](https://github.com/wayofdev/docker-nginx) for serving the application.
- Network configuration for both default and shared networks.
- Volume mounts for application code, assets, and configuration files.
- Environment variables for PHP and Xdebug configuration.
- Traefik labels for reverse proxy and SSL termination.

#### Real-world Example

For a comprehensive, real-world example of how to use this image in a Docker Compose setup, please refer to the [wayofdev/laravel-starter-tpl](https://github.com/wayofdev/laravel-starter-tpl) repository. This template provides a fully configured development environment for Laravel projects using the `wayofdev/php-dev` image.

<br>

## ⚙️ Configuration

The Nginx image is pre-configured for optimal performance with PHP applications, but you can customize it further to suit your specific needs.

### → Default Configuration

The default configuration is generated using Ansible templates and includes:

- Optimized settings for PHP-FPM
- SSL/TLS support with self-signed certificates
- Gzip compression enabled
- Basic security headers

### → Custom Configuration

While the configuration is primarily managed through Ansible templates, you can override specific settings:

1. **Environment Variables:** The image uses the following environment variables:

   | Variable               | Default Value | Description                           |
      |------------------------|---------------|---------------------------------------|
   | PHP_UPSTREAM_CONTAINER | app           | The name of the PHP-FPM container     |
   | PHP_UPSTREAM_PORT      | 9000          | The port of the PHP-FPM container     |

   Set these in your `docker-compose.yml` file:

   ```yaml
   services:
     web:
       image: wayofdev/nginx:k8s-alpine-latest
       environment:
         - PHP_UPSTREAM_CONTAINER=my-php-app
         - PHP_UPSTREAM_PORT=9001
   ```

2. **Volume Mounts:** For more extensive customizations, you can mount your own config files:

   ```yaml
   services:
     web:
       image: wayofdev/nginx:k8s-alpine-latest
       volumes:
         - ./custom-nginx.conf:/etc/nginx/nginx.conf
         - ./custom-default.conf:/etc/nginx/conf.d/default.conf
   ```

### → SSL Configuration

The image includes self-signed SSL certificates. To use your own:

```yaml
services:
  web:
    image: wayofdev/nginx:k8s-alpine-latest
    volumes:
      - ./certs/cert.pem:/etc/nginx/ssl/cert.pem
      - ./certs/key.pem:/etc/nginx/ssl/key.pem
```

### → Advanced Configuration

For more advanced configurations:

1. Fork this repository
2. Modify the Ansible templates in the `src` directory
3. Regenerate the Dockerfiles using `make generate`
4. Build your custom image

<br>

## 🔨 Development

This project uses a set of tools for development and testing. The `Makefile` provides various commands to streamline the development process.

### → Requirements

- Docker
- Make
- Ansible
- goss and dgoss for testing

### → Setting Up the Development Environment

Clone the repository:

```bash
git clone git@github.com:wayofdev/docker-nginx.git && \
cd docker-nginx
```

### → Generating Dockerfiles

Ansible is used to generate Dockerfiles and configurations. To generate distributable Dockerfiles from Jinja template source code:

```bash
make generate
```

### → Building Images

- Build the default image:

  ```bash
  make build
  ```

  This command builds the image specified by the `IMAGE_TEMPLATE` variable in the Makefile. By default, it's set to `k8s-alpine`.

- Build a specific image:

  ```bash
  make build IMAGE_TEMPLATE="k8s-alpine"
  ```

  Replace `8.3-fpm-alpine` with your desired PHP version, type, and OS.

- Build all images:

  ```bash
  make build IMAGE_TEMPLATE="k8s-alpine"
  make build IMAGE_TEMPLATE="dev-alpine"
  ```

  These commands will build all supported image variants.

<br>

## 🧪 Testing

This project uses a testing approach to ensure the quality and functionality of the Docker images. The primary testing tool is [dgoss](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss), which allows for testing Docker containers.

### → Running Tests

You can run tests using the following commands:

- Test the default image:

  ```bash
  make test
  ```

  This command tests the image specified by the `IMAGE_TEMPLATE` variable in the Makefile (default is `k8s-alpine`).

- Test a specific image:

  ```bash
  make test IMAGE_TEMPLATE="k8s-alpine"
  ```

  Replace `8.3-fpm-alpine` with your desired PHP version, type, and OS.

- Test all images:

  ```bash
  make test IMAGE_TEMPLATE="k8s-alpine"
  make test IMAGE_TEMPLATE="dev-alpine"
  ```

### → Test Configuration

The test configurations are defined in `goss.yaml` files, which are generated for each image variant. These files specify the tests to be run, including:

- File existence and permissions
- Process checks
- Port availability
- Package installations
- Command outputs

### → Test Process

When you run the `make test` command, the following steps occur:

1. The specified Docker image is built (if not already present).
2. dgoss runs the tests defined in the `goss.yaml` file against the Docker container.
3. The test results are displayed in the console.

<br>

## 🔒 Security Policy

This project has a [security policy](.github/SECURITY.md).

<br>

## 🙌 Want to Contribute?

Thank you for considering contributing to the wayofdev community! We are open to all kinds of contributions. If you want to:

- 🤔 [Suggest a feature](https://github.com/wayofdev/docker-nginx/issues/new?assignees=&labels=type%3A+enhancement&projects=&template=2-feature-request.yml&title=%5BFeature%5D%3A+)
- 🐛 [Report an issue](https://github.com/wayofdev/docker-nginx/issues/new?assignees=&labels=type%3A+documentation%2Ctype%3A+maintenance&projects=&template=1-bug-report.yml&title=%5BBug%5D%3A+)
- 📖 [Improve documentation](https://github.com/wayofdev/docker-nginx/issues/new?assignees=&labels=type%3A+documentation%2Ctype%3A+maintenance&projects=&template=4-docs-bug-report.yml&title=%5BDocs%5D%3A+)
- 👨‍💻 [Contribute to the code](./.github/CONTRIBUTING.md)

You are more than welcome. Before contributing, kindly check our [contribution guidelines](.github/CONTRIBUTING.md).

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg?style=for-the-badge)](https://conventionalcommits.org)

<br>

## 🫡 Contributors

<p align="left">
<a href="https://github.com/wayofdev/docker-nginx/graphs/contributors">
<img align="left" src="https://img.shields.io/github/contributors-anon/wayofdev/docker-nginx?style=for-the-badge" alt="Contributors Badge"/>
</a>
<br>
<br>
</p>

## 🌐 Social Links

- **Twitter:** Follow our organization [@wayofdev](https://twitter.com/intent/follow?screen_name=wayofdev) and the author [@wlotyp](https://twitter.com/intent/follow?screen_name=wlotyp).
- **Discord:** Join our community on [Discord](https://discord.gg/CE3TcCC5vr).

<br>

## ⚖️ License

[![Licence](https://img.shields.io/github/license/wayofdev/docker-nginx?style=for-the-badge&color=blue)](./LICENSE.md)

<br>
