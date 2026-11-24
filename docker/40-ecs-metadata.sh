#!/bin/sh
# Injects the ECS task ID and availability zone into index.html at container start.
# Runs automatically through the official nginx image's /docker-entrypoint.d hook.
# Data source: ECS Task Metadata Endpoint v4 (injected by the ECS agent on Fargate).
set -eu

HTML_FILE="/usr/share/nginx/html/index.html"
TASK_ID="local"
AZ="local"

# Keep only characters valid in task IDs and AZ names to avoid sed/HTML injection.
sanitize() {
  printf '%s' "$1" | tr -cd 'A-Za-z0-9-'
}

if [ -n "${ECS_CONTAINER_METADATA_URI_V4:-}" ]; then
  if METADATA="$(wget -q -T 5 -O - "${ECS_CONTAINER_METADATA_URI_V4}/task")"; then
    TASK_ARN="$(printf '%s' "$METADATA" | jq -r '.TaskARN // empty')"
    META_AZ="$(printf '%s' "$METADATA" | jq -r '.AvailabilityZone // empty')"

    # TaskARN format: arn:aws:ecs:<region>:<account>:task/<cluster>/<task-id>
    [ -n "$TASK_ARN" ] && TASK_ID="$(sanitize "${TASK_ARN##*/}")"
    [ -n "$META_AZ" ] && AZ="$(sanitize "$META_AZ")"
  else
    echo "40-ecs-metadata: metadata endpoint unreachable, using fallback values" >&2
    TASK_ID="unavailable"
    AZ="unavailable"
  fi
else
  echo "40-ecs-metadata: not running on ECS, using fallback values" >&2
fi

sed -i -e "s/__ECS_TASK_ID__/${TASK_ID}/g" -e "s/__ECS_AZ__/${AZ}/g" "$HTML_FILE"
echo "40-ecs-metadata: task_id=${TASK_ID} az=${AZ}"
