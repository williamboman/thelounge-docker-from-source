FROM node:lts-alpine

WORKDIR /opt/thelounge

RUN apk --update --no-cache --virtual build-deps add \
    git

# If you're using an architecture that has no pre-compiled binaries, switch to this command instead of the above.
# RUN apk --update --no-cache --virtual build-deps add \
#     git python3 build-base

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

RUN yarn --non-interactive && \
    NODE_ENV=production yarn --non-interactive build && \
    rm -rf node_modules && \
    yarn install --production --non-interactive && \
    yarn link --non-interactive && \
    yarn cache clean --non-interactive && \
    apk del build-deps

ENV NODE_ENV=production

# expose the default port
EXPOSE 9000

CMD ["thelounge", "start"]
