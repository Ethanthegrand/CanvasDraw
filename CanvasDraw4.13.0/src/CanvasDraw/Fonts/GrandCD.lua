--[[

Font: GrandCD
Desc: A thin 7x8 font set that I designed for CanvasDraw.
	  92 Characters are supported

]]

return {
	Lower = false,
	CharacterSize = Vector2.new(7, 8),
	Padding = 0,
	Bitmap = {
		[" "] = {0b0000000,0b0000000,0b0000000,0b0000000,0b0000000,0b0000000,0b0000000,0b0000000},
		["!"] = {0b0000000,0b0001000,0b0001000,0b0001000,0b0001000,0b0000000,0b0001000,0b0000000},
		['"'] = {0b0000000,0b0100010,0b0100010,0b0000000,0b0000000,0b0000000,0b0000000,0b0000000},
		["#"] = {0b0000000,0b0010010,0b0111111,0b0010010,0b0010010,0b0111111,0b0010010,0b0000000},
		["$"] = {0b0001000,0b0011110,0b0110000,0b0011100,0b0000110,0b0111100,0b0001000,0b0000000},
		["%"] = {0b0000000,0b0110001,0b0110010,0b0000100,0b0001000,0b0010011,0b0100011,0b0000000},
		["&"] = {0b0001100,0b0010010,0b0001010,0b0010100,0b0100011,0b0100010,0b0011101,0b0000000},
		["'"] = {0b0000000,0b0001000,0b0001000,0b0000000,0b0000000,0b0000000,0b0000000,0b0000000},
		["("] = {0b0000010,0b0000100,0b0001000,0b0001000,0b0001000,0b0001000,0b0000100,0b0000010},
		[")"] = {0b0010000,0b0001000,0b0000100,0b0000100,0b0000100,0b0000100,0b0001000,0b0010000},
		["*"] = {0b0000000,0b0010010,0b0001100,0b0111111,0b0001100,0b0010010,0b0000000,0b0000000},
		["+"] = {0b0000000,0b0000100,0b0000100,0b0011111,0b0000100,0b0000100,0b0000000,0b0000000},
		[","] = {0b0000000,0b0000000,0b0000000,0b0000000,0b0000000,0b0000000,0b0001100,0b0011000},
		["-"] = {0b0000000,0b0000000,0b0000000,0b1111110,0b0000000,0b0000000,0b0000000,0b0000000},
		["."] = {0b0000000,0b0000000,0b0000000,0b0000000,0b0000000,0b0000000,0b0100000,0b0000000},
		["/"] = {0b0000000,0b0000100,0b0001000,0b0001000,0b0010000,0b0010000,0b0100000,0b0000000},
		["0"] = {0b0000000,0b0011100,0b0100010,0b0100010,0b0100010,0b0100010,0b0011100,0b0000000},
		["1"] = {0b0000000,0b0001000,0b0011000,0b0001000,0b0001000,0b0001000,0b0111110,0b0000000},
		["2"] = {0b0000000,0b0011100,0b0100010,0b0000100,0b0001000,0b0010000,0b0111110,0b0000000},
		["3"] = {0b0000000,0b0111110,0b0000100,0b0001000,0b0000100,0b0100010,0b0011110,0b0000000},
		["4"] = {0b0000000,0b0010010,0b0010010,0b0100010,0b0111110,0b0000010,0b0000010,0b0000000},
		["5"] = {0b0000000,0b0111110,0b0100000,0b0111100,0b0000010,0b0100010,0b0011100,0b0000000},
		["6"] = {0b0000000,0b0011100,0b0100000,0b0111100,0b0100010,0b0100010,0b0011100,0b0000000},
		["7"] = {0b0000000,0b0111110,0b0000010,0b0000100,0b0001000,0b0001000,0b0010000,0b0000000},
		["8"] = {0b0000000,0b0011100,0b0100010,0b0011100,0b0100010,0b0100010,0b0011100,0b0000000},
		["9"] = {0b0000000,0b0011100,0b0100010,0b0011110,0b0000010,0b0000100,0b0011000,0b0000000},
		[":"] = {0b0000000,0b0001000,0b0000000,0b0000000,0b0000000,0b0001000,0b0000000,0b0000000},
		[";"] = {0b0000000,0b0000100,0b0000000,0b0000000,0b0000000,0b0000100,0b0001000,0b0000000},
		["<"] = {0b0000000,0b0000000,0b0000010,0b0000100,0b0001000,0b0000100,0b0000010,0b0000000},
		["="] = {0b0000000,0b0000000,0b1111110,0b0000000,0b0000000,0b1111110,0b0000000,0b0000000},
		[">"] = {0b0000000,0b0000000,0b0100000,0b0010000,0b0001000,0b0010000,0b0100000,0b0000000},
		["?"] = {0b0000000,0b0011100,0b0100010,0b0000100,0b0001000,0b0000000,0b0001000,0b0000000},
		["@"] = {0b0011110,0b0100001,0b0101101,0b0101101,0b0101110,0b0100000,0b0011110,0b0000000},
		["A"] = {0b0000000,0b0011000,0b0010100,0b0010100,0b0111110,0b0100010,0b0100001,0b0000000},
		["B"] = {0b0000000,0b0111100,0b0100010,0b0100010,0b0111100,0b0100010,0b0111100,0b0000000},
		["C"] = {0b0000000,0b0011100,0b0100010,0b0100000,0b0100000,0b0100010,0b0011100,0b0000000},
		["D"] = {0b0000000,0b0111000,0b0100100,0b0100010,0b0100010,0b0100010,0b0111100,0b0000000},
		["E"] = {0b0000000,0b0111110,0b0100000,0b0100000,0b0111110,0b0100000,0b0111110,0b0000000},
		["F"] = {0b0000000,0b0111110,0b0100000,0b0100000,0b0111000,0b0100000,0b0100000,0b0000000},
		["G"] = {0b0000000,0b0001110,0b0010000,0b0100000,0b0100110,0b0100010,0b0011110,0b0000000},
		["H"] = {0b0000000,0b0100010,0b0100010,0b0100010,0b0111110,0b0100010,0b0100010,0b0000000},
		["I"] = {0b0000000,0b0011100,0b0001000,0b0001000,0b0001000,0b0001000,0b0011100,0b0000000},
		["J"] = {0b0000000,0b0000010,0b0000010,0b0000010,0b0000010,0b0100010,0b0011100,0b0000000},
		["K"] = {0b0000000,0b0100010,0b0100100,0b0101000,0b0110000,0b0101100,0b0100010,0b0000000},
		["L"] = {0b0000000,0b0010000,0b0010000,0b0010000,0b0100000,0b0100000,0b0111110,0b0000000},
		["M"] = {0b0000000,0b0100010,0b0110110,0b0101010,0b0100010,0b0100010,0b0100010,0b0000000},
		["N"] = {0b0000000,0b0100010,0b0110010,0b0101010,0b0101010,0b0100110,0b0100010,0b0000000},
		["O"] = {0b0000000,0b0011100,0b0100010,0b0100010,0b0100010,0b0100010,0b0011100,0b0000000},
		["P"] = {0b0000000,0b0111100,0b0100010,0b0100010,0b0111100,0b0100000,0b0100000,0b0000000},
		["Q"] = {0b0000000,0b0011100,0b0100010,0b0100010,0b0100010,0b0100110,0b0011100,0b0000010},
		["R"] = {0b0000000,0b0111100,0b0100010,0b0100010,0b0111100,0b0100010,0b0100010,0b0000000},
		["S"] = {0b0000000,0b0011110,0b0100000,0b0100000,0b0011100,0b0000010,0b0111100,0b0000000},
		["T"] = {0b0000000,0b0111110,0b0001000,0b0001000,0b0010000,0b0010000,0b0010000,0b0000000},
		["U"] = {0b0000000,0b0100010,0b0100010,0b0100010,0b0100010,0b0100010,0b0011100,0b0000000},
		["V"] = {0b0000000,0b0100010,0b0100100,0b0100100,0b0101000,0b0011000,0b0010000,0b0000000},
		["W"] = {0b0000000,0b0100010,0b0100010,0b0100010,0b0101010,0b0110110,0b0100010,0b0000000},
		["X"] = {0b0000000,0b0100010,0b0010100,0b0001000,0b0001000,0b0010100,0b0100010,0b0000000},
		["Y"] = {0b0000000,0b0100010,0b0100010,0b0010100,0b0001000,0b0001000,0b0001000,0b0000000},
		["Z"] = {0b0000000,0b0111110,0b0000010,0b0001100,0b0010000,0b0100000,0b0111110,0b0000000},
		["["] = {0b0000000,0b0011100,0b0010000,0b0010000,0b0010000,0b0010000,0b0011100,0b0000000},
		["\\"] = {0b0000000,0b0100000,0b0010000,0b0010000,0b0001000,0b0001000,0b0000100,0b0000000},
		["]"] = {0b0000000,0b0011100,0b0000100,0b0000100,0b0000100,0b0000100,0b0011100,0b0000000},
		["^"] = {0b0000000,0b0010000,0b0101000,0b1000100,0b0000000,0b0000000,0b0000000,0b0000000},
		["_"] = {0b0000000,0b0000000,0b0000000,0b0000000,0b0000000,0b0000000,0b0000000,0b0111110},
		["°"] = {0b0001000,0b0010100,0b0001000,0b0000000,0b0000000,0b0000000,0b0000000,0b0000000},
		["a"] = {0b0000000,0b0000000,0b0011100,0b0000010,0b0011110,0b0100010,0b0011110,0b0000000},
		["b"] = {0b0000000,0b0100000,0b0100000,0b0111100,0b0100010,0b0100010,0b0111100,0b0000000},
		["c"] = {0b0000000,0b0000000,0b0011110,0b0100000,0b0100000,0b0100000,0b0011110,0b0000000},
		["d"] = {0b0000000,0b0000010,0b0000010,0b0011110,0b0100010,0b0100010,0b0011110,0b0000000},
		["e"] = {0b0000000,0b0000000,0b0011100,0b0100010,0b0111110,0b0100000,0b0011100,0b0000000},
		["f"] = {0b0000000,0b0001100,0b0010000,0b0111000,0b0010000,0b0010000,0b0010000,0b0000000},
		["g"] = {0b0000000,0b0000000,0b0011110,0b0100010,0b0100010,0b0011110,0b0000010,0b0111100},
		["h"] = {0b0000000,0b0100000,0b0100000,0b0111100,0b0100010,0b0100010,0b0100010,0b0000000},
		["i"] = {0b0000000,0b0001000,0b0000000,0b0001000,0b0001000,0b0001000,0b0001000,0b0000000},
		["j"] = {0b0000000,0b0000100,0b0000000,0b0000100,0b0000100,0b0000100,0b0100100,0b0011000},
		["k"] = {0b0000000,0b0100000,0b0100000,0b0101100,0b0110000,0b0101000,0b0100100,0b0000000},
		["l"] = {0b0000000,0b0010000,0b0010000,0b0010000,0b0010000,0b0010000,0b0001000,0b0000000},
		["m"] = {0b0000000,0b0000000,0b0110100,0b0101010,0b0101010,0b0101010,0b0101010,0b0000000},
		["n"] = {0b0000000,0b0000000,0b0111100,0b0100010,0b0100010,0b0100010,0b0100010,0b0000000},
		["o"] = {0b0000000,0b0000000,0b0011100,0b0100010,0b0100010,0b0100010,0b0011100,0b0000000},
		["p"] = {0b0000000,0b0000000,0b0101100,0b0110010,0b0100010,0b0111100,0b0100000,0b0100000},
		["q"] = {0b0000000,0b0000000,0b0011010,0b0100110,0b0100010,0b0011110,0b0000010,0b0000010},
		["r"] = {0b0000000,0b0000000,0b0101100,0b0110010,0b0100000,0b0100000,0b0100000,0b0000000},
		["s"] = {0b0000000,0b0000000,0b0011110,0b0100000,0b0011100,0b0000010,0b0111100,0b0000000},
		["t"] = {0b0000000,0b0001000,0b0001000,0b0011110,0b0001000,0b0001000,0b0000110,0b0000000},
		["u"] = {0b0000000,0b0000000,0b0100010,0b0100010,0b0100010,0b0100010,0b0011100,0b0000000},
		["v"] = {0b0000000,0b0000000,0b0100100,0b0100100,0b0101000,0b0011000,0b0010000,0b0000000},
		["w"] = {0b0000000,0b0000000,0b0100010,0b0100010,0b0101010,0b0101010,0b0010100,0b0000000},
		["x"] = {0b0000000,0b0000000,0b0100010,0b0010100,0b0001000,0b0010100,0b0100010,0b0000000},
		["y"] = {0b0000000,0b0000000,0b0100010,0b0100010,0b0100010,0b0011110,0b0000010,0b0111100},
		["z"] = {0b0000000,0b0000000,0b0111110,0b0000100,0b0001000,0b0010000,0b0111110,0b0000000},
		["|"] = {0b0001000,0b0001000,0b0001000,0b0001000,0b0001000,0b0001000,0b0001000,0b0001000},
	}
}