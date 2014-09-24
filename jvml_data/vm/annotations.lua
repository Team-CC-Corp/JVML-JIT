local proxyNum = 0

local function deepCopy(t)
	local newT = {}
	for k,v in pairs(t) do
		if type(v) == "table" then
			newT[k] = deepCopy(v)
		else
			newT[k] = v
		end
	end
	return newT
end

function createAnnotation(annot, cls)
	proxyNum = proxyNum + 1
	local proxyClass = createClass("$"..proxyNum.."proxy", "java.lang.Object", {cls})
	proxyClass.attributes_count = 0
    proxyClass.attributes = {}

    for i,v in ipairs(proxyClass.methods) do
    	if not v[1] then
	    	print(v.name)
	    end
    end
    for i,v in ipairs(proxyClass.methods) do
    	if not v[1] then
	    	proxyClass.methods[i] = deepCopy(v)
	    	local m = proxyClass.methods[i]
	    	local value
	    	for i2,v2 in ipairs(annot.element_value_pairs) do
	    		if m.name:find("^"..v2.name) then
	    			value = v2.value
	    			break
	    		end
	    	end
	    	print(m.name)
	    	if not value then
	    		value = m.attrByName.AnnotationDefault.default_value
	    	end

	    	m[1] = function()
	    		return value
		    end
		end
    end

    
end