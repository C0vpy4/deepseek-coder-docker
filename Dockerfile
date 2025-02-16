# Используем официальный образ Ubuntu Server
FROM ubuntu:20.04

# Устанавливаем базовые зависимости и обновляем систему
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    wget \
    git \
    python3 \
    python3-pip \
    python3-venv \
    libgl1 \
    libglib2.0-0 \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем Python зависимости
RUN pip3 install --upgrade pip

# Клонируем репозиторий DeepSeek Coder
RUN git clone https://github.com/deepseek-ai/deepseek-coder /app/deepseek-coder

WORKDIR /app/deepseek-coder

# Установка зависимостей Python из requirements.txt
RUN pip3 install -r requirements.txt

# Копируем конфигурацию Nginx в контейнер
COPY nginx.conf /etc/nginx/sites-available/default

# Настройка логов Nginx
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Создаем скрипт для автозапуска сервисов
RUN echo "#!/bin/bash\n\
service nginx start\n\
python3 app.py --host 0.0.0.0 --port 7860 &\n\
vncserver :0 -geometry 1920x1080 -depth 24" > /startup.sh \
    && chmod +x /startup.sh

# Открываем порты для приложения
EXPOSE 80 5900 6080 7860

# Устанавливаем команду для запуска сервисов
CMD ["/startup.sh"]
