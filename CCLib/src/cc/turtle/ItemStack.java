package cc.turtle;

public class ItemStack {
	
	private String name;
	private int damage;
	private int count;
	
	public ItemStack(String id) {
		this.name = id;
	}
	
	public ItemStack(String id, int metadata) {
		this.name = id;
		this.damage = metadata;
	}
	
	public ItemStack(String id, int metadata, int count) {
		this.name = id;
		this.damage = metadata;
		this.count = count;
	}
	
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append(count).append("x ");
		builder.append(name);
		if(damage > 0) {
			builder.append("(").append(damage).append(")");
		}
		return builder.toString();
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getMetadata() {
		return damage;
	}

	public void setMetadata(int metadata) {
		this.damage = metadata;
	}

	public int getDamage() {
		return count;
	}

	public void setDamage(int damage) {
		this.count = damage;
	}

}
