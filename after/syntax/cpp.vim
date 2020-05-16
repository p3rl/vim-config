" Vim syntax file
" Language: C++ Additions

" Unreal types
syn keyword	cppType uint8 uint16 uint32 uint64
syn keyword	cppType int8 int16 int32 int64
syn keyword	ueMacro check UE_LOG UE_CLOG TRACE_CPUPROFILER_EVENT_SCOPE

hi def link ueMacro Typedef
