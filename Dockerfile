FROM jenkinsxio/builder-base:0.0.162

ENV LANG="en_US.UTF-8"
ENV OTP_VERSION="20.3.2"
ENV REBAR3_VERSION="3.5.0"
ENV ELIXIR_VERSION="v1.6.4"

# Install erlang and otp
RUN set -xe \
      && OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz" \
      && OTP_DOWNLOAD_SHA256="9809be52baa23d6fd18ee70b9a9b7c548e44f586db2f46ff5bfe66719cfab10a" \
      && curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL" \
      && echo "$OTP_DOWNLOAD_SHA256  otp-src.tar.gz" | sha256sum -c - \
      && yum install -y gcc \
                        gcc-c++ \
                        openssl-devel \
                        autoconf \
                        ncurses-devel \
                        unixODBC-devel \
                        wxGTK-devel \
                        wxGTK3-devel \
      && mkdir -p /usr/src/otp \
      && tar -xzf otp-src.tar.gz -C /usr/src/otp --strip-components=1 \
      && ( cd /usr/src/otp \
          && ./otp_build autoconf \
          && ./configure \
          && make -j$(nproc) \
          && make install ) \
      && find /usr/local -name examples | xargs rm -rf \
      && rm -rf otp-src.tar.gz /usr/src/otp

# Install rebar3
RUN set -xe \
      && REBAR3_DOWNLOAD_URL="https://github.com/erlang/rebar3/archive/${REBAR3_VERSION}.tar.gz" \
      && REBAR3_DOWNLOAD_SHA256="e95e9d1f2ce219f548d4f49ad41409af02069190f19e2b6717585eef6ee77501" \
      && mkdir -p /usr/src/rebar3 \
      && curl -fSL -o rebar3-src.tar.gz "$REBAR3_DOWNLOAD_URL" \
      && echo "$REBAR3_DOWNLOAD_SHA256 rebar3-src.tar.gz" | sha256sum -c - \
      && tar -xzf rebar3-src.tar.gz -C /usr/src/rebar3 --strip-components=1 \
      && ( cd /usr/src/rebar3 \
          && HOME=$PWD ./bootstrap \
          && install -v ./rebar3 /usr/local/bin/ ) \
      && rm -rf rebar3-src.tar.gz /usr/src/rebar3

# Install elixir
RUN set -xe \
      && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
      && ELIXIR_DOWNLOAD_SHA256="c12a4931a5383a8a9e9eb006566af698e617b57a1f645a6cb132a321b671292d" \
      && curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
      && echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
      && mkdir -p /usr/src/elixir \
      && tar -xzC /usr/src/elixir --strip-components=1 -f elixir-src.tar.gz \
      && ( cd /usr/src/elixir \
          && make install clean ) \
      && rm -rf elixir-src.tar.gz /usr/src/elixir

# Install hex and rebar into mix
RUN mix do local.hex --force, \
           local.rebar --force
