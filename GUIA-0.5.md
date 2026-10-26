# INERTES 0.5 — Depósito de sucata

## Testar
Extraia o ZIP em uma pasta nova. Importe project.godot no Godot e pressione F5.
Escolha seu protagonista. A dupla acompanha e dispara contra inimigos próximos,
mesmo quando o protagonista está fora da máquina.

## Entrar no farm
No início da missão, vá ao círculo azul próximo ao abrigo e pressione **F**.
No depósito, volte ao círculo da esquerda e pressione **F** para retornar à missão.
O progresso dos inimigos e do núcleo da missão fica preservado durante a visita.

## Suprimentos
- Aproxime-se das caixas para recolher automaticamente.
- Sucata: cada coleta vale 5; troque 10 na bancada por um kit e 50 de energia.
- Célula: recupera 30 de energia, até 100.
- Kit: pressione **R** para recuperar até 40 de vida; só consome se houver vida faltando.
- Bancada no setor inferior esquerdo do pátio: aproxime-se e pressione **E**.
- Inimigos derrotados no depósito deixam recursos. Ondas reaparecem quando não há inimigos vivos e o intervalo termina.

## Fusão
Aproxime-se de uma das três máquinas no pátio e pressione **E**:
- Bípede: equilibrado, velocidade 125.
- Flutuante: velocidade 190.
- Cérbero: velocidade 100 e dano aumentado em 30%.
E fora das estações encerra a fusão. A máquina selecionada acompanha o retorno à missão.
A fusão consome 0,5 de energia por segundo. Ao zerar, ela termina.

## Dupla
Dispara automaticamente a até 240 unidades, com intervalo de 0,85 s e 12 de dano.
Os disparos verificam os obstáculos cadastrados no mapa; não atravessam essas paredes.
A dupla acompanha o caminho do jogador e não precisa se fundir.
Nesta versão, não recebe dano e não possui comandos manuais ou inventário próprio.

## Ambientação
Novo cenário do depósito com carros destruídos, árvores enormes caídas e prédios em chamas.
Luzes locais alaranjadas, brasas e fumaça animadas, sombras translúcidas e ordenação por profundidade.
Os efeitos param durante a pausa. Poucas luzes e partículas para manter o protótipo leve.

## Limites do protótipo
A arte de fundo é uma ilustração única; copas e fachadas ainda não são objetos independentes.
As sombras são estilizadas, sem projeção física de cada objeto da imagem.
O depósito tem barreiras nas faixas superior/inferior; colisões detalhadas de carros e árvores ainda precisam ser desenhadas.
Os atores usam poses estáticas com balanço e espelhamento, sem ciclos completos de animação.
O inventário e a seleção não são salvos ao fechar o jogo; reiniciar a missão restaura os recursos iniciais.
F e R usam teclado; os controles antigos de movimento/ataque continuam disponíveis.

## Validação
Godot 4.5.1 headless: 58 verificações originais e testes de seleção, movimento, farm e combate de apoio.
Não houve inspeção gráfica interativa nesta versão: teste o enquadramento e as luzes no seu PC.
