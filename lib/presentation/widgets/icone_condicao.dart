import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/condicao_tempo.dart';

class IconeCondicao extends StatelessWidget {
  const IconeCondicao(this.condicao, {super.key, this.tamanho = 24});

  final CondicaoTempo condicao;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final (icone, claro, noEscuro) = switch (condicao.grupo) {
      GrupoTempo.sol => (CupertinoIcons.sun_max, 0xFFD98E04, 0xFFF5B83D),
      GrupoTempo.parcialmenteNublado => (CupertinoIcons.cloud_sun, 0xFF5F7182, 0xFFA9B8C6),
      GrupoTempo.nublado => (CupertinoIcons.cloud, 0xFF66707C, 0xFFA2ABB5),
      GrupoTempo.chuvisco => (CupertinoIcons.cloud_drizzle, 0xFF3F7FBF, 0xFF7DB3F5),
      GrupoTempo.chuva => (CupertinoIcons.cloud_rain, 0xFF1D6FC2, 0xFF6CB4F7),
      GrupoTempo.pancadas => (CupertinoIcons.cloud_heavyrain, 0xFF1D6FC2, 0xFF6CB4F7),
      GrupoTempo.tempestade => (CupertinoIcons.cloud_bolt_rain, 0xFF5B4BB7, 0xFFA99BF2),
      GrupoTempo.nevoeiro => (CupertinoIcons.cloud_fog, 0xFF6F7780, 0xFFA2ABB5),
      GrupoTempo.geada => (CupertinoIcons.thermometer_snowflake, 0xFF2B8AA6, 0xFF7CCBE0),
      GrupoTempo.neve => (CupertinoIcons.snow, 0xFF2B8AA6, 0xFF7CCBE0),
      GrupoTempo.indefinido => (CupertinoIcons.question_circle, 0xFF8A929C, 0xFF7D858F),
    };

    return Icon(
      icone,
      size: tamanho,
      color: Color(escuro ? noEscuro : claro),
      semanticLabel: condicao.descricao,
    );
  }
}
