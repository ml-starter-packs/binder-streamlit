FROM python:3.9-slim

RUN apt-get update -q && \
	apt-get install -yqq \
	curl \
	git \
	htop \
	nginx \
	make \
	tmux \
	vim \
	&& \
	apt-get -qq purge && \
	apt-get -qq clean && \
	rm -rf /var/lib/apt/lists/*

# create user with a home directory
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER=${NB_USER}
ENV HOME=/home/${NB_USER}

RUN adduser --disabled-password \
	--gecos "Default user" \
	--uid ${NB_UID} \
	${NB_USER}

WORKDIR /work/
WORKDIR ${HOME}
USER ${NB_USER}
ENV PATH="/home/${NB_USER}/.local/bin:${PATH}"
ENV SHELL="/bin/bash"
COPY requirements.txt /tmp
RUN pip install -U pip
RUN pip install --no-cache -r /tmp/requirements.txt
COPY postBuild /tmp
COPY jupyter_notebook_config.py /home/${NB_USER}/.jupyter/
RUN sh /tmp/postBuild

CMD streamlit run app.py --server.address 0.0.0.0 --server.port 8501 --server.enableCORS False --server.enableXsrfProtection False
