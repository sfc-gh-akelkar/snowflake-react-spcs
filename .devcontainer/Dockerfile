FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install Snow CLI
RUN pip install --upgrade pip && \
    pip install snowflake-cli

# Install Cortex Code CLI
RUN curl -fsSL https://downloads.snowflake.com/cortex-code/latest/cortex-linux-x64 -o /usr/local/bin/cortex && \
    chmod +x /usr/local/bin/cortex

# Set up workspace
WORKDIR /workspace
