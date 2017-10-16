FROM alpine:3.6

RUN apk add --no-cache python3 
RUN python3 -m ensurepip
RUN rm -r /usr/lib/python*/ensurepip
RUN pip3 install --upgrade pip setuptools
RUN if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi
RUN rm -r /root/.cache
RUN apk add --no-cache libstdc++ lapack-dev
RUN apk add --no-cache --virtual=.build-dependencies  g++ gfortran musl-dev  python3-dev
RUN ln -s locale.h /usr/include/xlocale.h
RUN pip install numpy
RUN pip install pandas
RUN pip install scipy
RUN pip install scikit-learn
RUN find /usr/lib/python3.*/ -name 'tests' -exec rm -rf '{}' \; 2> /dev/null ; echo $?
RUN rm /usr/include/xlocale.h
RUN rm -rf /root/.cache
RUN apk del .build-dependencies

## Openfaas part
RUN apk --no-cache add curl \
    && echo "Pulling watchdog binary from Github." \
    && curl -sSL https://github.com/openfaas/faas/releases/download/0.6.1/fwatchdog > /usr/bin/fwatchdog \
    && chmod +x /usr/bin/fwatchdog \
    && apk del curl --no-cache

RUN ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /root/

ENV fprocess="python index.py"

HEALTHCHECK --interval=1s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
