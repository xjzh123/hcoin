# HCoin

A Nim miner for a joke "crypto coin": HCoin.

## Build

```text
nimble build -d:release
```

OR:

```text
nim c hcoin.nim -d:release
```

## Usage

```text
hcoin [threads]

[threads]: Number of Threads to use. Default is number of your processors, which should be the fastest option.
```
