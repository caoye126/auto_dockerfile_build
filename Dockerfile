#ѡ����
FROM php:5.6.36-fpm-stretch

#��Ϊ�ٷ��������õ�debain stretch ���Ե�һ�����滻Դ �����Jessie Ҫ�滻��Ӧ��Դ
RUN echo "deb http://mirrors.aliyun.com/debian stretch main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian stretch main contrib non-free" >> /etc/apt/sources.list  && \
    echo "deb http://mirrors.aliyun.com/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian-security stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian-security stretch/updates main contrib non-free" >> /etc/apt/sources.lis

#��װ������ʹ�õĹ��� composer���õ�git php gd��չ���õ�libpng-dev
RUN apt-get update && apt-get install -y \
    git\
    libpng-dev

#�����չ������һ�ַ�ʽ ���ǰ������������һ��
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
    && rm -r redis-4.0.2 \ #ɾ����Ϊ�˽�Լ�ռ�
    && docker-php-ext-enable redis  
#��װphp����ʱ�ٷ�û�а�װ����չ,�ĸ��汾��php����,�������ĸ��汾��Դ��
RUN curl -fsSL 'http://ba1.php.net/get/php-5.6.36.tar.gz/from/this/mirror' -o php-5.6.36.tar.gz \
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
#��װcomposer �Ҹ��˾�����������ʹ��
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    composer self-update && \
    composer config -g repo.packagist composer https://packagist.phpcomposer.com
#����
CMD ["php-fpm"]

