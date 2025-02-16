FROM dorowu/ubuntu-desktop-lxde-vnc:latest

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    wget \
    git \
    python3 \
    python3-pip \
    python3-venv \
    libgl1 \
    libglib2.0-0 \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Клонирование репозитория DeepSeek Coder
RUN git clone https://github.com/deepseek-ai/deepseek-coder /app/deepseek-coder

WORKDIR /app/deepseek-coder

# Установка Python зависимостей
RUN pip3 install -r requirements.txt

# Настройка Nginx
COPY nginx.conf /etc/nginx/sites-available/default
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Настройка автозапуска
RUN echo "#!/bin/bash\n\
service nginx start\n\
python3 app.py --host 0.0.0.0 --port 7860 &\n\
vncserver :0 -geometry 1920x1080 -depth 24" > /startup.sh \
    && chmod +x /startup.sh

EXPOSE 80 5900 6080 7860

CMD ["/startup.sh"]
