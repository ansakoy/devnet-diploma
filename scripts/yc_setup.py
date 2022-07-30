import json
import logging
import os
from pathlib import Path
import secrets
import sys
from typing import Optional

import environ
import requests

logging.basicConfig(level=logging.INFO, stream=sys.stdout)
logger = logging.getLogger(__name__)

BASE_DIR = Path(__file__).resolve().parent.parent
KEY_FILE_NAME = "key.json"

env = environ.Env(
    YANDEX_PASSPORT_OAUTH_TOKEN=(str, ""),
    FOLDER_ID=(str, ""),
    CLOUD_ID=(str, ""),
    TF_VAR_ACCESS_KEY_ID=(str, ""),
    TF_VAR_ACCESS_KEY_SECRET=(str, ""),
    DOMAIN=(str, ""),
    MYSQL_SLAVE_USER_PASS=(str, ""),
    MYSQL_WP_USER_PASS=(str, ""),
)
environ.Env.read_env(str(BASE_DIR / ".env"))

CONTENT_TYPE_HEADER = {"Content-type": "application/json"}

BASE_URL = "https://iam.api.cloud.yandex.net/iam/v1/"

YANDEX_PASSPORT_OAUTH_TOKEN = env('YANDEX_PASSPORT_OAUTH_TOKEN')
FOLDER_ID = env('FOLDER_ID')
CLOUD_ID = env('CLOUD_ID')
TF_VAR_ACCESS_KEY_ID = env('TF_VAR_ACCESS_KEY_ID')
TF_VAR_ACCESS_KEY_SECRET = env('TF_VAR_ACCESS_KEY_SECRET')
DOMAIN = env('DOMAIN')
MYSQL_SLAVE_USER_PASS = env('MYSQL_SLAVE_USER_PASS')
MYSQL_WP_USER_PASS = env('MYSQL_WP_USER_PASS')

WP_AUTH_KEY = "wp_auth_key"
WP_SECURE_AUTH_KEY = "wp_secure_auth_key"
WP_LOGGED_IN_KEY = "wp_logged_in_key"
WP_NONCE_KEY = "wp_nonce_key"
WP_AUTH_SALT = "wp_auth_salt"
WP_SECURE_AUTH_SALT = "wp_secure_auth_salt"
WP_LOGGED_IN_SALT = "wp_logged_in_salt"
WP_NONCE_SALT = "wp_nonce_salt"


# Вспомогательные функции

def load_json(source: str) -> None:
    """Загрузить файл JSON
    """
    with open(source, 'r', encoding="utf8") as handler:
        return json.load(handler)


def dump_json(dictionary: dict, json_file: str) -> None:
    """Записать словарь в виде файла json
    """
    with open(json_file, 'w', encoding='utf-8') as handler:
        json.dump(dictionary, handler, ensure_ascii=False, indent=2)


