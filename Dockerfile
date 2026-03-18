FROM python:3.11-slim

# HTB Labels
LABEL maintainer="Denis Sanchez Leyva | Vertex Coders LLC"
LABEL htb.difficulty="Easy-Medium"
LABEL htb.category="Web/Linux"

WORKDIR /app

# 1. Instalamos sudo (Vital en las versiones slim)
RUN apt-get update && apt-get install -y sudo && \
    mkdir -p /etc/sudoers.d && \
    rm -rf /var/lib/apt/lists/*

# 2. Dependencies
RUN pip install flask gunicorn requests --no-cache-dir

# 3. Create structure ANTES de cambiar de usuario
RUN mkdir -p /opt/aria/tasks /opt/aria/config /opt/aria/tasks/modules && \
    echo "nvidia/nemotron-3-nano-4b" > /opt/aria/config/system_prompt.txt

# 4. Create vulnerable run_task.py
RUN printf "#!/usr/bin/env python3\nimport sys, os\nsys.path.insert(0, '/opt/aria/tasks/modules')\ntry:\n    from logger import log_maintenance\n    log_maintenance('Starting ARIA maintenance...')\nexcept:\n    print('Logger module not found')\nos.system('python3 /opt/aria/maintenance.py')" > /opt/aria/tasks/run_task.py && \
    chmod +x /opt/aria/tasks/run_task.py

# 5. Create htbuser y configurar sudoers (Aquí está el fix del error)
RUN useradd -m -u 1000 -s /bin/bash htbuser && \
    echo "htbuser ALL=(ALL) NOPASSWD: /opt/aria/tasks/run_task.py" > /etc/sudoers.d/htbuser && \
    chmod 440 /etc/sudoers.d/htbuser

# 6. Plantar Flags (Como somos root todavía, esto funciona)
RUN echo "HTB{pr0mpt_1nj3ct10n_1s_r34l_d4ng3r}" > /home/htbuser/user.txt && \
    echo "HTB{askm34nyth1ng_r34l1st1c_v2_4ppr0v3d}" > /root/root.txt && \
    chown htbuser:htbuser /home/htbuser/user.txt && \
    chmod 400 /home/htbuser/user.txt /root/root.txt

# 7. Copiar la app
COPY app.py .
RUN chown -R htbuser:htbuser /app

USER htbuser
EXPOSE 5000

# Usamos puerto 8000 como quedamos ayer para Vertex
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
