package arm64

import "core:fmt"
@(private)
augment_imm_sf :: #force_inline proc(imm: Imm, sf: Sf) -> Imm {
	switch sf {
	case .B32: assert(imm%4 == 0, "imm unaligned to 4 bytes"); return imm/4
	case .B64: assert(imm%8 == 0, "imm unaligned to 8 bytes"); return imm/8
	}

	unreachable()
}

@(private)
augment :: proc {
	augment_imm_sf,
}
