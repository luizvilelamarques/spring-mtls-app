# 🛡️ Guia: Usando Certificados Próprios (Customizados)
Use seus próprios certificados em vez dos certificados gerados automaticamente pela imagem Docker. Isso é essencial para garantir que cada ambiente (Produção, Homologação, Cliente A, Cliente B) possua identidades digitais exclusivas.

1. Requisitos
Java JDK instalado (para usar o comando keytool).

A imagem Docker do microserviço já publicada no seu registry.

2. Gerando as Novas Chaves (Powershell)
Crie uma pasta local para armazenar as chaves e execute os comandos abaixo para gerar um par de chaves e a confiança (truststore) com uma senha personalizada.

PowerShell

# 1. Criar pasta e acessar
mkdir certs-cliente; cd certs-cliente

# 2. Gerar Keystore do Servidor (Identidade da API)
keytool -genkeypair -alias server-alias -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore keystore.p12 -validity 365 -dname "CN=api.cliente.com" -storepass minha-senha-segura -keypass minha-senha-segura

# 3. Gerar Chave do Cliente (Identidade do Usuário/App que consome)
keytool -genkeypair -alias client-alias -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore client.p12 -validity 365 -dname "CN=app-cliente" -storepass minha-senha-segura -keypass minha-senha-segura

# 4. Exportar certificado do cliente para importar no Truststore do servidor
keytool -exportcert -alias client-alias -file client.crt -keystore client.p12 -storepass minha-senha-segura

# 5. Criar Truststore (Lista de quem o servidor confia)
keytool -importcert -alias client-alias -file client.crt -keystore truststore.p12 -storepass minha-senha-segura -noprompt

3. Rodando o Docker com Injeção de Volume
Agora, utilizaremos o conceito de Bind Mount para sobrepor os certificados da imagem pelos seus novos arquivos locais. Também utilizaremos Variáveis de Ambiente para informar ao Spring Boot as novas senhas.

Execute o comando na pasta onde os certificados foram gerados:

CMD

docker run -d -p 8443:8443 --name mtls-custom -v "%cd%:/app/certs" -e SERVER_SSL_KEY_STORE_PASSWORD=minha-senha-segura -e SERVER_SSL_TRUST_STORE_PASSWORD=minha-senha-segura seu-usuario/mtls-service:latest

PowerShell

docker run -d -p 8443:8443 --name mtls-custom -v "${PWD}:/app/certs" -e SERVER_SSL_KEY_STORE_PASSWORD=minha-senha-segura -e SERVER_SSL_TRUST_STORE_PASSWORD=minha-senha-segura   seu-usuario/mtls-service:latest


4. Testando a Nova Identidade
Como a senha e os arquivos mudaram, o teste via curl deve refletir essas mudanças:

PowerShell

curl.exe -v --insecure --cert-type P12 --cert "client.p12:minha-senha-segura" https://localhost:8443/hello