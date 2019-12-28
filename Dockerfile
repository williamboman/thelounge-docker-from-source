FROM node:12-alpine

WORKDIR /opt/thelounge

RUN apk --no-cache add \
    git

# needed to create merge commits
RUN git config --global user.name "Docker" && \
    git config --global user.email "docker@local.docker"

ENV THELOUNGE_HOME /var/opt/thelounge
VOLUME "${THELOUNGE_HOME}"

# commit SHA, branch, tag, etc.
ARG GIT_REVISION=master
# comma separated list of PRs to try and merge into $GIT_REVISION, will fail silently and continue if automatic merge fails
ARG PULL_REQUESTS=

RUN git clone https://github.com/thelounge/thelounge.git . && \
    git checkout "$GIT_REVISION"

# merge all (optional) pull requests
RUN \
for pr in $(echo $PULL_REQUESTS | tr ',' '\n'); do \
    git fetch origin "refs/pull/$pr/head" && (git merge --no-edit --no-ff FETCH_HEAD || git merge --abort); \
done; \
rm -rf node_modules

RUN yarn && \
    NODE_ENV=production yarn build && \
    yarn install --production && \
    yarn link

ENV NODE_ENV=production

# expose the default port
EXPOSE 9000

CMD ["thelounge", "start"]
