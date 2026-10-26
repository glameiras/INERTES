# INERTES 0.6 — Profundidade, suprimentos e noite

Extraia em uma pasta nova e importe project.godot. F5 inicia.

## Profundidade do depósito
Entrada, bancada, estações e loot foram movidos para o pátio livre.
Barreiras bloqueiam as áreas de carros nas laterais, fachadas e vegetação inferior.
Uma camada frontal reutiliza a parte inferior do cenário: personagens passam atrás da copa ao se aproximar.
O fundo continua sendo uma ilustração. Este é um primeiro recorte por faixa; não há recorte individual de cada folha ou carro.
As colisões da missão original continuam provisórias; as novas barreiras são do depósito.

## Suprimentos com ícones
Ferragens: coletadas como sucata, prontas como recurso para futuras melhorias de reparo.
Célula de regeneração: +30 energia e +10 vida, limitadas a 100.
Kit médico: R recupera até 40 vida.
Kit de munição: +24 disparos de apoio da dupla.
A dupla consome um projétil por disparo e para de atirar sem munição.
A bancada ainda troca 10 ferragens por um kit e 50 energia. Não existe durabilidade/reparo individual dos robôs nesta versão.

## Relógio
Começa às 17h30. Uma hora no jogo dura dois minutos reais.
A luz diminui progressivamente até 18h30. Entre 18h30 e 06h as máquinas usam modo noturno:
alcance de detecção 65% maior, preparo de ataque 20% mais curto e indicação verde.
Este modo representa sensores de visão noturna, não um filtro verde sobre toda a tela.
O tempo congela na pausa e reinicia ao começar uma nova missão; permanece ao trocar de área.

## Comandos
F junto ao círculo: entrar ou voltar do depósito.
E junto às estações: escolher fusão. E na bancada: trocar materiais.
R: kit médico. WASD/setas: andar. J: atacar. Espaço: esquivar. Esc: pausar.

## Validação
Testes headless de ciclo, barreiras, loot, munição, troca de áreas, combate da dupla e regras originais.
Inspeção gráfica interativa ainda precisa ser feita no PC do jogador.
