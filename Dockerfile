# syntax=docker/dockerfile:1

# --- Stage 1: download & extract the MegaMek release ----------------------
# MM_VERSION can be an explicit version (e.g. 0.50.12) or "latest" to resolve
# the newest GitHub release at build time.
FROM alpine:3.20 AS downloader

ARG MM_VERSION=latest

RUN apk add --no-cache curl jq tar

WORKDIR /opt
RUN set -eux; \
    if [ "$MM_VERSION" = "latest" ]; then \
      MM_VERSION="$(curl -fsSL https://api.github.com/repos/MegaMek/megamek/releases/latest \
        | jq -r .tag_name | sed 's/^v//')"; \
    fi; \
    echo "Installing MegaMek ${MM_VERSION}"; \
    curl -fSL "https://github.com/MegaMek/megamek/releases/download/v${MM_VERSION}/MegaMek-${MM_VERSION}.tar.gz" \
      -o /tmp/mm.tar.gz; \
    mkdir -p /opt/megamek; \
    tar -xzf /tmp/mm.tar.gz -C /opt/megamek --strip-components=1; \
    rm /tmp/mm.tar.gz

# --- Stage 2: lean runtime ------------------------------------------------
# MegaMek requires Java 17 LTS or newer. The dedicated server is headless,
# so the JRE (no JDK, no GUI libs) is enough.
FROM eclipse-temurin:17-jre

# Run as a non-root user.
RUN groupadd -r megamek && useradd -r -g megamek -d /opt/megamek megamek

COPY --from=downloader /opt/megamek /opt/megamek
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /opt/megamek
RUN chmod +x /usr/local/bin/entrypoint.sh \
 && mkdir -p mmconf savegames logs \
 && chown -R megamek:megamek /opt/megamek

USER megamek

# Default dedicated-server port.
EXPOSE 2346

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
