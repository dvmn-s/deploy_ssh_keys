SHELL=/bin/bash

# Определяем текущую директорию
CURRENT_DIR := $(shell pwd)
ANSIBLE_CMD = source /opt/ansible_venv/bin/activate && ansible-playbook -i inventory.yaml upload_authorized_keys.yaml

# Деплой ключей через Ansible
deploy:
	@echo "🚀 Развертывание..."
	@export VAULT_TOKEN=$$(cat /root/.vault-token) && ANSIBLE_HOST_KEY_CHECKING=False $(ANSIBLE_CMD) -e "group=admins keys=admins"
	@export VAULT_TOKEN=$$(cat /root/.vault-token) && ANSIBLE_HOST_KEY_CHECKING=False $(ANSIBLE_CMD) -e "group=dev keys=dev"

# Создание виртуального окружения и установка зависимостей
create_env:
	@echo "🛠️ Создаем виртуальное окружение..."
	@python3 -m venv /opt/ansible_venv && \
	source /opt/ansible_venv/bin/activate && \
	pip install ansible hvac

# Настройка cron-задания для автоматического запуска каждые 10 минут
setup_cron:
	@echo "⏳ Настраиваем cron..."
	@(crontab -l 2>/dev/null | grep -v 'upload_authorized_keys.yaml'; echo "*/10 * * * * cd $(CURRENT_DIR) && source /opt/ansible_venv/bin/activate && make deploy >> /tmp/deploy.log") | crontab -

.PHONY: deploy create_env setup_cron
