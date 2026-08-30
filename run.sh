ODIN_FLAGS=-collection:src=.

if [ ! -e private/bios.bin ]; then
  echo "Warning: BIOS doesn't exist at private/bios.bin"
fi

umka scripts/arm64_encoding_list_convert.um
armips tests/make.mips.s

case "$1" in
  "test" )
    odin test main -all-packages $ODIN_FLAGS
    ;;
  * )
    odin run main $ODIN_FLAGS
    ;;
esac
