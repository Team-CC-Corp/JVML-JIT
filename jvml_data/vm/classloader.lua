--This will load class files and will register them--
natives = {["java.lang.Object"]={
	["registerNatives()V"] = function()
		local path = fs.combine(jcd, "CCLib/java/lang/native")
		for i,v in ipairs(fs.list(path)) do
			dofile(fs.combine(path, v))
		end
	end
}}
os.loadAPI(fs.combine(jcd, "jvml_data/vm/bigInt"))

function asInt(d)
	return {type="int",data=d}
end
function asFloat(d)
	return {type="float",data=d}
end
function asDouble(d)
	return {type="double",data=d}
end
function asLong(d)
	return {type="long",data=d}
end
function asBoolean(d)
	return {type="boolean",data=d}
end
function asChar(d)
	return {type="char",data=d}
end
function asByte(d)
	return {type="byte",data=d}
end
function asShort(d)
	return {type="short",data=d}
end
function asObjRef(d)
	return {type="ref",data=d}
end

CONSTANT = {
	Class=7,
	Fieldref=9,
	Methodref=10,
	InterfaceMethodref=11,
	String=8,
	Integer=3,
	Float=4,
	Long=5,
	Double=6,
	NameAndType=12,
	Utf8=1,
	MethodHandle=15,
	MethodType=16,
	InvokeDynamic=18
}

local nan = -(0/0)

local CONSTANTLOOKUP = {}
for i, v in pairs(CONSTANT) do CONSTANTLOOKUP[v] = i end

METHOD_ACC = {
	PUBLIC=0x0001,
	PRIVATE=0x0002,
	PROTECTED=0x0004,
	STATIC=0x0008,
	FINAL=0x0010,
	SYNCHRONIZED=0x0020,
	BRIDGE=0x0040,
	VARARGS=0x0080,
	NATIVE=0x0100,
	ABSTRACT=0x0400,
	STRICT=0x0800,
	SYNTHETIC=0x1000,
}

CLASS_ACC = {
	PUBLIC=0x0001,
	FINAL=0x0010,
	SUPER=0x0020,
	INTERFACE=0x0200,
	ABSTRACT=0x0400,
	SYNTHETIC=0x1000,
	ANNOTATION=0x2000,
	ENUM=0x4000,
}

