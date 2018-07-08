# thelounge-docker-from-source

Dockerfile that facilitates building images directly from source.

## Example usage

### Build an image containing pull requests

```sh
$ docker build -t thelounge:custom --build-arg PULL_REQUESTS=2278,2301,2477 .
```

### Build an image against a specific branch/tag/git revision

```sh
$ docker build -t thelounge:custom --build-arg GIT_REVISION=xpaws-new-awesome-feature-branch .
```

> You can of course combine the build args mentioned above to your heart's content.
