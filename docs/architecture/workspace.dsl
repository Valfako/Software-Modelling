workspace "Marketplace B2B de Sobras" "Arquitetura de cadastro PJ e validação da Licença Ambiental (UC01 e UC02)." {

    model {
        empresa = person "Empresa (PJ)" "Pessoa jurídica que deseja negociar sobras e materiais reutilizáveis."

        marketplace = softwareSystem "Marketplace B2B de Sobras" "Plataforma para negociação B2B de sobras industriais." {
            web = container "Interface Web" "Formulário de cadastro PJ, envio de documentos e acompanhamento do processo." "React.js"
            acesso = container "Componente de Acesso / API" "Autenticação, autorização e coordenação dos casos de uso UC01 e UC02." "Node.js, REST, HTTPS"
            empresas = container "Serviço de Empresas" "Gerencia a entidade Empresa e as regras cadastrais de CNPJ e CNAE." "Node.js"
            ambiental = container "Serviço Ambiental" "Gerencia LicencaAmbiental e o processo de validação da LO." "Node.js"
            banco = container "Banco de Dados" "Armazena empresas, licenças, estados e a tabela Outbox; os dados são separados por schemas." "PostgreSQL 16"
            fila = container "Mensageria" "Distribui eventos de aprovação e pendência sem bloquear as requisições." "RabbitMQ, AMQP 0-9-1"
            notificacao = container "Serviço de Notificação" "Consome eventos e solicita o envio de notificações." "Node.js"
        }

        receita = softwareSystem "Provedor de Consulta CNPJ" "Serviço externo autorizado para consulta da situação cadastral e CNAE."
        orgao = softwareSystem "Provedor de Consulta Ambiental" "Serviço externo autorizado para consulta da situação da Licença Ambiental de Operação."
        email = softwareSystem "Provedor de E-mail" "Serviço externo utilizado para entrega de notificações às empresas."

        empresa -> web "Acessa e preenche o cadastro" "HTTPS"
        web -> acesso "Envia CadastroPJDTO e LicencaDTO" "HTTPS / JSON"
        acesso -> empresas "Coordena UC01 e operações cadastrais" "REST / HTTP"
        acesso -> ambiental "Coordena UC02 e validação da LO" "REST / HTTP"
        empresas -> banco "Persiste Empresa e registros Outbox" "SQL / TCP"
        ambiental -> banco "Persiste LicencaAmbiental e registros Outbox" "SQL / TCP"
        empresas -> receita "Consulta CNPJ e CNAE" "HTTPS / REST"
        ambiental -> orgao "Consulta situação da LO" "HTTPS / REST"
        empresas -> fila "Publica evento EmpresaAprovada" "AMQP"
        ambiental -> fila "Publica evento PendenciaAmbiental" "AMQP"
        fila -> notificacao "Entrega eventos para consumo" "AMQP"
        notificacao -> email "Solicita envio de e-mail" "HTTPS / API"
    }

    views {
        container marketplace "Containers" {
            include *
            autolayout lr
        }

        styles {
            element "Person" {
                shape person
                background "#08427B"
                color "#FFFFFF"
            }
            element "Software System" {
                background "#1168BD"
                color "#FFFFFF"
            }
            element "Container" {
                background "#438DD5"
                color "#FFFFFF"
            }
        }
    }
}
