from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

def get_secret(secret_name):
    credential = DefaultAzureCredential()
    client = SecretClient(
        vault_url="https://crime-analysis-kv.vault.azure.net",
        credential=credential
    )
    return client.get_secret(secret_name).value

if __name__ == "__main__":
    print(get_secret("OPENAI-API-KEY"))
