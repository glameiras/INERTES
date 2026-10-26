# Versão atual: 0.6

Consulte GUIA-0.6.md para profundidade, itens e ciclo dia/noite.

# Versão atual: 0.5

Veja GUIA-0.5.md para farm, suprimentos, fusões e combate da dupla.

# INERTES — versão 0.4: personagens e máquinas

## Abrir no Windows
1. Extraia este ZIP em uma pasta nova.
2. No Godot, importe o arquivo project.godot desta pasta.
3. Aguarde a importação das imagens e pressione F5.
4. Clique no homem ou na mulher. O outro personagem será sua dupla.

## Refinamento 0.4
- Protagonistas 25% menores: altura de desenho de 96 para 72 pixels.
- Bípedes e flutuantes nos inimigos; Cérbero como chefe.
- Inerte e fusão usam arte do bípede, com tonalidade e aro azul para identificação.
- Aceleração e parada progressivas; dupla desacelera ao se aproximar.
- Balanço de caminhada, respiração, flutuação, inclinação de ataque e sombras.
- São animações por transformação de poses estáticas, não ciclos com quadros de pernas/braços.
- Novos testes de aceleração, parada, pausa e variantes em tests/movimento.gd.

## O que mudou
- Tela inicial com as duas artes aprovadas, seleção por clique ou foco e Enter.
- O personagem escolhido usa sua imagem no mapa; o outro acompanha o caminho percorrido.
- A escolha é mantida ao reiniciar a missão. Após vitória ou derrota, Enter retorna à seleção.
- Cenário enviado mantido, com limite inferior da câmera ajustado à altura da imagem.
- Imagens PNG com canal alfa real em assets/personagens.

## Limites desta versão
- Artes de pose única com movimento por transformação e espelhamento; ainda não há ciclos por quadros.
- A dupla segue o jogador, mas ainda não combate, recebe dano ou tem diálogos próprios.
- A fusão usa agora a arte detalhada do bípede.
- As colisões originais do protótipo foram preservadas: ainda não correspondem exatamente aos carros e prédios da ilustração.
- A seleção vale para a sessão; ainda não existe salvamento de campanha.

## Validação
Testes executados em Godot 4.5.1 headless; projeto enviado originalmente em Godot 4.7.2.
Testes: tests/smoke.gd (regras originais) e tests/dupla.gd (seleção, dupla, pausa e reinício).

---
Documentação anterior:

# INERTES: Chuva de Ferro — protótipo 0.2

Universo e lore: Gustavo Lameiras. Título provisório.
Implementação criada com assistência de IA.

## Abrir no Windows

1. Baixe Godot **Standard** 4.4.1 (ou 4.x compatível) em https://godotengine.org/download/archive/4.4.1-stable/ (não precisa da edição .NET).
2. Extraia este ZIP inteiro para uma pasta.
3. Abra o Godot, escolha **Importar** e selecione `project.godot` dentro da pasta INERTES.
4. Pressione **F5** para executar. Na tela inicial, Enter (teclado) ou A (controle).

Não inclui .exe pronto. Não requer assets, plugins ou pacotes externos.

## Controles

| Ação | Teclado | Controle (layout Xbox) |
|---|---|---|
| Mover / orientar | WASD ou setas | Analógico esquerdo ou direcional |
| Atacar | J | X |
| Esquivar (25 de fôlego) | Espaço | A |
| Fundir / sair / recolher núcleo | E | Y |
| Pausar | Esc | Start |
| Iniciar / reiniciar | Enter | A |

As dicas na tela trocam sozinhas entre teclado e controle conforme o último dispositivo usado.

## Refinamento 0.4
- Protagonistas 25% menores: altura de desenho de 96 para 72 pixels.
- Bípedes e flutuantes nos inimigos; Cérbero como chefe.
- Inerte e fusão usam arte do bípede, com tonalidade e aro azul para identificação.
- Aceleração e parada progressivas; dupla desacelera ao se aproximar.
- Balanço de caminhada, respiração, flutuação, inclinação de ataque e sombras.
- São animações por transformação de poses estáticas, não ciclos com quadros de pernas/braços.
- Novos testes de aceleração, parada, pausa e variantes em tests/movimento.gd.

## O que mudou da 0.1 para a 0.2

**Entrada.** Tudo usa ações do InputMap (`scripts/controles.gd`), com teclado e controle. Isso prepara o menu de remapeamento.

**Estrutura.** O arquivo único `game.gd` foi dividido:

| Arquivo | Responsabilidade |
|---|---|
| `scripts/jogo.gd` | Estados, entrada, objetivo e ligação entre as peças |
| `scripts/jogador.gd` | Movimento, ataque, esquiva, vida |
| `scripts/inimigo.gd` | Inimigo comum e Soberano (preparar, golpear, recuperar) |
| `scripts/mundo.gd` | Cenário e colisão (desenha uma vez só) |
| `scripts/hud.gd` | Interface e telas de título/pausa/fim |
| `scripts/efeitos.gd` | Partículas e sons (agora com cache e vários players) |
| `scripts/config.gd` | **Todos os números de balanceamento** |
| `cenas/*.tscn` | Jogador, Inimigo, Inerte e Hud como cenas editáveis |

**Combate** (valores em `scripts/config.gd`):

- Dano do Sucateiro sem fusão: 16 → 20. Vida do Soberano: 280 → 240. A fusão continua sendo vantagem, mas deixa de ser obrigatória.
- Buffer de ataque: apertar o botão até 0,15 s antes do fim da recarga ainda conta.
- A área vermelha dos golpes inimigos agora "enche" durante a preparação, mostrando quando o golpe cai.
- Inimigos tentam desviar de obstáculos e não ficam mais empilhados (navegação ainda simples).
- Corrigido: fundir perto de uma parede podia prender o personagem; agora ele é empurrado para um ponto livre.

## Validação

**Esta versão ainda não foi executada no Godot.** O código foi escrito e revisado sem acesso ao editor. A lógica de desvio dos inimigos foi simulada à parte, mas o resto precisa de uma primeira execução sua.

Para rodar os testes de regras:

```
godot --headless --path . --script res://tests/smoke.gd
```

Sai com "PASSOU: N verificações" ou lista o que falhou. Se aparecer erro de sintaxe ao importar, copie a mensagem completa para ajustar.

## Limitações conhecidas

- Arte e sons provisórios; sem animações.
- Navegação dos inimigos ainda básica (trocar por NavigationAgent2D quando houver mapas maiores).
- Sem save, menu de opções, remapeamento em tela, A.I.R. e Culto ao Núcleo.
- Rótulos de controle seguem o layout Xbox.
- Sem integração Steam. Nenhuma publicação foi feita.

## Próximas etapas

1. Rodar o teste e jogar no PC; ajustar `config.gd` conforme a sensação.
2. Aprovar perspectiva, escala dos personagens e direção de arte.
3. Missão de 10 a 15 minutos com diálogos e identidade dos Sucateiros.
4. Menu de opções com remapeamento, volume e salvamento.
5. Exportação desktop, testes externos e materiais de loja.
