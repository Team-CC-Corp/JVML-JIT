natives["java.lang.Class"] = natives["java.lang.Class"] or {}
natives["java.lang.Class"]["getSuperclass()Ljava/lang/Class;"] = function(this)
	if this.classItem == classByName("java.lang.Object") or bit.band(this.classItem.acc, CLASS_ACC.INTERFACE) > 0 then
		return nil
	end
	return getJClass(getClassByName(toLString(getObjectField(this, "name"))).super.name)
end