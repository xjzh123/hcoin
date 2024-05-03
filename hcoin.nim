import std/[syncio, strutils, strformat, base64, parseopt, threadpool, cpuinfo, random]
import nimcrypto/sha2

proc print(s: string) =
  let s = s & "\n"
  discard stdout.writeBuffer(cstring(s), len(s))

proc random_prefix(): string =
  for i in 0..2:
    result.add sample({'a'..'z', 'A'..'Z', '0'..'9', '_', '='})

func sha512_nimcrypto(s: string): string =
  var ctx: sha512
  init(ctx)
  ctx.update(s)
  base64.encode(ctx.finish().data, false)

proc minecoin() {.gcsafe.} =
  let prefix = random_prefix()
  for i in 1..10000000:
    let hash = sha512_nimcrypto(prefix & $i)
    if hash[0..4].toLowerAscii == "hcoin":
      print &"Got hash: {hash} with value:"
      let full_value = prefix & $i
      print full_value

      break

proc minecoin_thread() {.thread.} =
  while true:
    minecoin()

proc mine(threadcount: Positive) =
  print &"Mining with {threadcount} threads."
  if threadcount == 1:
    while true:
      minecoin()
  else:
    for i in 1..threadcount:
      spawn minecoin_thread()
    sync()

proc getOptions(): seq[string] =
  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      result.add key
    else:
      print &"Unsupported option: {kind}, {key}, {val}"

when isMainModule:
  randomize()
  let args = getOptions()
  print &"HCoin Nim Miner\nArguments: {args}"
  if args.len notin 0..1:
    print &"Too many arguments ({args.len} notin 0..1), all arguments are discarded"
  let threadcount =
    if args.len == 1:
      args[0].parseInt
    else:
      countProcessors()
  mine(threadcount)
