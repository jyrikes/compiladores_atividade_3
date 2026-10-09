#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
temp=$(mktemp)
trap 'rm -f "$temp"' EXIT

echo '[1/7] Exemplo do professor'
./calc entrada.txt > "$temp"
diff -u saida_esperada.txt "$temp"

echo '[2/7] Potencia associativa a direita, menos unario e notacao cientifica'
printf '%s\n' '2**3**2' '-2**2' '2**-3' '2.5e2+1' | ./calc > "$temp"
printf '%s\n' '= 512' '= -4' '= 0.125' '= 251' | diff -u - "$temp"

echo '[3/7] Reatribuicao e ordem das variaveis'
printf '%s\n' 'y >>> 2' 'x >>> 3' 'y >>> y+1' 'printar_variaveis' | ./calc > "$temp"
printf '%s\n' 'y >>> 3' 'x >>> 3' | diff -u - "$temp"

echo '[4/7] Ultima linha sem quebra final'
printf '7' | ./calc > "$temp"
printf '= 7\n' | diff -u - "$temp"

echo '[5/7] Variavel inexistente falha corretamente'
if printf '%s\n' 'inexistente' | ./calc > "$temp" 2>&1; then
    echo 'ERRO: nome inexistente deveria falhar' >&2
    exit 1
fi
grep -q 'Variavel nao definida: inexistente' "$temp"

echo '[6/7] Comandos diferentes na mesma linha sao rejeitados'
if printf '%s\n' '2 3' | ./calc > "$temp" 2>&1; then
    echo 'ERRO: faltou rejeitar dois comandos na mesma linha' >&2
    exit 1
fi

echo '[7/7] Sintaxe 2eE10 nao deve confundir identificadores'
if printf '%s\n' '2eE10' | ./calc > "$temp" 2>&1; then
    echo 'ERRO: token eE nao faz parte dos operadores exigidos' >&2
    exit 1
fi
echo 'Todos os 7 testes passaram.'
