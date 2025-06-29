# 🧮 Calculadora Mocami

Uma calculadora inteligente de despesas em Flutter com funcionalidades avançadas de expressões matemáticas e persistência de dados.

## ✨ Funcionalidades

### 🧮 **Cálculos Inteligentes**

-    **Expressões simples**: `Aluguel 800`, `Energia 120.50`
-    **Operações básicas**: `Combustível 5.59*40` → 223.60
-    **Expressões complexas**: `Total (800+120)*12` → 11040.00
-    **Parênteses**: `Desconto -(50+20)` → -70.00
-    **Precedência matemática**: `Conta 2+3*4` → 14.00

### 💾 **Persistência de Dados**

-    **Auto-save**: Salva automaticamente enquanto você digita
-    **Restauração**: Dados são carregados automaticamente ao abrir o app
-    **Compatível**: Funciona em Android, iOS, Web e Desktop
-    **Storage local**: Usa SharedPreferences (equivalente ao localStorage)

### ⚡ **Performance Otimizada**

-    **Debounce de 300ms**: Evita recálculos desnecessários
-    **Parser híbrido**: Código próprio para operações simples, biblioteca para complexas
-    **Interface responsiva**: Indicadores visuais de salvamento

#### **Despesas Simples:**

```
Aluguel 800
Energia 120.50
Internet 89
Água 45.30
```

#### **Cálculos Avançados:**

```
Energia base 100+50+20
Combustível 5.59*40
Parcela anual 1200/12
Desconto total -(50+20)
Investimento (1000+500)*1.1
```
