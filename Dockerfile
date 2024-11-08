# 使用轻量的基础镜像
FROM alpine:latest

# 设置工作目录
WORKDIR /home/www

# 设置环境变量以映射架构
ENV ARCH_MAP="x86_64:amd64 aarch64:arm64 x86:x86"

# 根据系统架构设置 ARCH 变量
RUN echo "Detected architecture (uname -m): $(uname -m)" && \
    ARCH=$(uname -m) && \
    MAPPED_ARCH=$(echo "$ARCH_MAP" | tr ' ' '\n' | grep "^$ARCH:" | cut -d':' -f2) && \
    if [ -z "$MAPPED_ARCH" ]; then \
        echo "Unsupported architecture: $ARCH"; \
        exit 1; \
    fi && \
    echo "Mapped architecture: $MAPPED_ARCH" && \
    # 更新 apk 并安装 curl
    apk update && \
    apk add --no-cache curl && \
    # 下载并解压相应架构的 lade
    curl -L https://github.com/lade-io/lade/releases/latest/download/lade-linux-$MAPPED_ARCH.tar.gz | tar xz && \
    mv lade /usr/local/bin && \
    rm -rf /var/cache/apk/*

# 添加一个命令，使容器保持运行
CMD ["tail", "-f", "/dev/null"]

