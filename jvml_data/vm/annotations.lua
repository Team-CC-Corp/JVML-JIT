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
    proxyClass.acc = 0 -- TODO: Figure out exactly what to assign to this

    for i,v in ipairs(proxyClass.methods) do
    	if not v[1] then
	    	proxyClass.methods[i] = deepCopy(v)
	    	local m = proxyClass.methods[i]

	    	if m.name == "hashCode()I" then
	    		local pn = proxyNum
	    		m[1] = function()
	    			return pn
		    	end
			elseif m.name == "annotationType()Ljava/lang/Class;" then
				getJClass(cls.name)
			else
		    	local value
		    	for i2,v2 in ipairs(annot.element_value_pairs) do
		    		if m.name:find("^"..v2.name) then
		    			value = v2.value
		    			break
		    		end
		    	end

		    	if not value then
		    		value = m.attrByName.AnnotationDefault.default_value
		    	end

		    	m[1] = function()
		    		return value
			    end
			end
		end
    end

    return newInstance(proxyClass)
end

function findClassAnnotation(cls, annot)
	if not cls.attrByName.RuntimeVisibleAnnotations then
		return
	end
	for i=0, cls.attrByName.RuntimeVisibleAnnotations.num_annotations - 1 do
		local an = cls.attrByName.RuntimeVisibleAnnotations.annotations[i]
		if isClassAssignableFromClass(annot, an[1]) then
			return an
		end
	end
end

function findMethodAnnotation(mt, annot)
	if not mt.attrByName.RuntimeVisibleAnnotations then
		return
	end
	for i=0, mt.attrByName.RuntimeVisibleAnnotations.num_annotations - 1 do
		local an = mt.attrByName.RuntimeVisibleAnnotations.annotations[i]
		if isClassAssignableFromClass(annot, an[1]) then
			return an
		end
	end
end