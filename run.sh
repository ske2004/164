case "$1" in
  "test" )
    odin test main -all-packages\
      -collection:src=.
    ;;
  * )
    odin run main\
      -collection:src=.
    ;;
esac
