# sigwrap

A simple **signal‐handling wrapper** for Linux commands.  
When you prefix any command with `sigwrap.sh`, the wrapper will:

1. **Trap `SIGTERM`** sent to the wrapper process  
2. **Log** a message to stdout when it receives `SIGTERM`  
3. **Force‐kill** the wrapped command with `SIGKILL`  
4. **Exit** with code `1`  

This ensures that a polite termination request to your wrapper always results in a hard kill of the underlying process—useful in Docker containers, systemd services, or any place you need reliable shutdown behavior.


## Usage

### Standalone

Run any command under `sigwrap.sh`:

    sigwrap.sh your-command [arg1 arg2 …]

#### Example

    # Start a long‐running sleep under sigwrap
    sigwrap.sh sleep 300 &
    wrapper_pid=$!

    # In another terminal, send SIGTERM to the wrapper
    kill -TERM $wrapper_pid

You should see:

    [sigwrap] Received SIGTERM. Sending SIGKILL to child (<child_pid>)...
    # And the wrapper exits with code 1


### As an ENTRYPOINT in your Dockerfile

    FROM ubuntu:24.04

    # Copy the wrapper in
    COPY sigwrap.sh /usr/local/bin/sigwrap.sh
    RUN chmod +x /usr/local/bin/sigwrap.sh

    # Install your app...
    COPY my-service /usr/local/bin/my-service
    RUN chmod +x /usr/local/bin/my-service

    # Use sigwrap as the entrypoint
    ENTRYPOINT ["sigwrap.sh", "/usr/local/bin/my-service"]
    CMD ["--config", "/etc/my-service.conf"]

Now `docker run my-image` will launch your service under `sigwrap`, guaranteeing that `docker stop` (which sends `SIGTERM`) kills the child process.

