import requests
import json
import time

class PushNotificationSender:
    def __init__(self):
        self.project_id = "push-5b79c"  # Substitua pelo seu Project ID
        self.access_token = "ya29.c.c0ASRK0Ga5YVrWH8SQ1U5xuWAPueZANi7QBG4YAQ32QQK9f0VYJqNIvSc2yBeI5pYPkliFF3Jbl79yrr958u0PXrBWlq9PXNOF-tNu8KiqQsRnAVzUqTChzDPk_9TzPmYhSzAWqUCL-SOFnskH5_4jrJA-9HkIJaLOo_vt253GIWZLl0CzyxfjuObAesQ2UV4sO0unhDTUH0nCjzSJ6bgmPGHD0ZEdbaEXrJxuktfePQ7_-Dw_KBCSCCfp7YJ2peZHjEnv8bTjVvsUsk7w3kvSPT8fHKTrmkGM0HgyB2fR8dazRa1AEoKbdtaUCbY5n10-2nPpdoIiUefEPzNOdksN1EGZck2WVByxBWCSmq69fzAadEct_Kz6Hj6qN385COYyv4xo4gV47eYupryF-oxySBy2UU0kpoVl5y--44_tVd_opjdebBgc0hQmd_mS3tUIoqJybYl557ycmc_7a3kMhrZFV4o0vMb09Q3aoSr6jb9bdOpkBiS6oSl3FnBVy7ki75p5YnW63XtWIy8o-XvR-lfwYOMl3-sS9WMiqlhhM-k75UJzoBVhSr0wc7wyd_cU6iuhzc8j4dsqggWwe2Yme_cWel1pixsB-kB34nhzBc8xh9ukozWBifSfmRj3610n2nMmz1uh8YpZoq8UxwQ5IY46deJl-0Ubu10-mk-UzFvpr9igpzq423d6hVg_dzB0X8qvfbZ33bkB4yaQ7XgyqWBsQ8pjrWzoZna69uXvvydhb_V-QrZfMpir2p10U2w3as73j5V-0ncJmqMfZ4-rph7Jz7R2_zlx5VUrWgrujplo84rXjcx0QF1eaz0auJf8YIuwb8yX1jj3R7uIWywz6hZZm_IgkMqj7oR0Svqesl4l8ad1jsMylac_Uc4zbQhsy87jVscdmqlMd1e9a5JnVFcBi5m3bOxkzlMZZ8ydnt6ufY57rhuu-msykk2pwm5r_VgWmgbpUO5_inz9QIt8a8SBJZpRXl18y0lM3izSn5R6tmtbSsWMaWw"  # Substitua pelo seu Access Token
        self.fcm_url = f"https://fcm.googleapis.com/v1/projects/{self.project_id}/messages:send"

    def send_notification(self, title, body, delay_in_seconds=0):
        headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {self.access_token}'
        }

        body_data = {
            "message": {
                "topic": "all",  # Envia para todos os dispositivos inscritos no tópico "all"
                "notification": {
                    "title": title,
                    "body": body
                }
            }
        }

        # Atraso opcional antes do envio
        if delay_in_seconds > 0:
            time.sleep(delay_in_seconds)

        try:
            response = requests.post(self.fcm_url, headers=headers, data=json.dumps(body_data))

            if response.status_code == 200:
                print("Notificação enviada com sucesso!")
                print("Resposta do FCM:", response.json())
            else:
                print(f"Erro ao enviar notificação: {response.status_code}")
                print("Resposta:", response.json())
        except Exception as e:
            print(f"Erro durante o envio da notificação: {e}")

# Teste
if __name__ == "__main__":
    sender = PushNotificationSender()

    # Configuração dos dados da notificação
    notification_title = "pelo python"
    notification_body = "Essa é uma mensagem de teste."
    delay_seconds = 5  # Envia após 5 segundos

    # Envia a notificação
    sender.send_notification(notification_title, notification_body, delay_seconds)
