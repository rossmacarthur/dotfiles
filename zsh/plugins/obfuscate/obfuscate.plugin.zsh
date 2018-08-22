# XOR text with key
alias xor="python -c 'from itertools import izip, cycle; import sys; sys.stdout.write(\"\".join(chr(ord(c) ^ ord(k)) for c, k in izip(sys.stdin.read(), cycle(sys.argv[1]))))'"

# Obfuscate text with a key
obf() {
  cat - | xor $1 | base64 | xz -c | xxd -ps
}

# Unobfuscate text with a key
unobf() {
  cat - | xxd -ps -r | xz -d | base64 --decode | xor $1
}
