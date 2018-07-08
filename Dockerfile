FROM node:8-alpine

WORKDIR /opt/thelounge

RUN apk --no-cache add \
    git

# commit SHA, branch, tag, etc.
ARG GIT_REVISION=master
# comma separated list of PRs to try and merge into $branch, will fail silently and continue if automatic merge fails
ARG PULL_REQUESTS=

# needed to create merge commits
RUN git config --global user.name "Docker" && \
    git config --global user.email "docker@local.docker"

RUN git clone https://github.com/thelounge/thelounge.git . && \
    git checkout "$GIT_REVISION"

# merge all (optional) pull requests
RUN for pr in $(echo $PULL_REQUESTS | tr ',' '\n'); do git fetch origin "refs/pull/$pr/head" && (git merge --no-edit --no-ff FETCH_HEAD || git merge --abort); done

RUN yarn && \
    NODE_ENV=production yarn build && \
    rm -rf node_modules && NODE_ENV=production yarn && \
    yarn link

ENV NODE_ENV=development

CMD ["thelounge", "start"]
