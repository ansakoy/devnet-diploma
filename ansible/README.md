# Роли и сценарий Ansible

Файл inventory генерируется по итогам отработки терраформа (inventory.tf заполняет 
шаблон inventory.tmpl).

Автономный запуск:

```
ansible-playbook -i inventory.ini provision.yml
```
* Настраивает jump-сервер (reverse-proxy) с публичным адресом
* Устанавливает сертификаты Letsencrypt
* Устанавливает MySQL, настраивает репликацию (в общей сложности 2 ноды)
* Устанавливает Wordpress
* Устанавливает Gitlab и runner
* Устанавливает стек мониторинга (Node Exporter на все машины, Prometheus, Grafana, Alertmanager)


