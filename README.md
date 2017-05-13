# llg-erlang
A last letter game benchmark implemented in Erlang

## How to run
Clone repository recursively:

```bash
git clone --recursive https://github.com/LLGAssessment/llg-erlang.git
```

Compile test:

```bash
cd llg-erlang
make
```

Run it and measure its time:

```
time erl -s llg main -s init stop -noshell < llg-dataset/70pokemons.txt
```
