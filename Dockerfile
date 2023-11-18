FROM oven/bun

EXPOSE 3000

WORKDIR /avatars.continuum-ai.de
COPY ./package.json ./
COPY . .

RUN bun install --prod

# Set the STOPSIGNAL to SIGTERM (15)
STOPSIGNAL SIGTERM

# Use the custom shutdown handler script as the ENTRYPOINT
ENTRYPOINT ["/bin/bash", "./shutdown-handler.sh"]

CMD ["bun", "run", "build:production"]
