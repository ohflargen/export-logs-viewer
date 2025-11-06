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
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the rest of the code....skipping directories that may contain data
COPY ./src /app/code

# Copy the gunicorn script
COPY gunicorn.sh /app/code/gunicorn.sh

# set python path and working dir
ENV PYTHONPATH=/app/code
WORKDIR /app/code

# run the flask app!
ENTRYPOINT ["sh", "-x", "./gunicorn.sh"]
