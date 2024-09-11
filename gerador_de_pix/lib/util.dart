String generatePixCode(double? amount) {
  var chavePix = "11111111111"; // Chave Pix (e-mail, CPF, CNPJ, etc.)
  var nomeRecebedor = "Fulano de Tal"; // Nome do recebedor
  var cidadeRecebedor = "Cidade Exemplo"; // Cidade do recebedor
  var transacaoId = "123123"; // Identificador da transação (opcional)

  String pixCode = '';

  // Identificador do Payload Format Indicator
  pixCode += '000201';

  String informacaoConta =
      '0014BR.GOV.BCB.PIX01${chavePix.length.toString().padLeft(2, '0')}$chavePix';
  pixCode +=
      '26${informacaoConta.length.toString().padLeft(2, '0')}$informacaoConta';

  pixCode += '52040000';

  // Transaction Currency (986 = BRL)
  pixCode += '5303986';

  // Valor (amount)
  if (amount != null && amount > 0) {
    String formattedAmount =
        amount.toStringAsFixed(2); // Formata com duas casas decimais
    pixCode +=
        '54${formattedAmount.length.toString().padLeft(2, '0')}$formattedAmount';
  }
  pixCode += '5802BR';
  if (nomeRecebedor.isNotEmpty) {
    pixCode +=
        '59${nomeRecebedor.length.toString().padLeft(2, '0')}$nomeRecebedor';
  } else {
    pixCode += '5901 ';
  }

  if (cidadeRecebedor.isNotEmpty) {
    pixCode +=
        '60${cidadeRecebedor.length.toString().padLeft(2, '0')}$cidadeRecebedor';
  } else {
    pixCode += '6003   '; // Três espaços para cidade mínima
  }

  // Transaction ID
  if (transacaoId.isNotEmpty) {
    pixCode += '62$transacaoId***';
  } else {
    pixCode += '6204***'; // Valor padrão para ID de transação
  }

  // Adicionar CRC (Checksum)
  pixCode += '6304';
  String crc16 = calculateCRC16(pixCode);
  pixCode += crc16;

  return pixCode;
}

String calculateCRC16(String str) {
  int crc = 0xFFFF; // Valor inicial do CRC
  for (int i = 0; i < str.length; i++) {
    crc ^= str.codeUnitAt(i) << 8; // XOR com o byte atual
    for (int j = 0; j < 8; j++) {
      if ((crc & 0x8000) != 0) {
        crc = (crc << 1) ^ 0x1021; // Polinômio CRC16
      } else {
        crc <<= 1;
      }
    }
  }
  // Ajustar o CRC final para garantir que tenha 4 caracteres
  crc &= 0xFFFF; // Limitar a 16 bits
  return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
}
