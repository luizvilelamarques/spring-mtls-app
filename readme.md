# 🚀 Guia de Operação: Microserviço Spring Boot com mTLS

Mutual TLS é uma das bases da arquitetura Zero Trust (Confiança Zero). As principais vantagens são:

Identidade Forte: Não depende apenas de senhas ou tokens que podem ser vazados. A autenticação é baseada em criptografia de chave pública.

Prevenção de Impostores: Mesmo que a URL da sua API seja descoberta, ninguém consegue estabelecer uma conexão sem possuir um certificado de cliente válido e assinado.

Segurança Camada 4: A autenticação acontece no handshake do TCP/SSL, antes mesmo de qualquer dado da requisição HTTP (como headers ou corpo) ser processado pela aplicação.

Ideal para Comunicação Machine-to-Machine (M2M): Excelente para microserviços que precisam conversar entre si com segurança máxima dentro ou fora de um cluster.

Este guia contém os passos consolidados para build, publicação e teste do microserviço utilizando autenticação mTLS.

1. Build e Publicação da Imagem
Utilize o comando abaixo para gerar a imagem e enviá-la ao seu Registry.

Nota: Certifique-se de estar logado (docker login) antes do push.

Bash

# Definir variáveis para facilitar o reuso
$IMAGE_NAME = "seu-usuario/mtls-service:latest"

# Build da imagem
docker build -t $IMAGE_NAME .

# Envio para o Registry (Docker Hub / Nexus / Quay)
docker push $IMAGE_NAME
2. Teste em Ambiente Local (Docker)
Execução do Container
PowerShell

# Subir o container mapeando a porta HTTPS
docker run -d -p 8443:8443 --name mtls-test seu-usuario/mtls-service:latest

# Extrair o certificado de cliente gerado no build para o host Windows
docker cp mtls-test:/app/certs/client.p12 ./client.p12
Validação com cURL (Windows)
PowerShell

# O uso do 'curl.exe' evita conflitos com o alias do PowerShell
curl.exe -v --insecure `
    --cert-type P12 `
    --cert "client.p12:password" `
    https://localhost:8443/hello
3. Teste no Navegador (Chrome / Edge)
Para testar via interface gráfica, o Windows precisa reconhecer a identidade do cliente:

Instalação do Certificado:

Dê um duplo clique em client.p12.

Loja: "Usuário Atual".

Senha: password.

Opção Crítica: Marque "Incluir todas as propriedades estendidas".

Local: Deixe em "Selecionar automaticamente o repositório".

Acesso:

Navegue até https://localhost:8443/hello.

Aceite o aviso de certificado autoassinado (Avançado -> Prosseguir).

Selecione o certificado "client" na janela pop-up que o Chrome exibirá.

4. Implantação e Teste no Kubernetes / OpenShift
Extração do Certificado do Cluster
Como o certificado é gerado no build, precisamos buscar a via que está dentro do Pod rodando no cluster:

PowerShell

# Obter o nome do Pod dinamicamente
$POD_NAME = (kubectl get pods -l app=mtls-app -o jsonpath='{.items[0].metadata.name}')

# Copiar o certificado do Pod para sua máquina local
kubectl cp "${POD_NAME}:/app/certs/client.p12" ./client.p12
Teste da Route (OpenShift com Passthrough)
PowerShell

# Teste via Route externa
curl.exe -v --insecure `
    --cert-type P12 `
    --cert "client.p12:password" `
    https://mtls-app.apps.seu-cluster.exemplo.com/hello
🔒 Melhores Práticas Aplicadas
Isolamento de Certificados: Os certificados foram movidos para /app/certs/ para evitar mistura com arquivos binários da aplicação.

TLS Passthrough: Configuração essencial para que o mTLS não seja "encerrado" no Load Balancer/Router, garantindo segurança end-to-end.

Consistência de Ferramentas: Uso de curl.exe no Windows para garantir compatibilidade com arquivos P12 e evitar comportamentos inesperados do Invoke-WebRequest do PowerShell.