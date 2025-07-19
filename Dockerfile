FROM alpine:3.20

# --- Install base packages via apk ---
RUN echo "--- Installing base packages via apk ---" \
    && apk add --no-cache \
    openssl \
    openssl-dev \
    ca-certificates \
    build-base \
    cmake \
    git \
    perl \
    bash \
    linux-headers \
    libstdc++

# --- Update base system packages ---
RUN echo "--- Updating base system packages ---" \
    && apk update && apk upgrade

# --- Sanity check: make sure apk works after base package install ---
RUN echo "--- Sanity check: test apk after base package install ---" \
    && apk update

# --- Build liboqs ---
RUN echo "--- Building liboqs ---" \
    && git clone --branch 0.14.0 https://github.com/open-quantum-safe/liboqs.git \
    && cd liboqs \
    && mkdir build && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
             -DBUILD_SHARED_LIBS=ON \
             -DOQS_ENABLE_SIG_DILITHIUM=ON \
             -DOQS_USE_AVX2=OFF .. \
    && make -j$(nproc) && make install \
    && echo "--- liboqs build complete ---" \
    && echo "--- Checking liboqs.so dependencies ---" \
    && ldd /usr/local/lib/liboqs.so || true \
    && cd ../.. && rm -rf liboqs

# --- Check for liboqs.so file ---
RUN echo "--- Checking for liboqs.so file ---" \
    && ls -lh /usr/local/lib/liboqs.so

# --- Build oqs-provider ---
RUN echo "--- Building oqs-provider ---" \
    && git clone --branch main https://github.com/open-quantum-safe/oqs-provider.git \
    && cd oqs-provider \
    && mkdir build && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
             -DCMAKE_PREFIX_PATH="/usr/local" \
             -DOPENSSL_ROOT_DIR=/usr \
             -DOPENSSL_LIBRARIES=/usr/lib \
             -DOPENSSL_INCLUDE_DIR=/usr/include .. \
    && make VERBOSE=1 -j$(nproc) | tee ../make_output.log \
    && make install \
    && echo "--- oqs-provider build complete ---" \
    && find / -name 'oqsprovider.so' 2>/dev/null \
    && echo "--- Checking oqsprovider.so dependencies ---" \
    && ldd /usr/lib/ossl-modules/oqsprovider.so || true \
    && cd ../.. && rm -rf oqs-provider

# --- Check for oqsprovider.so file ---
RUN echo "--- Checking for oqsprovider.so file ---" \
    && ls -lh /usr/lib/ossl-modules/oqsprovider.so

# --- Set provider library and runtime paths ---
ENV OPENSSL_MODULES=/usr/lib/ossl-modules
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:${LD_LIBRARY_PATH}

# --- Patch openssl.cnf to activate oqsprovider and default providers ---
RUN echo "--- Modifying openssl.cnf to enable oqsprovider and default providers ---" \
    # Add oqsprovider_sect section
    && printf "\n[oqsprovider_sect]\nmodule = /usr/lib/ossl-modules/oqsprovider.so\nactivate = 1\n" >> /etc/ssl/openssl.cnf \
    # Enable default provider by uncommenting 'activate = 1' in [default_sect]
    && sed -i '/^\[default_sect\]/,/^$/ s/^# *activate = 1/activate = 1/' /etc/ssl/openssl.cnf \
    # Add oqsprovider entry in [provider_sect]
    && sed -i '/^\[provider_sect\]/a oqsprovider = oqsprovider_sect' /etc/ssl/openssl.cnf \
    && echo "--- openssl.cnf modified ---" \
    && cat /etc/ssl/openssl.cnf

ENV OPENSSL_CONF=/etc/ssl/openssl.cnf

CMD ["/bin/sh"]
