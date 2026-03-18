FROM python:3.11-slim

# HTB Labels - Updated
LABEL maintainer="Denis Sanchez Leyva | Vertex Coders LLC"
LABEL htb.difficulty="Easy-Medium"
LABEL htb.category="Web/Linux"
LABEL htb.vulnerability="Misconfig,LLM Injection,Credential Reuse,Python Path Hijacking"
LABEL htb.os="Linux"

WORKDIR /app

# Dependencies
RUN pip install flask gunicorn requests --no-cache-dir

# Copy app
COPY app.py .

# Create REALISTIC filesystem structure
RUN mkdir -p /opt/aria/tasks /opt/aria/config /home/htbuser && \
    echo "nvidia/nemotron-3-nano-4b" > /opt/aria/config/system_prompt.txt && \
    chmod 644 /opt/aria/config/system_prompt.txt

# Create vulnerable run_task.py
RUN cat > /opt/aria/tasks/run_task.py << 'EOF' && \
    chmod +x /opt/aria/tasks/run_task.py
#!/usr/bin/env python3
import sys, os
sys.path.insert(0, "/opt/aria/tasks/modules")
try:
    from logger import log_maintenance
    log_maintenance("Starting ARIA maintenance...")
except:
    print("Logger module not found")
os.system("python3 /opt/aria/maintenance.py")
EOF

# Create htbuser with sudo privs
RUN useradd -m -u 1000 -s /bin/bash htbuser && \
    echo "htbuser ALL=(ALL) NOPASSWD: /opt/aria/tasks/run_task.py" >> /etc/sudoers.d/htbuser && \
    echo "HTB{pr0mpt_1nj3ct10n_1s_r34l_d4ng3r}" > /home/htbuser/user.txt && \
    echo "HTB{askm34nyth1ng_r34l1st1c_v2_4ppr0v3d}" > /root/root.txt && \
    chown htbuser:htbuser /home/htbuser/user.txt && \
    chmod 600 /home/htbuser/user.txt /root/root.txt

USER htbuser
EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
