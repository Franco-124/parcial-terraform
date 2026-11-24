# ECR Public mirror of the official image: avoids Docker Hub rate limits in CodeBuild.
FROM public.ecr.aws/docker/library/nginx:1.27-alpine

# jq parses the ECS Task Metadata Endpoint JSON at startup.
RUN apk add --no-cache jq

# Explicit modes: host file permissions (e.g. 600) must not leak into the image,
# otherwise the unprivileged nginx worker gets "Permission denied" (HTTP 403).
COPY --chmod=644 index.html /usr/share/nginx/html/index.html
COPY --chmod=755 docker/40-ecs-metadata.sh /docker-entrypoint.d/40-ecs-metadata.sh

EXPOSE 80