class YandexCloudConfig:
    def __init__(self, oauth_token, folder_id, sa_name):
        self.oauth_token = oauth_token
        self.folder_id = folder_id
        self.base_url = BASE_URL
        self.iam_token = self._get_iam_token()
        self.headers = {"Authorization": f"Bearer {self.iam_token}", "Content-type": "application/json"}
        self.sa_name = sa_name
        self.sa_id = self._get_or_create_service_account_id(self.sa_name)
        self.key_path = os.path.join(BASE_DIR, KEY_FILE_NAME)

    def _get_iam_token(self) -> Optional[str]:
        """ Обменять OAuth токен на IAM токен
        https://cloud.yandex.ru/docs/iam/concepts/authorization/iam-token
        https://cloud.yandex.ru/docs/iam/operations/iam-token/create
        """
        logger.info("Getting IAM token...")
        data = {"yandexPassportOauthToken": self.oauth_token}
        url = f"{self.base_url}tokens"
        response = requests.post(url=url, data=json.dumps(data))
        status_code = response.status_code
        if status_code == 200:
            logger.info("  -> IAM token received.")
            return response.json().get("iamToken")
        logger.info(f"status_code: {status_code}\n{response.text}")

    def _get_or_create_service_account_id(self, name: str) -> Optional[str]:
        """Получить ID сервисного аккаунта
        https://cloud.yandex.ru/docs/iam/api-ref/ServiceAccount/list
        https://cloud.yandex.ru/docs/iam/api-ref/ServiceAccount/create
        https://cloud.yandex.ru/docs/iam/operations/sa/create
        """
        logger.info(f"Getting id for service account named {name}...")
        url = f"{self.base_url}serviceAccounts"

        # Если аккаунт с таким именем существует, используем его
        sa_response = requests.get(url=url, headers=self.headers, params={"folderId": FOLDER_ID})
        if sa_response.status_code == 200:
            accounts = sa_response.json()["serviceAccounts"]
            for account in accounts:
                if account["name"] == self.sa_name:
                    sa_id = account["id"]
                    logger.info(f"  -> Service account {self.sa_name} already exists, id: {sa_id}")
                    return sa_id

        # Если такого аккаунта нет, создаем новый
        logger.info(f"  -> Service account {name} does not exist, creating...")
        data = {
            "folderId": FOLDER_ID,
            "name": self.sa_name,
            "description": "This is my new service account",
        }
        sa_response = requests.post(url=url, headers=self.headers, data=json.dumps(data))
        if sa_response.status_code == 200:
            sa_id = sa_response.json()["id"]
            logger.info(f"  -> Success: created service account {self.sa_name}, id: {sa_id}")
            return sa_id

        print(sa_response.status_code)
        print(sa_response.text)

    def add_sa_role(self, role: str) -> None:
        """Добавить роль сервисному аккаунту
        https://cloud.yandex.ru/docs/iam/operations/sa/assign-role-for-sa
        """
        logger.info(f"Adding role {role} for service account with id {self.sa_id}...")
        url = f"https://resource-manager.api.cloud.yandex.net/resource-manager/v1/folders/{self.folder_id}:updateAccessBindings"

        data = {
            "accessBindingDeltas": [
                {
                    "action": "ADD",
                    "accessBinding": {
                        "roleId": role,
                        "subject": {
                            "id": self.sa_id,
                            "type": "serviceAccount"
                        }
                    }
                }
            ]
        }
        response = requests.post(url=url, data=json.dumps(data), headers=self.headers)
        if response.status_code == 200:
            logger.info(f"  -> Success: Added role {role} to service account {self.sa_name}, id: {self.sa_id}")
            return
        print(response.status_code)
        print(response.text)

    def generate_sa_key(self) -> None:
        """Сгенерировать ключи для сервисного аккаунта
        https://cloud.yandex.ru/docs/iam/api-ref/Key/create
        """
        logger.info(f"Generating key pair for service account {self.sa_name} with id {self.sa_id}...")
        url = f"{BASE_URL}keys"
        data = {"serviceAccountId": self.sa_id}
        response = requests.post(url=url, data=json.dumps(data), headers=self.headers)
        if response.status_code == 200:
            data = response.json()
            # Яндекс, а трудно было вернуть в ответе именно тот джейсон, который требуется для файла?
            key = {
                "id": data["key"]["id"],
                "service_account_id": data["key"]["serviceAccountId"],
                "created_at": data["key"]["createdAt"],
                "key_algorithm": data["key"]["keyAlgorithm"],
                "public_key": data["key"]["publicKey"],
                "private_key": data["privateKey"],
            }
            dump_json(key, self.key_path)
            logger.info(f"  -> Success: saved key to {self.key_path}")
            return
        print(response.status_code)
        print(response.text)

    def generate_variables_tf(self) -> None:
        """Сгенерировать файл terraform/variables.tf, содержащий все необходимые переменные
        """
        vars = [
            {"yc_cloud_id": {"default": CLOUD_ID, "description": "ID облака"}},
            {"yc_folder_id": {"default": self.folder_id, "description": "ID каталога"}},
            {"yc_sa_account": {"default": self.sa_id, "description": "ID сервисного аккаунта"}},
            {"yc_sa_key_path": {"default": self.key_path, "description": "Путь к ключу сервисного аккаунта"}},
            {"yc_zone_1a": {"default": "ru-central1-a", "description": "Зона доступности A"}},
            {"yc_zone_1b": {"default": "ru-central1-b", "description": "Зона доступности B"}},
            {"access_key_id": {"default": "", "description": "Access key для бакета"}},
            {"access_key_secret": {"default": "", "description": "Secret для access key бакета"}},
            {"domain": {"default": DOMAIN, "description": "Домен, на котором будут создаваться поддомены"}},
            {"ubuntu2004": {"default": "fd8f1tik9a7ap9ik2dg1", "description": "Образ Убунту 20.04"}},
            {"ubuntu1804": {"default": "fd84mnpg35f7s7b0f5lg", "description": "Образ Убунту 18.04"}},
            {"ssh_key_file": {"default": "~/.ssh/id_ed25519", "description": "Ключ SSH"}},
            {"mysql_slave_user_pass": {"default": MYSQL_SLAVE_USER_PASS, "description": "Пароль для реплики MySQL"}},
            {"mysql_wp_user_pass": {"default": MYSQL_WP_USER_PASS, "description": "Пароль для юзера wordpress"}},
            {WP_AUTH_KEY: {"default": secrets.token_urlsafe(64), "description": "Wordpress secret key"}},
            {WP_SECURE_AUTH_KEY: {"default": secrets.token_urlsafe(64), "description": "Wordpress secret key"}},
            {WP_LOGGED_IN_KEY: {"default": secrets.token_urlsafe(64), "description": "Wordpress secret key"}},
            {WP_NONCE_KEY: {"default": secrets.token_urlsafe(64), "description": "Wordpress secret key"}},
            {WP_AUTH_SALT: {"default": secrets.token_urlsafe(64), "description": "Wordpress secret key"}},
            {WP_SECURE_AUTH_SALT: {"default": secrets.token_urlsafe(64), "description": "Wordpress secret key"}},
            {WP_LOGGED_IN_SALT: {"default": secrets.token_urlsafe(64), "description": "Wordpress secret key"}},
            {WP_NONCE_SALT: {"default": secrets.token_urlsafe(64), "description": "Wordpress secret key"}},
        ]
        block = 'variable "{var_name}" {{\n  type = string\n  default = ' \
                '"{default}"\n  description = "{description}"\n}}\n\n'
        fname = os.path.join(BASE_DIR, "terraform", "variables.tf")
        code = "# This file was autogenerated as a result of setting up a YC account\n\n"
        for var in vars:
            var_name = list(var.keys())[0]
            code += block.format(
                var_name=var_name,
                default=var[var_name]["default"],
                description=var[var_name]["description"],
            )

        with open(fname, "w", encoding="utf-8") as handler:
            handler.write(code)


def init_terraform_with_bucket() -> None:
    """Инициализировать терраформ с бакетом. Вносится в скрипт, потому что так проще всего передать
    ему переменные через .env. Нормальным образом через variable значения не принимаются.
    """
    logger.info(f"Running terraform init with variables for bucket...\n")
    command = 'cd {} && terraform init \\\n    ' \
              '-backend-config="access_key=${}" \\\n    ' \
              '-backend-config="secret_key=${}"'.format(
                            os.path.join(BASE_DIR, "terraform"),
                            TF_VAR_ACCESS_KEY_ID,
                            TF_VAR_ACCESS_KEY_SECRET,
                        )
    os.system(command)


if __name__ == '__main__':
    yacl = YandexCloudConfig(YANDEX_PASSPORT_OAUTH_TOKEN, FOLDER_ID, "hey-sa")
    # # yacl.add_sa_role("editor")
    yacl.generate_sa_key()
    yacl.generate_variables_tf()
    # init_terraform_with_bucket()

