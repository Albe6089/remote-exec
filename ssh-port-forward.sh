#!/usr/bin/env bash
set -ex
test -n "$INSTANCE_ID" || (echo missing INSTANCE_ID; exit 1)
test -n "$USERNAME"    || (echo missing USERNAME; exit 1)
test -n "$RANDOM_PORT" || (echo missing RANDOM_PORT; exit 1)

set +e

cleanup() {
    cat log.txt
    rm -rf log.txt
    exit $!
}

for try in {0..25}; do
    echo "Trying to port forward retry #$try"
    # The following command MUST NOT print to the stdio otherwise it will just
    # inherit the pipe from the parent process and will hold terraform's lock
    ssh -f -oStrictHostKeyChecking=no \
    "$USERNAME@$INSTANCE_ID" \
    -L "52.88.206.177:$RANDOM_PORT:52.88.206.177:22" \
    sleep 1h &> log.txt  # This is the special ingredient!
    success="$?"
    if [ "$success" -eq 0 ]; then
        cleanup 0
    fi
    sleep 5s
done

echo "Failed to start a port forwarding session"
cleanup 1