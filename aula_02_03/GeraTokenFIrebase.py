from google.oauth2 import service_account
import google.auth.transport.requests

def get_access_token(service_account_file):
    # Lê a chave da conta de serviço e gera um Access Token
    credentials = service_account.Credentials.from_service_account_file(
        service_account_file,
        scopes=["https://www.googleapis.com/auth/firebase.messaging"]
    )
    request = google.auth.transport.requests.Request()
    credentials.refresh(request)  # Atualiza o token
    return credentials.token

# Caminho para o arquivo JSON da conta de serviço
service_account_file = "D:\\Users\\vinic\\Downloads\\push-5b79c-79466f1af8f5.json"  # Substitua pelo caminho do seu arquivo

# Obtém e exibe o Access Token
access_token = get_access_token(service_account_file)
print("Access Token:", access_token)
