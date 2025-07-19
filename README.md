<p align="center">
  <img src="https://raw.githubusercontent.com/zenthracore/zen.falcon/main/assets/zenthra.png" width="120" alt="ZENTHRA logo" />
</p>

<h1 align="center">zen.falcon</h1>
<p align="center">
  🧘 Alpine-based OpenSSL 3.3.4 image with Falcon post-quantum crypto and oqs-provider.<br>
  <strong>Silence is infrastructure.</strong>
</p>

---

## 🔐 What is this?

`zen.falcon` is a minimal Alpine Linux container featuring:

- OpenSSL **3.3.4** (built July 2025)
- Integrated [`oqs-provider`](https://github.com/open-quantum-safe/oqs-provider) for OpenSSL 3.x
- Post-quantum algorithm: **Falcon512 / Falcon1024** from [NIST PQC standards](https://csrc.nist.gov/projects/post-quantum-cryptography)
- Working `openssl.cnf` with dynamic provider loading
- CLI support for:
    - `genpkey`, `req`, `x509` with Falcon keys
    - `openssl list -providers`, `openssl list -public-key-algorithms`

---

## 🧰 Use cases

- 🛡️ Generating **Falcon-based TLS certificates**
- 🧪 Spinning up **post-quantum mTLS** endpoints (via `s_server`, NGINX, Redis, etc.)
- ⚙️ Using as a **base image** for secure microservices
- 📦 Integrating Falcon into **CI/CD pipelines** and `cosign`, `sigstore`, etc.
- 🔭 Testing PQC infrastructure in containerized environments

---

## ⚙️ Quick start

### 🔧 1. Clone and build the image
```bash
git clone https://github.com/zenthracore/zen.falcon.git
cd zen.falcon

# Build the image locally
docker build -t zen.falcon .
```

### 🧘 2. Run the container
```bash
docker run -it --rm ghcr.io/zenthracore/zen.falcon sh
```
### 🔐 3. Generate Falcon key and cert
```bash
# Generate Falcon1024 private key
openssl genpkey -algorithm falcon1024 -out server.key

# Generate CSR
openssl req -new -key server.key -out server.csr \
-subj "/C=UA/ST=Kyiv/L=Kyiv/O=ZENTHRACORE/CN=api.example.com"

# Self-sign certificate
openssl x509 -req -in server.csr -signkey server.key -out server.crt -days 365
```

## 🧪 Provider check

```bash
openssl version
openssl list -providers
openssl list -public-key-algorithms
```
You should see oqsprovider active and Falcon listed among the algorithms.

## 📄 License
- Falcon: MIT
- oqs-provider: Apache-2.0 + BSD-compatible
- OpenSSL 3.3.4: Apache 2.0
- Everything in this repo: MIT

## 🧘 About ZENTHRACORE

Silence is infrastructure.
ZENTHRACORE is a minimal security-first stack for post-quantum, zero-trust, hardened systems.
zen.falcon is its cryptographic foundation

## 📫 Contact

- 📧 Email: [zenthracore@proton.me](mailto:zenthracore@proton.me)
- ⚡ Damus (Nostr): `npub1msz8ejzagf5z760c74d6svrpmqcd3nq6ffhrq7akesege9dq748sjlul4s`