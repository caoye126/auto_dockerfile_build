#选择镜像
FROM php:5.6.36-fpm-stretch

#因为官方镜像是用的debain stretch 所以第一步先替换源 如果是Jessie 要替换对应的源
RUN echo "deb http://mirrors.aliyun.com/debian stretch main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian stretch main contrib non-free" >> /etc/apt/sources.list  && \
    echo "deb http://mirrors.aliyun.com/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian-security stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian-security stretch/updates main contrib non-free" >> /etc/apt/sources.lis

#安装后面所使用的工具 composer会用到git php gd扩展会用到libpng-dev
RUN apt-get update && apt-get install -y \
    git\
    libpng-dev

#添加扩展的其中一种方式 就是把命令组合在了一起
RUN curl -fsSL 'https://pecl.php.net//get/redis-4.0.2.tgz' -o redis-4.0.2.tar.gz \
    && tar -xvf redis-4.0.2.tar.gz \
    && rm redis-4.0.2.tar.gz \
    && ( \
        cd redis-4.0.2 \
        && phpize \
        && ./configure  \
        && make \
        && make install \
    ) \
    && rm -r redis-4.0.2 \
    && docker-php-ext-enable redis
#安装php编译时官方没有安装的扩展,哪个版本的php镜像,就下载哪个版本的源码
RUN curl -fsSL 'http://am1.php.net/distributions/php-5.6.36.tar.gz' -o php-5.6.36.tar.gz \
    && tar -xvf php-5.6.36.tar.gz \
    && rm php-5.6.36.tar.gz \
    && ( \
        cd php-5.6.36/ext/mysql \
        && phpize \
        && ./configure  \
        && make \
        && make install \
    ) \
    && ( \
        cd php-5.6.36/ext/pdo_mysql \
        && phpize \
        && ./configure  \
        && make \
        && make install \
    ) \
    && ( \
        cd php-5.6.36/ext/mysqli \
        && phpize \
        && ./configure  \
        && make \
        && make install \
    ) \
    && ( \
           cd php-5.6.36/ext/bcmath \
           && phpize \
           && ./configure  \
           && make \
           && make install \
    ) \
    && ( \
           cd php-5.6.36/ext/gd \
           && phpize \
           && ./configure  \
           && make \
           && make install \
    ) \
    && rm -r php-5.6.36 \
    && docker-php-ext-enable mysql pdo_mysql mysqli bcmath gd
#安装composer 我个人觉得这样方便使用
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    composer self-update && \
    composer config -g repo.packagist composer https://packagist.phpcomposer.com
#命令
CMD ["php-fpm"]
