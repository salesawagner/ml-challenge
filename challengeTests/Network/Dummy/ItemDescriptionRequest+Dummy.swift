//
//  ItemDescriptionRequest+Dummy.swift
//  challenge
//
//  Created by Wagner Sales on 05/12/25.
//

@testable import challenge

extension ItemDescriptionRequest {
    static var dummy: ItemDescriptionRequest {
        return .init(itemId: "12345")
    }
}

extension ItemDescriptionResponse {
    static var expected: String {
        "O Protetor de Cabeca para Motocicleta da marca Capacete Plus é a escolha ideal para quem busca seguranca e conforto durante suas viagens. Com um design aerodinamico, ele proporciona uma excelente protecao sem comprometer a visibilidade. Seu peso leve de apenas 157 g garante que voce possa usá-lo por longos períodos sem desconforto.\n\nAs dimensoes da embalagem sao cuidadosamente projetadas, com 27 cm de altura, 23 cm de largura e 6 cm de comprimento, facilitando o armazenamento e o transporte. A embalagem adicional oferece uma protecao extra, assegurando que o produto chegue em perfeitas condicoes. Este protetor é perfeito para motociclistas que valorizam tanto a seguranca quanto a praticidade.\n\nCom um design moderno e funcional, o Protetor de Cabeca para Motocicleta é ideal para quem deseja se destacar nas estradas. A qualidade dos materiais utilizados garante durabilidade e resistencia, tornando-o um investimento seguro para suas aventuras sobre duas rodas. Escolha Capacete Plus e experimente a diferenca em cada viagem."
    }
}
