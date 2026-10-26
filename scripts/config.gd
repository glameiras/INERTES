extends RefCounted
## Balanceamento e constantes do protótipo.
## Todos os números de jogo ficam aqui: ajuste depois de testar no PC.

# --- Mundo ---
const MUNDO := Vector2(1600, 960)
const SPAWN := Vector2(150, 480)
const NUCLEO := Vector2(1420, 480)
const INERTE_INICIAL := Vector2(330, 480)
const DISTANCIA_INTERACAO := 55.0
const RAIO_ABRIGO := 65.0

# --- Jogador ---
const VIDA_MAX := 100.0
const FOLEGO_MAX := 100.0
const FOLEGO_REGEN := 22.0
const INVULN_APOS_DANO := 0.65
const FOLEGO_POR_ABATE := 15.0

# Sucateiro (sozinho)
const VEL_SUCATEIRO := 170.0
const RAIO_SUCATEIRO := 10.0
const ATAQUE_RECARGA_SUCATEIRO := 0.30
const ATAQUE_ALCANCE_SUCATEIRO := 49.0
const ATAQUE_DANO_SUCATEIRO := 20.0

# Fundido com o Inerte
const VEL_FUSAO := 125.0
const RAIO_FUSAO := 17.0
const ATAQUE_RECARGA_FUSAO := 0.48
const ATAQUE_ALCANCE_FUSAO := 88.0
const ATAQUE_DANO_FUSAO := 38.0
const DANO_RECEBIDO_FUSAO := 0.65 # multiplicador: 0.65 = recebe 65% do dano

# Ataque: apertar J um pouco antes do fim da recarga ainda conta
const ATAQUE_BUFFER := 0.15

# Esquiva
const ESQUIVA_CUSTO := 25.0
const ESQUIVA_DURACAO := 0.17
const ESQUIVA_RECARGA := 0.7
const ESQUIVA_VELOCIDADE := 540.0
const ESQUIVA_INVULN := 0.22

# --- Inimigos comuns ---
const COMUM_VIDA := 60.0
const COMUM_VELOCIDADE := 85.0
const COMUM_RAIO := 12.0
const COMUM_GATILHO := 43.0 # distância para começar a preparar o golpe
const COMUM_PREPARO := 0.5
const COMUM_RECUPERACAO := 0.6
const COMUM_AREA := 38.0
const COMUM_DANO := 13.0
const COMUM_EMPURRAO := 15.0

# --- Soberano (chefe) ---
const CHEFE_VIDA := 240.0
const CHEFE_VELOCIDADE := 60.0
const CHEFE_RAIO := 20.0
const CHEFE_GATILHO := 110.0
const CHEFE_PREPARO := 0.8
const CHEFE_RECUPERACAO := 1.0
const CHEFE_AREA := 76.0
const CHEFE_DANO := 28.0
const CHEFE_EMPURRAO := 5.0

const AGRO := 340.0 # distância em que os inimigos passam a perseguir
