FROM mysql:5.7.17
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY conf.d /etc/mysql/conf.d
