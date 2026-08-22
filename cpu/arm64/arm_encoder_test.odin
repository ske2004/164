package arm64

import "core:testing"
import "core:fmt"

@(test)
encoding_test :: proc(t: ^testing.T) {
	verify :: proc(t: ^testing.T, ref: Piece, res: Piece, ref_expr := #caller_expression(ref), res_expr := #caller_expression(res), loc := #caller_location) {
		testing.expect(t, ref == res, fmt.tprintf("%08X | %08X", ref, res), ref_expr, loc)
	}

	verify(t, 0xD65F0000, encode_ret(0))
	verify(t, 0xD65F0020, encode_ret(1))
	verify(t, 0xD65F03C0, encode_ret(30))
	verify(t, 0x52A24680, encode_movz(.B32, 1, 0x1234, 0))
	verify(t, 0xD2A24680, encode_movz(.B64, 1, 0x1234, 0))
	verify(t, 0x52824681, encode_movz(.B32, 0, 0x1234, 1))
	verify(t, 0xD2824681, encode_movz(.B64, 0, 0x1234, 1))
	verify(t, 0xD2C24682, encode_movz(.B64, 2, 0x1234, 2))
	verify(t, 0xD2E24682, encode_movz(.B64, 3, 0x1234, 2))
	verify(t, 0xF9000800, encode_str_imm_uns(.B64, 2, 0, 0))
	verify(t, 0xB9001021, encode_str_imm_uns(.B32, 4, 1, 1))
	verify(t, 0xF9400800, encode_ldr_imm_uns(.B64, 2, 0, 0))
	verify(t, 0xB9401021, encode_ldr_imm_uns(.B32, 4, 1, 1))
}
