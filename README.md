# bash-to-fish
A transpiler from bash script to fish script

## WARNING INCOMPLETE AND NOT RECOMMENDED FOR ACTUAL USAGE

### usage

```
usage: bash-to-fish.sh [OPTIONS] <bash file> [fish file]
description:
  it tries to convert all bash syntax to fish syntax
  and then prints it to stdout. Or writes it to given
  fish file.
options:
  --debug
  --run       run transpiled script directly in fish
```

### example

convert bash script to fish and then run it
```
fish$ ./bash-to-fish.sh myscript.sh output.fish
fish$ ./output.fish
```

run fish script directly in fish no matter from which shell
```
bash$ ./bash-to-fish.sh --run myscript.sh
```
