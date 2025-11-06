FROM python:3.12.8
WORKDIR /app

RUN pip install --no-cache-dir --upgrade pip

# Add Broadcom (WSS) client certificate to the systems /etc/ssl/certs/ca-certificates.crt file
ADD ./CertEmulationCA.crt /usr/local/share/ca-certificates/CertEmulationCA.crt
RUN update-ca-certificates

# point to the updated certs for python and openssl
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

RUN pip config set global.cert /etc/ssl/certs/ca-certificates.crt

COPY ./requirements/requirements.txt /app/requirements.txt

# Install the requirements
# Note: DGL requires a specific CUDA version, so we use the extra index URL for DGL
# Ensure that the CUDA version matches your environment; here we assume CUDA 12.1
# If you are using a different version, change the URL accordingly.
# For example, for CUDA 11.8, use: https://data.dgl.ai/wheels/cu118/repo.html
# For CUDA 12.0, use: https://data.dgl.ai/wheels/cu120/repo.html
RUN pip install --no-cache-dir \
            --extra-index-url https://data.dgl.ai/wheels/cu121/repo.html \
            --trusted-host data.dgl.ai \
            -r /app/requirements.txt

            # Copy the rest of the code....skipping directories that may contain data
COPY ./src /app/code
COPY ./data /app/data
COPY ./reqFiles /app/reqFiles

# set python path and working dir 
ENV PYTHONPATH=/app/code
WORKDIR /app/code

# run the flask app!
ENTRYPOINT ["sh", "-x", "gunicorn.sh"]
