/// Gerador PROCEDURAL de frases de foco/estudos — SEM IA, offline e sem custo.
///
/// Combina abertura + verdade + fecho para MILHARES de frases únicas
/// (16 × 16 × 12 = 3.072). A "frase do dia" é determinística (muda a cada dia).
class GreetingGenerator {
  GreetingGenerator._();

  static const List<String> _open = [
    'Lembre-se hoje:',
    'Foco no objetivo:',
    'Pra estudar melhor:',
    'No seu dia de estudos:',
    'Antes de abrir o material:',
    'Quando bater a preguiça:',
    'Pra não perder o ritmo:',
    'Concurseiro, anota:',
    'Hoje a meta é clara:',
    'Mantenha em mente:',
    'A cada hora de estudo:',
    'Na rota da aprovação:',
    'Quando a vontade sumir:',
    'No caminho do edital:',
    'Pra render mais:',
    'A disciplina diz:',
    'Pra vencer hoje:',
    'Foque nisto:',
    'Coragem, concurseiro:',
    'A sua meta pede:',
    'No silêncio do estudo:',
    'Pra chegar na vaga:',
  ];

  static const List<String> _core = [
    'cada página estudada hoje é um ponto a mais na prova',
    'constância vence o talento que não estuda',
    'foco não é fazer tudo, é fazer o que importa',
    'a aprovação é a soma de pequenos dias bem feitos',
    'quem persiste no edital chega na posse',
    'disciplina hoje é liberdade amanhã',
    'estudar cansado ainda conta; desistir não',
    'revisar é onde a memória de verdade acontece',
    'a sua única concorrência é a sua versão de ontem',
    'a vaga é de quem não larga o cronograma',
    'errar questão é aprender de graça antes da prova',
    'o desconforto de estudar é o preço da estabilidade',
    'mente descansada aprende mais rápido',
    'pequenos blocos de foco constroem grandes resultados',
    'o sonho da aprovação cabe em um dia de cada vez',
    'quem controla a rotina controla o resultado',
    'cada simulado te deixa mais perto do gabarito',
    'estabilidade é fruto de quem não para',
    'a aprovação prefere a rotina à inspiração',
    'o edital recompensa a consistência',
    'foco é dizer não pro que não te aprova',
    'você está a um ciclo de revisão da virada',
  ];

  static const List<String> _close = [
    'Bora estudar!',
    'Foco e fé.',
    'Você consegue.',
    'Segue firme.',
    'Rumo à aprovação!',
    'Não desista.',
    'Constância sempre.',
    'Um dia de cada vez.',
    'A posse te espera.',
    'Mãos à obra.',
    'Disciplina vence.',
    'Hoje conta muito.',
    'Fé no edital!',
    'A vaga é sua.',
    'Sem desculpas hoje.',
    'Persiste e conquista.',
  ];

  static int get total => _open.length * _core.length * _close.length;

  static String byIndex(int i) {
    final n = i.abs();
    final o = _open[n % _open.length];
    final c = _core[(n ~/ _open.length) % _core.length];
    final f = _close[(n ~/ (_open.length * _core.length)) % _close.length];
    return '$o $c. $f';
  }

  /// Frase do dia (determinística).
  static String ofNow([DateTime? date]) {
    final d = date ?? DateTime.now();
    final dayIndex =
        DateTime(d.year, d.month, d.day).difference(DateTime(2020, 1, 1)).inDays;
    return byIndex(dayIndex * 7919);
  }
}
