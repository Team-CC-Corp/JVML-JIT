package cc.turtle;

public class ItemStack {
    
    private String name;
    private int metadata;
    private int count;
    
    public ItemStack(String id) {
        this.name = id;
    }
    
    public ItemStack(String id, int metadata) {
        this.name = id;
        this.metadata = metadata;
    }
    
    public ItemStack(String id, int metadata, int count) {
        this.name = id;
        this.metadata = metadata;
        this.count = count;
    }
    
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append(count).append("x ");
        builder.append(name);
        if(metadata > 0) {
            builder.append("(").append(metadata).append(")");
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
        return metadata;
    }

    public void setMetadata(int metadata) {
        this.metadata = metadata;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

}
