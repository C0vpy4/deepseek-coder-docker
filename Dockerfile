# Используем образ с Ubuntu
FROM ubuntu:20.04

# Устанавливаем основные зависимости
RUN apt-get update && apt-get install -y \
    wget \
    git \
    python3 \
    python3-pip \
    python3-venv \
    libgl1 \
    libglib2.0-0 \
    nginx \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    curl \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

# Клонируем репозиторий DeepSeek Coder
RUN git clone https://github.com/deepseek-ai/deepseek-coder /home/deepseek-coder

# Устанавливаем Python зависимости
WORKDIR /home/deepseek-coder
RUN pip3 install -r requirements.txt

# Настройка VNC
RUN echo "#!/bin/bash\n\
xrdb $HOME/.Xresources\n\
startxfce4 &\n\
" > /home/deepseek-coder/.vnc/xstartup && \
    chmod +x /home/deepseek-coder/.vnc/xstartup

# Настройка автозапуска
RUN echo "#!/bin/bash\n\
vncserver :1 -geometry 1920x1080 -depth 24\n\
python3 /home/deepseek-coder/app.py --host 0.0.0.0 --port 7860 &\n\
nginx -g 'daemon off;'\n\
" > /home/deepseek-coder/startup.sh && \
    chmod +x /home/deepseek-coder/startup.sh

# Открываем порты для VNC и приложения
EXPOSE 80 5900 7860

# Запускаем скрипт автозапуска
CMD ["/home/deepseek-coder/startup.sh"]