function loadJavaClass(file)
	if not fs.exists(file) then return false end
	local fh = fs.open(file,"rb")
	local cn
	local cp = {}
	local i = 0
	
	local u1 = fh.read--function() i=i+1 print("at ",i-1) return fh.read() end
	local function u2()
		return bit.blshift(u1(),8) + u1()
	end
	
	local function u4()
		return bit.blshift(u1(),24) + bit.blshift(u1(),16) + bit.blshift(u1(),8) + u1()
	end
	
	local function parse_descriptor(desc,descriptor)
		--parse descriptor
		local i = 1
		local cur = {}
		while i <= #descriptor do
			local c = descriptor:sub(i,i)
			if c == "(" or c == ")" then
				--arglst start
			else
				if c == "[" then
					cur.array = true
				elseif c == "L" then
					--im guessing ref or something
					cur.type = "objref"
					cur.class = ""
					i = i+1
					c = descriptor:sub(i,i)
					while c ~= ";" and c do
						cur.class = cur.class..c
						i = i+1
						c = descriptor:sub(i,i)
					end
					table.insert(desc,cur)
					cur = {}
				elseif c == "V" then
					cur.type = "void"
					table.insert(desc,cur)
					cur = {}
				elseif c == "I" then
					cur.type = "int"
					table.insert(desc,cur)
					cur = {}
				elseif c == "D" then
					cur.type = "double"
					table.insert(desc,cur)
					cur = {}
				elseif c == "Z" then
					cur.type = "boolean"
					table.insert(desc,cur)
					cur = {}
				end
			end
			i = i+1
		end
	end
	
	local function cp_class_info(c)
		c.name_index = u2() --name index
	end
	
	local function cp_ref_info(c)
		c.class_index = u2()
		c.name_and_type_index = u2()
	end
	
	local function cp_string_info(c)
		c.string_index= u2()
	end
	
	local function cp_intfloat_info(c)
		c.bytes = u4()
	end
	
	local function cp_longdouble_info(c)
		c.high_bytes = u4()
		c.low_bytes = u4()
	end
	
	local function cp_nameandtype_info(c)
		c.name_index = u2()
		c.descriptor_index = u2()
	end
	
	local function cp_utf8_info(c)
		c.length = u2()
		c.bytes = ""
		for i=1, c.length do
			c.bytes = c.bytes..string.char(u1()) --UTF8? Fuck that!
		end
	end
	
	local function cp_methodhandle_info(c)
		c.reference_kind = u1()
		c.reference_index = u2()
	end
	
	local function cp_methodtype_info(c)
		c.descriptor_index = u2()
	end
	
	local function cp_invokedynamic_info(c)
		c.bootstrap_method_attr_index = u2()
		c.name_and_type_index = u2()
	end
	
	local function parse_float(bits)
		if bits == 0x7f800000 then
			return math.huge
		elseif bits == 0xff800000 then
			return -math.huge
		elseif bits >= 0x7f800001 and bits <= 0x7fffffff and bits >= 0xff800001 and bits <= 0xffffffff then
			return nan
		else
			local s = (bit.brshift(bits, 31) == 0) and 1 or -1;
			local e = bit.band(bit.brshift(bits, 23), 0xff);
			local m = (e == 0) and
					  bit.blshift(bit.band(bits, 0x7fffff), 1) or
					  bit.band(bits, 0x7fffff) + 0x800000
			return s*m*(2^(e-150))
		end
	end
	
	local function parse_long(high_bytes,low_bytes)
		return bigInt.add(bigInt.brshift(high_bytes,32),low_bytes)
	end
	
	local function parse_double(high_bytes,low_bytes)
		local x = ""
		x = x..string.char(bit.band(low_bytes,0xFF))
		x = x..string.char(bit.band(bit.brshift(low_bytes,8),0xFF))
		x = x..string.char(bit.band(bit.brshift(low_bytes,16),0xFF))
		x = x..string.char(bit.band(bit.brshift(low_bytes,24),0xFF))
		
		x = x..string.char(bit.band(high_bytes,0xFF))
		x = x..string.char(bit.band(bit.brshift(high_bytes,8),0xFF))
		x = x..string.char(bit.band(bit.brshift(high_bytes,16),0xFF))
		x = x..string.char(bit.band(bit.brshift(high_bytes,24),0xFF))
		--x = string.reverse(x)
		local sign = 1
		local mantissa = string.byte(x, 7) % 16
		for i = 6, 1, -1 do mantissa = mantissa * 256 + string.byte(x, i) end
		if string.byte(x, 8) > 127 then sign = -1 end
		local exponent = (string.byte(x, 8) % 128) * 16 +math.floor(string.byte(x, 7) / 16)
		if exponent == 0 then return 0 end
		mantissa = (math.ldexp(mantissa, -52) + 1) * sign
		return math.ldexp(mantissa, exponent - 1023)
	end
	
	local function cp_entry(ei)
		local c = {}
		c.tag = u1()
		c.cl = CONSTANTLOOKUP[c.tag]
		local ct = c.tag
		if ct == CONSTANT.Class then
			cp_class_info(c)
		elseif ct == CONSTANT.Fieldref or ct == CONSTANT.Methodref or ct == CONSTANT.InterfaceMethodref then
			cp_ref_info(c)
		elseif ct == CONSTANT.String then
			cp_string_info(c)
		elseif ct == CONSTANT.Integer then
			cp_intfloat_info(c)
		elseif ct == CONSTANT.Float then
			cp_intfloat_info(c)
			c.bytes = parse_float(c.bytes)
		elseif ct == CONSTANT.Long then
			print("warning: longs are not supported")
			cp_longdouble_info(c)
			c.bytes = parse_long(c.high_bytes,c.low_bytes)
		elseif ct == CONSTANT.Double then
			cp_longdouble_info(c)
			c.bytes = parse_double(c.high_bytes,c.low_bytes)
		elseif ct == CONSTANT.NameAndType then
			cp_nameandtype_info(c)
		elseif ct == CONSTANT.Utf8 then
			cp_utf8_info(c)
		elseif ct == CONSTANT.MethodHandle then
			cp_methodhandle_info(c)
		elseif ct == CONSTANT.MethodType then
			cp_methodtype_info(c)
		elseif ct == CONSTANT.InvokeDynamic then
			cp_invokedynamic_info(c)
		else
			print("Mindfuck in ConstantPool: "..ct)
		end
		return c
	end
	
	local function attribute()
		local attrib = {}
		attrib.attribute_name_index = u2()
		attrib.attribute_length = u4()
		attrib.name = cp[attrib.attribute_name_index].bytes
		local an = attrib.name
		if an == "ConstantValue" then
			attrib.constantvalue_index = u2()
		elseif an == "Code" then
			attrib.max_stack = u2()
			attrib.max_locals = u2()
			attrib.code_length = u4()
			attrib.code = {}
			for i=0, attrib.code_length-1 do
				attrib.code[i] = u1()
			end
			attrib.exception_table_length = u2()
			attrib.exception_table = {}
			for i=0, attrib.exception_table_length-1 do
				attrib.exception_table[i] = {
					start_pc = u2(),
					end_pc = u2(),
					handler_pc = u2(),
					catch_type = u2()
				}
			end
			attrib.attributes_count = u2()
			attrib.attributes = {}
			for i=0, attrib.attributes_count-1 do
				attrib.attributes[i] = attribute()
			end
		elseif an == "Exceptions" then
			attrib.number_of_exceptions = u2()
			attrib.exception_index_table = {}
			for i=0, attrib.number_of_exceptions-1 do
				attrib.exception_index_table[i] = u2()
			end
		elseif an == "InnerClasses" then
			attrib.number_of_classes = u2()
			attrib.classes = {}
			for i=0, attrib.number_of_classes-1 do
				attrib.classes[i] = {
					inner_class_info_index = u2(),
					outer_class_info_index = u2(),
					inner_name_index = u2(),
					inner_class_access_flags = u2()
				}
			end
		elseif an == "EnclosingMethod" then
			attrib.class_index = u2()
			attrib.method_index = u2()
		elseif an == "Synthetic" then
			error("Fuck that, Synthetic attributes are not supported",0)
		elseif an == "Signature" then
			attrib.signature_index = u2()
		elseif an == "SourceDebugExtension" then
			error("SourceDebugExtension? LELHUEHUEHUELELELELELHUE",0)
		elseif an == "LineNumberTable" then
			attrib.line_number_table_length = u2()
			attrib.line_number_table = {}
			for i=0, attrib.line_number_table_length-1 do
				attrib.line_number_table[i] = {
					start_pc = u2(),
					line_number = u2()
				}
			end
		elseif an == "LocalVariableTable" then
			error("LVT is so mainstream",0)
		elseif an == "LocalVariableTypeTable" then
			error("LVTT is so mainstream",0)
		elseif an == "Deprecated" then
			--lel, this doesn't have content in it--
		elseif an == "SourceFile" then
			attrib.source_file_index = u2()
		else
			print("Unhandled Attrib: "..an)
			attrib.bytes = {}
			for i=1, attrib.attribute_length do
				attrib.bytes[i] = u1()
			end
		end
		return attrib
	end
	
	local function field_info()
		local field = {
			access_flags = u2(),
			name = cp[u2()].bytes,
			descriptor = cp[u2()].bytes,
			attributes_count = u2(),
			attributes = {}
		}
		for i=0, field.attributes_count-1 do
			field.attributes[i] = attribute()
		end
		return field
	end
	
	local function resolveClass(c)
		local cn = cp[c.name_index].bytes:gsub("/",".")
		return classByName(cn)
	end


	local function createCodeFunction(code)
		return function(...)
			local stack = {}
			local lvars = {}
			for i,v in ipairs({...}) do
				lvars[i - 1] = v
			end
			local sp = 1
			local function push(i)
				--print(i)
				stack[sp] = i
				sp = sp+1
			end
			local function pop()
				sp = sp-1
				return stack[sp]
			end
			local pc = 0
			local function u1()
				pc = pc+1
				return code[pc-1]
			end
			local function u2()
				return bit.blshift(u1(),8) + u1()
			end
			
			while true do
				local inst = u1()
				FROM = classByName(cn)
				if inst == 0x0 then
				elseif inst == 0x1 then
					--null
					push(nil)
				elseif inst == 0x2 then
					push(asInt(-1))
				elseif inst == 0x3 then
					push(asInt(0))
				elseif inst == 0x4 then
					push(asInt(1))
				elseif inst == 0x5 then
					push(asInt(2))
				elseif inst == 0x6 then
					push(asInt(3))
				elseif inst == 0x7 then
					push(asInt(4))
				elseif inst == 0x8 then
					push(asInt(5))
				elseif inst == 0x9 then
					push(asLong(bigInt.toBigInt(0)))
				elseif inst == 0xA then
					push(asLong(bigInt.toBigInt(1)))
				elseif inst == 0xB then
					push(asFloat(0))
				elseif inst == 0xC then
					push(asFloat(1))
				elseif inst == 0xD then
					push(asFloat(2))
				elseif inst == 0xE then
					push(asDouble(0))
				elseif inst == 0xF then
					push(asDouble(1))
				elseif inst == 0x10 then
					--push imm byte
					push(asInt(u1()))
				elseif inst == 0x11 then
					--push imm short
					push(asInt(u2()))
				elseif inst == 0x12 then
					--ldc
					--push constant
					local s = cp[u1()]
					if s.bytes then
						push({type=s.cl:lower(),data=s.bytes})
					else
						push({type="String",data=cp[s.string_index].bytes}) --TODO: Change to ObjectRef
					end
				elseif inst == 0x13 then
					--ldc_w
					--push constant
					local s = cp[u2()]
					if s.bytes then
						push({type=s.cl:lower(),data=s.bytes})
					else
						push({type="String",data=cp[s.string_index].bytes})
					end
				elseif inst == 0x14 then
					--ldc2_w
					--push constant
					local s = cp[u2()]
					push({type=s.cl:lower(),data=s.bytes})
				elseif inst >= 0x15 and inst <= 0x19 then
					--loads
					push(lvars[u1()])
				elseif inst == 0x1A or inst == 0x1E or inst == 0x22 or inst == 0x26 or inst == 0x2A then
					--load_0
					push(lvars[0])
				elseif inst == 0x1B or inst == 0x1F or inst == 0x23 or inst == 0x27 or inst == 0x2B then
					--load_1
					push(lvars[1])
				elseif inst == 0x1C or inst == 0x20 or inst == 0x24 or inst == 0x28 or inst == 0x2C then
					--load_2
					push(lvars[2])
				elseif inst == 0x1D or inst == 0x21 or inst == 0x25 or inst == 0x29 or inst == 0x2D then
					--load_3
					push(lvars[3])
				elseif inst >= 0x2E and inst <= 0x35 then
					--aload
					local i,t = pop(),pop()
					push(t[i])
				elseif inst >= 0x36 and inst <= 0x3A then
					--stores
					lvars[u1()] = pop()
				elseif inst == 0x3B or inst == 0x3F or inst == 0x43 or inst == 0x47 or inst == 0x4B then
					lvars[0] = pop()
				elseif inst == 0x3C or inst == 0x40 or inst == 0x44 or inst == 0x48 or inst == 0x4C then
					lvars[1] = pop()
				elseif inst == 0x3D or inst == 0x41 or inst == 0x45 or inst == 0x49 or inst == 0x4D then
					lvars[2] = pop()
				elseif inst == 0x3E or inst == 0x42 or inst == 0x46 or inst == 0x4A or inst == 0x4E then
					lvars[3] = pop()
				elseif inst >= 0x50 and inst <= 0x56 then
					--aastore
					local v,i,t = pop(),pop(),pop()
					t[i] = v
				elseif inst == 0x57 then
					pop()
				elseif inst == 0x58 then
					local pv = pop()
					if pv.type ~= "double" and pv.type ~= "long" then
						pop()
					end
				elseif inst == 0x59 then
					local v = pop()
					push(v)
					push({type=v.type,data=v.data})
				elseif inst == 0x5a then
					local v = pop()
					push(v)
					table.insert(stack,sp-2,{type=v.type,data=v.data})
					sp = sp+1
				elseif inst == 0x5b then
					local v = pop()
					push(v)
					table.insert(stack,sp-(pv.type == "double" or pv.type == "long" and 2 or 3),{type=v.type,data=v.data})
					sp = sp+1
				elseif inst == 0x5c then
					local a = pop()
					if a.type ~= "double" and a.type ~= "long" then
						local b = pop()
						push(b)
						push(a)
						push({type=b.type,data=b.data})
						push({type=a.type,data=a.data})
					else
						push(a)
						push({type=a.type,data=a.data})
					end
				elseif inst == 0x5d then
					error("swap2_x1 is bullshit and you know it")
				elseif inst == 0x5e then
					error("swap2_x2 is bullshit and you know it")
				elseif inst == 0x5f then
					local a = pop()
					local b = pop()
					push(a)
					push(b)
				elseif inst >= 0x60 and inst <= 0x63 then
					--add
					local b, a = pop(), pop()
					push({type=a.type,data=a.data+b.data})
				elseif inst >= 0x64 and inst <= 0x67 then
					--sub
					local b, a = pop(), pop()
					push({type=a.type,data=a.data-b.data})
				elseif inst >= 0x68 and inst <= 0x6b then
					--mul
					local b, a = pop(), pop()
					push({type=a.type,data=a.data*b.data})
				elseif inst >= 0x6c and inst <= 0x6f then
					--div
					local b, a = pop(), pop()
					push({type=a.type,data=a.data/b.data})
				elseif inst >= 0x70 and inst <= 0x73 then
					--rem
					local b, a = pop(), pop()
					push({type=a.type,data=a.data%b.data})
				elseif inst >= 0x74 and inst <= 0x77 then
					--neg
					local a = pop(), pop()
					push({type=a.type,data=-a.data})
				elseif inst >= 0x78 and inst <= 0x79 then
					--shl
					local b, a = pop(), pop()
					push({type=b.type,data=bit.blshift(b.data,a.data)})
				elseif inst >= 0x7a and inst <= 0x7b then
					--shr
					local b, a = pop(), pop()
					push({type=b.type,data=bit.brshift(b.data,a.data)})
				elseif inst >= 0x7c and inst <= 0x7d then
					--shlr
					local b, a = pop(), pop()
					push({type=b.type,data=bit.blogic_rshift(b.data,a.data)})
				elseif inst >= 0x7e and inst <= 0x7f then
					--and
					local b, a = pop(), pop()
					push({type=a.type,data=bit.band(a.data,b.data)})
				elseif inst >= 0x80 and inst <= 0x81 then
					--or
					local b, a = pop(), pop()
					push({type=a.type,data=bit.bor(a.data,b.data)})
				elseif inst >= 0x82 and inst <= 0x83 then
					--xor
					local b, a = pop(), pop()
					push({type=a.type,data=bit.bxor(a.data,b.data)})
				elseif inst == 0x84 then
					--iinc
					local idx = u1()
					local c = u1()-127
					lvars[idx] = lvars[idx]+c
				elseif inst >= 0xAC and inst <= 0xB0 then
					return pop()
				elseif inst == 0xB1 then
					return
				elseif inst == 0xB2 then
					--getstatic
					local fr = cp[u2()]
					local cl = resolveClass(cp[fr.class_index])
					local name = cp[cp[fr.name_and_type_index].name_index].bytes
					push(asObjRef(cl.fields[name].value))
				elseif inst == 0xB3 then
					--putstatic
					local fr = cp[u2()]
					local cl = resolveClass(cp[fr.class_index])
					local name = cp[cp[fr.name_and_type_index].name_index].bytes
					cl.fields[name].value = pop().data
				elseif inst == 0xB6 then
					--invokevirtual
					local mr = cp[u2()]
					local cl = resolveClass(cp[mr.class_index])
					local name = cp[cp[mr.name_and_type_index].name_index].bytes..cp[cp[mr.name_and_type_index].descriptor_index].bytes
					local mt = findMethod(cl,name)
					local args = {}
					for i=#mt.desc-1,1,-1 do
						args[i+1] = pop()
					end
					args[1] = pop()
					local obj = args[1].data
					if bit.band(mt.acc,METHOD_ACC.NATIVE) == METHOD_ACC.NATIVE then
						for i=1, #args do
							args[i] = args[i].data
						end
					end
					local ret = mt[1](unpack(args))
					if mt.desc[#mt.desc].type ~= "void" then
						push(ret)
					end
				elseif inst == 0xB7 then
					--invokespecial
					local mr = cp[u2()]
					local cl = resolveClass(cp[mr.class_index])
					local name = cp[cp[mr.name_and_type_index].name_index].bytes..cp[cp[mr.name_and_type_index].descriptor_index].bytes
					local mt = findMethod(cl,name)
					local args = {}
					for i=#mt.desc-1,1,-1 do
						args[i+1] = pop()
					end
					args[1] = pop()
					local obj = args[1].data
					if bit.band(mt.acc,METHOD_ACC.NATIVE) == METHOD_ACC.NATIVE then
						for i=1, #args do
							args[i] = args[i].data
						end
					end
					local ret = mt[1](unpack(args))
					if mt.desc[#mt.desc].type ~= "void" then
						push(ret)
					end
				elseif inst == 0xB8 then
					--invokestatic
					local mr = cp[u2()]
					local cl = resolveClass(cp[mr.class_index])
					local name = cp[cp[mr.name_and_type_index].name_index].bytes..cp[cp[mr.name_and_type_index].descriptor_index].bytes
					local mt = findMethod(cl,name)
					local args = {}
					for i=#mt.desc-1,1,-1 do
						args[i] = pop()
					end
					if bit.band(mt.acc,METHOD_ACC.NATIVE) == METHOD_ACC.NATIVE then
						for i=1, #args do
							args[i] = args[i].data
						end
					end
					local ret = mt[1](unpack(args))
					if mt.desc[#mt.desc].type ~= "void" then
						push(ret)
					end
				elseif inst == 0xBB then
					--new
					local cr = cp[u2()]
					local obj = newInstance(resolveClass(cr))
					push(asObjRef(obj))
				else
					error("Unknown Opcode: "..string.format("%x",inst))
				end
			end
		end
	end
	
	local function method_info()
		local a,n = u2(),u2()
		local method = {
			acc = a,
			name = cp[n].bytes,
			descriptor = cp[u2()].bytes,
			attributes_count = u2(),
			attributes = {}
		}
		for i=0, method.attributes_count-1 do
			method.attributes[i] = attribute()
		end
		method.desc = {}
		parse_descriptor(method.desc,method.descriptor)
		method.name = method.name..method.descriptor
		return method
	end
	
	local s, e = pcall(function()
		assert(u1() == 0xCA and u1() == 0xFE and u1() == 0xBA and u1() == 0xBE,"invalid magic header")
		u2()u2()
		local cplen = u2()
		local prev
		for i=1, cplen-1 do
			if prev and (prev.cl == "Double" or prev.cl == "Long") then
				prev = nil
			else
				cp[i] = cp_entry()
				prev = cp[i]
			end
		end
		local access_flags = u2()
		local this_class = u2()
		local super_class = u2()

		cn = cp[cp[this_class].name_index].bytes:gsub("/",".")
		local super
		if cp[super_class] then -- Object.class won't
			super = cp[cp[super_class].name_index].bytes:gsub("/",".")
		end
		local Class = createClass(super, cn)
		
		--start processing the data
		Class.name = cn
		Class.acc = access_flags

		local interfaces_count = u2()
		Class.interfaces = {}
		for i=0, interfaces_count-1 do
			interfaces[i] = u2()
		end
		local fields_count = u2()
		for i=0, fields_count-1 do
			Class.fields[i] = field_info()
			Class.fields[Class.fields[i].name] = Class.fields[i]
		end
		local methods_count = u2()
		local initialCount = #Class.methods
		local subtractor = 0
		for index=1, methods_count do
			local i = index + initialCount - subtractor

			local m = method_info()
			for i2,v in ipairs(Class.methods) do
				--print(v.name)
				if v.name == m.name then
					i = i2
					subtractor = subtractor + 1
				end
			end

			Class.methods[i] = m
			--find code attrib
			local ca
			for _, v in pairs(m.attributes) do
				--print(v.name)
				if v.code then ca = v break end
			end
			if ca then
				m[1] = createCodeFunction(ca.code)
			elseif bit.band(m.acc,METHOD_ACC.NATIVE) == METHOD_ACC.NATIVE then
				if not natives[cn] then natives[cn] = {} end
				m[1] = function(...)
					if not natives[cn][m.name] then
						error("Native not implemented: " .. m.name)
					end
					return natives[cn][m.name](...)
				end
			else
				print(m.name," doesn't have code")
			end
		end
		local attrib_count = u2()
		Class.attributes = {}
		for i=0, attrib_count-1 do
			Class.attributes[i] = attribute()
		end


		-- invoke static{}
		local staticmr = findMethod(Class, "<clinit>()V")
		if staticmr then
			staticmr[1]()
		end
	end)
	fh.close()
	if not s then error(e,0) end
	return cn
end
